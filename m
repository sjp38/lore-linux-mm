Received: from aloha.cc.columbia.edu (localhost [127.0.0.1])
	by aloha.cc.columbia.edu (8.12.8/8.12.8) with ESMTP id h5QHLQEX026393
	for <linux-mm@kvack.org>; Thu, 26 Jun 2003 13:21:26 -0400 (EDT)
Received: from localhost by aloha.cc.columbia.edu (8.12.8/8.12.8/Submit) with ESMTP id h5QHLQ0s026387
	for <linux-mm@kvack.org>; Thu, 26 Jun 2003 13:21:26 -0400 (EDT)
Date: Thu, 26 Jun 2003 13:21:26 -0400 (EDT)
From: Raghu R Arur <rra2002@columbia.edu>
Subject: shrink_caches() 
Message-ID: <Pine.GSO.4.50.0306261315060.26256-100000@aloha.cc.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.44.0306261314382.5752@delhi.clic.cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I was going thru the code of shrink_caches(). it returns the difference
between the number of pages requested to be freed and the number of pages
that were actually freed. What i see over here is that the nr_pages which
is the return value, is decremented only when the pages are freed from
slab cache and page cache. The value is not decremented when the pages get
freed from dentry cache, inode cache or the quota cache, which are freed
at high memory pressure times. So when no pages get freed from page cache,
but get freed from dentry/inode caches we will be returning a value which
says that no pages were freed. Why is this done? can you PLEASE explain me
this.

559 static int FASTCALL(shrink_caches(zone_t * classzone, int priority,
unsigned int gfp_mask, int nr_pages));
560 static int shrink_caches(zone_t* classzone, int priority, unsigned int
gfp_mask, int nr_pages)
561 {
562 int chunk_size = nr_pages;
563 unsigned long ratio;
564
565 nr_pages -= kmem_cache_reap(gfp_mask);
566 if (nr_pages <= 0)
567 return 0;
568
569 nr_pages = chunk_size;
570 /* try to keep the active list 2/3 of the size of the cache */
571 ratio = (unsigned long) nr_pages * nr_active_pages /((nr_inactive_pages + 1) * 2);
572 refill_inactive(ratio);
573
574 nr_pages = shrink_cache(nr_pages,classzone, gfp_mask, priority);
576 return 0;
577
578 shrink_dcache_memory(priority, gfp_mask);
579 shrink_icache_memory(priority, gfp_mask);
580 #ifdef CONFIG_QUOTA
581 shrink_dqcache_memory(DEF_PRIORITY, gfp_mask);
582 #endif
583
584 return nr_pages;
585 }


  thanks , Raghu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
