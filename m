Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id CEBEF828DF
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:58:50 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id c20so19001284pfc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:58:50 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id x80si626612pfa.98.2016.04.05.14.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:58:50 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id 184so19018096pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:58:50 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:58:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 26/31] huge tmpfs recovery: shmem_recovery_swapin to read
 from swap
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051456330.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If pages of the extent are out on swap, we would much prefer to read
them in to their final locations on the assigned huge page, than have
swapin_readahead() adding unrelated pages, and __read_swap_cache_async()
allocating intermediate pages, from which we would then have to migrate
(though some may well be already in swapcache, and then need migration).

And we'd like to get all the swap I/O underway at the start, then wait
on it in probably a single page lock of the main population loop:
which can forget about swap, leaving shmem_getpage_gfp() to handle
the transitions from swapcache to pagecache.

shmem_recovery_swapin() is very much based on __read_swap_cache_async(),
but the things it needs to worry about are not always the same: it does
not matter if __read_swap_cache_async() occasionally reads an unrelated
page which has inherited a freed swap block; but shmem_recovery_swapin()
better not place that inside the huge page it is helping to build.

Ifdef CONFIG_SWAP around it and its shmem_next_swap() helper because a
couple of functions it calls are undeclared without CONFIG_SWAP.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |  101 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 101 insertions(+)

--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -804,6 +804,105 @@ static bool shmem_work_still_useful(stru
 		!RB_EMPTY_ROOT(&mapping->i_mmap);  /* file is still mapped */
 }
 
+#ifdef CONFIG_SWAP
+static void *shmem_next_swap(struct address_space *mapping,
+			     pgoff_t *index, pgoff_t end)
+{
+	pgoff_t start = *index + 1;
+	struct radix_tree_iter iter;
+	void **slot;
+	void *radswap;
+
+	rcu_read_lock();
+restart:
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+		if (iter.index >= end)
+			break;
+		radswap = radix_tree_deref_slot(slot);
+		if (radix_tree_exception(radswap)) {
+			if (radix_tree_deref_retry(radswap))
+				goto restart;
+			goto out;
+		}
+	}
+	radswap = NULL;
+out:
+	rcu_read_unlock();
+	*index = iter.index;
+	return radswap;
+}
+
+static void shmem_recovery_swapin(struct recovery *recovery, struct page *head)
+{
+	struct shmem_inode_info *info = SHMEM_I(recovery->inode);
+	struct address_space *mapping = recovery->inode->i_mapping;
+	pgoff_t index = recovery->head_index - 1;
+	pgoff_t end = recovery->head_index + HPAGE_PMD_NR;
+	struct blk_plug plug;
+	void *radswap;
+	int error;
+
+	/*
+	 * If the file has nothing swapped out, don't waste time here.
+	 * If the team has already been exposed by an earlier attempt,
+	 * it is not safe to pursue this optimization again - truncation
+	 * *might* let swapin I/O overlap with fresh use of the page.
+	 */
+	if (!info->swapped || recovery->exposed_team)
+		return;
+
+	blk_start_plug(&plug);
+	while ((radswap = shmem_next_swap(mapping, &index, end))) {
+		swp_entry_t swap = radix_to_swp_entry(radswap);
+		struct page *page = head + (index & (HPAGE_PMD_NR-1));
+
+		/*
+		 * Code below is adapted from __read_swap_cache_async():
+		 * we want to set up async swapin to the right pages.
+		 * We don't have to worry about a more limiting gfp_mask
+		 * leading to -ENOMEM from __add_to_swap_cache(), but we
+		 * do have to worry about swapcache_prepare() succeeding
+		 * when swap has been freed and reused for an unrelated page.
+		 */
+		shr_stats(swap_entry);
+		error = radix_tree_preload(GFP_KERNEL);
+		if (error)
+			break;
+
+		error = swapcache_prepare(swap);
+		if (error) {
+			radix_tree_preload_end();
+			shr_stats(swap_cached);
+			continue;
+		}
+
+		if (!shmem_confirm_swap(mapping, index, swap)) {
+			radix_tree_preload_end();
+			swapcache_free(swap);
+			shr_stats(swap_gone);
+			continue;
+		}
+
+		__SetPageLocked(page);
+		__SetPageSwapBacked(page);
+		error = __add_to_swap_cache(page, swap);
+		radix_tree_preload_end();
+		VM_BUG_ON(error);
+
+		shr_stats(swap_read);
+		lru_cache_add_anon(page);
+		swap_readpage(page);
+		cond_resched();
+	}
+	blk_finish_plug(&plug);
+	lru_add_drain();	/* not necessary but may help debugging */
+}
+#else
+static void shmem_recovery_swapin(struct recovery *recovery, struct page *head)
+{
+}
+#endif /* CONFIG_SWAP */
+
 static struct page *shmem_get_recovery_page(struct page *page,
 					unsigned long private, int **result)
 {
@@ -855,6 +954,8 @@ static int shmem_recovery_populate(struc
 	/* Warning: this optimization relies on disband's ClearPageChecked */
 	if (PageTeam(head) && PageChecked(head))
 		return 0;
+
+	shmem_recovery_swapin(recovery, head);
 again:
 	migratable = 0;
 	unmigratable = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
