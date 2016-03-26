Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 80EDA6B0253
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 12:42:57 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id 4so141712417pfd.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 09:42:57 -0700 (PDT)
Received: from smtp-outbound-2.vmware.com (smtp-outbound-2.vmware.com. [208.91.2.13])
        by mx.google.com with ESMTPS id e72si16449648pfb.126.2016.03.28.09.42.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Mar 2016 09:42:56 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v2 2/2] mm/rmap: batched invalidations should use existing api
Date: Sat, 26 Mar 2016 01:25:05 -0700
Message-Id: <1458980705-121507-3-git-send-email-namit@vmware.com>
In-Reply-To: <1458980705-121507-1-git-send-email-namit@vmware.com>
References: <1458980705-121507-1-git-send-email-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, mgorman@suse.de, sasha.levin@oracle.com, akpm@linux-foundation.org, namit@vmware.com, riel@redhat.com, dave.hansen@linux.intel.com, luto@kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, jmarchan@redhat.com, hughd@google.com, vdavydov@virtuozzo.com, minchan@kernel.org, linux-kernel@vger.kernel.org

The recently introduced batched invalidations mechanism uses its own
mechanism for shootdown. However, it does wrong accounting of interrupts
(e.g., inc_irq_stat is called for local invalidations), trace-points
(e.g., TLB_REMOTE_SHOOTDOWN for local invalidations) and may break some
platforms as it bypasses the invalidation mechanisms of Xen and SGI UV.

This patch reuses the existing TLB flushing mechnaisms instead. We use
NULL as mm to indicate a global invalidation is required.

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 arch/x86/include/asm/tlbflush.h |  6 ------
 arch/x86/mm/tlb.c               |  2 +-
 mm/rmap.c                       | 28 +++++++---------------------
 3 files changed, 8 insertions(+), 28 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 6df2029..cd79194 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -261,12 +261,6 @@ static inline void reset_lazy_tlbstate(void)
 
 #endif	/* SMP */
 
-/* Not inlined due to inc_irq_stat not being defined yet */
-#define flush_tlb_local() {		\
-	inc_irq_stat(irq_tlb_count);	\
-	local_flush_tlb();		\
-}
-
 #ifndef CONFIG_PARAVIRT
 #define flush_tlb_others(mask, mm, start, end)	\
 	native_flush_tlb_others(mask, mm, start, end)
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 5fb6ada..fe9b9f7 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -104,7 +104,7 @@ static void flush_tlb_func(void *info)
 
 	inc_irq_stat(irq_tlb_count);
 
-	if (f->flush_mm != this_cpu_read(cpu_tlbstate.active_mm))
+	if (f->flush_mm && f->flush_mm != this_cpu_read(cpu_tlbstate.active_mm))
 		return;
 
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
diff --git a/mm/rmap.c b/mm/rmap.c
index 79f3bf0..37fb08f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -569,19 +569,6 @@ void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
 }
 
 #ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
-static void percpu_flush_tlb_batch_pages(void *data)
-{
-	/*
-	 * All TLB entries are flushed on the assumption that it is
-	 * cheaper to flush all TLBs and let them be refilled than
-	 * flushing individual PFNs. Note that we do not track mm's
-	 * to flush as that might simply be multiple full TLB flushes
-	 * for no gain.
-	 */
-	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
-	flush_tlb_local();
-}
-
 /*
  * Flush TLB entries for recently unmapped pages from remote CPUs. It is
  * important if a PTE was dirty when it was unmapped that it's flushed
@@ -598,15 +585,14 @@ void try_to_unmap_flush(void)
 
 	cpu = get_cpu();
 
-	trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, -1UL);
-
-	if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask))
-		percpu_flush_tlb_batch_pages(&tlb_ubc->cpumask);
-
-	if (cpumask_any_but(&tlb_ubc->cpumask, cpu) < nr_cpu_ids) {
-		smp_call_function_many(&tlb_ubc->cpumask,
-			percpu_flush_tlb_batch_pages, (void *)tlb_ubc, true);
+	if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask)) {
+		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
+		local_flush_tlb();
+		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
 	}
+
+	if (cpumask_any_but(&tlb_ubc->cpumask, cpu) < nr_cpu_ids)
+		flush_tlb_others(&tlb_ubc->cpumask, NULL, 0, TLB_FLUSH_ALL);
 	cpumask_clear(&tlb_ubc->cpumask);
 	tlb_ubc->flush_required = false;
 	tlb_ubc->writable = false;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
