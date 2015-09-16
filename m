Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 504C86B0267
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:50:50 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so219560782pac.2
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:50:50 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id lg2si42353578pbc.60.2015.09.16.10.50.47
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:50:47 -0700 (PDT)
Subject: [PATCH 12/26] mm: factor out VMA fault permission checking
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:07 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174907.D6419FD0@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


This code matches a fault condition up with the VMA and ensures
that the VMA allows the fault to be handled instead of just
erroring out.

We will be extending this in a moment to comprehend protection
keys.

---

 b/mm/gup.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff -puN mm/gup.c~pkeys-10-pte-fault mm/gup.c
--- a/mm/gup.c~pkeys-10-pte-fault	2015-09-16 10:48:16.591207512 -0700
+++ b/mm/gup.c	2015-09-16 10:48:16.595207693 -0700
@@ -554,6 +554,17 @@ next_page:
 }
 EXPORT_SYMBOL(__get_user_pages);
 
+bool vma_permits_fault(struct vm_area_struct *vma, unsigned int fault_flags)
+{
+        vm_flags_t vm_flags =
+		(fault_flags & FAULT_FLAG_WRITE) ? VM_WRITE : VM_READ;
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
@@ -585,15 +596,13 @@ int fixup_user_fault(struct task_struct
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
