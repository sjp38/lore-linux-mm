Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4CA76B02B4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 16:30:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s14so45102201pgs.4
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 13:30:35 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id x1si1184924pgc.116.2017.08.08.13.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 13:30:34 -0700 (PDT)
From: Ashok Raj <ashok.raj@intel.com>
Subject: [PATCH 4/4] iommu/vt-d: Hooks to invalidate iotlb/devtlb when using supervisor PASID's.
Date: Tue,  8 Aug 2017 13:29:30 -0700
Message-Id: <1502224170-5344-5-git-send-email-ashok.raj@intel.com>
In-Reply-To: <1502224170-5344-1-git-send-email-ashok.raj@intel.com>
References: <1502224170-5344-1-git-send-email-ashok.raj@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Joerg Roedel <joro@8bytes.org>
Cc: Ashok Raj <ashok.raj@intel.com>, Dave Hansen <dave.hansen@intel.com>, CQ Tang <cq.tang@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Vegard Nossum <vegard.nossum@oracle.com>, x86@kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, David Woodhouse <dwmw2@infradead.org>, Jean-Phillipe Brucker <jean-philippe.brucker@arm.com>

When a kernel client uses intel_svm_bind_mm() and requests a supervisor
PASID, IOMMU needs to track changes to these addresses. Otherwise the device
tlb will be stale compared to what's on the cpu for kernel mappings. This
is similar to what's done for user space registrations via
mmu_notifier_register() api's.

To: linux-kernel@vger.kernel.org
To: Joerg Roedel <joro@8bytes.org>
Cc: Ashok Raj <ashok.raj@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc:	Huang Ying <ying.huang@intel.com>
Cc: CQ Tang <cq.tang@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Vegard Nossum <vegard.nossum@oracle.com>
Cc: x86@kernel.org
Cc: linux-mm@kvack.org
Cc: iommu@lists.linux-foundation.org
Cc: David Woodhouse <dwmw2@infradead.org>
CC: Jean-Phillipe Brucker <jean-philippe.brucker@arm.com>

Signed-off-by: Ashok Raj <ashok.raj@intel.com>
---
 drivers/iommu/intel-svm.c   | 29 +++++++++++++++++++++++++++--
 include/linux/intel-iommu.h |  5 ++++-
 2 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index 0c9f077..1758814 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -292,6 +292,26 @@ static const struct mmu_notifier_ops intel_mmuops = {
 
 static DEFINE_MUTEX(pasid_mutex);
 
+static int intel_init_mm_inval_range(struct notifier_block *nb,
+	unsigned long action, void *data)
+{
+	struct kernel_mmu_address_range *range;
+	struct intel_svm *svm = container_of(nb, struct intel_svm, init_mm_nb);
+	unsigned long start, end;
+	struct intel_iommu *iommu;
+
+	if (action == KERNEL_MMU_INVALIDATE_RANGE) {
+		range = data;
+		start = range->start;
+		end = range->end;
+		iommu = svm->iommu;
+
+		intel_flush_svm_range(svm, start,
+			(end - start + PAGE_SIZE - 1) >> VTD_PAGE_SHIFT, 0, 0);
+	}
+	return 0;
+}
+
 int intel_svm_bind_mm(struct device *dev, int *pasid, int flags, struct svm_dev_ops *ops)
 {
 	struct intel_iommu *iommu = intel_svm_device_to_iommu(dev);
@@ -391,12 +411,12 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, int flags, struct svm_dev_
 			goto out;
 		}
 		svm->pasid = ret;
-		svm->notifier.ops = &intel_mmuops;
 		svm->mm = mm;
 		svm->flags = flags;
 		INIT_LIST_HEAD_RCU(&svm->devs);
 		ret = -ENOMEM;
 		if (mm) {
+			svm->notifier.ops = &intel_mmuops;
 			ret = mmu_notifier_register(&svm->notifier, mm);
 			if (ret) {
 				idr_remove(&svm->iommu->pasid_idr, svm->pasid);
@@ -405,8 +425,11 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, int flags, struct svm_dev_
 				goto out;
 			}
 			iommu->pasid_table[svm->pasid].val = (u64)__pa(mm->pgd) | 1;
-		} else
+		} else {
+			svm->init_mm_nb.notifier_call = intel_init_mm_inval_range;
+			kernel_mmu_notifier_register(&svm->init_mm_nb);
 			iommu->pasid_table[svm->pasid].val = (u64)__pa(init_mm.pgd) | 1 | (1ULL << 11);
+		}
 		wmb();
 		/* In caching mode, we still have to flush with PASID 0 when
 		 * a PASID table entry becomes present. Not entirely clear
@@ -471,6 +494,8 @@ int intel_svm_unbind_mm(struct device *dev, int pasid)
 					idr_remove(&svm->iommu->pasid_idr, svm->pasid);
 					if (svm->mm)
 						mmu_notifier_unregister(&svm->notifier, svm->mm);
+					else
+						kernel_mmu_notifier_unregister(&svm->init_mm_nb);
 
 					/* We mandate that no page faults may be outstanding
 					 * for the PASID when intel_svm_unbind_mm() is called.
diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
index 485a5b4..d6019b4 100644
--- a/include/linux/intel-iommu.h
+++ b/include/linux/intel-iommu.h
@@ -477,7 +477,10 @@ struct intel_svm_dev {
 };
 
 struct intel_svm {
-	struct mmu_notifier notifier;
+	union {
+		struct mmu_notifier notifier;
+		struct notifier_block init_mm_nb;
+	};
 	struct mm_struct *mm;
 	struct intel_iommu *iommu;
 	int flags;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
