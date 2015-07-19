Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 70AD5280360
	for <linux-mm@kvack.org>; Sun, 19 Jul 2015 08:32:21 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so87167405pac.3
        for <linux-mm@kvack.org>; Sun, 19 Jul 2015 05:32:21 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fh4si28672045pdb.61.2015.07.19.05.32.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jul 2015 05:32:20 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v9 5/8] mmu-notifier: add clear_young callback
Date: Sun, 19 Jul 2015 15:31:14 +0300
Message-ID: <e4ab6e8be3f9f94fe9814219c4a9a19c375a5835.1437303956.git.vdavydov@parallels.com>
In-Reply-To: <cover.1437303956.git.vdavydov@parallels.com>
References: <cover.1437303956.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

In the scope of the idle memory tracking feature, which is introduced by
the following patch, we need to clear the referenced/accessed bit not
only in primary, but also in secondary ptes. The latter is required in
order to estimate wss of KVM VMs. At the same time we want to avoid
flushing tlb, because it is quite expensive and it won't really affect
the final result.

Currently, there is no function for clearing pte young bit that would
meet our requirements, so this patch introduces one. To achieve that we
have to add a new mmu-notifier callback, clear_young, since there is no
method for testing-and-clearing a secondary pte w/o flushing tlb. The
new method is not mandatory and currently only implemented by KVM.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Reviewed-by: Andres Lagar-Cavilla <andreslc@google.com>
Acked-by: Paolo Bonzini <pbonzini@redhat.com>
---
 include/linux/mmu_notifier.h | 44 ++++++++++++++++++++++++++++++++++++++++++++
 mm/mmu_notifier.c            | 17 +++++++++++++++++
 virt/kvm/kvm_main.c          | 18 ++++++++++++++++++
 3 files changed, 79 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 61cd67f4d788..a5b17137c683 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -66,6 +66,16 @@ struct mmu_notifier_ops {
 				 unsigned long end);
 
 	/*
+	 * clear_young is a lightweight version of clear_flush_young. Like the
+	 * latter, it is supposed to test-and-clear the young/accessed bitflag
+	 * in the secondary pte, but it may omit flushing the secondary tlb.
+	 */
+	int (*clear_young)(struct mmu_notifier *mn,
+			   struct mm_struct *mm,
+			   unsigned long start,
+			   unsigned long end);
+
+	/*
 	 * test_young is called to check the young/accessed bitflag in
 	 * the secondary pte. This is used to know if the page is
 	 * frequently used without actually clearing the flag or tearing
@@ -203,6 +213,9 @@ extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long start,
 					  unsigned long end);
+extern int __mmu_notifier_clear_young(struct mm_struct *mm,
+				      unsigned long start,
+				      unsigned long end);
 extern int __mmu_notifier_test_young(struct mm_struct *mm,
 				     unsigned long address);
 extern void __mmu_notifier_change_pte(struct mm_struct *mm,
@@ -231,6 +244,15 @@ static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
 	return 0;
 }
 
+static inline int mmu_notifier_clear_young(struct mm_struct *mm,
+					   unsigned long start,
+					   unsigned long end)
+{
+	if (mm_has_notifiers(mm))
+		return __mmu_notifier_clear_young(mm, start, end);
+	return 0;
+}
+
 static inline int mmu_notifier_test_young(struct mm_struct *mm,
 					  unsigned long address)
 {
@@ -311,6 +333,28 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	__young;							\
 })
 
+#define ptep_clear_young_notify(__vma, __address, __ptep)		\
+({									\
+	int __young;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	__young = ptep_test_and_clear_young(___vma, ___address, __ptep);\
+	__young |= mmu_notifier_clear_young(___vma->vm_mm, ___address,	\
+					    ___address + PAGE_SIZE);	\
+	__young;							\
+})
+
+#define pmdp_clear_young_notify(__vma, __address, __pmdp)		\
+({									\
+	int __young;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	__young = pmdp_test_and_clear_young(___vma, ___address, __pmdp);\
+	__young |= mmu_notifier_clear_young(___vma->vm_mm, ___address,	\
+					    ___address + PMD_SIZE);	\
+	__young;							\
+})
+
 #define	ptep_clear_flush_notify(__vma, __address, __ptep)		\
 ({									\
 	unsigned long ___addr = __address & PAGE_MASK;			\
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 3b9b3d0741b2..5fbdd367bbed 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -123,6 +123,23 @@ int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 	return young;
 }
 
+int __mmu_notifier_clear_young(struct mm_struct *mm,
+			       unsigned long start,
+			       unsigned long end)
+{
+	struct mmu_notifier *mn;
+	int young = 0, id;
+
+	id = srcu_read_lock(&srcu);
+	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->clear_young)
+			young |= mn->ops->clear_young(mn, mm, start, end);
+	}
+	srcu_read_unlock(&srcu, id);
+
+	return young;
+}
+
 int __mmu_notifier_test_young(struct mm_struct *mm,
 			      unsigned long address)
 {
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 8b8a44453670..ff4173ce6924 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -387,6 +387,23 @@ static int kvm_mmu_notifier_clear_flush_young(struct mmu_notifier *mn,
 	return young;
 }
 
+static int kvm_mmu_notifier_clear_young(struct mmu_notifier *mn,
+					struct mm_struct *mm,
+					unsigned long start,
+					unsigned long end)
+{
+	struct kvm *kvm = mmu_notifier_to_kvm(mn);
+	int young, idx;
+
+	idx = srcu_read_lock(&kvm->srcu);
+	spin_lock(&kvm->mmu_lock);
+	young = kvm_age_hva(kvm, start, end);
+	spin_unlock(&kvm->mmu_lock);
+	srcu_read_unlock(&kvm->srcu, idx);
+
+	return young;
+}
+
 static int kvm_mmu_notifier_test_young(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
 				       unsigned long address)
@@ -419,6 +436,7 @@ static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
 	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
 	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
 	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,
+	.clear_young		= kvm_mmu_notifier_clear_young,
 	.test_young		= kvm_mmu_notifier_test_young,
 	.change_pte		= kvm_mmu_notifier_change_pte,
 	.release		= kvm_mmu_notifier_release,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
