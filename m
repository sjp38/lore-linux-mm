Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC4D36B025E
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 20:09:02 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x24so2693403pgv.5
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 17:09:02 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i11si2062131pgf.430.2017.12.13.17.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 17:09:01 -0800 (PST)
From: Lu Baolu <baolu.lu@linux.intel.com>
Subject: [PATCH 2/2] iommu/vt-d: Register kernel MMU notifier to manage IOTLB/DEVTLB
Date: Thu, 14 Dec 2017 09:02:46 +0800
Message-Id: <1513213366-22594-3-git-send-email-baolu.lu@linux.intel.com>
In-Reply-To: <1513213366-22594-1-git-send-email-baolu.lu@linux.intel.com>
References: <1513213366-22594-1-git-send-email-baolu.lu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Alex Williamson <alex.williamson@redhat.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>
Cc: iommu@lists.linux-foundation.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ashok Raj <ashok.raj@intel.com>, Dave Hansen <dave.hansen@intel.com>, Huang Ying <ying.huang@intel.com>, CQ Tang <cq.tang@intel.com>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Vegard Nossum <vegard.nossum@oracle.com>, Jean-Phillipe Brucker <jean-philippe.brucker@arm.com>, Lu Baolu <baolu.lu@linux.intel.com>

From: Ashok Raj <ashok.raj@intel.com>

When a kernel client calls intel_svm_bind_mm() and gets a valid
supervisor PASID,  the memory mapping of init_mm will be shared
between CPUs and device. IOMMU has to track the changes to this
memory mapping, and get notified whenever a TLB flush is needed.
Otherwise, the device TLB will be stale compared to that on the
cpu for kernel mappings. This is similar to what have been done
for user space registrations via mmu_notifier_register() api's.

To: Alex Williamson <alex.williamson@redhat.com>
To: linux-kernel@vger.kernel.org
To: Joerg Roedel <joro@8bytes.org>
Cc: Ashok Raj <ashok.raj@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: CQ Tang <cq.tang@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Vegard Nossum <vegard.nossum@oracle.com>
Cc: x86@kernel.org
Cc: linux-mm@kvack.org
Cc: iommu@lists.linux-foundation.org
Cc: David Woodhouse <dwmw2@infradead.org>
CC: Jean-Phillipe Brucker <jean-philippe.brucker@arm.com>

Signed-off-by: Ashok Raj <ashok.raj@intel.com>
Signed-off-by: Lu Baolu <baolu.lu@linux.intel.com>
---
 drivers/iommu/intel-svm.c   | 27 +++++++++++++++++++++++++--
 include/linux/intel-iommu.h |  5 ++++-
 2 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index ed1cf7c..1456092 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -283,6 +283,24 @@ static const struct mmu_notifier_ops intel_mmuops = {
 
 static DEFINE_MUTEX(pasid_mutex);
 
+static int intel_init_mm_inval_range(struct notifier_block *nb,
+				     unsigned long action, void *data)
+{
+	struct kernel_mmu_address_range *range;
+	struct intel_svm *svm = container_of(nb, struct intel_svm, init_mm_nb);
+	unsigned long start, end;
+
+	if (action == KERNEL_MMU_INVALIDATE_RANGE) {
+		range = data;
+		start = range->start;
+		end = range->end;
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
@@ -382,12 +400,12 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, int flags, struct svm_dev_
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
@@ -396,8 +414,11 @@ int intel_svm_bind_mm(struct device *dev, int *pasid, int flags, struct svm_dev_
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
@@ -464,6 +485,8 @@ int intel_svm_unbind_mm(struct device *dev, int pasid)
 					idr_remove(&svm->iommu->pasid_idr, svm->pasid);
 					if (svm->mm)
 						mmu_notifier_unregister(&svm->notifier, svm->mm);
+					else
+						kernel_mmu_notifier_unregister(&svm->init_mm_nb);
 
 					/* We mandate that no page faults may be outstanding
 					 * for the PASID when intel_svm_unbind_mm() is called.
diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
index f3274d9..5cf83db 100644
--- a/include/linux/intel-iommu.h
+++ b/include/linux/intel-iommu.h
@@ -478,7 +478,10 @@ struct intel_svm_dev {
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
