Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DEC36B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 21:54:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so129309905pfa.3
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 18:54:35 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v5si2575339pgg.234.2017.02.06.18.54.33
        for <linux-mm@kvack.org>;
        Mon, 06 Feb 2017 18:54:34 -0800 (PST)
Date: Tue, 7 Feb 2017 11:54:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170207025426.GA1528@bbox>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1486111347-112972-1-git-send-email-zhouxianrong@huawei.com>
 <20170205142100.GA9611@bbox>
 <2f6e188c-5358-eeab-44ab-7634014af651@huawei.com>
 <20170206234805.GA12188@bbox>
 <ba64f168-72f5-65c3-c88c-7a59e57b20aa@huawei.com>
MIME-Version: 1.0
In-Reply-To: <ba64f168-72f5-65c3-c88c-7a59e57b20aa@huawei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, willy@infradead.org, iamjoonsoo.kim@lge.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On Tue, Feb 07, 2017 at 10:20:57AM +0800, zhouxianrong wrote:

< snip >

> >>3. the below should be modified.
> >>
> >>static inline bool zram_meta_get(struct zram *zram)
> >>@@ -495,11 +553,17 @@ static void zram_meta_free(struct zram_meta *meta, u64 disksize)
> >>
> >> 	/* Free all pages that are still in this zram device */
> >> 	for (index = 0; index < num_pages; index++) {
> >>-		unsigned long handle = meta->table[index].handle;
> >>+		unsigned long handle;
> >>+
> >>+		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
> >>+		handle = meta->table[index].handle;
> >>
> >>-		if (!handle)
> >>+		if (!handle || zram_test_flag(meta, index, ZRAM_SAME)) {
> >>+			bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
> >> 			continue;
> >>+		}
> >>
> >>+		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
> >> 		zs_free(meta->mem_pool, handle);
> >
> >Could you explain why we need this modification?
> >
> >> 	}
> >>
> >>@@ -511,7 +575,7 @@ static void zram_meta_free(struct zram_meta *meta, u64 disksize)
> >> static struct zram_meta *zram_meta_alloc(char *pool_name, u64 disksize)
> >> {
> >> 	size_t num_pages;
> >>-	struct zram_meta *meta = kmalloc(sizeof(*meta), GFP_KERNEL);
> >>+	struct zram_meta *meta = kzalloc(sizeof(*meta), GFP_KERNEL);
> >
> >Ditto
> >
> >>
> >>
> >
> >.
> >
> 
> because of union of handle and element, i think a non-zero element (other than handle) is prevented from freeing.
> if zram_meta_get was modified, zram_meta_alloc did so.

Right. Thanks but I don't see why we need the locking in there and modification of
zram_meta_alloc.

Isn't it enough with this?

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index c20b05a84f21..a25d34a8af19 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -425,8 +425,11 @@ static void zram_meta_free(struct zram_meta *meta, u64 disksize)
 	/* Free all pages that are still in this zram device */
 	for (index = 0; index < num_pages; index++) {
 		unsigned long handle = meta->table[index].handle;
-
-		if (!handle)
+		/*
+		 * No memory is allocated for same element filled pages.
+		 * Simply clear same page flag.
+		 */
+		if (!handle || zram_test_flag(meta, index, ZRAM_SAME))
 			continue;
 
 		zs_free(meta->mem_pool, handle);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
