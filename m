Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id A212F6B0038
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 18:26:00 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/6] mm: memcg: enable memcg OOM killer only for user faults
Date: Thu, 25 Jul 2013 18:25:37 -0400
Message-Id: <1374791138-15665-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

System calls and kernel faults (uaccess, gup) can handle an out of
memory situation gracefully and just return -ENOMEM.

Enable the memcg OOM killer only for user faults, where it's really
the only option available.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 23 +++++++++++++++++++++++
 include/linux/sched.h      |  3 +++
 mm/filemap.c               | 11 ++++++++++-
 mm/memcontrol.c            |  2 +-
 mm/memory.c                | 40 ++++++++++++++++++++++++++++++----------
 5 files changed, 67 insertions(+), 12 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7b4d9d7..9bb5eeb 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -125,6 +125,24 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 extern void mem_cgroup_replace_page_cache(struct page *oldpage,
 					struct page *newpage);
 
+/**
+ * mem_cgroup_xchg_may_oom - toggle the memcg OOM killer for a task
+ * @p: task
+ * @new: true to enable, false to disable
+ *
+ * Toggle whether a failed memcg charge should invoke the OOM killer
+ * or just return -ENOMEM.  Returns the previous toggle state.
+ */
+static inline bool mem_cgroup_xchg_may_oom(struct task_struct *p, bool new)
+{
+	bool old;
+
+	old = p->memcg_oom.may_oom;
+	p->memcg_oom.may_oom = new;
+
+	return old;
+}
+
 #ifdef CONFIG_MEMCG_SWAP
 extern int do_swap_account;
 #endif
@@ -348,6 +366,11 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
 {
 }
 
+static inline bool mem_cgroup_xchg_may_oom(struct task_struct *p, bool new)
+{
+	return !new;
+}
+
 static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_page_stat_item idx)
 {
diff --git a/include/linux/sched.h b/include/linux/sched.h
index fc09d21..4b3effc 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1398,6 +1398,9 @@ struct task_struct {
 		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
 	} memcg_batch;
 	unsigned int memcg_kmem_skip_account;
+	struct memcg_oom_info {
+		unsigned int may_oom:1;
+	} memcg_oom;
 #endif
 #ifdef CONFIG_UPROBES
 	struct uprobe_task *utask;
diff --git a/mm/filemap.c b/mm/filemap.c
index a6981fe..2932810 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1617,6 +1617,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
 	pgoff_t offset = vmf->pgoff;
+	unsigned int may_oom;
 	struct page *page;
 	pgoff_t size;
 	int ret = 0;
@@ -1626,7 +1627,11 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		return VM_FAULT_SIGBUS;
 
 	/*
-	 * Do we have something in the page cache already?
+	 * Do we have something in the page cache already?  Either
+	 * way, try readahead, but disable the memcg OOM killer for it
+	 * as readahead is optional and no errors are propagated up
+	 * the fault stack.  The OOM killer is enabled while trying to
+	 * instantiate the faulting page individually below.
 	 */
 	page = find_get_page(mapping, offset);
 	if (likely(page) && !(vmf->flags & FAULT_FLAG_TRIED)) {
@@ -1634,10 +1639,14 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		 * We found the page, so try async readahead before
 		 * waiting for the lock.
 		 */
+		may_oom = mem_cgroup_xchg_may_oom(current, 0);
 		do_async_mmap_readahead(vma, ra, file, page, offset);
+		mem_cgroup_xchg_may_oom(current, may_oom);
 	} else if (!page) {
 		/* No page in the page cache at all */
+		may_oom = mem_cgroup_xchg_may_oom(current, 0);
 		do_sync_mmap_readahead(vma, ra, file, offset);
+		mem_cgroup_xchg_may_oom(current, may_oom);
 		count_vm_event(PGMAJFAULT);
 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 00a7a66..30ae46a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2614,7 +2614,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		return CHARGE_RETRY;
 
 	/* If we don't need to call oom-killer at el, return immediately */
-	if (!oom_check)
+	if (!oom_check || !current->memcg_oom.may_oom)
 		return CHARGE_NOMEM;
 	/* check OOM */
 	if (!mem_cgroup_handle_oom(mem_over_limit, gfp_mask, get_order(csize)))
diff --git a/mm/memory.c b/mm/memory.c
index f2ab2a8..5ea7b47 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3752,22 +3752,14 @@ unlock:
 /*
  * By the time we get here, we already hold the mm semaphore
  */
-int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+			     unsigned long address, unsigned int flags)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
-	__set_current_state(TASK_RUNNING);
-
-	count_vm_event(PGFAULT);
-	mem_cgroup_count_vm_event(mm, PGFAULT);
-
-	/* do counter updates before entering really critical section. */
-	check_sync_rss_stat(current);
-
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, flags);
 
@@ -3851,6 +3843,34 @@ retry:
 	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
+int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		    unsigned long address, unsigned int flags)
+{
+	int ret;
+
+	__set_current_state(TASK_RUNNING);
+
+	count_vm_event(PGFAULT);
+	mem_cgroup_count_vm_event(mm, PGFAULT);
+
+	/* do counter updates before entering really critical section. */
+	check_sync_rss_stat(current);
+
+	/*
+	 * Enable the memcg OOM handling for faults triggered in user
+	 * space.  Kernel faults are handled more gracefully.
+	 */
+	if (flags & FAULT_FLAG_USER)
+		WARN_ON(mem_cgroup_xchg_may_oom(current, true) == true);
+
+	ret = __handle_mm_fault(mm, vma, address, flags);
+
+	if (flags & FAULT_FLAG_USER)
+		WARN_ON(mem_cgroup_xchg_may_oom(current, false) == false);
+
+	return ret;
+}
+
 #ifndef __PAGETABLE_PUD_FOLDED
 /*
  * Allocate page upper directory.
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
