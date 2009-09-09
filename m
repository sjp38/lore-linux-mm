Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D8B906B0082
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 04:46:02 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n898k5AE030040
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Sep 2009 17:46:06 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DB98D45DE62
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:46:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A705445DE51
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:46:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 842961DB803F
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:46:04 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C1751DB803C
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:46:03 +0900 (JST)
Date: Wed, 9 Sep 2009 17:44:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/4][mmotm] memcg: batched uncharge
Message-Id: <20090909174407.abc0b45d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


In massive parallel enviroment, res_counter can be a performance bottleneck.
This patch is a trial for reducing lock contention.
One strong techinque to reduce lock contention is reducing calls by
batching some amount of calls int one.

Considering charge/uncharge chatacteristic,
	- charge is done one by one via demand-paging.
	- uncharge is done by
		- in chunk at munmap, truncate, exit, execve...
		- one by one via vmscan/paging.

It seems we hace a chance to batched-uncharge.
This patch is a base patch for batched uncharge. For avoiding
scattering memcg's structure, this patch adds memcg batch uncharge
information to the task. please see start/end usage in next patch.

The degree of coalescing depends on callers
  - at invalidate/trucate... pagevec size
  - at unmap ....ZAP_BLOCK_SIZE
(memory itself will be freed in this degree.)

Changelog: v3
 - fixed invaldiate_inode_pages2() path. for this, do_batch is
   not 'int', not 'bool'

Changelog: v2
 - unified patch for callers
 - added commetns.
 - make ->do_batch as bool.
 - removed css_get() at el. We don't need it.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |   13 ++++++
 include/linux/sched.h      |    7 +++
 mm/memcontrol.c            |   89 +++++++++++++++++++++++++++++++++++++++++----
 mm/memory.c                |    2 +
 mm/truncate.c              |    6 +++
 5 files changed, 111 insertions(+), 6 deletions(-)

Index: mmotm-2.6.31-Sep3/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.31-Sep3.orig/include/linux/memcontrol.h
+++ mmotm-2.6.31-Sep3/include/linux/memcontrol.h
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
 
+static inline void mem_cgroup_uncharge_batch_start(void)
+{
+}
+
+static inline void mem_cgroup_uncharge_batch_start(void)
+{
+}
+
 static inline void mem_cgroup_uncharge_page(struct page *page)
 {
 }
Index: mmotm-2.6.31-Sep3/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep3.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep3/mm/memcontrol.c
@@ -1825,6 +1825,49 @@ void mem_cgroup_cancel_charge_swapin(str
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
+	 * And, we do uncharge one by one if this is killed by OOM.
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
+	batch->pages += PAGE_SIZE;
+	if (uncharge_memsw)
+		batch->memsw += PAGE_SIZE;
+	return;
+direct_uncharge:
+	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	if (uncharge_memsw)
+		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+	return;
+}
 
 /*
  * uncharge if !page_mapped(page)
@@ -1873,12 +1916,8 @@ __mem_cgroup_uncharge_common(struct page
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
@@ -1924,6 +1963,46 @@ void mem_cgroup_uncharge_cache_page(stru
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
 }
 
+/*
+ * batch_start/batch_end is called in unmap_page_range/invlidate/trucate.
+ * In that cases, pages are freed continuously and we can expect pages
+ * are in the same memcg. All these calls itself limits the number of
+ * pages freed at once, then uncharge_start/end() is called properly.
+ */
+
+void mem_cgroup_uncharge_start(void)
+{
+	if (!current->memcg_batch.do_batch) {
+		current->memcg_batch.memcg = NULL;
+		current->memcg_batch.pages = 0;
+		current->memcg_batch.memsw = 0;
+	}
+	current->memcg_batch.do_batch++;
+}
+
+void mem_cgroup_uncharge_end(void)
+{
+	struct mem_cgroup *mem;
+
+	if (!current->memcg_batch.do_batch)
+		return;
+
+	current->memcg_batch.do_batch--;
+	if (current->memcg_batch.do_batch) /* Nested ? */
+		return;
+
+	mem = current->memcg_batch.memcg;
+	if (!mem)
+		return;
+	/* This "mem" is valid bacause we hide charges behind us. */
+	if (current->memcg_batch.pages)
+		res_counter_uncharge(&mem->res, current->memcg_batch.pages);
+	if (current->memcg_batch.memsw)
+		res_counter_uncharge(&mem->memsw, current->memcg_batch.memsw);
+	/* Not necessary. but forget this pointer */
+	current->memcg_batch.memcg = NULL;
+}
+
 #ifdef CONFIG_SWAP
 /*
  * called after __delete_from_swap_cache() and drop "page" account.
Index: mmotm-2.6.31-Sep3/include/linux/sched.h
===================================================================
--- mmotm-2.6.31-Sep3.orig/include/linux/sched.h
+++ mmotm-2.6.31-Sep3/include/linux/sched.h
@@ -1548,6 +1548,13 @@ struct task_struct {
 	unsigned long trace_recursion;
 #endif /* CONFIG_TRACING */
 	unsigned long stack_start;
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR /* memcg uses this to do batch job */
+	struct memcg_batch_info {
+		int do_batch;
+		struct mem_cgroup *memcg;
+		long pages, memsw;
+	} memcg_batch;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
Index: mmotm-2.6.31-Sep3/mm/memory.c
===================================================================
--- mmotm-2.6.31-Sep3.orig/mm/memory.c
+++ mmotm-2.6.31-Sep3/mm/memory.c
@@ -922,6 +922,7 @@ static unsigned long unmap_page_range(st
 		details = NULL;
 
 	BUG_ON(addr >= end);
+	mem_cgroup_uncharge_start();
 	tlb_start_vma(tlb, vma);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
@@ -934,6 +935,7 @@ static unsigned long unmap_page_range(st
 						zap_work, details);
 	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
 	tlb_end_vma(tlb, vma);
+	mem_cgroup_uncharge_end();
 
 	return addr;
 }
Index: mmotm-2.6.31-Sep3/mm/truncate.c
===================================================================
--- mmotm-2.6.31-Sep3.orig/mm/truncate.c
+++ mmotm-2.6.31-Sep3/mm/truncate.c
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
