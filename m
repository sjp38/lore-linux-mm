Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C99B0828F3
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 16:02:27 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id ho8so52466055pac.2
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:02:27 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id dg7si22158755pad.75.2016.02.12.13.02.17
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 13:02:17 -0800 (PST)
Subject: [PATCH 17/33] mm: factor out VMA fault permission checking
From: Dave Hansen <dave@sr71.net>
Date: Fri, 12 Feb 2016 13:02:16 -0800
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
In-Reply-To: <20160212210152.9CAD15B0@viggo.jf.intel.com>
Message-Id: <20160212210216.C3824032@viggo.jf.intel.com>
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
--- a/mm/gup.c~pkeys-10-pte-fault	2016-02-12 10:44:21.164472103 -0800
+++ b/mm/gup.c	2016-02-12 10:44:21.167472240 -0800
@@ -610,6 +610,18 @@ next_page:
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
@@ -645,7 +657,6 @@ int fixup_user_fault(struct task_struct
 		     bool *unlocked)
 {
 	struct vm_area_struct *vma;
-	vm_flags_t vm_flags;
 	int ret, major = 0;
 
 	if (unlocked)
@@ -656,8 +667,7 @@ retry:
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
