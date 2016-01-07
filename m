Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B36AF828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:09:43 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id uo6so224809259pac.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:09:43 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xy7si53705206pab.6.2016.01.06.16.01.26
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:27 -0800 (PST)
Subject: [PATCH 15/31] mm: factor out VMA fault permission checking
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:26 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000126.4DFCD531@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


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
--- a/mm/gup.c~pkeys-10-pte-fault	2016-01-06 15:50:09.144315322 -0800
+++ b/mm/gup.c	2016-01-06 15:50:09.148315502 -0800
@@ -557,6 +557,18 @@ next_page:
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
@@ -588,15 +600,13 @@ int fixup_user_fault(struct task_struct
 		     unsigned long address, unsigned int fault_flags)
 {
 	struct vm_area_struct *vma;
-	vm_flags_t vm_flags;
 	int ret;
 
 	vma = find_extend_vma(mm, address);
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
