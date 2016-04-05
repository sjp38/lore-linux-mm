Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 21518828DF
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:53:35 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id n1so18886413pfn.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:53:35 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id e1si30417453pfd.154.2016.04.05.14.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:53:34 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id 184so18945135pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:53:34 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:53:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 23/31] huge tmpfs recovery: framework for reconstituting huge
 pages
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051451430.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Huge tmpfs is great when you're allocated a huge page from the start;
but not much use if there was a shortage of huge pages at that time,
or your huge pages were disbanded and swapped out under pressure, and
now paged back in 4k pieces once the pressure has eased.  At present
the best you can do is copy your original file, and start afresh on
the unfragmented copy; but we do need a better answer.

The approach taken here is driven from page fault: assembling a huge
page from existing pieces is more expensive than initial allocation
from an empty huge page, and the work done quite likely to be wasted,
unless there's some evidence that a huge TLB mapping will be useful
to the process.  A page fault in a suitable area suggests that it may.

So we adjust the original "Shall we map a huge page hugely?" tests in
shmem_fault(), to distinguish what can be done on this occasion from
what may be possible later: invoking shmem_huge_recovery() when we
cannot map a huge page now, but might be able to use one later.

It's likely that this is over-eager, that it needs some rate-limiting,
and should be tuned by the number of faults which occur in the extent.
Such information will have to be stored somewhere: probably in the
extent's recovery work struct; but no attempt to do so in this series.

So as not to add latency to the fault, shmem_huge_recovery() just
enqueues a work item - with no consideration for all the flavors
of workqueue that might be used: would something special be better?

But skips it if this range of the file is already on the queue
(which is both more efficient, and avoids awkward races later),
or if too many items are currently enqueued.  "Too many" defaults
to more than 8, tunable via /proc/sys/vm/shmem_huge_recoveries -
seems more appropriate than adding it into the huge=N mount option.
Why 8?  Well, anon THP's khugepaged is equivalent to 1, but work
queues let us be less restrictive.  Initializing or tuning it to 0
completely disables huge tmpfs recovery.

shmem_recovery_work() is where the huge page is allocated - using
__alloc_pages_node() rather than alloc_pages_vma(), like anon THP
does nowadays: ignoring vma mempol complications for now, though
I'm sure our NUMA behavior here will need to be improved very soon.
Population and remap phases left as stubs in this framework commit.

But a fresh huge page is not necessarily allocated: page migration
is never sure to succeed, so it's wiser to allow a work item to
resume on a huge page begun by an earlier, than re-migrate all its
pages so far instantiated, to yet another huge page.  Sometimes
an unfinished huge page can be easily recognized by PageTeam;
but sometimes it has to be located, by the same SHMEM_TAG_HUGEHOLE
mechanism that exposes it to the hugehole shrinker.  Clear the tag
to prevent the shrinker from interfering (unexpectedly disbanding)
while in shmem_populate_hugeteam() itself.

If shmem_huge_recoveries is enabled, shmem_alloc_page()'s retry
after shrinking is disabled: in early testing, the shrinker was
too eager to undo the work of recovery.  That was probably a
side-effect of bugs at that time, but it still seems right to
reduce the latency of shmem_fault() when it has a second chance.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 Documentation/filesystems/tmpfs.txt |   12 +
 Documentation/sysctl/vm.txt         |    9 +
 include/linux/shmem_fs.h            |    2 
 kernel/sysctl.c                     |    7 
 mm/shmem.c                          |  233 +++++++++++++++++++++++++-
 5 files changed, 256 insertions(+), 7 deletions(-)

--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -176,6 +176,12 @@ user accesses between end of file and th
 not fail with SIGBUS, as they would on a huge=0 filesystem - but will fail
 with SIGBUS if the kernel could only allocate small pages to back it.
 
+When memory pressure eases, or compaction repairs memory fragmentation,
+huge tmpfs recovery attempts to restore the original performance with
+hugepages: as small pages are faulted back in, a workitem is queued to
+bring the remainder back from swap, and migrate small pages into place,
+before remapping the completed hugepage with a pmd.
+
 /proc/sys/vm/shmem_huge (intended for experimentation only):
 
 Default 0; write 1 to set tmpfs mount option huge=1 on the kernel's
@@ -186,6 +192,12 @@ In addition to 0 and 1, it also accepts
 automatically on for all tmpfs mounts (intended for testing), or -1
 to force huge off for all (intended for safety if bugs appeared).
 
+/proc/sys/vm/shmem_huge_recoveries:
+
+Default 8, allows up to 8 concurrent workitems, recovering hugepages
+after fragmentation prevented or reclaim disbanded; write 0 to disable
+huge recoveries, or a higher number to allow more concurrent recoveries.
+
 /proc/<pid>/smaps shows:
 
 ShmemHugePages:    10240 kB   tmpfs hugepages mapped by pmd into this region
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -57,6 +57,7 @@ Currently, these files are in /proc/sys/
 - panic_on_oom
 - percpu_pagelist_fraction
 - shmem_huge
+- shmem_huge_recoveries
 - stat_interval
 - stat_refresh
 - swappiness
@@ -764,6 +765,14 @@ See Documentation/filesystems/tmpfs.txt
 
 ==============================================================
 
+shmem_huge_recoveries
+
+Default 8, allows up to 8 concurrent workitems, recovering hugepages
+after fragmentation prevented or reclaim disbanded; write 0 to disable
+huge recoveries, or a higher number to allow more concurrent recoveries.
+
+==============================================================
+
 stat_interval
 
 The time interval between which vm statistics are updated.  The default
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -20,6 +20,7 @@ struct shmem_inode_info {
 	struct list_head	swaplist;	/* chain of maybes on swap */
 	struct shared_policy	policy;		/* NUMA memory alloc policy */
 	struct simple_xattrs	xattrs;		/* list of xattrs */
+	atomic_t		recoveries;	/* huge recovery work queued */
 	struct inode		vfs_inode;
 };
 
@@ -87,6 +88,7 @@ static inline long shmem_fcntl(struct fi
 # ifdef CONFIG_SYSCTL
 struct ctl_table;
 extern int shmem_huge, shmem_huge_min, shmem_huge_max;
+extern int shmem_huge_recoveries;
 extern int shmem_huge_sysctl(struct ctl_table *table, int write,
 			     void __user *buffer, size_t *lenp, loff_t *ppos);
 # endif /* CONFIG_SYSCTL */
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1324,6 +1324,13 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &shmem_huge_min,
 		.extra2		= &shmem_huge_max,
 	},
+	{
+		.procname	= "shmem_huge_recoveries",
+		.data		= &shmem_huge_recoveries,
+		.maxlen		= sizeof(shmem_huge_recoveries),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #endif
 #ifdef CONFIG_HUGETLB_PAGE
 	{
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -59,6 +59,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/splice.h>
 #include <linux/security.h>
 #include <linux/shrinker.h>
+#include <linux/workqueue.h>
 #include <linux/sysctl.h>
 #include <linux/swapops.h>
 #include <linux/pageteam.h>
@@ -319,6 +320,7 @@ static DEFINE_SPINLOCK(shmem_shrinklist_
 /* ifdef here to avoid bloating shmem.o when not necessary */
 
 int shmem_huge __read_mostly;
+int shmem_huge_recoveries __read_mostly = 8;	/* concurrent recovery limit */
 
 static struct page *shmem_hugeteam_lookup(struct address_space *mapping,
 					  pgoff_t index, bool speculative)
@@ -377,8 +379,8 @@ static int shmem_freeholes(struct page *
 		HPAGE_PMD_NR - (nr / TEAM_PAGE_COUNTER);
 }
 
-static void shmem_clear_tag_hugehole(struct address_space *mapping,
-				     pgoff_t index)
+static struct page *shmem_clear_tag_hugehole(struct address_space *mapping,
+					     pgoff_t index)
 {
 	struct page *page = NULL;
 
@@ -391,9 +393,13 @@ static void shmem_clear_tag_hugehole(str
 	 */
 	radix_tree_gang_lookup_tag(&mapping->page_tree, (void **)&page,
 					index, 1, SHMEM_TAG_HUGEHOLE);
-	VM_BUG_ON(!page || page->index >= index + HPAGE_PMD_NR);
-	radix_tree_tag_clear(&mapping->page_tree, page->index,
+	VM_BUG_ON(radix_tree_exception(page));
+	if (page && page->index < index + HPAGE_PMD_NR) {
+		radix_tree_tag_clear(&mapping->page_tree, page->index,
 					SHMEM_TAG_HUGEHOLE);
+		return page;
+	}
+	return NULL;
 }
 
 static void shmem_added_to_hugeteam(struct page *page, struct zone *zone,
@@ -748,6 +754,190 @@ static void shmem_disband_hugeteam(struc
 	preempt_enable();
 }
 
+static LIST_HEAD(shmem_recoverylist);
+static unsigned int shmem_recoverylist_depth;
+static DEFINE_SPINLOCK(shmem_recoverylist_lock);
+
+struct recovery {
+	struct list_head list;
+	struct work_struct work;
+	struct mm_struct *mm;
+	struct inode *inode;
+	struct page *page;
+	pgoff_t head_index;
+};
+
+#define shr_stats(x)	do {} while (0)
+/* Stats implemented in a later patch */
+
+static bool shmem_work_still_useful(struct recovery *recovery)
+{
+	struct address_space *mapping = READ_ONCE(recovery->page->mapping);
+
+	return mapping &&			/* page is not yet truncated */
+#ifdef CONFIG_MEMCG
+		recovery->mm->owner &&		/* mm can still charge memcg */
+#else
+		atomic_read(&recovery->mm->mm_users) &&	/* mm still has users */
+#endif
+		!RB_EMPTY_ROOT(&mapping->i_mmap);  /* file is still mapped */
+}
+
+static int shmem_recovery_populate(struct recovery *recovery, struct page *head)
+{
+	/* Huge page has been split but is not yet PageTeam */
+	shmem_disband_hugetails(head, NULL, 0);
+	return -ENOENT;
+}
+
+static void shmem_recovery_remap(struct recovery *recovery, struct page *head)
+{
+}
+
+static void shmem_recovery_work(struct work_struct *work)
+{
+	struct recovery *recovery;
+	struct shmem_inode_info *info;
+	struct address_space *mapping;
+	struct page *page;
+	struct page *head = NULL;
+	int error = -ENOENT;
+
+	recovery = container_of(work, struct recovery, work);
+	info = SHMEM_I(recovery->inode);
+	if (!shmem_work_still_useful(recovery)) {
+		shr_stats(work_too_late);
+		goto out;
+	}
+
+	/* Are we resuming from an earlier partially successful attempt? */
+	mapping = recovery->inode->i_mapping;
+	spin_lock_irq(&mapping->tree_lock);
+	page = shmem_clear_tag_hugehole(mapping, recovery->head_index);
+	if (page)
+		head = team_head(page);
+	spin_unlock_irq(&mapping->tree_lock);
+	if (head) {
+		/* Serialize with shrinker so it won't mess with our range */
+		spin_lock(&shmem_shrinklist_lock);
+		spin_unlock(&shmem_shrinklist_lock);
+	}
+
+	/* If team is now complete, no tag and head would be found above */
+	page = recovery->page;
+	if (PageTeam(page))
+		head = team_head(page);
+
+	/* Get a reference to the head of the team already being assembled */
+	if (head) {
+		if (!get_page_unless_zero(head))
+			head = NULL;
+		else if (!PageTeam(head) || head->mapping != mapping ||
+				head->index != recovery->head_index) {
+			put_page(head);
+			head = NULL;
+		}
+	}
+
+	if (head) {
+		/* We are resuming work from a previous partial recovery */
+		if (PageTeam(page))
+			shr_stats(resume_teamed);
+		else
+			shr_stats(resume_tagged);
+	} else {
+		gfp_t gfp = mapping_gfp_mask(mapping);
+		/*
+		 * XXX: Note that with swapin readahead, page_to_nid(page) will
+		 * often choose an unsuitable NUMA node: something to fix soon,
+		 * but not an immediate blocker.
+		 */
+		head = __alloc_pages_node(page_to_nid(page),
+			gfp | __GFP_NOWARN | __GFP_THISNODE, HPAGE_PMD_ORDER);
+		if (!head) {
+			shr_stats(huge_failed);
+			error = -ENOMEM;
+			goto out;
+		}
+		if (!shmem_work_still_useful(recovery)) {
+			__free_pages(head, HPAGE_PMD_ORDER);
+			shr_stats(huge_too_late);
+			goto out;
+		}
+		split_page(head, HPAGE_PMD_ORDER);
+		get_page(head);
+		shr_stats(huge_alloced);
+	}
+
+	put_page(page);			/* before trying to migrate it */
+	recovery->page = head;		/* to put at out */
+
+	error = shmem_recovery_populate(recovery, head);
+	if (!error)
+		shmem_recovery_remap(recovery, head);
+out:
+	put_page(recovery->page);
+	/* Let shmem_evict_inode proceed towards freeing it */
+	if (atomic_dec_and_test(&info->recoveries))
+		wake_up_atomic_t(&info->recoveries);
+	mmdrop(recovery->mm);
+
+	spin_lock(&shmem_recoverylist_lock);
+	shmem_recoverylist_depth--;
+	list_del(&recovery->list);
+	spin_unlock(&shmem_recoverylist_lock);
+	kfree(recovery);
+}
+
+static void shmem_huge_recovery(struct inode *inode, struct page *page,
+				struct vm_area_struct *vma)
+{
+	struct recovery *recovery;
+	struct recovery *r;
+
+	/* Limit the outstanding work somewhat; but okay to overshoot */
+	if (shmem_recoverylist_depth >= shmem_huge_recoveries) {
+		shr_stats(work_too_many);
+		return;
+	}
+	recovery = kmalloc(sizeof(*recovery), GFP_KERNEL);
+	if (!recovery)
+		return;
+
+	recovery->mm = vma->vm_mm;
+	recovery->inode = inode;
+	recovery->page = page;
+	recovery->head_index = round_down(page->index, HPAGE_PMD_NR);
+
+	spin_lock(&shmem_recoverylist_lock);
+	list_for_each_entry(r, &shmem_recoverylist, list) {
+		/* Is someone already working on this extent? */
+		if (r->inode == inode &&
+		    r->head_index == recovery->head_index) {
+			spin_unlock(&shmem_recoverylist_lock);
+			kfree(recovery);
+			shr_stats(work_already);
+			return;
+		}
+	}
+	list_add(&recovery->list, &shmem_recoverylist);
+	shmem_recoverylist_depth++;
+	spin_unlock(&shmem_recoverylist_lock);
+
+	/*
+	 * It's safe to leave inc'ing these reference counts until after
+	 * dropping the list lock above, because the corresponding decs
+	 * cannot happen until the work is run, and we queue it below.
+	 */
+	atomic_inc(&recovery->mm->mm_count);
+	atomic_inc(&SHMEM_I(inode)->recoveries);
+	get_page(page);
+
+	INIT_WORK(&recovery->work, shmem_recovery_work);
+	schedule_work(&recovery->work);
+	shr_stats(work_queued);
+}
+
 static struct page *shmem_get_hugehole(struct address_space *mapping,
 				       unsigned long *index)
 {
@@ -998,6 +1188,8 @@ static struct shrinker shmem_hugehole_sh
 #else /* !CONFIG_TRANSPARENT_HUGEPAGE */
 
 #define shmem_huge SHMEM_HUGE_DENY
+#define shmem_huge_recoveries 0
+#define shr_stats(x) do {} while (0)
 
 static inline struct page *shmem_hugeteam_lookup(struct address_space *mapping,
 					pgoff_t index, bool speculative)
@@ -1022,6 +1214,11 @@ static inline int shmem_populate_hugetea
 	return -EAGAIN;
 }
 
+static inline void shmem_huge_recovery(struct inode *inode,
+				struct page *page, struct vm_area_struct *vma)
+{
+}
+
 static inline unsigned long shmem_shrink_hugehole(struct shrinker *shrink,
 						  struct shrink_control *sc)
 {
@@ -1505,6 +1702,12 @@ static int shmem_setattr(struct dentry *
 	return error;
 }
 
+static int shmem_wait_on_atomic_t(atomic_t *atomic)
+{
+	schedule();
+	return 0;
+}
+
 static void shmem_evict_inode(struct inode *inode)
 {
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -1526,6 +1729,9 @@ static void shmem_evict_inode(struct ino
 			list_del_init(&info->swaplist);
 			mutex_unlock(&shmem_swaplist_mutex);
 		}
+		/* Stop inode from being freed while recovery is in progress */
+		wait_on_atomic_t(&info->recoveries, shmem_wait_on_atomic_t,
+				 TASK_UNINTERRUPTIBLE);
 	}
 
 	simple_xattrs_free(&info->xattrs);
@@ -1879,7 +2085,8 @@ static struct page *shmem_alloc_page(gfp
 			head = alloc_pages_vma(gfp|__GFP_NORETRY|__GFP_NOWARN,
 				HPAGE_PMD_ORDER, &pvma, 0, numa_node_id(),
 				true);
-			if (!head &&
+			/* Shrink and retry? Or leave it to recovery worker */
+			if (!head && !shmem_huge_recoveries &&
 			    shmem_shrink_hugehole(NULL, NULL) != SHRINK_STOP) {
 				head = alloc_pages_vma(
 					gfp|__GFP_NORETRY|__GFP_NOWARN,
@@ -2377,9 +2584,9 @@ single:
 	 */
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
 		return ret;
-	if (!(vmf->flags & FAULT_FLAG_MAY_HUGE))
+	if (shmem_huge == SHMEM_HUGE_DENY)
 		return ret;
-	if (!PageTeam(vmf->page))
+	if (shmem_huge != SHMEM_HUGE_FORCE && !SHMEM_SB(inode->i_sb)->huge)
 		return ret;
 	if (once++)
 		return ret;
@@ -2393,6 +2600,17 @@ single:
 		return ret;
 	/* But omit i_size check: allow up to huge page boundary */
 
+	if (!PageTeam(vmf->page) || !(vmf->flags & FAULT_FLAG_MAY_HUGE)) {
+		/*
+		 * XXX: Need to add check for unobstructed pmd
+		 * (no anon or swap), and per-pmd ratelimiting.
+		 * Use anon_vma as over-strict hint of COWed pages.
+		 */
+		if (shmem_huge_recoveries && !vma->anon_vma)
+			shmem_huge_recovery(inode, vmf->page, vma);
+		return ret;
+	}
+
 	head = team_head(vmf->page);
 	if (!get_page_unless_zero(head))
 		return ret;
@@ -2580,6 +2798,7 @@ static struct inode *shmem_get_inode(str
 		info = SHMEM_I(inode);
 		memset(info, 0, (char *)inode - (char *)info);
 		spin_lock_init(&info->lock);
+		atomic_set(&info->recoveries, 0);
 		info->seals = F_SEAL_SEAL;
 		info->flags = flags & VM_NORESERVE;
 		INIT_LIST_HEAD(&info->shrinklist);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
