Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC966B0069
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 20:08:58 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a5so1253950pgu.1
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 17:08:58 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i11si2062131pgf.430.2017.12.13.17.08.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 17:08:57 -0800 (PST)
From: Lu Baolu <baolu.lu@linux.intel.com>
Subject: [PATCH 1/2] mm: Add kernel MMU notifier to manage IOTLB/DEVTLB
Date: Thu, 14 Dec 2017 09:02:45 +0800
Message-Id: <1513213366-22594-2-git-send-email-baolu.lu@linux.intel.com>
In-Reply-To: <1513213366-22594-1-git-send-email-baolu.lu@linux.intel.com>
References: <1513213366-22594-1-git-send-email-baolu.lu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Alex Williamson <alex.williamson@redhat.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>
Cc: iommu@lists.linux-foundation.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Ashok Raj <ashok.raj@intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Dave Jiang <dave.jiang@intel.com>, Michal Hocko <mhocko@suse.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Vegard Nossum <vegard.nossum@oracle.com>, Lu Baolu <baolu.lu@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

Shared Virtual Memory (SVM) allows a kernel memory mapping to be
shared between CPU and and a device which requested a supervisor
PASID. Both devices and IOMMU units have TLBs that cache entries
from CPU's page tables. We need to get a chance to flush them at
the same time when we flush the CPU TLBs.

We already have an existing MMU notifiers for userspace updates,
however we lack the same thing for kernel page table updates. To
implement the MMU notification mechanism for the kernel address
space, a kernel MMU notifier chain is defined and will be called
whenever the CPU TLB is flushed for the kernel address space.

As consumer of this notifier, the IOMMU SVM implementations will
register callbacks on this notifier and manage the cache entries
in both IOTLB and DevTLB.

Cc: Ashok Raj <ashok.raj@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Vegard Nossum <vegard.nossum@oracle.com>
Cc: x86@kernel.org
Cc: linux-mm@kvack.org

Tested-by: CQ Tang <cq.tang@intel.com>
Signed-off-by: Huang Ying <ying.huang@intel.com>
Signed-off-by: Lu Baolu <baolu.lu@linux.intel.com>
---
 arch/x86/mm/tlb.c            |  2 ++
 include/linux/mmu_notifier.h | 33 +++++++++++++++++++++++++++++++++
 mm/mmu_notifier.c            | 27 +++++++++++++++++++++++++++
 3 files changed, 62 insertions(+)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 3118392cd..5ff104f 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -6,6 +6,7 @@
 #include <linux/interrupt.h>
 #include <linux/export.h>
 #include <linux/cpu.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
@@ -567,6 +568,7 @@ void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 		info.end = end;
 		on_each_cpu(do_kernel_range_flush, &info, 1);
 	}
+	kernel_mmu_notifier_invalidate_range(start, end);
 }
 
 void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index b25dc9d..44d7c06 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -408,6 +408,25 @@ extern void mmu_notifier_call_srcu(struct rcu_head *rcu,
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
 
 static inline int mm_has_notifiers(struct mm_struct *mm)
@@ -474,6 +493,20 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
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
index 96edb33..52f816a 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -393,3 +393,30 @@ void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
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
+EXPORT_SYMBOL_GPL(kernel_mmu_notifier_register);
+
+int kernel_mmu_notifier_unregister(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&kernel_mmu_notifier_list, nb);
+}
+EXPORT_SYMBOL_GPL(kernel_mmu_notifier_unregister);
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
