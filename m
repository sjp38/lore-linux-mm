Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D2B676B025F
	for <linux-mm@kvack.org>; Mon,  9 May 2016 09:03:24 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so304098654pac.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 06:03:24 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id r86si13077612pfb.204.2016.05.09.06.03.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 06:03:23 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id r5so74427767pag.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 06:03:23 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v2] zsmalloc: fix zs_can_compact() integer overflow
Date: Mon,  9 May 2016 23:00:52 +0900
Message-Id: <20160509140052.3389-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "[4.3+]" <stable@vger.kernel.org>

zs_can_compact() has two race conditions in its core calculation:

unsigned long obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
				zs_stat_get(class, OBJ_USED);

1) classes are not locked, so the numbers of allocated and used
   objects can change by the concurrent ops happening on other CPUs
2) shrinker invokes it from preemptible context

Depending on the circumstances, thus, OBJ_ALLOCATED can become
less than OBJ_USED, which can result in either very high or
negative `total_scan' value calculated later in do_shrink_slab().

do_shrink_slab() has some logic to prevent those cases:

 vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-64
 vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62

However, due to the way `total_scan' is calculated, not every
shrinker->count_objects() overflow can be spotted and handled.
To demonstrate the latter, I added some debugging code to do_shrink_slab()
(x86_64) and the results were:

 vmscan: OVERFLOW: shrinker->count_objects() == -1 [18446744073709551615]
 vmscan: but total_scan > 0: 92679974445502
 vmscan: resulting total_scan: 92679974445502
[..]
 vmscan: OVERFLOW: shrinker->count_objects() == -1 [18446744073709551615]
 vmscan: but total_scan > 0: 22634041808232578
 vmscan: resulting total_scan: 22634041808232578

Even though shrinker->count_objects() has returned an overflowed value,
the resulting `total_scan' is positive, and, what is more worrisome, it
is insanely huge. This value is getting used later on in
shrinker->scan_objects() loop:

        while (total_scan >= batch_size ||
               total_scan >= freeable) {
                unsigned long ret;
                unsigned long nr_to_scan = min(batch_size, total_scan);

                shrinkctl->nr_to_scan = nr_to_scan;
                ret = shrinker->scan_objects(shrinker, shrinkctl);
                if (ret == SHRINK_STOP)
                        break;
                freed += ret;

                count_vm_events(SLABS_SCANNED, nr_to_scan);
                total_scan -= nr_to_scan;

                cond_resched();
        }

`total_scan >= batch_size' is true for a very-very long time and
'total_scan >= freeable' is also true for quite some time, because
`freeable < 0' and `total_scan' is large enough, for example,
22634041808232578. The only break condition, in the given scheme of
things, is shrinker->scan_objects() == SHRINK_STOP test, which is a
bit too weak to rely on, especially in heavy zsmalloc-usage scenarios.

To fix the issue, take a pool stat snapshot and use it instead of
racy zs_stat_get() calls.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: <stable@vger.kernel.org>        [4.3+]
---

v2: add more detailed explanation and use proper version (-next)

 mm/zsmalloc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 3d6d3da..13c08ce 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1731,10 +1731,13 @@ static struct page *isolate_source_page(struct size_class *class)
 static unsigned long zs_can_compact(struct size_class *class)
 {
 	unsigned long obj_wasted;
+	unsigned long obj_allocated = zs_stat_get(class, OBJ_ALLOCATED);
+	unsigned long obj_used = zs_stat_get(class, OBJ_USED);
 
-	obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
-		zs_stat_get(class, OBJ_USED);
+	if (obj_allocated <= obj_used)
+		return 0;
 
+	obj_wasted = obj_allocated - obj_used;
 	obj_wasted /= get_maxobj_per_zspage(class->size,
 			class->pages_per_zspage);
 
-- 
2.8.2.294.gbbc6168

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
