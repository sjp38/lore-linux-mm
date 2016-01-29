Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 68A6A828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:17:21 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id ho8so45051844pac.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:21 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id we3si3530534pab.52.2016.01.29.10.17.04
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:17:04 -0800 (PST)
Subject: [PATCH 15/31] mm: factor out VMA fault permission checking
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:17:03 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181703.02114D45@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

This code matches a fault condition up with the VMA and ensures
that the VMA allows the fault to be handled instead of just
erroring out.

We will be extending this in a moment to comprehend protection
keys.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/mm/gup.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff -puN mm/gup.c~pkeys-10-pte-fault mm/gup.c
--- a/mm/gup.c~pkeys-10-pte-fault	2016-01-28 15:52:22.856518359 -0800
+++ b/mm/gup.c	2016-01-28 15:52:22.860518543 -0800
@@ -611,6 +611,18 @@ next_page:
 }
 EXPORT_SYMBOL(__get_user_pages);
 
+bool vma_permits_fault(struct vm_area_struct *vma, unsigned int fault_flags)
+{
+	vm_flags_t vm_flags;
+
+	vm_flags = (fault_flags & FAULT_FLAG_WRITE) ? VM_WRITE : VM_READ;
+
+	if (!(vm_flags & vma->vm_flags))
+		return false;
+
+	return true;
+}
+
 /*
  * fixup_user_fault() - manually resolve a user page fault
  * @tsk:	the task_struct to use for page fault accounting, or
@@ -646,7 +658,6 @@ int fixup_user_fault(struct task_struct
 		     bool *unlocked)
 {
 	struct vm_area_struct *vma;
-	vm_flags_t vm_flags;
 	int ret, major = 0;
 
 	if (unlocked)
@@ -657,8 +668,7 @@ retry:
 	if (!vma || address < vma->vm_start)
 		return -EFAULT;
 
-	vm_flags = (fault_flags & FAULT_FLAG_WRITE) ? VM_WRITE : VM_READ;
-	if (!(vm_flags & vma->vm_flags))
+	if (!vma_permits_fault(vma, fault_flags))
 		return -EFAULT;
 
 	ret = handle_mm_fault(mm, vma, address, fault_flags);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
