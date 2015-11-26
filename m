Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id C25E16B0254
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 12:27:15 -0500 (EST)
Received: by wmww144 with SMTP id w144so30509996wmw.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 09:27:15 -0800 (PST)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id b186si4818687wmd.88.2015.11.26.09.27.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Nov 2015 09:27:14 -0800 (PST)
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Thu, 26 Nov 2015 17:27:13 -0000
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm: bring in additional flag for fixup_user_fault to signal unlock
Date: Thu, 26 Nov 2015 18:27:01 +0100
Message-Id: <1448558822-41358-2-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1448558822-41358-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1448558822-41358-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Eric B Munson <emunson@akamai.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, linux-kernel@vger.kernel.org

With the introduction of userfaultfd, kvm on s390 needs fixup_user_fault to
pass in FAULT_FLAG_ALLOW_RETRY and give feedback if during the faulting we
ever unlocked mmap_sem.

This patch brings in the logic to handle retries as well as it cleans up
the current documentation.  fixup_user_fault was not having the same
semantics as filemap_fault.  It never indicated if a retry happened and so
a caller wasn't able to handle that case.  So we now changed the behaviour
to always retry a locked mmap_sem.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/mm/pgtable.c |  8 +++++---
 include/linux/mm.h     |  5 +++--
 kernel/futex.c         |  2 +-
 mm/gup.c               | 25 +++++++++++++++++++++----
 4 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 54ef3bc..b15759c 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -585,7 +585,7 @@ int gmap_fault(struct gmap *gmap, unsigned long gaddr,
 		rc = vmaddr;
 		goto out_up;
 	}
-	if (fixup_user_fault(current, gmap->mm, vmaddr, fault_flags)) {
+	if (fixup_user_fault(current, gmap->mm, vmaddr, fault_flags, NULL)) {
 		rc = -EFAULT;
 		goto out_up;
 	}
@@ -730,7 +730,8 @@ int gmap_ipte_notify(struct gmap *gmap, unsigned long gaddr, unsigned long len)
 			break;
 		}
 		/* Get the page mapped */
-		if (fixup_user_fault(current, gmap->mm, addr, FAULT_FLAG_WRITE)) {
+		if (fixup_user_fault(current, gmap->mm, addr, FAULT_FLAG_WRITE,
+				     NULL)) {
 			rc = -EFAULT;
 			break;
 		}
@@ -805,7 +806,8 @@ retry:
 	if (!(pte_val(*ptep) & _PAGE_INVALID) &&
 	     (pte_val(*ptep) & _PAGE_PROTECT)) {
 		pte_unmap_unlock(ptep, ptl);
-		if (fixup_user_fault(current, mm, addr, FAULT_FLAG_WRITE)) {
+		if (fixup_user_fault(current, mm, addr, FAULT_FLAG_WRITE,
+				     NULL)) {
 			up_read(&mm->mmap_sem);
 			return -EFAULT;
 		}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00bad77..7783073 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1163,7 +1163,8 @@ int invalidate_inode_page(struct page *page);
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
-			    unsigned long address, unsigned int fault_flags);
+			    unsigned long address, unsigned int fault_flags,
+			    bool *unlocked);
 #else
 static inline int handle_mm_fault(struct mm_struct *mm,
 			struct vm_area_struct *vma, unsigned long address,
@@ -1175,7 +1176,7 @@ static inline int handle_mm_fault(struct mm_struct *mm,
 }
 static inline int fixup_user_fault(struct task_struct *tsk,
 		struct mm_struct *mm, unsigned long address,
-		unsigned int fault_flags)
+		unsigned int fault_flags, bool *unlocked)
 {
 	/* should never happen if there's no MMU */
 	BUG();
diff --git a/kernel/futex.c b/kernel/futex.c
index 684d754..fb640c5 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -639,7 +639,7 @@ static int fault_in_user_writeable(u32 __user *uaddr)
 
 	down_read(&mm->mmap_sem);
 	ret = fixup_user_fault(current, mm, (unsigned long)uaddr,
-			       FAULT_FLAG_WRITE);
+			       FAULT_FLAG_WRITE, NULL);
 	up_read(&mm->mmap_sem);
 
 	return ret < 0 ? ret : 0;
diff --git a/mm/gup.c b/mm/gup.c
index deafa2c..4ed35a3 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -564,6 +564,8 @@ EXPORT_SYMBOL(__get_user_pages);
  * @mm:		mm_struct of target mm
  * @address:	user address
  * @fault_flags:flags to pass down to handle_mm_fault()
+ * @unlocked:	did we unlock the mmap_sem while retrying, maybe NULL if caller
+ *		does not allow retry
  *
  * This is meant to be called in the specific scenario where for locking reasons
  * we try to access user memory in atomic context (within a pagefault_disable()
@@ -575,17 +577,19 @@ EXPORT_SYMBOL(__get_user_pages);
  * The main difference with get_user_pages() is that this function will
  * unconditionally call handle_mm_fault() which will in turn perform all the
  * necessary SW fixup of the dirty and young bits in the PTE, while
- * handle_mm_fault() only guarantees to update these in the struct page.
+ * get_user_pages() only guarantees to update these in the struct page.
  *
  * This is important for some architectures where those bits also gate the
  * access permission to the page because they are maintained in software.  On
  * such architectures, gup() will not be enough to make a subsequent access
  * succeed.
  *
- * This has the same semantics wrt the @mm->mmap_sem as does filemap_fault().
+ * This function will not return with an unlocked mmap_sem. So it has not the
+ * same semantics wrt the @mm->mmap_sem as does filemap_fault().
  */
 int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
-		     unsigned long address, unsigned int fault_flags)
+		     unsigned long address, unsigned int fault_flags,
+		     bool *unlocked)
 {
 	struct vm_area_struct *vma;
 	vm_flags_t vm_flags;
@@ -599,6 +603,10 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	if (!(vm_flags & vma->vm_flags))
 		return -EFAULT;
 
+	if (unlocked)
+		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
+
+retry:
 	ret = handle_mm_fault(mm, vma, address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
@@ -609,12 +617,21 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			return -EFAULT;
 		BUG();
 	}
-	if (tsk) {
+	if (tsk && !(fault_flags & FAULT_FLAG_TRIED)) {
 		if (ret & VM_FAULT_MAJOR)
 			tsk->maj_flt++;
 		else
 			tsk->min_flt++;
 	}
+	if (ret & VM_FAULT_RETRY) {
+		down_read(&mm->mmap_sem);
+		if (!(fault_flags & FAULT_FLAG_TRIED)) {
+			*unlocked = true;
+			fault_flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			fault_flags |= FAULT_FLAG_TRIED;
+			goto retry;
+		}
+	}
 	return 0;
 }
 
-- 
2.3.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
