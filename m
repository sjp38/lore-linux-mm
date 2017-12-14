Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF4A46B025E
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:39:25 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id r88so4684367pfi.23
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 05:39:25 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id t1si2928846pgc.68.2017.12.14.05.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 05:39:23 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V2] mm, swap: Fix race between swapoff and some swap operations
Date: Thu, 14 Dec 2017 21:38:32 +0800
Message-Id: <20171214133832.11266-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

From: Huang Ying <ying.huang@intel.com>

When the swapin is performed, after getting the swap entry information
from the page table, system will swap in the swap entry, without any
lock held to prevent the swap device from being swapoff.  This may
cause the race like below,

CPU 1				CPU 2
-----				-----
				do_swap_page
				  swapin_readahead
				    __read_swap_cache_async
swapoff				      swapcache_prepare
  p->swap_map = NULL		        __swap_duplicate
					  p->swap_map[?] /* !!! NULL pointer access */

Because swap off is usually done when system shutdown only, the race
may not hit many people in practice.  But it is still a race need to
be fixed.

To fix the race, get_swap_device() is added to prevent swap device
from being swapoff until put_swap_device() is called.  When
get_swap_device() is called, the caller should have some locks (like
PTL, page lock, or swap_info_struct->lock) held to guarantee the swap
entry is valid, or check the origin of swap entry again to make sure
the swap device hasn't been swapoff already.

Because swapoff() is very race code path, to make the normal path runs
as fast as possible, SRCU instead of reference count is used to
implement get/put_swap_device().  From get_swap_device() to
put_swap_device(), the reader side of SRCU is locked, so
synchronize_srcu() in swapoff() will wait until put_swap_device() is
called.

Several other code paths in addition to swapin has similar race, they
are fixed too in the same way.

In addition to swap_map, cluster_info, etc. data structure in the
struct swap_info_struct, the swap cache radix tree will be freed after
swapoff, so this patch fixes the race between swap cache looking up
and swapoff too.

Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Shaohua Li <shli@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>

Changelog:

V2:

- Re-implemented with SRCU to reduce the overhead of normal paths.

- Avoid to check whether the swap device has been swapoff in
  get_swap_device().  Because we can check the origin of the swap
  entry to make sure the swap device hasn't bee swapoff.
---
 include/linux/swap.h | 38 ++++++++++++++++++++++++++++++++++++--
 init/Kconfig         |  1 +
 mm/madvise.c         | 14 ++++++++++----
 mm/memory.c          | 28 ++++++++++++++++++++++------
 mm/shmem.c           | 16 +++++++++++++++-
 mm/swapfile.c        | 28 +++++++++++++++-------------
 6 files changed, 99 insertions(+), 26 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2417d288e016..1857dd454596 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -12,6 +12,7 @@
 #include <linux/fs.h>
 #include <linux/atomic.h>
 #include <linux/page-flags.h>
+#include <linux/srcu.h>
 #include <asm/page.h>
 
 struct notifier_block;
@@ -172,8 +173,6 @@ enum {
 	SWP_PAGE_DISCARD = (1 << 9),	/* freed swap page-cluster discards */
 	SWP_STABLE_WRITES = (1 << 10),	/* no overwrite PG_writeback pages */
 	SWP_SYNCHRONOUS_IO = (1 << 11),	/* synchronous IO is efficient */
-					/* add others here before... */
-	SWP_SCANNING	= (1 << 12),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
@@ -273,6 +272,10 @@ struct swap_info_struct {
 					 */
 	struct work_struct discard_work; /* discard worker */
 	struct swap_cluster_list discard_clusters; /* discard clusters list */
+	struct srcu_struct srcu;	/*
+					 * synchronize with swap entry
+					 * reference holders.
+					 */
 };
 
 #ifdef CONFIG_64BIT
@@ -471,6 +474,27 @@ struct backing_dev_info;
 extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
 extern void exit_swap_address_space(unsigned int type);
 
+/*
+ * Get a reference to the swap_info_struct to prevent it to be
+ * swapoff.  The caller should have some locks (like PTL, page lock,
+ * or swap_info_struct->lock) held to guarantee the swap entry is
+ * valid, or check the origin of swap entry again to make sure the
+ * swap device hasn't been swapoff already.
+ */
+static inline struct swap_info_struct *get_swap_device(swp_entry_t entry,
+						       int *sidx)
+{
+	struct swap_info_struct *si = swp_swap_info(entry);
+
+	*sidx = srcu_read_lock(&si->srcu);
+	return si;
+}
+
+static inline void put_swap_device(struct swap_info_struct *si, int sidx)
+{
+	srcu_read_unlock(&si->srcu, sidx);
+}
+
 #else /* CONFIG_SWAP */
 
 static inline int swap_readpage(struct page *page, bool do_poll)
@@ -605,6 +629,16 @@ static inline swp_entry_t get_swap_page(struct page *page)
 	return entry;
 }
 
+static inline struct swap_info_struct *get_swap_device(swp_entry_t entry,
+						       int *sidx)
+{
+	return NULL;
+}
+
+static inline void put_swap_device(struct swap_info_struct *si, int sidx)
+{
+}
+
 #endif /* CONFIG_SWAP */
 
 #ifdef CONFIG_THP_SWAP
diff --git a/init/Kconfig b/init/Kconfig
index 2934249fba46..50cc9b400493 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -223,6 +223,7 @@ config DEFAULT_HOSTNAME
 config SWAP
 	bool "Support for paging of anonymous memory (swap)"
 	depends on MMU && BLOCK
+	select SRCU
 	default y
 	help
 	  This option allows you to choose whether you want to have support
diff --git a/mm/madvise.c b/mm/madvise.c
index 751e97aa2210..dc2ed9e6d47b 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -205,21 +205,27 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
 		swp_entry_t entry;
 		struct page *page;
 		spinlock_t *ptl;
+		struct swap_info_struct *si;
+		int sidx;
 
 		orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);
 		pte = *(orig_pte + ((index - start) / PAGE_SIZE));
-		pte_unmap_unlock(orig_pte, ptl);
-
 		if (pte_present(pte) || pte_none(pte))
-			continue;
+			goto unlock_continue;
 		entry = pte_to_swp_entry(pte);
 		if (unlikely(non_swap_entry(entry)))
-			continue;
+			goto unlock_continue;
+		si = get_swap_device(entry, &sidx);
+		pte_unmap_unlock(orig_pte, ptl);
 
 		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
 							vma, index, false);
 		if (page)
 			put_page(page);
+		put_swap_device(si, sidx);
+		continue;
+unlock_continue:
+		pte_unmap_unlock(orig_pte, ptl);
 	}
 
 	return 0;
diff --git a/mm/memory.c b/mm/memory.c
index 1a969992f76b..d71fc7798910 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1069,6 +1069,8 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	int progress = 0;
 	int rss[NR_MM_COUNTERS];
 	swp_entry_t entry = (swp_entry_t){0};
+	struct swap_info_struct *si = NULL;
+	int sidx = 0;
 
 again:
 	init_rss_vec(rss);
@@ -1100,8 +1102,10 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		}
 		entry.val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
 							vma, addr, rss);
-		if (entry.val)
+		if (entry.val) {
+			si = get_swap_device(entry, &sidx);
 			break;
+		}
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
@@ -1113,7 +1117,11 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	cond_resched();
 
 	if (entry.val) {
-		if (add_swap_count_continuation(entry, GFP_KERNEL) < 0)
+		int ret;
+
+		ret = add_swap_count_continuation(entry, GFP_KERNEL);
+		put_swap_device(si, sidx);
+		if (ret < 0)
 			return -ENOMEM;
 		progress = 0;
 	}
@@ -2871,16 +2879,19 @@ int do_swap_page(struct vm_fault *vmf)
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL, *swapcache = NULL;
 	struct mem_cgroup *memcg;
+	struct swap_info_struct *si = NULL;
 	swp_entry_t entry;
 	pte_t pte;
-	int locked;
+	int locked, sidx = 0;
 	int exclusive = 0;
 	int ret = 0;
 
+	entry = pte_to_swp_entry(vmf->orig_pte);
+	if (likely(!non_swap_entry(entry)))
+		si = get_swap_device(entry, &sidx);
 	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
 		goto out;
 
-	entry = pte_to_swp_entry(vmf->orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
 			migration_entry_wait(vma->vm_mm, vmf->pmd,
@@ -2906,8 +2917,6 @@ int do_swap_page(struct vm_fault *vmf)
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	page = lookup_swap_cache(entry, vma, vmf->address);
 	if (!page) {
-		struct swap_info_struct *si = swp_swap_info(entry);
-
 		if (si->flags & SWP_SYNCHRONOUS_IO &&
 				__swap_count(si, entry) == 1) {
 			/* skip swapcache */
@@ -2954,6 +2963,9 @@ int do_swap_page(struct vm_fault *vmf)
 		goto out_release;
 	}
 
+	put_swap_device(si, sidx);
+	si = NULL;
+
 	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags);
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
@@ -3064,6 +3076,8 @@ int do_swap_page(struct vm_fault *vmf)
 unlock:
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
 out:
+	if (si)
+		put_swap_device(si, sidx);
 	return ret;
 out_nomap:
 	mem_cgroup_cancel_charge(page, memcg, false);
@@ -3071,6 +3085,8 @@ int do_swap_page(struct vm_fault *vmf)
 out_page:
 	unlock_page(page);
 out_release:
+	if (si)
+		put_swap_device(si, sidx);
 	put_page(page);
 	if (page != swapcache && swapcache) {
 		unlock_page(swapcache);
diff --git a/mm/shmem.c b/mm/shmem.c
index 2b157bd55326..4c4befdd9ac3 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1603,10 +1603,11 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct mm_struct *charge_mm;
 	struct mem_cgroup *memcg;
 	struct page *page;
+	struct swap_info_struct *si = NULL;
 	swp_entry_t swap;
 	enum sgp_type sgp_huge = sgp;
 	pgoff_t hindex = index;
-	int error;
+	int error, sidx = 0;
 	int once = 0;
 	int alloced = 0;
 
@@ -1619,6 +1620,13 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	page = find_lock_entry(mapping, index);
 	if (radix_tree_exceptional_entry(page)) {
 		swap = radix_to_swp_entry(page);
+		si = get_swap_device(swap, &sidx);
+		/* Make sure swap device not swap off/on under us */
+		if (!shmem_confirm_swap(mapping, index, swap)) {
+			put_swap_device(si, sidx);
+			si = NULL;
+			goto repeat;
+		}
 		page = NULL;
 	}
 
@@ -1668,6 +1676,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 				goto failed;
 			}
 		}
+		put_swap_device(si, sidx);
+		si = NULL;
 
 		/* We have to do this with page locked to prevent races */
 		lock_page(page);
@@ -1895,6 +1905,10 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, inode,
 	if (swap.val && !shmem_confirm_swap(mapping, index, swap))
 		error = -EEXIST;
 unlock:
+	if (si) {
+		put_swap_device(si, sidx);
+		si = NULL;
+	}
 	if (page) {
 		unlock_page(page);
 		put_page(page);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 42fe5653814a..8e2964d2ee40 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -676,6 +676,7 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 	unsigned long last_in_cluster = 0;
 	int latency_ration = LATENCY_LIMIT;
 	int n_ret = 0;
+	int sidx;
 
 	if (nr > SWAP_BATCH)
 		nr = SWAP_BATCH;
@@ -691,7 +692,7 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 	 * And we let swap pages go all over an SSD partition.  Hugh
 	 */
 
-	si->flags += SWP_SCANNING;
+	sidx = srcu_read_lock(&si->srcu);
 	scan_base = offset = si->cluster_next;
 
 	/* SSD algorithm */
@@ -821,7 +822,7 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 	}
 
 done:
-	si->flags -= SWP_SCANNING;
+	srcu_read_unlock(&si->srcu, sidx);
 	return n_ret;
 
 scan:
@@ -859,7 +860,7 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 	spin_lock(&si->lock);
 
 no_page:
-	si->flags -= SWP_SCANNING;
+	srcu_read_unlock(&si->srcu, sidx);
 	return n_ret;
 }
 
@@ -2599,6 +2600,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	atomic_long_sub(p->pages, &nr_swap_pages);
 	total_swap_pages -= p->pages;
 	p->flags &= ~SWP_WRITEOK;
+	p->highest_bit = 0;		/* cuts scans short */
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 
@@ -2617,6 +2619,12 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 
 	reenable_swap_slots_cache_unlock();
 
+	/*
+	 * wait for anyone still operate on swap device, like scan, swapin,
+	 * copy page table, etc.
+	 */
+	synchronize_srcu(&p->srcu);
+
 	flush_work(&p->discard_work);
 
 	destroy_swap_extents(p);
@@ -2631,16 +2639,6 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	spin_lock(&p->lock);
 	drain_mmlist();
 
-	/* wait for anyone still in scan_swap_map */
-	p->highest_bit = 0;		/* cuts scans short */
-	while (p->flags >= SWP_SCANNING) {
-		spin_unlock(&p->lock);
-		spin_unlock(&swap_lock);
-		schedule_timeout_uninterruptible(1);
-		spin_lock(&swap_lock);
-		spin_lock(&p->lock);
-	}
-
 	swap_file = p->swap_file;
 	old_block_size = p->old_block_size;
 	p->swap_file = NULL;
@@ -2836,6 +2834,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 	struct swap_info_struct *p;
 	unsigned int type;
 	int i;
+	bool new = false;
 
 	p = kzalloc(sizeof(*p), GFP_KERNEL);
 	if (!p)
@@ -2861,6 +2860,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 		 */
 		smp_wmb();
 		nr_swapfiles++;
+		new = true;
 	} else {
 		kfree(p);
 		p = swap_info[type];
@@ -2877,6 +2877,8 @@ static struct swap_info_struct *alloc_swap_info(void)
 	spin_unlock(&swap_lock);
 	spin_lock_init(&p->lock);
 	spin_lock_init(&p->cont_lock);
+	if (new)
+		init_srcu_struct(&p->srcu);
 
 	return p;
 }
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
