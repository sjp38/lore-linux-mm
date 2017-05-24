Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BEB776B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 12:09:57 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p86so197716002pfl.12
        for <linux-mm@kvack.org>; Wed, 24 May 2017 09:09:57 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z69si24786567pfk.418.2017.05.24.09.09.56
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 09:09:56 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH] mm/hugetlb: Report -EHWPOISON not -EFAULT when FOLL_HWPOISON is specified
Date: Wed, 24 May 2017 17:09:00 +0100
Message-Id: <20170524160900.28786-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, james.morse@arm.com, Punit Agrawal <punit.agrawal@arm.com>

KVM uses get_user_pages() to resolve its stage2 faults. KVM sets the
FOLL_HWPOISON flag causing faultin_page() to return -EHWPOISON when it
finds a VM_FAULT_HWPOISON. KVM handles these hwpoison pages as a special
case. (check_user_page_hwpoison())

When huge pages are involved, this doesn't work so well. get_user_pages()
calls follow_hugetlb_page(), which stops early if it receives
VM_FAULT_HWPOISON from hugetlb_fault(), eventually returning -EFAULT to
the caller. The step to map this to -EHWPOISON based on the FOLL_ flags
is missing. The hwpoison special case is skipped, and -EFAULT is returned
to user-space, causing Qemu or kvmtool to exit.

Instead, move this VM_FAULT_ to errno mapping code into a header file
and use it from faultin_page() and follow_hugetlb_page().

With this, KVM works as expected.

CC: Punit Agrawal <punit.agrawal@arm.com>
Signed-off-by: James Morse <james.morse@arm.com>
---
This isn't a problem for arm64 today as we haven't enabled MEMORY_FAILURE,
but I can't see any reason this doesn't happen on x86 too, so I think this
should be a fix. This doesn't apply earlier than stable's v4.11.1 due to
all sorts of cleanup. My best offer is:
Cc: stable@vger.kernel.org # 4.11.1

 include/linux/mm.h | 10 ++++++++++
 mm/gup.c           |  9 +++------
 mm/hugetlb.c       |  3 +++
 3 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7cb17c6b97de..48b47c214c50 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2327,6 +2327,16 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 #define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
 #define FOLL_COW	0x4000	/* internal GUP flag */
 
+static inline int vm_fault_to_errno(int vm_fault, int foll_flags) {
+	if (vm_fault & VM_FAULT_OOM)
+		return -ENOMEM;
+	if (vm_fault & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
+		return (foll_flags & FOLL_HWPOISON) ? -EHWPOISON : -EFAULT;
+	if (vm_fault & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV))
+		return -EFAULT;
+	return 0;
+}
+
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
 extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
diff --git a/mm/gup.c b/mm/gup.c
index d9e6fddcc51f..69f6cec279b3 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -407,12 +407,9 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 
 	ret = handle_mm_fault(vma, address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {
-		if (ret & VM_FAULT_OOM)
-			return -ENOMEM;
-		if (ret & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
-			return *flags & FOLL_HWPOISON ? -EHWPOISON : -EFAULT;
-		if (ret & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV))
-			return -EFAULT;
+		int err = vm_fault_to_errno(ret, *flags);
+		if (err)
+			return err;
 		BUG();
 	}
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e5828875f7bb..08f69dadbc63 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4170,7 +4170,10 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			}
 			ret = hugetlb_fault(mm, vma, vaddr, fault_flags);
 			if (ret & VM_FAULT_ERROR) {
+				int err = vm_fault_to_errno(ret, flags);
 				remainder = 0;
+				if (err)
+					return err;
 				break;
 			}
 			if (ret & VM_FAULT_RETRY) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
