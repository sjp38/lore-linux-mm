Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1D56B0081
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 11:19:01 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id g10so3381555pdj.9
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 08:19:01 -0800 (PST)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id sg6si8743336pbc.95.2014.11.21.08.18.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 08:19:00 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id y10so5563021pdj.7
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 08:18:59 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/zsmalloc: support max obj with length of PAGE_SIZE
Date: Sat, 22 Nov 2014 00:18:39 +0800
Message-Id: <1416586719-10125-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, ddstreet@ieee.org, sergey.senozhatsky@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

2014-11-21 18:32 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> On Fri, Nov 21, 2014 at 06:48:49AM +0000, Minchan Kim wrote:
>> On Fri, Nov 21, 2014 at 01:33:26PM +0800, Ganesh Mahendran wrote:
>> > Hello
>> >
>> > 2014-11-21 11:54 GMT+08:00 Minchan Kim <minchan@kernel.org>:
>> > > On Thu, Nov 20, 2014 at 09:21:56PM +0800, Mahendran Ganesh wrote:
>> > >> ZS_SIZE_CLASSES is calc by:
>> > >>   ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / ZS_SIZE_CLASS_DELTA + 1)
>> > >>
>> > >> So when i is in [0, ZS_SIZE_CLASSES - 1), the size:
>> > >>   size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA
>> > >> will not be greater than ZS_MAX_ALLOC_SIZE
>> > >>
>> > >> This patch removes the unnecessary check.
>> > >
>> > > It depends on ZS_MIN_ALLOC_SIZE.
>> > > For example, we would change min to 8 but MAX is still 4096.
>> > > ZS_SIZE_CLASSES is (4096 - 8) / 16 + 1 = 256 so 8 + 255 * 16 = 4088,
>> > > which exceeds the max.
>> > Here, 4088 is less than MAX(4096).
>> >
>> > ZS_SIZE_CLASSES = (MAX - MIN) / Delta + 1
>> > So, I think the value of
>> >     MIN + (ZS_SIZE_CLASSES - 1) * Delta =
>> >     MIN + ((MAX - MIN) / Delta) * Delta =
>> >     MAX
>> > will not exceed the MAX
>>
>> You're right. It was complext math for me.
>> I should go back to elementary school.
>>
>> Thanks!
>>
>> Acked-by: Minchan Kim <minchan@kernel.org>
>
> I catch a nasty cold but above my poor math makes me think more.
> ZS_SIZE_CLASSES is broken. In above my example, current code cannot
> allocate 4096 size class so we should correct ZS_SIZE_CLASSES
> at first.
>
> zs_size_classes = zs_max - zs_min / delta + 1;
> if ((zs_max - zs_min) % delta)
>         zs_size_classes += 1;
>
> Then, we need to code piece you removed.
> As well, we need to fix below.
>
> - area->vm_buf = (char *)__get_free_page(GFP_KERNEL);
> + area->vm_buf = kmalloc(ZS_MAX_ALLOC_SIZE);
>
> Hope I am sane in this time :(

how about something like this?

In zsmalloc, if ZS_MIN_ALLOC_SIZE is less than ZS_SIZE_CLASS_DELTA.
Max obj size (ZS_MIN_ALLOC_SIZE + ZS_SIZE_CLASSES * ZS_SIZE_CLASS_DELTA)
will be less than ZS_MAX_ALLOC_SIZE(page size).
And in zs_malloc(), we thought we can put an obj(len == PAGE_SIZE)
into zsmalloc. But actually we can not. This will make user confused.

This patch takes Minchan Kim's suggestion.
    https://lkml.org/lkml/2014/11/21/172

When (ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) % ZS_SIZE_CLASS_DELTA) != 0,
we add increase sz_size_class by 1 to make the size of max obj equal to
ZS_MAX_ALLOC_SIZE(PAGE_SIZE).

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
---
 mm/zsmalloc.c |   22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 810eda1..bcea72d 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -155,8 +155,6 @@
  *  (reason above)
  */
 #define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> 8)
-#define ZS_SIZE_CLASSES		((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / \
-					ZS_SIZE_CLASS_DELTA + 1)
 
 /*
  * We do not maintain any list for completely empty or full pages
@@ -214,7 +212,8 @@ struct link_free {
 };
 
 struct zs_pool {
-	struct size_class *size_class[ZS_SIZE_CLASSES];
+	struct size_class **size_class;
+	int nr_size_classes;
 
 	gfp_t flags;	/* allocation flags used when growing pool */
 	atomic_long_t pages_allocated;
@@ -956,17 +955,28 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 {
 	int i, ovhd_size;
 	struct zs_pool *pool;
+	int nr;
 
 	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
 	pool = kzalloc(ovhd_size, GFP_KERNEL);
 	if (!pool)
 		return NULL;
 
+	nr = (ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / ZS_SIZE_CLASS_DELTA + 1;
+	if ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) % ZS_SIZE_CLASS_DELTA)
+		nr += 1;
+
+	pool->size_class = kcalloc(nr, sizeof(struct size_class *),
+			GFP_KERNEL);
+	if (!pool->size_class)
+		goto err;
+	pool->nr_size_classes = nr;
+
 	/*
 	 * Iterate reversly, because, size of size_class that we want to use
 	 * for merging should be larger or equal to current size.
 	 */
-	for (i = ZS_SIZE_CLASSES - 1; i >= 0; i--) {
+	for (i = pool->nr_size_classes - 1; i >= 0; i--) {
 		int size;
 		int pages_per_zspage;
 		struct size_class *class;
@@ -1020,7 +1030,7 @@ void zs_destroy_pool(struct zs_pool *pool)
 {
 	int i;
 
-	for (i = 0; i < ZS_SIZE_CLASSES; i++) {
+	for (i = 0; i < pool->nr_size_classes; i++) {
 		int fg;
 		struct size_class *class = pool->size_class[i];
 
@@ -1038,6 +1048,8 @@ void zs_destroy_pool(struct zs_pool *pool)
 		}
 		kfree(class);
 	}
+
+	kfree(pool->size_class);
 	kfree(pool);
 }
 EXPORT_SYMBOL_GPL(zs_destroy_pool);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
