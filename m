Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22F896B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 16:23:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r187so42701160pfr.8
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 13:23:23 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id x33si1433526plb.838.2017.08.08.13.23.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 13:23:21 -0700 (PDT)
From: Ashok Raj <ashok.raj@intel.com>
Subject: [PATCH 3/4] mm: Add kernel MMU notifier to manage remote TLB
Date: Tue,  8 Aug 2017 13:22:20 -0700
Message-Id: <1502223741-5269-4-git-send-email-ashok.raj@intel.com>
In-Reply-To: <1502223741-5269-1-git-send-email-ashok.raj@intel.com>
References: <1502223741-5269-1-git-send-email-ashok.raj@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Joerg Roedel <joro@8bytes.org>
Cc: Huang Ying <ying.huang@intel.com>, Ashok Raj <ashok.raj@intel.com>, Dave Hansen <dave.hansen@intel.com>, CQ Tang <cq.tang@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Vegard Nossum <vegard.nossum@oracle.com>, x86@kernel.org, linux-mm@kvack.org, iommu@lists-foundation.org, David Woodhouse <dwmw2@infradead.org>, Jean-Phillipe Brucker <jean-philippe.brucker@arm.com>

From: Huang Ying <ying.huang@intel.com>

Shared Virtual Memory (SVM) devices have TLBs that cache entries from
the CPU's page tables.  We need SVM device drivers to flush them at
the same time that we flush the CPU TLBs.  We can use the existing MMU
notifiers for userspace updates, but we lack a mechanism to get
notified when kernel page tables are updated.

To implement the MMU notification mechanism for the kernel address
space, a kernel MMU notifier chain is defined, and will be called when
the CPU TLB is flushed for the kernel address space.  The IOMMU SVM
driver can register on the notifier chain to flush the device TLBs
when necessary.

To: linux-kernel@vger.kernel.org
To: Joerg Roedel <joro@8bytes.org>
Cc: Ashok Raj <ashok.raj@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: CQ Tang <cq.tang@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Vegard Nossum <vegard.nossum@oracle.com>
Cc: x86@kernel.org
Cc: linux-mm@kvack.org
Cc: iommu@lists-foundation.org
Cc: David Woodhouse <dwmw2@infradead.org>
CC: Jean-Phillipe Brucker <jean-philippe.brucker@arm.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 arch/x86/include/asm/tlbflush.h |  1 +
 arch/x86/mm/tlb.c               |  1 +
 include/linux/mmu_notifier.h    | 33 +++++++++++++++++++++++++++++++++
 mm/mmu_notifier.c               | 25 +++++++++++++++++++++++++
 4 files changed, 60 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 50ea348..f5fd0b8 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -3,6 +3,7 @@
 
 #include <linux/mm.h>
 #include <linux/sched.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/processor.h>
 #include <asm/cpufeature.h>
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 014d07a..6dea8e9 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -314,6 +314,7 @@ void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 		info.end = end;
 		on_each_cpu(do_kernel_range_flush, &info, 1);
 	}
+	kernel_mmu_notifier_invalidate_range(start, end);
 }
 
 void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index c91b3bc..4a96089 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -418,6 +418,25 @@ extern void mmu_notifier_call_srcu(struct rcu_head *rcu,
 				   void (*func)(struct rcu_head *rcu));
 extern void mmu_notifier_synchronize(void);
 
+struct kernel_mmu_address_range {
+	unsigned long start;
+	unsigned long end;
+};
+
+/*
+ * Before the virtual address range managed by kernel (vmalloc/kmap)
+ * is reused, That is, remapped to the new physical addresses, the
+ * kernel MMU notifier will be called with KERNEL_MMU_INVALIDATE_RANGE
+ * and struct kernel_mmu_address_range as parameters.  This is used to
+ * manage the remote TLB.
+ */
+#define KERNEL_MMU_INVALIDATE_RANGE		1
+extern int kernel_mmu_notifier_register(struct notifier_block *nb);
+extern int kernel_mmu_notifier_unregister(struct notifier_block *nb);
+
+extern int kernel_mmu_notifier_invalidate_range(unsigned long start,
+						unsigned long end);
+
 #else /* CONFIG_MMU_NOTIFIER */
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
@@ -479,6 +498,20 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 #define pudp_huge_clear_flush_notify pudp_huge_clear_flush
 #define set_pte_at_notify set_pte_at
 
+static inline int kernel_mmu_notifier_register(struct notifier_block *nb)
+{
+	return 0;
+}
+
+static inline int kernel_mmu_notifier_unregister(struct notifier_block *nb)
+{
+	return 0;
+}
+
+static inline void kernel_mmu_notifier_invalidate_range(unsigned long start,
+							unsigned long end)
+{
+}
 #endif /* CONFIG_MMU_NOTIFIER */
 
 #endif /* _LINUX_MMU_NOTIFIER_H */
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 54ca545..a919038 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -400,3 +400,28 @@ void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
 	mmdrop(mm);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister_no_release);
+
+static ATOMIC_NOTIFIER_HEAD(kernel_mmu_notifier_list);
+
+int kernel_mmu_notifier_register(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&kernel_mmu_notifier_list, nb);
+}
+
+int kernel_mmu_notifier_unregister(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&kernel_mmu_notifier_list, nb);
+}
+
+int kernel_mmu_notifier_invalidate_range(unsigned long start,
+					 unsigned long end)
+{
+	struct kernel_mmu_address_range range = {
+		.start	= start,
+		.end	= end,
+	};
+
+	return atomic_notifier_call_chain(&kernel_mmu_notifier_list,
+					  KERNEL_MMU_INVALIDATE_RANGE,
+					  &range);
+}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
