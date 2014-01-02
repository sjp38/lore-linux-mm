Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id DC9C86B0055
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:20 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so13831767pdj.4
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:20 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ll1si23308157pab.57.2014.01.01.23.13.18
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:19 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 11/16] vrange: support shmem_purge_page
Date: Thu,  2 Jan 2014 16:12:19 +0900
Message-Id: <1388646744-15608-12-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

If VM discards volatile page of shmem/tmpfs, it should remove
exceptional swap entry from radix tree as well as page itself.

For it, this patch introduces shmem_purge_page and free_swap_and_
cache_locked which is needed because I don't want to add more
overhead in hot path(ex, zap_pte).

A later patch will use it.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/shmem_fs.h |    1 +
 include/linux/swap.h     |    1 +
 mm/shmem.c               |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/swapfile.c            |   37 +++++++++++++++++++++++++++++++++++++
 mm/vrange.c              |    2 ++
 5 files changed, 87 insertions(+)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 30aa0dc60d75..3df94fe5dfb9 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -53,6 +53,7 @@ extern void shmem_unlock_mapping(struct address_space *mapping);
 extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 					pgoff_t index, gfp_t gfp_mask);
 extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
+extern void shmem_purge_page(struct inode *inode, struct page *page);
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 
 static inline struct page *shmem_read_mapping_page(
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 197a7799b59c..fb9f6d1daf89 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -469,6 +469,7 @@ extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
 extern void swapcache_free(swp_entry_t, struct page *page);
+extern int free_swap_and_cache_locked(swp_entry_t);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
diff --git a/mm/shmem.c b/mm/shmem.c
index 8297623fcaed..e3626f969e0f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -441,6 +441,52 @@ void shmem_unlock_mapping(struct address_space *mapping)
 	}
 }
 
+void shmem_purge_page(struct inode *inode, struct page *page)
+{
+	struct page *ret_page;
+	struct address_space *mapping = inode->i_mapping;
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	pgoff_t indices;
+	long nr_swaps_freed = 0;
+	pgoff_t index = page->index;
+
+	VM_BUG_ON(page_mapped(page));
+	VM_BUG_ON(!PageLocked(page));
+
+	if (!shmem_find_get_pages_and_swap(mapping, index,
+				1, &ret_page, &indices))
+		return;
+
+	index = indices;
+	mem_cgroup_uncharge_start();
+	if (radix_tree_exceptional_entry(ret_page)) {
+		int error;
+		spin_lock_irq(&mapping->tree_lock);
+		error = shmem_radix_tree_replace(mapping, index,
+						ret_page, NULL);
+		spin_unlock_irq(&mapping->tree_lock);
+		if (!error) {
+			swp_entry_t swap = radix_to_swp_entry(ret_page);
+			free_swap_and_cache_locked(swap);
+		}
+	} else {
+		if (page->mapping == mapping)
+			truncate_inode_page(mapping, ret_page);
+		put_page(ret_page);
+	}
+
+	mem_cgroup_uncharge_end();
+
+	spin_lock(&info->lock);
+	info->swapped -= nr_swaps_freed;
+	shmem_recalc_inode(inode);
+	spin_unlock(&info->lock);
+
+	/* Question: We should update? */
+	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+}
+EXPORT_SYMBOL_GPL(shmem_purge_page);
+
 /*
  * Remove range of pages and swap entries from radix tree, and free them.
  * If !unfalloc, truncate or punch hole; if unfalloc, undo failed fallocate.
diff --git a/mm/swapfile.c b/mm/swapfile.c
index de7c904e52e5..5b1cb7461e52 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -998,6 +998,43 @@ int free_swap_and_cache(swp_entry_t entry)
 	return p != NULL;
 }
 
+/*
+ * Same with free_swap_cache but user know in advance that page found
+ * from swapper_spaces is already locked so that we could remove the page
+ * from page cache safely.
+ */
+int free_swap_and_cache_locked(swp_entry_t entry)
+{
+	struct swap_info_struct *p;
+	struct page *page = NULL;
+
+	if (non_swap_entry(entry))
+		return 1;
+
+	p = swap_info_get(entry);
+	if (p) {
+		if (swap_entry_free(p, entry, 1) == SWAP_HAS_CACHE) {
+			page = find_get_page(swap_address_space(entry),
+						entry.val);
+		}
+		spin_unlock(&p->lock);
+	}
+
+	if (page) {
+		/*
+		 * Not mapped elsewhere, or swap space full? Free it!
+		 * Also recheck PageSwapCache now page is locked (above).
+		 */
+		if (PageSwapCache(page) && !PageWriteback(page) &&
+				(!page_mapped(page) || vm_swap_full())) {
+			delete_from_swap_cache(page);
+			SetPageDirty(page);
+		}
+		page_cache_release(page);
+	}
+	return p != NULL;
+}
+
 #ifdef CONFIG_HIBERNATION
 /*
  * Find the swap type that corresponds to given device (if any).
diff --git a/mm/vrange.c b/mm/vrange.c
index 0fa669c56ab8..ed89835bcff4 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -13,6 +13,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/mm_inline.h>
 #include <linux/migrate.h>
+#include <linux/shmem_fs.h>
 
 static struct kmem_cache *vrange_cachep;
 
@@ -638,6 +639,7 @@ static int try_to_discard_file_vpage(struct page *page)
 	}
 
 	VM_BUG_ON(page_mapped(page));
+	shmem_purge_page(mapping->host, page);
 	ret = 0;
 out:
 	vrange_unlock(vroot);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
