Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 456E96B03A7
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:58:24 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id p66so241273411pga.4
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 22:58:24 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id k5si6750451pfk.138.2016.11.17.22.58.22
        for <linux-mm@kvack.org>;
        Thu, 17 Nov 2016 22:58:23 -0800 (PST)
Date: Fri, 18 Nov 2016 15:58:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: support anonymous stable page
Message-ID: <20161118065820.GA7277@bbox>
References: <1478842202-24009-1-git-send-email-minchan@kernel.org>
 <20161111060644.GA24342@bbox>
 <alpine.LSU.2.11.1611171950250.7304@eggly.anvils>
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1611171950250.7304@eggly.anvils>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>

Hi Hugh,

On Thu, Nov 17, 2016 at 08:35:10PM -0800, Hugh Dickins wrote:
> On Fri, 11 Nov 2016, Minchan Kim wrote:
> > Sorry for sending a wrong version. Here is new one.
> > 
> > From 2d42ead9335cde51fd58d6348439ca03cf359ba2 Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Fri, 11 Nov 2016 15:02:57 +0900
> > Subject: [PATCH] mm: support anonymous stable page
> > 
> > For developemnt for zram-swap asynchronous writeback, I found
> > strange corruption of compressed page. With investigation, it
> > reveals currently stable page doesn't support anonymous page.
> > IOW, reuse_swap_page can reuse the page without waiting
> > writeback completion so that it can corrupt data during
> > zram compression. It can affect every swap device which supports
> > asynchronous writeback and CRC checking as well as zRAM.
> > 
> > Unfortunately, reuse_swap_page should be atomic so that we
> > cannot wait on writeback in there so the approach in this patch
> > is simply return false if we found it needs stable page.
> > Although it increases memory footprint temporarily, it happens
> > rarely and it should be reclaimed easily althoug it happened.
> > Also, It would be better than waiting of IO completion, which
> > is critial path for application latency.
> > 
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Darrick J. Wong <darrick.wong@oracle.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Ack to your intention (we discussed this together years ago, but saw
> no actual demand for it before now), and I like what you're doing;
> but it has to be NAK to this implementation.
> 
> I sensed there was an problem when you posted; but only now, after
> searching through the uses of mapping->host, do I see that problem.
> 
> You're setting swap's mapping->host = inode when it used to be NULL:
> which seems like a very good way to get what you need, but I'm afraid
> it's a change which goes way beyond your intention.
> 
> See inode_to_bdi(): for ordinary disk-based swap, it will now pick
> up the bdi of the block device instead of noop_backing_dev_info, so
> swap would then pass the mapping_cap_account_dirty() and similar
> tests (mostly in mm/page-writeback.c), and go down codepaths it
> has never gone down before.
> 
> It's possible that swap (and shmem) would be better off going down
> those paths, to be throttled in a similar way to files; but that's
> debatable, and a much bigger change than you want to get into for
> zram stable pages.

Good point.
Thanks for the review, Hugh.

> 
> Maybe add SWP_STABLE_WRITES in include/linux/swap.h, and set that
> in swap_info->flags according to bdi_cap_stable_pages_required(),
> leaving mapping->host itself NULL as before?

The problem with the approach is that we need to get swap_info_struct
in reuse_swap_page so maybe, every caller should pass swp_entry_t
into reuse_swap_page. It would be no problem if swap slot is really
referenced the page(IOW, pte is real swp_entry_t) but some cases
where swap slot is already empty but the page remains in only
swap cache, we cannot pass swp_entry_t which means that we cannot
get swap_info_struct.

So, if I didn't miss, another option I can imagine is to move
SWP_STABLE_WRITES to address_space->flags as AS_STABLE_WRITES.
With that, we can always get the information without passing
swp_entry_t. Is there any better idea?


diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index dd15d39e1985..5397e82bfd57 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -26,6 +26,8 @@ enum mapping_flags {
 	AS_EXITING	= 4, 	/* final truncate in progress */
 	/* writeback related tags are not used */
 	AS_NO_WRITEBACK_TAGS = 5,
+	/* need stable write for swap */
+	AS_STABLE_WRITES = 6,
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -55,6 +57,21 @@ static inline int mapping_unevictable(struct address_space *mapping)
 	return !!mapping;
 }
 
+static inline void mapping_set_stable(struct address_space *mapping)
+{
+	set_bit(AS_STABLE_WRITES, &mapping->flags);
+}
+
+static inline void mapping_clear_stable(struct address_space *mapping)
+{
+	clear_bit(AS_STABLE_WRITES, &mapping->flags);
+}
+
+static inline int mapping_stable(struct address_space *mapping)
+{
+	return test_bit(AS_STABLE_WRITES, &mapping->flags);
+}
+
 static inline void mapping_set_exiting(struct address_space *mapping)
 {
 	set_bit(AS_EXITING, &mapping->flags);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 2210de290b54..0c31fd814933 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -943,11 +943,20 @@ bool reuse_swap_page(struct page *page, int *total_mapcount)
 	count = page_trans_huge_mapcount(page, total_mapcount);
 	if (count <= 1 && PageSwapCache(page)) {
 		count += page_swapcount(page);
-		if (count == 1 && !PageWriteback(page)) {
+		if (count != 1)
+			goto out;
+		if (!PageWriteback(page)) {
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
+		} else {
+			struct address_space *mapping;
+
+			mapping = page_mapping(page);
+			if (mapping_stable(mapping))
+				return false;
 		}
 	}
+out:
 	return count <= 1;
 }
 
@@ -2386,6 +2395,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	unsigned long *frontswap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
+	struct address_space *swapper_space;
 
 	if (swap_flags & ~SWAP_FLAGS_VALID)
 		return -EINVAL;
@@ -2447,6 +2457,13 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		error = -ENOMEM;
 		goto bad_swap;
 	}
+
+	swapper_space = &swapper_spaces[p->type];
+	if (bdi_cap_stable_pages_required(inode_to_bdi(inode)))
+		mapping_set_stable(swapper_space);
+	else
+		mapping_clear_stable(swapper_space);
+
 	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
 		int cpu;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
