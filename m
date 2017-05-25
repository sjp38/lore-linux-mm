Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4AFBE6B02F4
	for <linux-mm@kvack.org>; Thu, 25 May 2017 13:11:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m5so236642403pfc.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 10:11:27 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d71si27232448pgc.68.2017.05.25.10.11.25
        for <linux-mm@kvack.org>;
        Thu, 25 May 2017 10:11:26 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v2] mm/hugetlb: Report -EHWPOISON not -EFAULT when FOLL_HWPOISON is specified
Date: Thu, 25 May 2017 18:10:35 +0100
Message-Id: <20170525171035.16359-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Punit Agrawal <punit.agrawal@arm.com>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

KVM uses get_user_pages() to resolve its stage2 faults. KVM sets the
FOLL_HWPOISON flag causing faultin_page() to return -EHWPOISON when it
finds a VM_FAULT_HWPOISON. KVM handles these hwpoison pages as a special
case.

When huge pages are involved, this doesn't work so well. get_user_pages()
calls follow_hugetlb_page(), which stops early if it receives
VM_FAULT_HWPOISON from hugetlb_fault(), eventually returning -EFAULT to
the caller. The step to map this to -EHWPOISON based on the FOLL_ flags
is missing. The hwpoison special case is skipped, and -EFAULT is returned
to user-space, causing Qemu or kvmtool to exit.

Instead, move this VM_FAULT_ to errno mapping code into a header file
and use it from faultin_page(), follow_hugetlb_page() and faultin_page().

With this, KVM works as expected.

CC: Punit Agrawal <punit.agrawal@arm.com>
CC: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: James Morse <james.morse@arm.com>
---
Changes since v1:
 * Fixed checkpatch warnings (oops, wrong file)
 * Added vm_fault_to_errno() call to faultin_page() as Naoya Horiguchi
   suggested.

This isn't a problem for arm64 today as we haven't enabled MEMORY_FAILURE,
but I can't see any reason this doesn't happen on x86 too, so I think this
should be a fix. This doesn't apply earlier than stable's v4.11.1 due to
all sorts of cleanup. My best offer is:
Cc: <stable@vger.kernel.org> # 4.11.1

 include/linux/mm.h | 11 +++++++++++
 mm/gup.c           | 20 ++++++++------------
 mm/hugetlb.c       |  5 +++++
 3 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7cb17c6b97de..b892e95d4929 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2327,6 +2327,17 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 #define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
 #define FOLL_COW	0x4000	/* internal GUP flag */
 
+static inline int vm_fault_to_errno(int vm_fault, int foll_flags)
+{
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
index d9e6fddcc51f..b3c7214d710d 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -407,12 +407,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 
 	ret = handle_mm_fault(vma, address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {
-		if (ret & VM_FAULT_OOM)
-			return -ENOMEM;
-		if (ret & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
-			return *flags & FOLL_HWPOISON ? -EHWPOISON : -EFAULT;
-		if (ret & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV))
-			return -EFAULT;
+		int err = vm_fault_to_errno(ret, *flags);
+
+		if (err)
+			return err;
 		BUG();
 	}
 
@@ -723,12 +721,10 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	ret = handle_mm_fault(vma, address, fault_flags);
 	major |= ret & VM_FAULT_MAJOR;
 	if (ret & VM_FAULT_ERROR) {
-		if (ret & VM_FAULT_OOM)
-			return -ENOMEM;
-		if (ret & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
-			return -EHWPOISON;
-		if (ret & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV))
-			return -EFAULT;
+		int err = vm_fault_to_errno(ret, 0);
+
+		if (err)
+			return err;
 		BUG();
 	}
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e5828875f7bb..3eedb187e549 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4170,6 +4170,11 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			}
 			ret = hugetlb_fault(mm, vma, vaddr, fault_flags);
 			if (ret & VM_FAULT_ERROR) {
+				int err = vm_fault_to_errno(ret, flags);
+
+				if (err)
+					return err;
+
 				remainder = 0;
 				break;
 			}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
