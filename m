Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5A766B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 13:28:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w7-v6so11097507pfd.9
        for <linux-mm@kvack.org>; Mon, 14 May 2018 10:28:35 -0700 (PDT)
Received: from mx142.netapp.com (mx142.netapp.com. [2620:10a:4005:8000:2306::b])
        by mx.google.com with ESMTPS id p8-v6si2724843pgs.441.2018.05.14.10.28.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 10:28:34 -0700 (PDT)
From: Boaz Harrosh <boazh@netapp.com>
Subject: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-ID: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
Date: Mon, 14 May 2018 20:28:01 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van
 Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>


On a call to mmap an mmap provider (like an FS) can put
this flag on vma->vm_flags.

The VM_LOCAL_CPU flag tells the Kernel that the vma will be used
from a single-core only, and therefore invalidation (flush_tlb) of
PTE(s) need not be a wide CPU scheduling.

The motivation of this flag is the ZUFS project where we want
to optimally map user-application buffers into a user-mode-server
execute the operation and efficiently unmap.

In this project we utilize a per-core server thread so everything
is kept local. If we use the regular zap_ptes() API All CPU's
are scheduled for the unmap, though in our case we know that we
have only used a single core. The regular zap_ptes adds a very big
latency on every operation and mostly kills the concurrency of the
over all system. Because it imposes a serialization between all cores

Some preliminary measurements on a 40 core machines:

	unpatched		patched
Threads	Op/s	Lat [us]	Op/s	Lat [us]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1	185391	4.9		200799	4.6
2	197993	9.6		314321	5.9
4	310597	12.1		565574	6.6
8	546702	13.8		1113138	6.6
12	641728	17.2		1598451	6.8
18	744750	22.2		1648689	7.8
24	790805	28.3		1702285	8
36	849763	38.9		1783346	13.4
48	792000	44.6		1741873	17.4

We can clearly see that on an unpatched Kernel we do not scale
and the threads are interfering with each other. This is because
flush-tlb is scheduled on all (other) CPUs.

NOTE: This vma (VM_LOCAL_CPU) is never used during a page_fault. It is
always used in a synchronous way from a thread pinned to a single core.

Signed-off-by: Boaz Harrosh <boazh@netapp.com>
---
 arch/x86/mm/tlb.c  |  3 ++-
 fs/proc/task_mmu.c |  3 +++
 include/linux/mm.h |  3 +++
 mm/memory.c        | 13 +++++++++++--
 4 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index e055d1a..1d398a0 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -640,7 +640,8 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 		local_irq_enable();
 	}
 
-	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
+	if (!(vmflag & VM_LOCAL_CPU) &&
+	    cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), &info);
 
 	put_cpu();
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c486ad4..305d6e4 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -680,6 +680,9 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_PKEY_BIT2)]	= "",
 		[ilog2(VM_PKEY_BIT3)]	= "",
 #endif
+#ifdef CONFIG_ARCH_USES_HIGH_VMA_FLAGS
+		[ilog2(VM_LOCAL_CPU)]	= "lc",
+#endif
 	};
 	size_t i;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1ac1f06..3d14107 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -226,6 +226,9 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
+#define VM_LOCAL_CPU	BIT(37)		/* FIXME: Needs to move from here */
+#else /* ! CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
+#define VM_LOCAL_CPU	0		/* FIXME: Needs to move from here */
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
 #if defined(CONFIG_X86)
diff --git a/mm/memory.c b/mm/memory.c
index 01f5464..6236f5e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1788,6 +1788,7 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	int retval;
 	pte_t *pte, entry;
 	spinlock_t *ptl;
+	bool need_flush = false;
 
 	retval = -ENOMEM;
 	pte = get_locked_pte(mm, addr, &ptl);
@@ -1795,7 +1796,12 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 		goto out;
 	retval = -EBUSY;
 	if (!pte_none(*pte)) {
-		if (mkwrite) {
+		if ((vma->vm_flags & VM_LOCAL_CPU)) {
+			/* VM_LOCAL_CPU is set, A single CPU is allowed to not
+			 * go through zap_vma_ptes before changing a pte
+			 */
+			need_flush = true;
+		} else if (mkwrite) {
 			/*
 			 * For read faults on private mappings the PFN passed
 			 * in may not match the PFN we have mapped if the
@@ -1807,8 +1813,9 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 				goto out_unlock;
 			entry = *pte;
 			goto out_mkwrite;
-		} else
+		} else {
 			goto out_unlock;
+		}
 	}
 
 	/* Ok, finally just insert the thing.. */
@@ -1824,6 +1831,8 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	}
 
 	set_pte_at(mm, addr, pte, entry);
+	if (need_flush)
+		flush_tlb_range(vma, addr, addr + PAGE_SIZE);
 	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
 
 	retval = 0;
-- 
2.5.5
