Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 77BA86B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 04:00:52 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9980nXc005653
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Oct 2009 17:00:49 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E12245DE58
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:00:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DD5C45DE55
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:00:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D0341DB803E
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:00:49 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 886A51DB8041
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 17:00:48 +0900 (JST)
Date: Fri, 9 Oct 2009 16:58:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] memcg: coalescing uncharge at unmap/truncate (Oct/9)
Message-Id: <20091009165826.59c6f6e3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, h-shimamoto@ct.jp.nec.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Thank you for all review to previous ones (Oct/2).

This patch is against mmotm + softlimit fix patches.
(which are now in -rc git tree.)
==
In massive parallel enviroment, res_counter can be a performance bottleneck.
One strong techinque to reduce lock contention is reducing calls by
coalescing some amount of calls into one.

Considering charge/uncharge chatacteristic,
	- charge is done one by one via demand-paging.
	- uncharge is done by
		- in chunk at munmap, truncate, exit, execve...
		- one by one via vmscan/paging.

It seems we have a chance to coalesce uncharges for improving scalability
at unmap/truncation.

This patch is a for coalescing uncharge. For avoiding scattering memcg's
structure to functions under /mm, this patch adds memcg batch uncharge
information to the task. A reason for per-task batching is for making
use of caller's context information. We do batched uncharge (deleyed uncharge)
when truncation/unmap occurs but do direct uncharge when uncharge is
called by memory reclaim (vmscan.c).

The degree of coalescing depends on callers
  - at invalidate/trucate... pagevec size
  - at unmap ....ZAP_BLOCK_SIZE
(memory itself will be freed in this degree.)
Then, we'll not coalescing too much.

On x86-64 8cpu server, I tested overheads of memcg at page fault by
running a program which does map/fault/unmap in a loop. Running 
a task per a cpu by taskset and see sum of the number of page faults
in 60secs.

[without memcg config] 
  40156968  page-faults              #      0.085 M/sec   ( +-   0.046% )
  27.67 cache-miss/faults
[root cgroup]
  36659599  page-faults              #      0.077 M/sec   ( +-   0.247% )
  31.58 miss/faults
[in a child cgroup]
  18444157  page-faults              #      0.039 M/sec   ( +-   0.133% )
  69.96 miss/faults
[child with this patch]
  27133719  page-faults              #      0.057 M/sec   ( +-   0.155% )
  47.16 miss/faults

We can see some amounts of improvement.
(root cgroup doesn't affected by this patch)
Another patch for "charge" will follow this and above will be improved more.

Changelog(since 2009/10/02):
 - renamed filed of memcg_batch (as pages to bytes, memsw to memsw_bytes)
 - some clean up and commentary/description updates.
 - added initialize code to copy_process(). (possible bug fix)

Changelog(old):
 - fixed !CONFIG_MEM_CGROUP case. 
 - rebased onto the latest mmotm + softlimit fix patches.
 - unified patch for callers
 - added commetns.
 - make ->do_batch as bool.
 - removed css_get() at el. We don't need it.

Cc: Balbir Singh <balbir@in.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |   13 ++++++
 include/linux/sched.h      |    8 +++
 kernel/fork.c              |    4 +
 mm/memcontrol.c            |   96 ++++++++++++++++++++++++++++++++++++++++++---
 mm/memory.c                |    2 
 mm/truncate.c              |    6 ++
 6 files changed, 123 insertions(+), 6 deletions(-)

Index: mmotm-2.6.31-Sep28/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.31-Sep28.orig/include/linux/memcontrol.h
+++ mmotm-2.6.31-Sep28/include/linux/memcontrol.h
@@ -54,6 +54,11 @@ extern void mem_cgroup_rotate_lru_list(s
 extern void mem_cgroup_del_lru(struct page *page);
 extern void mem_cgroup_move_lists(struct page *page,
 				  enum lru_list from, enum lru_list to);
+
+/* For coalescing uncharge for reducing memcg' overhead*/
+extern void mem_cgroup_uncharge_start(void);
+extern void mem_cgroup_uncharge_end(void);
+
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);
 extern int mem_cgroup_shmem_charge_fallback(struct page *page,
@@ -151,6 +156,14 @@ static inline void mem_cgroup_cancel_cha
 {
 }
 
+static inline void mem_cgroup_uncharge_start(void)
+{
+}
+
+static inline void mem_cgroup_uncharge_end(void)
+{
+}
+
 static inline void mem_cgroup_uncharge_page(struct page *page)
 {
 }
Index: mmotm-2.6.31-Sep28/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep28.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep28/mm/memcontrol.c
@@ -1826,6 +1826,50 @@ void mem_cgroup_cancel_charge_swapin(str
 	css_put(&mem->css);
 }
 
+static void
+__do_uncharge(struct mem_cgroup *mem, const enum charge_type ctype)
+{
+	struct memcg_batch_info *batch = NULL;
+	bool uncharge_memsw = true;
+	/* If swapout, usage of swap doesn't decrease */
+	if (!do_swap_account || ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
+		uncharge_memsw = false;
+	/*
+	 * do_batch > 0 when unmapping pages or inode invalidate/truncate.
+	 * In those cases, all pages freed continously can be expected to be in
+	 * the same cgroup and we have chance to coalesce uncharges.
+	 * But we do uncharge one by one if this is killed by OOM(TIF_MEMDIE)
+	 * because we want to do uncharge as soon as possible.
+	 */
+	if (!current->memcg_batch.do_batch || test_thread_flag(TIF_MEMDIE))
+		goto direct_uncharge;
+
+	batch = &current->memcg_batch;
+	/*
+	 * In usual, we do css_get() when we remember memcg pointer.
+	 * But in this case, we keep res->usage until end of a series of
+	 * uncharges. Then, it's ok to ignore memcg's refcnt.
+	 */
+	if (!batch->memcg)
+		batch->memcg = mem;
+	/*
+	 * In typical case, batch->memcg == mem. This means we can
+	 * merge a series of uncharges to an uncharge of res_counter.
+	 * If not, we uncharge res_counter ony by one.
+	 */
+	if (batch->memcg != mem)
+		goto direct_uncharge;
+	/* remember freed charge and uncharge it later */
+	batch->bytes += PAGE_SIZE;
+	if (uncharge_memsw)
+		batch->memsw_bytes += PAGE_SIZE;
+	return;
+direct_uncharge:
+	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	if (uncharge_memsw)
+		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+	return;
+}
 
 /*
  * uncharge if !page_mapped(page)
@@ -1874,12 +1918,8 @@ __mem_cgroup_uncharge_common(struct page
 		break;
 	}
 
-	if (!mem_cgroup_is_root(mem)) {
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		if (do_swap_account &&
-				(ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
-	}
+	if (!mem_cgroup_is_root(mem))
+		__do_uncharge(mem, ctype);
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		mem_cgroup_swap_statistics(mem, true);
 	mem_cgroup_charge_statistics(mem, pc, false);
@@ -1925,6 +1965,50 @@ void mem_cgroup_uncharge_cache_page(stru
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
 }
 
+/*
+ * Batch_start/batch_end is called in unmap_page_range/invlidate/trucate.
+ * In that cases, pages are freed continuously and we can expect pages
+ * are in the same memcg. All these calls itself limits the number of
+ * pages freed at once, then uncharge_start/end() is called properly.
+ * This may be called prural(2) times in a context,
+ */
+
+void mem_cgroup_uncharge_start(void)
+{
+	current->memcg_batch.do_batch++;
+	/* We can do nest. */
+	if (current->memcg_batch.do_batch == 1) {
+		current->memcg_batch.memcg = NULL;
+		current->memcg_batch.bytes = 0;
+		current->memcg_batch.memsw_bytes = 0;
+	}
+}
+
+void mem_cgroup_uncharge_end(void)
+{
+	struct memcg_batch_info *batch = &current->memcg_batch;
+
+	if (!batch->do_batch)
+		return;
+
+	batch->do_batch--;
+	if (batch->do_batch) /* If stacked, do nothing. */
+		return;
+
+	if (!batch->memcg)
+		return;
+	/*
+	 * This "batch->memcg" is valid without any css_get/put etc...
+	 * bacause we hide charges behind us.
+	 */
+	if (batch->bytes)
+		res_counter_uncharge(&batch->memcg->res, batch->bytes);
+	if (batch->memsw_bytes)
+		res_counter_uncharge(&batch->memcg->memsw, batch->memsw_bytes);
+	/* forget this pointer (for sanity check) */
+	batch->memcg = NULL;
+}
+
 #ifdef CONFIG_SWAP
 /*
  * called after __delete_from_swap_cache() and drop "page" account.
Index: mmotm-2.6.31-Sep28/include/linux/sched.h
===================================================================
--- mmotm-2.6.31-Sep28.orig/include/linux/sched.h
+++ mmotm-2.6.31-Sep28/include/linux/sched.h
@@ -1549,6 +1549,14 @@ struct task_struct {
 	unsigned long trace_recursion;
 #endif /* CONFIG_TRACING */
 	unsigned long stack_start;
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR /* memcg uses this to do batch job */
+	struct memcg_batch_info {
+		int do_batch;	/* incremented when batch uncharge started */
+		struct mem_cgroup *memcg; /* target memcg of uncharge */
+		unsigned long bytes; 		/* uncharged usage */
+		unsigned long memsw_bytes; /* uncharged mem+swap usage */
+	} memcg_batch;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
Index: mmotm-2.6.31-Sep28/mm/memory.c
===================================================================
--- mmotm-2.6.31-Sep28.orig/mm/memory.c
+++ mmotm-2.6.31-Sep28/mm/memory.c
@@ -940,6 +940,7 @@ static unsigned long unmap_page_range(st
 		details = NULL;
 
 	BUG_ON(addr >= end);
+	mem_cgroup_uncharge_start();
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -952,6 +953,7 @@ static unsigned long unmap_page_range(st
 						zap_work, details);
 	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
 	tlb_end_vma(tlb, vma);
+	mem_cgroup_uncharge_end();
 
 	return addr;
 }
Index: mmotm-2.6.31-Sep28/mm/truncate.c
===================================================================
--- mmotm-2.6.31-Sep28.orig/mm/truncate.c
+++ mmotm-2.6.31-Sep28/mm/truncate.c
@@ -272,6 +272,7 @@ void truncate_inode_pages_range(struct a
 			pagevec_release(&pvec);
 			break;
 		}
+		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -286,6 +287,7 @@ void truncate_inode_pages_range(struct a
 			unlock_page(page);
 		}
 		pagevec_release(&pvec);
+		mem_cgroup_uncharge_end();
 	}
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
@@ -327,6 +329,7 @@ unsigned long invalidate_mapping_pages(s
 	pagevec_init(&pvec, 0);
 	while (next <= end &&
 			pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 			pgoff_t index;
@@ -354,6 +357,7 @@ unsigned long invalidate_mapping_pages(s
 				break;
 		}
 		pagevec_release(&pvec);
+		mem_cgroup_uncharge_end();
 		cond_resched();
 	}
 	return ret;
@@ -428,6 +432,7 @@ int invalidate_inode_pages2_range(struct
 	while (next <= end && !wrapped &&
 		pagevec_lookup(&pvec, mapping, next,
 			min(end - next, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 			pgoff_t page_index;
@@ -477,6 +482,7 @@ int invalidate_inode_pages2_range(struct
 			unlock_page(page);
 		}
 		pagevec_release(&pvec);
+		mem_cgroup_uncharge_end();
 		cond_resched();
 	}
 	return ret;
Index: mmotm-2.6.31-Sep28/kernel/fork.c
===================================================================
--- mmotm-2.6.31-Sep28.orig/kernel/fork.c
+++ mmotm-2.6.31-Sep28/kernel/fork.c
@@ -1114,6 +1114,10 @@ static struct task_struct *copy_process(
 #ifdef CONFIG_DEBUG_MUTEXES
 	p->blocked_on = NULL; /* not blocked yet */
 #endif
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	p->memcg_batch.do_batch = 0;
+	p->memcg_batch.memcg = NULL;
+#endif
 
 	p->bts = NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
