Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 8A4B36B0092
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:57:16 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 04/39] autonuma: x86 pte_numa() and pmd_numa()
Date: Mon, 26 Mar 2012 19:45:51 +0200
Message-Id: <1332783986-24195-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Implement pte_numa and pmd_numa and related methods on x86 arch.

We must atomically set the numa bit and clear the present bit to
define a pte_numa or pmd_numa.

Whenever a pte or pmd is set as pte_numa or pmd_numa the first time a
thread will touch that virtual address, a NUMA hinting page fault will
trigger. The NUMA hinting page fault will simply clear the NUMA bit
and set the present bit again to resolve the page fault.

NUMA hinting page faults are used:

1) to fill in the per-thread NUMA statistic stored for each thread in
   a current->sched_autonuma data structure

2) to track the per-node last_nid information in the page structure to
   detect false sharing

3) to queue the page mapped by the pte_numa or pmd_numa for async
   migration if there have been enough NUMA hinting page faults on the
   page coming from remote CPUs

NUMA hinting page faults don't do anything except collecting
information and possibly adding pages to migrate queues. They're
extremely quick and absolutely non blocking. They don't allocate any
memory either.

The only "input" information of the AutoNUMA algorithm that isn't
collected through NUMA hinting page faults are the per-process
(per-thread not) mm->mm_autonuma statistics. Those mm_autonuma
statistics are collected by the knuma_scand pmd/pte scans that are
also responsible for setting the pte_numa/pmd_numa to activate the
NUMA hinting page faults.

knuma_scand -> NUMA hinting page faults
  |                       |
 \|/                     \|/
mm_autonuma  <->  sched_autonuma (CPU follow memory, this is mm_autonuma too)
                  page last_nid  (false thread sharing/thread shared memory detection )
                  queue or cancel page migration (memory follow CPU)

After pages are queued, there is one knuma_migratedN daemon per NUMA
node that will take care of migrating the pages at a perfectly steady
rate in parallel from all nodes, and in round robin from all incoming
nodes going to the same destination node to keep all memory channels
in large boxes active at the same time to avoid hitting on a single
memory channel for too long to minimize memory bus migration latency
effects.

Once pages are queued for async migration by knuma_migratedN, their
migration can still be canceled before they're actually migrated, if
false sharing is later detected.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/x86/include/asm/pgtable.h |   51 +++++++++++++++++++++++++++++++++++++--
 1 files changed, 48 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 49afb3f..7514fa6 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -109,7 +109,7 @@ static inline int pte_write(pte_t pte)
 
 static inline int pte_file(pte_t pte)
 {
-	return pte_flags(pte) & _PAGE_FILE;
+	return (pte_flags(pte) & _PAGE_FILE) == _PAGE_FILE;
 }
 
 static inline int pte_huge(pte_t pte)
@@ -405,7 +405,9 @@ static inline int pte_same(pte_t a, pte_t b)
 
 static inline int pte_present(pte_t a)
 {
-	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
+	/* _PAGE_NUMA includes _PAGE_PROTNONE */
+	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE |
+			       _PAGE_NUMA_PTE);
 }
 
 static inline int pte_hidden(pte_t pte)
@@ -415,7 +417,46 @@ static inline int pte_hidden(pte_t pte)
 
 static inline int pmd_present(pmd_t pmd)
 {
-	return pmd_flags(pmd) & _PAGE_PRESENT;
+	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE |
+				 _PAGE_NUMA_PMD);
+}
+
+#ifdef CONFIG_AUTONUMA
+static inline int pte_numa(pte_t pte)
+{
+	return (pte_flags(pte) &
+		(_PAGE_NUMA_PTE|_PAGE_PRESENT)) == _PAGE_NUMA_PTE;
+}
+
+static inline int pmd_numa(pmd_t pmd)
+{
+	return (pmd_flags(pmd) &
+		(_PAGE_NUMA_PMD|_PAGE_PRESENT)) == _PAGE_NUMA_PMD;
+}
+#endif
+
+static inline pte_t pte_mknotnuma(pte_t pte)
+{
+	pte = pte_clear_flags(pte, _PAGE_NUMA_PTE);
+	return pte_set_flags(pte, _PAGE_PRESENT|_PAGE_ACCESSED);
+}
+
+static inline pmd_t pmd_mknotnuma(pmd_t pmd)
+{
+	pmd = pmd_clear_flags(pmd, _PAGE_NUMA_PMD);
+	return pmd_set_flags(pmd, _PAGE_PRESENT|_PAGE_ACCESSED);
+}
+
+static inline pte_t pte_mknuma(pte_t pte)
+{
+	pte = pte_set_flags(pte, _PAGE_NUMA_PTE);
+	return pte_clear_flags(pte, _PAGE_PRESENT);
+}
+
+static inline pmd_t pmd_mknuma(pmd_t pmd)
+{
+	pmd = pmd_set_flags(pmd, _PAGE_NUMA_PMD);
+	return pmd_clear_flags(pmd, _PAGE_PRESENT);
 }
 
 static inline int pmd_none(pmd_t pmd)
@@ -474,6 +515,10 @@ static inline pte_t *pte_offset_kernel(pmd_t *pmd, unsigned long address)
 
 static inline int pmd_bad(pmd_t pmd)
 {
+#ifdef CONFIG_AUTONUMA
+	if (pmd_numa(pmd))
+		return 0;
+#endif
 	return (pmd_flags(pmd) & ~_PAGE_USER) != _KERNPG_TABLE;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
