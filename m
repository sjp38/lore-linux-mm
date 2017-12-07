Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51CDF6B0261
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 20:15:21 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d4so3748459pgv.4
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 17:15:21 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id r1si2751425pgp.308.2017.12.06.17.15.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 17:15:19 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm, swap: Fix race between swapoff and some swap operations
Date: Thu,  7 Dec 2017 09:14:26 +0800
Message-Id: <20171207011426.1633-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

From: Huang Ying <ying.huang@intel.com>

When the swapin is performed, after getting the swap entry information
from the page table, the PTL (page table lock) will be released, then
system will go to swap in the swap entry, without any lock held to
prevent the swap device from being swapoff.  This may cause the race
like below,

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

To fix the race, a reference count is added to SIS (struct
swap_info_struct).  The data structure in SIS will be freed only if
the reference count indicates that there are no other users.

The refcount is implemented based on atomic_inc_not_zero() instead of
"normal" refcount_inc().  Because when a swap entry is swapin in
shmem, the swap entry is found in page mapping radix tree locklessly.
We cannot get a valid reference to SIS with the help of a lock.
Instead, we set the refcount to 0 when SIS is swap off or
uninitialized, so atomic_inc_not_zero() will return false for that.

Several other code paths in addition to swapin has similar race, they
are fixed too in the same way.

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
---
 include/linux/swap.h | 13 +++++++-
 mm/madvise.c         | 15 +++++++---
 mm/memory.c          | 26 ++++++++++++----
 mm/shmem.c           | 11 +++++++
 mm/swapfile.c        | 83 ++++++++++++++++++++++++++++++++++++++++++++--------
 5 files changed, 125 insertions(+), 23 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2417d288e016..ba9ced8a6a1d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -173,7 +173,6 @@ enum {
 	SWP_STABLE_WRITES = (1 << 10),	/* no overwrite PG_writeback pages */
 	SWP_SYNCHRONOUS_IO = (1 << 11),	/* synchronous IO is efficient */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 12),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
@@ -230,6 +229,7 @@ struct swap_cluster_list {
  */
 struct swap_info_struct {
 	unsigned long	flags;		/* SWP_USED etc: see above */
+	atomic_t	count;		/* reference count of the swap device */
 	signed short	prio;		/* swap priority of this type */
 	struct plist_node list;		/* entry in swap_active_head */
 	struct plist_node avail_lists[MAX_NUMNODES];/* entry in swap_avail_heads */
@@ -470,6 +470,8 @@ extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
 extern void exit_swap_address_space(unsigned int type);
+extern struct swap_info_struct *get_swap_device(swp_entry_t entry);
+extern void put_swap_device(struct swap_info_struct *si);
 
 #else /* CONFIG_SWAP */
 
@@ -605,6 +607,15 @@ static inline swp_entry_t get_swap_page(struct page *page)
 	return entry;
 }
 
+static inline struct swap_info_struct *get_swap_device(swp_entry_t entry)
+{
+	return NULL;
+}
+
+static inline void put_swap_device(struct swap_info_struct *si)
+{
+}
+
 #endif /* CONFIG_SWAP */
 
 #ifdef CONFIG_THP_SWAP
diff --git a/mm/madvise.c b/mm/madvise.c
index 751e97aa2210..74544424e96d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -205,21 +205,28 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
 		swp_entry_t entry;
 		struct page *page;
 		spinlock_t *ptl;
+		struct swap_info_struct *si;
 
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
+		si = get_swap_device(entry);
+		if (!si)
+			goto unlock_continue;
+		pte_unmap_unlock(orig_pte, ptl);
 
 		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
 							vma, index, false);
 		if (page)
 			put_page(page);
+		put_swap_device(si);
+		continue;
+unlock_continue:
+		pte_unmap_unlock(orig_pte, ptl);
 	}
 
 	return 0;
diff --git a/mm/memory.c b/mm/memory.c
index 1c9f3c03be15..68bbbed084e4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1066,6 +1066,7 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	int progress = 0;
 	int rss[NR_MM_COUNTERS];
 	swp_entry_t entry = (swp_entry_t){0};
+	struct swap_info_struct *si = NULL;
 
 again:
 	init_rss_vec(rss);
@@ -1097,8 +1098,10 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		}
 		entry.val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
 							vma, addr, rss);
-		if (entry.val)
+		if (entry.val) {
+			si = get_swap_device(entry);
 			break;
+		}
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
@@ -1109,8 +1112,12 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	pte_unmap_unlock(orig_dst_pte, dst_ptl);
 	cond_resched();
 
-	if (entry.val) {
-		if (add_swap_count_continuation(entry, GFP_KERNEL) < 0)
+	if (entry.val && si) {
+		int ret;
+
+		ret = add_swap_count_continuation(entry, GFP_KERNEL);
+		put_swap_device(si);
+		if (ret < 0)
 			return -ENOMEM;
 		progress = 0;
 	}
@@ -2849,6 +2856,7 @@ int do_swap_page(struct vm_fault *vmf)
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL, *swapcache = NULL;
 	struct mem_cgroup *memcg;
+	struct swap_info_struct *si = NULL;
 	swp_entry_t entry;
 	pte_t pte;
 	int locked;
@@ -2880,12 +2888,13 @@ int do_swap_page(struct vm_fault *vmf)
 		goto out;
 	}
 
+	si = get_swap_device(entry);
+	if (unlikely(!si))
+		goto out;
 
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	page = lookup_swap_cache(entry, vma, vmf->address);
 	if (!page) {
-		struct swap_info_struct *si = swp_swap_info(entry);
-
 		if (si->flags & SWP_SYNCHRONOUS_IO &&
 				__swap_count(si, entry) == 1) {
 			/* skip swapcache */
@@ -2932,6 +2941,9 @@ int do_swap_page(struct vm_fault *vmf)
 		goto out_release;
 	}
 
+	put_swap_device(si);
+	si = NULL;
+
 	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags);
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
@@ -3042,6 +3054,8 @@ int do_swap_page(struct vm_fault *vmf)
 unlock:
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
 out:
+	if (si)
+		put_swap_device(si);
 	return ret;
 out_nomap:
 	mem_cgroup_cancel_charge(page, memcg, false);
@@ -3049,6 +3063,8 @@ int do_swap_page(struct vm_fault *vmf)
 out_page:
 	unlock_page(page);
 out_release:
+	if (si)
+		put_swap_device(si);
 	put_page(page);
 	if (page != swapcache && swapcache) {
 		unlock_page(swapcache);
diff --git a/mm/shmem.c b/mm/shmem.c
index 2b157bd55326..5b0c9d9cdc86 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1603,6 +1603,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct mm_struct *charge_mm;
 	struct mem_cgroup *memcg;
 	struct page *page;
+	struct swap_info_struct *si = NULL;
 	swp_entry_t swap;
 	enum sgp_type sgp_huge = sgp;
 	pgoff_t hindex = index;
@@ -1619,6 +1620,10 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	page = find_lock_entry(mapping, index);
 	if (radix_tree_exceptional_entry(page)) {
 		swap = radix_to_swp_entry(page);
+		si = get_swap_device(swap);
+		/* Make sure swap device not swap off/on under us */
+		if (!si || !shmem_confirm_swap(mapping, index, swap))
+			goto repeat;
 		page = NULL;
 	}
 
@@ -1668,6 +1673,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 				goto failed;
 			}
 		}
+		put_swap_device(si);
+		si = NULL;
 
 		/* We have to do this with page locked to prevent races */
 		lock_page(page);
@@ -1895,6 +1902,10 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, inode,
 	if (swap.val && !shmem_confirm_swap(mapping, index, swap))
 		error = -EEXIST;
 unlock:
+	if (si) {
+		put_swap_device(si);
+		si = NULL;
+	}
 	if (page) {
 		unlock_page(page);
 		put_page(page);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3074b02eaa09..d219cd66d479 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -505,6 +505,57 @@ static void dec_cluster_info_page(struct swap_info_struct *p,
 		free_cluster(p, idx);
 }
 
+/*
+ * Must be called when the swap device is guaranteed to be valid, such
+ * as with swap_info_struct->lock held, etc.
+ */
+static void __get_swap_device(struct swap_info_struct *si)
+{
+	atomic_inc(&si->count);
+}
+
+/*
+ * Get a reference to the swap_info_struct to prevent it to be swap
+ * off.  Return NULL if swap device has been swap off, uninitialized,
+ * or invalid.
+ */
+struct swap_info_struct *get_swap_device(swp_entry_t entry)
+{
+	struct swap_info_struct *si;
+	unsigned long type;
+
+	if (!entry.val)
+		return NULL;
+	type = swp_type(entry);
+	if (type >= nr_swapfiles)
+		goto bad_nofile;
+	si = swap_info[type];
+	/*
+	 * If swap device is uninitialized or destroyed, the
+	 * reference count will be 0
+	 */
+	if (!atomic_inc_not_zero(&si->count))
+		si = NULL;
+	/*
+	 * If atomic_inc_not_zero() inc successfully, it will be fully
+	 * ordered with following accesses.
+	 */
+
+	return si;
+bad_nofile:
+	pr_err("%s: %s%08lx\n", __func__, Bad_file, entry.val);
+	return NULL;
+}
+
+/*
+ * Put the reference to the swap_info_struct
+ */
+void put_swap_device(struct swap_info_struct *si)
+{
+	/* RELEASE make all access to si done before dec refcount */
+	atomic_dec_return_release(&si->count);
+}
+
 /*
  * It's possible scan_swap_map() uses a free cluster in the middle of free
  * cluster list. Avoiding such abuse to avoid list corruption.
@@ -691,7 +742,7 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 	 * And we let swap pages go all over an SSD partition.  Hugh
 	 */
 
-	si->flags += SWP_SCANNING;
+	__get_swap_device(si);
 	scan_base = offset = si->cluster_next;
 
 	/* SSD algorithm */
@@ -821,7 +872,7 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 	}
 
 done:
-	si->flags -= SWP_SCANNING;
+	put_swap_device(si);
 	return n_ret;
 
 scan:
@@ -859,7 +910,7 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 	spin_lock(&si->lock);
 
 no_page:
-	si->flags -= SWP_SCANNING;
+	put_swap_device(si);
 	return n_ret;
 }
 
@@ -2479,6 +2530,8 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	p->swap_map = swap_map;
 	p->cluster_info = cluster_info;
 	p->flags |= SWP_WRITEOK;
+	/* RELEASE makes store above done before inc refcount */
+	atomic_inc_return_release(&p->count);
 	atomic_long_add(p->pages, &nr_swap_pages);
 	total_swap_pages += p->pages;
 
@@ -2599,6 +2652,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	atomic_long_sub(p->pages, &nr_swap_pages);
 	total_swap_pages -= p->pages;
 	p->flags &= ~SWP_WRITEOK;
+	p->highest_bit = 0;		/* cuts scans short */
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 
@@ -2617,6 +2671,18 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 
 	reenable_swap_slots_cache_unlock();
 
+	/*
+	 * wait for anyone still operate on swap device, like scan, swapin,
+	 * copy page table, etc.
+	 */
+	atomic_dec(&p->count);
+	while (atomic_read(&p->count) != 0)
+		schedule_timeout_uninterruptible(1);
+	/*
+	 * The control dependency on p->count above guarantees the following
+	 * stores will not occur before p->count been dec in other threads.
+	 */
+
 	flush_work(&p->discard_work);
 
 	destroy_swap_extents(p);
@@ -2631,16 +2697,6 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
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
@@ -2861,6 +2917,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 		 */
 		smp_wmb();
 		nr_swapfiles++;
+		atomic_set(&p->count, 0);
 	} else {
 		kfree(p);
 		p = swap_info[type];
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
