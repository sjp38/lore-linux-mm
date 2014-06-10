Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4357B6B00D3
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 00:21:56 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so249932pab.1
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 21:21:55 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id lk6si1402987pab.166.2014.06.09.21.21.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 21:21:55 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so5667334pdi.13
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 21:21:54 -0700 (PDT)
Date: Mon, 9 Jun 2014 21:20:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: NULL ptr deref in remove_migration_pte
In-Reply-To: <538498A1.7010305@oracle.com>
Message-ID: <alpine.LSU.2.11.1406092104330.12382@eggly.anvils>
References: <534E9ACA.2090008@oracle.com> <5367B365.1070709@oracle.com> <537FE9F3.40508@oracle.com> <alpine.LSU.2.11.1405261255530.3649@eggly.anvils> <538498A1.7010305@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Bob Liu <bob.liu@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Tue, 27 May 2014, Sasha Levin wrote:
> On 05/26/2014 04:05 PM, Hugh Dickins wrote:
> > On Fri, 23 May 2014, Sasha Levin wrote:
> > 
> >> Ping?
> >>
> >> On 05/05/2014 11:51 AM, Sasha Levin wrote:
> >>> Did anyone have a chance to look at it? I still see it in -next.
> >>>
> >>>
> >>> Thanks,
> >>> Sasha
> >>>
> >>> On 04/16/2014 10:59 AM, Sasha Levin wrote:
> >>>> Hi all,
> >>>>
> >>>> While fuzzing with trinity inside a KVM tools guest running latest -next
> >>>> kernel I've stumbled on the following:
> >>>>
> >>>> [ 2552.313602] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
> >>>> [ 2552.315878] IP: __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
> >>>> [ 2552.315878] PGD 465836067 PUD 465837067 PMD 0
> >>>> [ 2552.315878] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> >>>> [ 2552.315878] Dumping ftrace buffer:
> >>>> [ 2552.315878]    (ftrace buffer empty)
> >>>> [ 2552.315878] Modules linked in:
> >>>> [ 2552.315878] CPU: 6 PID: 16173 Comm: trinity-c364 Tainted: G        W     3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
> >>>> [ 2552.315878] task: ffff88046548b000 ti: ffff88044e532000 task.ti: ffff88044e532000
> >>>> [ 2552.320286] RIP: __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
> >>>> [ 2552.320286] RSP: 0018:ffff88044e5339c8  EFLAGS: 00010002
> >>>> [ 2552.320286] RAX: 0000000000000082 RBX: ffff88046548b000 RCX: 0000000000000000
> >>>> [ 2552.320286] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000018
> >>>> [ 2552.320286] RBP: ffff88044e533ab8 R08: 0000000000000001 R09: 0000000000000000
> >>>> [ 2552.320286] R10: ffff88046548b000 R11: 0000000000000001 R12: 0000000000000000
> >>>> [ 2552.320286] R13: 0000000000000018 R14: 0000000000000000 R15: 0000000000000000
> >>>> [ 2552.320286] FS:  00007fd286a9a700(0000) GS:ffff88018b000000(0000) knlGS:0000000000000000
> >>>> [ 2552.320286] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> >>>> [ 2552.320286] CR2: 0000000000000018 CR3: 0000000442c17000 CR4: 00000000000006a0
> >>>> [ 2552.320286] DR0: 0000000000695000 DR1: 0000000000000000 DR2: 0000000000000000
> >>>> [ 2552.320286] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> >>>> [ 2552.320286] Stack:
> >>>> [ 2552.320286]  ffff88044e5339e8 ffffffff9f56e761 0000000000000000 ffff880315c13000
> >>>> [ 2552.320286]  ffff88044e533a38 ffffffff9c193f0d ffffffff9c193e34 ffff8804654e8000
> >>>> [ 2552.320286]  ffff8804654e8000 0000000000000001 ffff88046548b000 0000000000000007
> >>>> [ 2552.320286] Call Trace:
> >>>> [ 2552.320286] ? _raw_spin_unlock_irq (arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:169 kernel/locking/spinlock.c:199)
> >>>> [ 2552.320286] ? finish_task_switch (include/linux/tick.h:206 kernel/sched/core.c:2163)
> >>>> [ 2552.320286] ? finish_task_switch (arch/x86/include/asm/current.h:14 kernel/sched/sched.h:993 kernel/sched/core.c:2145)
> >>>> [ 2552.320286] ? retint_restore_args (arch/x86/kernel/entry_64.S:1040)
> >>>> [ 2552.320286] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> >>>> [ 2552.320286] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/lockdep.c:2599)
> >>>> [ 2552.320286] lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
> >>>> [ 2552.320286] ? remove_migration_pte (mm/migrate.c:137)
> >>>> [ 2552.320286] ? retint_restore_args (arch/x86/kernel/entry_64.S:1040)
> >>>> [ 2552.320286] _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
> >>>> [ 2552.320286] ? remove_migration_pte (mm/migrate.c:137)
> >>>> [ 2552.320286] remove_migration_pte (mm/migrate.c:137)
> >>>> [ 2552.320286] rmap_walk (mm/rmap.c:1628 mm/rmap.c:1699)
> >>>> [ 2552.320286] remove_migration_ptes (mm/migrate.c:224)
> >>>> [ 2552.320286] ? new_page_node (mm/migrate.c:107)
> >>>> [ 2552.320286] ? remove_migration_pte (mm/migrate.c:195)
> >>>> [ 2552.320286] migrate_pages (mm/migrate.c:922 mm/migrate.c:960 mm/migrate.c:1126)
> >>>> [ 2552.320286] ? perf_trace_mm_numa_migrate_ratelimit (mm/migrate.c:1574)
> >>>> [ 2552.320286] migrate_misplaced_page (mm/migrate.c:1733)
> >>>> [ 2552.320286] __handle_mm_fault (mm/memory.c:3762 mm/memory.c:3812 mm/memory.c:3925)
> >>>> [ 2552.320286] ? __const_udelay (arch/x86/lib/delay.c:126)
> >>>> [ 2552.320286] ? __rcu_read_unlock (kernel/rcu/update.c:97)
> >>>> [ 2552.320286] handle_mm_fault (mm/memory.c:3948)
> >>>> [ 2552.320286] __get_user_pages (mm/memory.c:1851)
> >>>> [ 2552.320286] ? preempt_count_sub (kernel/sched/core.c:2527)
> >>>> [ 2552.320286] __mlock_vma_pages_range (mm/mlock.c:255)
> >>>> [ 2552.320286] __mm_populate (mm/mlock.c:711)
> >>>> [ 2552.320286] SyS_mlockall (include/linux/mm.h:1799 mm/mlock.c:817 mm/mlock.c:791)
> >>>> [ 2552.320286] tracesys (arch/x86/kernel/entry_64.S:749)
> >>>> [ 2552.320286] Code: 85 2d 1e 00 00 48 c7 c1 d7 68 6c a0 48 c7 c2 47 11 6c a0 31 c0 be fa 0b 00 00 48 c7 c7 91 68 6c a0 e8 1c 6d f9 ff e9 07 1e 00 00 <49> 81 7d 00 80 31 76 a2 b8 00 00 00 00 44 0f 44 c0 eb 07 0f 1f
> >>>> [ 2552.320286] RIP __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
> >>>> [ 2552.320286]  RSP <ffff88044e5339c8>
> >>>> [ 2552.320286] CR2: 0000000000000018
> > 
> > Sasha, please clarify your Ping: I've seen you say in other mail
> > "I had to disable transhuge/hugetlb in my testing .config".
> > 
> > Do you see this remove_migration_pte oops even with THP disabled?
> > 
> > Do you see the filemap.c:202 BUG_ON(page_mapped(page))
> > even with THP disabled?
> 
> The mail that you mentioned prompted me to go back and re-enable THP and
> see what still breaks, which would explain why I pinged this thread again (I
> only do that once I see that problem still occurs).
> 
> However, I can't confirm if these problems happen without THP as I didn't
> think they were related. I'll disable THP again and give it a go.

Although there's nothing in the backtrace to implicate it,
I think this crash is caused by THP: please try this patch - thanks.

[PATCH] mm: let mm_find_pmd fix buggy race with THP fault

Trinity has reported:
BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
IP: __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
CPU: 6 PID: 16173 Comm: trinity-c364 Tainted: G        W
                        3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
lock_acquire (arch/x86/include/asm/current.h:14
              kernel/locking/lockdep.c:3602)
_raw_spin_lock (include/linux/spinlock_api_smp.h:143
                kernel/locking/spinlock.c:151)
remove_migration_pte (mm/migrate.c:137)
rmap_walk (mm/rmap.c:1628 mm/rmap.c:1699)
remove_migration_ptes (mm/migrate.c:224)
migrate_pages (mm/migrate.c:922 mm/migrate.c:960 mm/migrate.c:1126)
migrate_misplaced_page (mm/migrate.c:1733)
__handle_mm_fault (mm/memory.c:3762 mm/memory.c:3812 mm/memory.c:3925)
handle_mm_fault (mm/memory.c:3948)
__get_user_pages (mm/memory.c:1851)
__mlock_vma_pages_range (mm/mlock.c:255)
__mm_populate (mm/mlock.c:711)
SyS_mlockall (include/linux/mm.h:1799 mm/mlock.c:817 mm/mlock.c:791)

I believe this comes about because, whereas collapsing and splitting
THP functions take anon_vma lock in write mode (which excludes
concurrent rmap walks), faulting THP functions (write protection and
misplaced NUMA) do not - and mostly they do not need to.

But they do use a pmdp_clear_flush(), set_pmd_at() sequence which,
for an instant (indeed, for a long instant, given the inter-CPU
TLB flush in there), leaves *pmd neither present not trans_huge.

Which can confuse a concurrent rmap walk, as when removing migration
ptes, seen in the dumped trace.  Although that rmap walk has a 4k
page to insert, anon_vmas containing THPs are in no way segregated
from 4k-page anon_vmas, so the 4k-intent mm_find_pmd() does need to
cope with that instant when a trans_huge pmd is temporarily absent.

I don't think we need strengthen the locking at the THP end: it's
easily handled with an ACCESS_ONCE() before testing both conditions.

And since mm_find_pmd() had only one caller who wanted a THP rather
than a pmd, let's slightly repurpose it to fail when it hits a THP
or non-present pmd, and open code split_huge_page_address() again.

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/huge_memory.c |   18 ++++++++++++------
 mm/ksm.c         |    1 -
 mm/migrate.c     |    2 --
 mm/rmap.c        |   12 ++++++++----
 4 files changed, 20 insertions(+), 13 deletions(-)

--- v3.15/mm/huge_memory.c	2014-06-08 11:19:54.000000000 -0700
+++ linux/mm/huge_memory.c	2014-06-09 19:18:20.004702465 -0700
@@ -2390,8 +2390,6 @@ static void collapse_huge_page(struct mm
 	pmd = mm_find_pmd(mm, address);
 	if (!pmd)
 		goto out;
-	if (pmd_trans_huge(*pmd))
-		goto out;
 
 	anon_vma_lock_write(vma->anon_vma);
 
@@ -2490,8 +2488,6 @@ static int khugepaged_scan_pmd(struct mm
 	pmd = mm_find_pmd(mm, address);
 	if (!pmd)
 		goto out;
-	if (pmd_trans_huge(*pmd))
-		goto out;
 
 	memset(khugepaged_node_load, 0, sizeof(khugepaged_node_load));
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
@@ -2844,12 +2840,22 @@ void split_huge_page_pmd_mm(struct mm_st
 static void split_huge_page_address(struct mm_struct *mm,
 				    unsigned long address)
 {
+	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 
 	VM_BUG_ON(!(address & ~HPAGE_PMD_MASK));
 
-	pmd = mm_find_pmd(mm, address);
-	if (!pmd)
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		return;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return;
+
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
 		return;
 	/*
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
--- v3.15/mm/ksm.c	2014-03-30 20:40:15.000000000 -0700
+++ linux/mm/ksm.c	2014-06-09 19:18:20.004702465 -0700
@@ -945,7 +945,6 @@ static int replace_page(struct vm_area_s
 	pmd = mm_find_pmd(mm, addr);
 	if (!pmd)
 		goto out;
-	BUG_ON(pmd_trans_huge(*pmd));
 
 	mmun_start = addr;
 	mmun_end   = addr + PAGE_SIZE;
--- v3.15/mm/migrate.c	2014-03-30 20:40:15.000000000 -0700
+++ linux/mm/migrate.c	2014-06-09 19:18:20.008702465 -0700
@@ -120,8 +120,6 @@ static int remove_migration_pte(struct p
 		pmd = mm_find_pmd(mm, addr);
 		if (!pmd)
 			goto out;
-		if (pmd_trans_huge(*pmd))
-			goto out;
 
 		ptep = pte_offset_map(pmd, addr);
 
--- v3.15/mm/rmap.c	2014-06-08 11:19:54.000000000 -0700
+++ linux/mm/rmap.c	2014-06-09 19:18:20.008702465 -0700
@@ -567,6 +567,7 @@ pmd_t *mm_find_pmd(struct mm_struct *mm,
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd = NULL;
+	pmd_t pmde;
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -577,7 +578,13 @@ pmd_t *mm_find_pmd(struct mm_struct *mm,
 		goto out;
 
 	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
+	/*
+	 * Some THP functions use the sequence pmdp_clear_flush(), set_pmd_at()
+	 * without holding anon_vma lock for write.  So when looking for a
+	 * genuine pmde (in which to find pte), test present and !THP together.
+	 */
+	pmde = ACCESS_ONCE(*pmd);
+	if (!pmd_present(pmde) || pmd_trans_huge(pmde))
 		pmd = NULL;
 out:
 	return pmd;
@@ -613,9 +620,6 @@ pte_t *__page_check_address(struct page
 	if (!pmd)
 		return NULL;
 
-	if (pmd_trans_huge(*pmd))
-		return NULL;
-
 	pte = pte_offset_map(pmd, address);
 	/* Make a quick check before getting the lock */
 	if (!sync && !pte_present(*pte)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
