Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id D23816B0192
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 06:21:02 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rq13so2003896pbb.6
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 03:21:02 -0800 (PST)
Received: from psmtp.com ([74.125.245.137])
        by mx.google.com with SMTP id q1si3539434pad.170.2013.11.08.03.20.58
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 03:21:00 -0800 (PST)
Date: Fri, 8 Nov 2013 11:20:54 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
Message-ID: <20131108112054.GB5040@suse.de>
References: <20131016155429.GP25735@sgi.com>
 <20131104145828.GA1218@suse.de>
 <20131104200346.GA3066@sgi.com>
 <20131106131048.GC4877@suse.de>
 <20131107214838.GY3066@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131107214838.GY3066@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 07, 2013 at 03:48:38PM -0600, Alex Thorlton wrote:
> > Try the following patch on top of 3.12. It's a patch that is expected to
> > be merged for 3.13. On its own it'll hurt automatic NUMA balancing in
> > -stable but corruption trumps performance and the full series is not
> > going to be considered acceptable for -stable
> 
> I gave this patch a shot, and it didn't seem to solve the problem.
> Actually I'm running into what appear to be *worse* problems on the 3.12
> kernel.  Here're a couple stack traces of what I get when I run the test
> on 3.12, 512 cores:
> 

Ok, so there are two issues at least. Whatever is causing your
corruption (which I still cannot reproduce) and the fact that 3.12 is
worse. The largest machine I've tested with is 40 cores. I'm trying to
get time on a 60 core machine to see if has a better chance. I will not
be able to get access to anything resembling 512 cores.

> (These are just two of the CPUs, obviously, but most of the memscale
> processes appeared to be in one of these two spots)
> 
> Nov  7 13:54:39 uvpsw1 kernel: NMI backtrace for cpu 6
> Nov  7 13:54:39 uvpsw1 kernel: CPU: 6 PID: 17759 Comm: thp_memscale Not tainted 3.12.0-rc7-medusa-00006-g0255d49 #381
> Nov  7 13:54:39 uvpsw1 kernel: Hardware name: Intel Corp. Stoutland Platform, BIOS 2.20 UEFI2.10 PI1.0 X64 2013-09-20
> Nov  7 13:54:39 uvpsw1 kernel: task: ffff8810647e0300 ti: ffff88106413e000 task.ti: ffff88106413e000
> Nov  7 13:54:39 uvpsw1 kernel: RIP: 0010:[<ffffffff8151c7d5>]  [<ffffffff8151c7d5>] _raw_spin_lock+0x1a/0x25
> Nov  7 13:54:39 uvpsw1 kernel: RSP: 0018:ffff88106413fd38  EFLAGS: 00000283
> Nov  7 13:54:39 uvpsw1 kernel: RAX: 00000000a1a9a0fe RBX: 0000000000000206 RCX: ffff880000000000
> Nov  7 13:54:41 uvpsw1 kernel: RDX: 000000000000a1a9 RSI: 00003ffffffff000 RDI: ffff8907ded35494
> Nov  7 13:54:41 uvpsw1 kernel: RBP: ffff88106413fd38 R08: 0000000000000006 R09: 0000000000000002
> Nov  7 13:54:41 uvpsw1 kernel: R10: 0000000000000007 R11: ffff88106413ff40 R12: ffff8907ded35494
> Nov  7 13:54:42 uvpsw1 kernel: R13: ffff88106413fe1c R14: ffff8810637a05f0 R15: 0000000000000206
> Nov  7 13:54:42 uvpsw1 kernel: FS:  00007fffd5def700(0000) GS:ffff88107d980000(0000) knlGS:0000000000000000
> Nov  7 13:54:42 uvpsw1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Nov  7 13:54:42 uvpsw1 kernel: CR2: 00007fffd5ded000 CR3: 00000107dfbcf000 CR4: 00000000000007e0
> Nov  7 13:54:42 uvpsw1 kernel: Stack:
> Nov  7 13:54:42 uvpsw1 kernel:  ffff88106413fda8 ffffffff810d670a 0000000000000002 0000000000000006
> Nov  7 13:54:42 uvpsw1 kernel:  00007fff57dde000 ffff8810640e1cc0 000002006413fe10 ffff8907ded35440
> Nov  7 13:54:45 uvpsw1 kernel:  ffff88106413fda8 0000000000000206 0000000000000002 0000000000000000
> Nov  7 13:54:45 uvpsw1 kernel: Call Trace:
> Nov  7 13:54:45 uvpsw1 kernel:  [<ffffffff810d670a>] follow_page_mask+0x123/0x3f1
> Nov  7 13:54:45 uvpsw1 kernel:  [<ffffffff810d7c4e>] __get_user_pages+0x3e3/0x488
> Nov  7 13:54:45 uvpsw1 kernel:  [<ffffffff810d7d90>] get_user_pages+0x4d/0x4f
> Nov  7 13:54:45 uvpsw1 kernel:  [<ffffffff810ec869>] SyS_get_mempolicy+0x1a9/0x3e0
> Nov  7 13:54:45 uvpsw1 kernel:  [<ffffffff8151d422>] system_call_fastpath+0x16/0x1b
> Nov  7 13:54:46 uvpsw1 kernel: Code: b1 17 39 c8 ba 01 00 00 00 74 02 31 d2 89 d0 c9 c3 55 48 89 e5 b8 00 00 01 00 f0 0f c1 07 89 c2 c1 ea 10 66 39 d0 74 0c 66 8b 07 <66> 39 d0 74 04 f3 90 eb f4 c9 c3 55 48 89 e5 9c 59 fa b8 00 00
> 

That is probably the mm->page_table_lock being contended on. Kirill has
patches that split this which will help the scalability when THP is
enabled. They should be merged for 3.13-rc1. In itself it should not
cause bugs other than maybe soft lockups.

> Nov  7 13:55:59 uvpsw1 kernel: NMI backtrace for cpu 8
> Nov  7 13:55:59 uvpsw1 kernel: INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 1.099 msecs
> Nov  7 13:56:04 uvpsw1 kernel: CPU: 8 PID: 17761 Comm: thp_memscale Not tainted 3.12.0-rc7-medusa-00006-g0255d49 #381
> Nov  7 13:56:04 uvpsw1 kernel: Hardware name: Intel Corp. Stoutland Platform, BIOS 2.20 UEFI2.10 PI1.0 X64 2013-09-20
> Nov  7 13:56:04 uvpsw1 kernel: task: ffff881063c56380 ti: ffff8810621b8000 task.ti: ffff8810621b8000
> Nov  7 13:56:04 uvpsw1 kernel: RIP: 0010:[<ffffffff8151c7d5>]  [<ffffffff8151c7d5>] _raw_spin_lock+0x1a/0x25
> Nov  7 13:56:04 uvpsw1 kernel: RSP: 0018:ffff8810621b9c98  EFLAGS: 00000283
> Nov  7 13:56:04 uvpsw1 kernel: RAX: 00000000a20aa0ff RBX: ffff8810621002b0 RCX: 8000000000000025
> Nov  7 13:56:04 uvpsw1 kernel: RDX: 000000000000a20a RSI: ffff8810621002b0 RDI: ffff8907ded35494
> Nov  7 13:56:04 uvpsw1 kernel: RBP: ffff8810621b9c98 R08: 0000000000000001 R09: 0000000000000001
> Nov  7 13:56:04 uvpsw1 kernel: R10: 000000000000000a R11: 0000000000000246 R12: ffff881062f726b8
> Nov  7 13:56:04 uvpsw1 kernel: R13: 0000000000000001 R14: ffff8810621002b0 R15: ffff881062f726b8
> Nov  7 13:56:09 uvpsw1 kernel: FS:  00007fff79512700(0000) GS:ffff88107da00000(0000) knlGS:0000000000000000
> Nov  7 13:56:09 uvpsw1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Nov  7 13:56:09 uvpsw1 kernel: CR2: 00007fff79510000 CR3: 00000107dfbcf000 CR4: 00000000000007e0
> Nov  7 13:56:09 uvpsw1 kernel: Stack:
> Nov  7 13:56:09 uvpsw1 kernel:  ffff8810621b9cb8 ffffffff810f3e57 8000000000000025 ffff881062f726b8
> Nov  7 13:56:09 uvpsw1 kernel:  ffff8810621b9ce8 ffffffff810f3edb 80000187dd73e166 00007fe2dae00000
> Nov  7 13:56:09 uvpsw1 kernel:  ffff881063708ff8 00007fe2db000000 ffff8810621b9dc8 ffffffff810def2c
> Nov  7 13:56:09 uvpsw1 kernel: Call Trace:
> Nov  7 13:56:09 uvpsw1 kernel:  [<ffffffff810f3e57>] __pmd_trans_huge_lock+0x1a/0x7c
> Nov  7 13:56:10 uvpsw1 kernel:  [<ffffffff810f3edb>] change_huge_pmd+0x22/0xcc
> Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810def2c>] change_protection+0x200/0x591
> Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810ecb07>] change_prot_numa+0x16/0x2c
> Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff8106c247>] task_numa_work+0x224/0x29a
> Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810551b1>] task_work_run+0x81/0x99
> Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810025e1>] do_notify_resume+0x539/0x54b
> Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810c3ce9>] ? put_page+0x10/0x24
> Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810ec9fa>] ? SyS_get_mempolicy+0x33a/0x3e0
> Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff8151d6aa>] int_signal+0x12/0x17
> Nov  7 13:56:14 uvpsw1 kernel: Code: b1 17 39 c8 ba 01 00 00 00 74 02 31 d2 89 d0 c9 c3 55 48 89 e5 b8 00 00 01 00 f0 0f c1 07 89 c2 c1 ea 10 66 39 d0 74 0c 66 8b 07 <66> 39 d0 74 04 f3 90 eb f4 c9 c3 55 48 89 e5 9c 59 fa b8 00 00
> 

And this is indicating that NUMA balancing is making contention on that lock
much worse. I would have expected it to run slower, but not cause corruption.

There is no indication from these partial logs what the crash might be
due to unfortunately. Is your machine configured to do anyhting like
panic on soft lockups? By any chance have you booted this machines to
use 1G pages by default for hugetlbfs?

> I managed to bisect the issue down to this commit:
> 
> 0255d491848032f6c601b6410c3b8ebded3a37b1 is the first bad commit
> commit 0255d491848032f6c601b6410c3b8ebded3a37b1
> Author: Mel Gorman <mgorman@suse.de>
> Date:   Mon Oct 7 11:28:47 2013 +0100
> 
>     mm: Account for a THP NUMA hinting update as one PTE update
> 
>     A THP PMD update is accounted for as 512 pages updated in vmstat.  This is
>     large difference when estimating the cost of automatic NUMA balancing and
>     can be misleading when comparing results that had collapsed versus split
>     THP. This patch addresses the accounting issue.
> 
>     Signed-off-by: Mel Gorman <mgorman@suse.de>
>     Reviewed-by: Rik van Riel <riel@redhat.com>
>     Cc: Andrea Arcangeli <aarcange@redhat.com>
>     Cc: Johannes Weiner <hannes@cmpxchg.org>
>     Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
>     Cc: <stable@kernel.org>
>     Signed-off-by: Peter Zijlstra <peterz@infradead.org>
>     Link: http://lkml.kernel.org/r/1381141781-10992-10-git-send-email-mgorman@suse.de
>     Signed-off-by: Ingo Molnar <mingo@kernel.org>
> 
> :040000 040000 e5a44a1f0eea2f41d2cccbdf07eafee4e171b1e2 ef030a7c78ef346095ac991c3e3aa139498ed8e7 M      mm
> 
> I haven't had a chance yet to dig into the code for this commit to see
> what might be causing the crashes, but I have confirmed that this is
> where the new problem started (checked the commit before this, and we
> don't get the crash, just segfaults like we were getting before). 

One consequence of this patch that it adjusts the speed that task_numa_work
scans the virtual address space. This was an oversight that needs to be
corrected. Can you test if the following patch on top of 3.12 brings you
back to "just" segfaulting? It is compile-tested only because my own tests
will not even be able to start with this patch for another 3-4 hours.

---8<---
mm: numa: Return the number of base pages altered by protection changes

Commit 0255d491 (mm: Account for a THP NUMA hinting update as one PTE
update) was added to account for the number of PTE updates when marking
pages prot_numa. task_numa_work was using the old return value to track
how much address space had been updated. Altering the return value causes
the scanner to do more work than it is configured to in a single pass.
The temptation is just to revert 0255d491 but that means the vmstat value
is once again impossible to interpret. This patch restores change_protection
to returning the number of pages updated but it will also return how many
base PTEs were skipped because THP pages were encounted. The impact of this
patch is that the NUMA PTE scanner will scan more slowly when THP is enabled.

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 3935428..3b510c4 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -32,7 +32,7 @@ extern int move_huge_pmd(struct vm_area_struct *vma,
 			 pmd_t *old_pmd, pmd_t *new_pmd);
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
-			int prot_numa);
+			bool prot_numa);
 
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8b6e55e..a1cc4bf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1088,7 +1088,8 @@ extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		bool need_rmap_locks);
 extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 			      unsigned long end, pgprot_t newprot,
-			      int dirty_accountable, int prot_numa);
+			      int dirty_accountable,
+			      int *prot_numa_pte_skipped);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
 			  unsigned long end, unsigned long newflags);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cca80d9..e554318 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1459,7 +1459,7 @@ out:
 }
 
 int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long addr, pgprot_t newprot, int prot_numa)
+		unsigned long addr, pgprot_t newprot, bool prot_numa)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int ret = 0;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0472964..7b27125 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -626,11 +626,14 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 			unsigned long addr, unsigned long end)
 {
 	int nr_updated;
+	int nr_pte_skipped = 0;
 	BUILD_BUG_ON(_PAGE_NUMA != _PAGE_PROTNONE);
 
-	nr_updated = change_protection(vma, addr, end, vma->vm_page_prot, 0, 1);
+	nr_updated = change_protection(vma, addr, end, vma->vm_page_prot,
+			0, &nr_pte_skipped);
 	if (nr_updated)
-		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
+		count_vm_numa_events(NUMA_PTE_UPDATES,
+					nr_updated - nr_pte_skipped);
 
 	return nr_updated;
 }
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 412ba2b..f74b848 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -133,12 +133,14 @@ static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
 
 static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		pud_t *pud, unsigned long addr, unsigned long end,
-		pgprot_t newprot, int dirty_accountable, int prot_numa)
+		pgprot_t newprot, int dirty_accountable,
+		int *prot_numa_pte_skipped)
 {
 	pmd_t *pmd;
 	unsigned long next;
 	unsigned long pages = 0;
 	bool all_same_node;
+	bool prot_numa = (prot_numa_pte_skipped != NULL);
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -148,7 +150,9 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 				split_huge_page_pmd(vma, addr, pmd);
 			else if (change_huge_pmd(vma, pmd, addr, newprot,
 						 prot_numa)) {
-				pages++;
+				pages += HPAGE_PMD_NR;
+				if (prot_numa_pte_skipped)
+					(*prot_numa_pte_skipped) += (HPAGE_PMD_NR - 1);
 				continue;
 			}
 			/* fall through */
@@ -173,7 +177,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 
 static inline unsigned long change_pud_range(struct vm_area_struct *vma,
 		pgd_t *pgd, unsigned long addr, unsigned long end,
-		pgprot_t newprot, int dirty_accountable, int prot_numa)
+		pgprot_t newprot, int dirty_accountable,
+		int *prot_numa_pte_skipped)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -185,7 +190,7 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma,
 		if (pud_none_or_clear_bad(pud))
 			continue;
 		pages += change_pmd_range(vma, pud, addr, next, newprot,
-				 dirty_accountable, prot_numa);
+				 dirty_accountable, prot_numa_pte_skipped);
 	} while (pud++, addr = next, addr != end);
 
 	return pages;
@@ -193,7 +198,7 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma,
 
 static unsigned long change_protection_range(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
-		int dirty_accountable, int prot_numa)
+		int dirty_accountable, int *prot_numa_pte_skipped)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
@@ -209,7 +214,7 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
 		pages += change_pud_range(vma, pgd, addr, next, newprot,
-				 dirty_accountable, prot_numa);
+				 dirty_accountable, prot_numa_pte_skipped);
 	} while (pgd++, addr = next, addr != end);
 
 	/* Only flush the TLB if we actually modified any entries: */
@@ -219,9 +224,15 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 	return pages;
 }
 
+/*
+ * Returns the number of base pages affected by the protection change. Huge
+ * pages are accounted as pages << huge_order. The number of THP pages updated
+ * is returned (prot_numa_pte_skipped) for NUMA hinting faults updates to
+ * account for the number of PTEs updated in vmstat.
+ */
 unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 		       unsigned long end, pgprot_t newprot,
-		       int dirty_accountable, int prot_numa)
+		       int dirty_accountable, int *prot_numa_pte_skipped)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long pages;
@@ -230,7 +241,8 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 	if (is_vm_hugetlb_page(vma))
 		pages = hugetlb_change_protection(vma, start, end, newprot);
 	else
-		pages = change_protection_range(vma, start, end, newprot, dirty_accountable, prot_numa);
+		pages = change_protection_range(vma, start, end, newprot,
+				dirty_accountable, prot_numa_pte_skipped);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 
 	return pages;
@@ -309,7 +321,7 @@ success:
 	}
 
 	change_protection(vma, start, end, vma->vm_page_prot,
-			  dirty_accountable, 0);
+			  dirty_accountable, NULL);
 
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
