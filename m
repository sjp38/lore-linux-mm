Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 1072F6B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 12:50:39 -0400 (EDT)
Date: Fri, 2 Aug 2013 18:50:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH] mm, numa: Do not group on RO pages
Message-ID: <20130802165032.GQ27162@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130730113857.GR3008@twins.programming.kicks-ass.net>
 <20130731150751.GA15144@twins.programming.kicks-ass.net>
 <51F93105.8020503@hp.com>
 <20130802164715.GP27162@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130802164715.GP27162@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Don Morris <don.morris@hp.com>
Cc: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, riel@redhat.com


Subject: mm, numa: Do not group on RO pages
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri Aug 2 18:38:34 CEST 2013

And here's a little something to make sure not the whole world ends up
in a single group.

As while we don't migrate shared executable pages, we do scan/fault on
them. And since everybody links to libc, everybody ends up in the same
group.

Sugested-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 include/linux/sched.h |    7 +++++--
 kernel/sched/fair.c   |    5 +++--
 mm/huge_memory.c      |   15 +++++++++++++--
 mm/memory.c           |   31 ++++++++++++++++++++++++++-----
 4 files changed, 47 insertions(+), 11 deletions(-)

--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1438,12 +1438,15 @@ struct task_struct {
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
+#define TNF_MIGRATED	0x01
+#define TNF_NO_GROUP	0x02
+
 #ifdef CONFIG_NUMA_BALANCING
-extern void task_numa_fault(int last_node, int node, int pages, bool migrated);
+extern void task_numa_fault(int last_node, int node, int pages, int flags);
 extern void set_numabalancing_state(bool enabled);
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
-				   bool migrated)
+				   int flags)
 {
 }
 static inline void set_numabalancing_state(bool enabled)
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1371,9 +1371,10 @@ void task_numa_free(struct task_struct *
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int last_cpupid, int node, int pages, bool migrated)
+void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 {
 	struct task_struct *p = current;
+	bool migrated = flags & TNF_MIGRATED;
 	int priv;
 
 	if (!numabalancing_enabled)
@@ -1409,7 +1410,7 @@ void task_numa_fault(int last_cpupid, in
 		pid = cpupid_to_pid(last_cpupid);
 
 		priv = (pid == (p->pid & LAST__PID_MASK));
-		if (!priv)
+		if (!priv && !(flags & TNF_NO_GROUP))
 			task_numa_group(p, cpu, pid);
 	}
 
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1295,6 +1295,7 @@ int do_huge_pmd_numa_page(struct mm_stru
 	int page_nid = -1, account_nid = -1, this_nid = numa_node_id();
 	int target_nid, last_cpupid;
 	bool migrated = false;
+	int flags = 0;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
@@ -1333,6 +1334,15 @@ int do_huge_pmd_numa_page(struct mm_stru
 		account_nid = page_nid = -1; /* someone else took our fault */
 		goto out_unlock;
 	}
+
+	/*
+	 * Avoid grouping on DSO/COW pages in specific and RO pages
+	 * in general, RO pages shouldn't hurt as much anyway since
+	 * they can be in shared cache state.
+	 */
+	if (page_mapcount(page) != 1 && !pmd_write(pmd))
+		flags |= TNF_NO_GROUP;
+
 	spin_unlock(&mm->page_table_lock);
 
 	/* Migrate the THP to the requested node */
@@ -1341,7 +1351,8 @@ int do_huge_pmd_numa_page(struct mm_stru
 	if (!migrated) {
 		account_nid = -1; /* account against the old page */
 		goto check_same;
-	}
+	} else
+		flags |= TNF_MIGRATED;
 
 	page_nid = target_nid;
 	goto out;
@@ -1364,7 +1375,7 @@ int do_huge_pmd_numa_page(struct mm_stru
 	if (account_nid == -1)
 		account_nid = page_nid;
 	if (account_nid != -1)
-		task_numa_fault(last_cpupid, account_nid, HPAGE_PMD_NR, migrated);
+		task_numa_fault(last_cpupid, account_nid, HPAGE_PMD_NR, flags);
 
 	return 0;
 }
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3537,6 +3537,7 @@ int do_numa_page(struct mm_struct *mm, s
 	int page_nid = -1, account_nid = -1;
 	int target_nid, last_cpupid;
 	bool migrated = false;
+	int flags = 0;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3569,6 +3570,14 @@ int do_numa_page(struct mm_struct *mm, s
 		return 0;
 	}
 
+	/*
+	 * Avoid grouping on DSO/COW pages in specific and RO pages
+	 * in general, RO pages shouldn't hurt as much anyway since
+	 * they can be in shared cache state.
+	 */
+	if (page_mapcount(page) != 1 && !pte_write(pte))
+		flags |= TNF_NO_GROUP;
+
 	last_cpupid = page_cpupid_last(page);
 	page_nid = page_to_nid(page);
 	target_nid = numa_migrate_prep(page, vma, addr, page_nid, &account_nid);
@@ -3580,14 +3589,16 @@ int do_numa_page(struct mm_struct *mm, s
 
 	/* Migrate to the requested node */
 	migrated = migrate_misplaced_page(page, vma, target_nid);
-	if (migrated)
+	if (migrated) {
 		page_nid = target_nid;
+		flags |= TNF_MIGRATED;
+	}
 
 out:
 	if (account_nid == -1)
 		account_nid = page_nid;
 	if (account_nid != -1)
-		task_numa_fault(last_cpupid, account_nid, 1, migrated);
+		task_numa_fault(last_cpupid, account_nid, 1, flags);
 
 	return 0;
 }
@@ -3632,6 +3643,7 @@ static int do_pmd_numa_page(struct mm_st
 		int page_nid = -1, account_nid = -1;
 		int target_nid;
 		bool migrated = false;
+		int flags = 0;
 
 		if (!pte_present(pteval))
 			continue;
@@ -3651,6 +3663,14 @@ static int do_pmd_numa_page(struct mm_st
 		if (unlikely(!page))
 			continue;
 
+		/*
+		 * Avoid grouping on DSO/COW pages in specific and RO pages
+		 * in general, RO pages shouldn't hurt as much anyway since
+		 * they can be in shared cache state.
+		 */
+		if (page_mapcount(page) != 1 && !pte_write(pteval))
+			flags |= TNF_NO_GROUP;
+
 		last_cpupid = page_cpupid_last(page);
 		page_nid = page_to_nid(page);
 		target_nid = numa_migrate_prep(page, vma, addr,
@@ -3659,9 +3679,10 @@ static int do_pmd_numa_page(struct mm_st
 
 		if (target_nid != -1) {
 			migrated = migrate_misplaced_page(page, vma, target_nid);
-			if (migrated)
+			if (migrated) {
 				page_nid = target_nid;
-			else
+				flags |= TNF_MIGRATED;
+			} else
 				account_nid = -1;
 		} else {
 			put_page(page);
@@ -3670,7 +3691,7 @@ static int do_pmd_numa_page(struct mm_st
 		if (account_nid == -1)
 			account_nid = page_nid;
 		if (account_nid != -1)
-			task_numa_fault(last_cpupid, account_nid, 1, migrated);
+			task_numa_fault(last_cpupid, account_nid, 1, flags);
 
 		cond_resched();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
