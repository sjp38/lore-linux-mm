Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1869C6B0036
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 10:40:23 -0500 (EST)
Received: by mail-vc0-f178.google.com with SMTP id lh4so13498114vcb.9
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 07:40:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id h7si34853388vee.71.2013.12.05.07.40.21
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 07:40:22 -0800 (PST)
Date: Thu, 5 Dec 2013 10:40:15 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 14/15] mm: numa: Flush TLB if NUMA hinting faults race
 with PTE scan update
Message-ID: <20131205104015.716ed0fe@annuminas.surriel.com>
In-Reply-To: <20131204160741.GC11295@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
	<1386060721-3794-15-git-send-email-mgorman@suse.de>
	<529E641A.7040804@redhat.com>
	<20131203234637.GS11295@suse.de>
	<529F3D51.1090203@redhat.com>
	<20131204160741.GC11295@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com

On Wed, 4 Dec 2013 16:07:41 +0000
Mel Gorman <mgorman@suse.de> wrote:

> Because I found it impossible to segfault processes under any level of
> scanning and numa hinting fault stress after it was applied
 
I think I still managed to trigger the bug, by setting numa page
scanning to ludicrous speed, and running two large specjbb2005
processes on a 4 node system in an infinite loop :)

I believe the reason is your patch flushes the TLB too late,
after the page contents have been migrated over to the new
page.

The changelog below should explain how the race works, and
how this patch supposedly fixes it. If it doesn't, let me
know and I'll go back to the drawing board :)

---8<---

Subject: mm,numa: fix memory corrupter race between THP NUMA unmap and migrate

There is a subtle race between THP NUMA migration, and the NUMA
unmapping code.

The NUMA unmapping code does a permission change on pages, which
is done with a batched (deferred) TLB flush. This is normally safe,
because the pages stay in the same place, and having other CPUs
continue to access them until the TLB flush is indistinguishable
from having other CPUs do those same accesses before the PTE
permission change.

The THP NUMA migration code normally does not do a remote TLB flush,
because the PTE is marked inaccessible, meaning no other CPUs should
have cached TLB entries that allow them to access the memory.

However, the following race is possible:

CPU A			CPU B			CPU C

						load TLB entry
make entry PMD_NUMA
			fault on entry
						write to page
			start migrating page
						write to page
			change PMD to new page
flush TLB
						reload TLB from new entry
						lose data

The obvious fix is to flush remote TLB entries from the numa
migrate code on CPU B, while CPU A is making PTE changes, and
has the TLB flush batched up for later.

The migration for 4kB pages is currently fine, because it calls
mk_ptenonnuma before migrating the page, which causes the migration
code to always do a remote TLB flush.  We should probably optimize
that at some point...

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mm_types.h |  3 +++
 kernel/sched/core.c      |  1 +
 kernel/sched/fair.c      |  4 ++++
 mm/huge_memory.c         | 10 ++++++++++
 4 files changed, 18 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 261ff4a..fa67ddb 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -427,6 +427,9 @@ struct mm_struct {
 
 	/* numa_scan_seq prevents two threads setting pte_numa */
 	int numa_scan_seq;
+
+	/* task_numa_work is unmapping pages, with deferred TLB flush */
+	bool numa_tlb_lazy;
 #endif
 	struct uprobes_state uprobes_state;
 };
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 5f14335..fe80455 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1732,6 +1732,7 @@ static void __sched_fork(unsigned long clone_flags, struct task_struct *p)
 	if (p->mm && atomic_read(&p->mm->mm_users) == 1) {
 		p->mm->numa_next_scan = jiffies + msecs_to_jiffies(sysctl_numa_balancing_scan_delay);
 		p->mm->numa_scan_seq = 0;
+		p->mm->numa_tlb_lazy = false;
 	}
 
 	if (clone_flags & CLONE_VM)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 2ec4afb..c9440f3 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1722,7 +1722,11 @@ void task_numa_work(struct callback_head *work)
 			start = max(start, vma->vm_start);
 			end = ALIGN(start + (pages << PAGE_SHIFT), HPAGE_SIZE);
 			end = min(end, vma->vm_end);
+			wmb(); /* with do_huge_pmd_numa_page */
+			mm->numa_tlb_lazy = true;
 			nr_pte_updates += change_prot_numa(vma, start, end);
+			wmb(); /* with do_huge_pmd_numa_page */
+			mm->numa_tlb_lazy = false;
 
 			/*
 			 * Scan sysctl_numa_balancing_scan_size but ensure that
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d68066f..3a03370 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1385,6 +1385,16 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	/*
+	 * Another CPU is currently turning ptes of this process into
+	 * NUMA ptes. That permission change batches the TLB flush,
+	 * so other CPUs may still have valid TLB entries pointing to
+	 * the current page. Make sure those are flushed before we
+	 * migrate to a new page.
+	 */
+	rmb(); /* with task_numa_work */
+	if (mm->numa_tlb_lazy)
+		flush_tlb_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
+	/*
 	 * Migrate the THP to the requested node, returns with page unlocked
 	 * and pmd_numa cleared.
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
