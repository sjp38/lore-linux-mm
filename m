Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id EC7256B0068
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 13:18:59 -0400 (EDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 23 Aug 2012 18:18:58 +0100
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7NHInBc28639272
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 17:18:49 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7NHIsfo018767
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:18:55 -0600
Message-Id: <20120823171854.580076595@de.ibm.com>
Date: Thu, 23 Aug 2012 19:17:36 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [RFC patch 3/7] thp: make MADV_HUGEPAGE check for mm->def_flags
References: <20120823171733.595087166@de.ibm.com>
Content-Disposition: inline; filename=linux-3.5-thp-madvise.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com
Cc: linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

This adds a check to hugepage_madvise(), to refuse MADV_HUGEPAGE
if VM_NOHUGEPAGE is set in mm->def_flags. On System z, the VM_NOHUGEPAGE
flag will be set in mm->def_flags for kvm processes, to prevent any
future thp mappings. In order to also prevent MADV_HUGEPAGE on such an
mm, hugepage_madvise() should check mm->def_flags.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 mm/huge_memory.c |    4 ++++
 1 file changed, 4 insertions(+)

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1464,6 +1464,8 @@ out:
 int hugepage_madvise(struct vm_area_struct *vma,
 		     unsigned long *vm_flags, int advice)
 {
+	struct mm_struct *mm = vma->vm_mm;
+
 	switch (advice) {
 	case MADV_HUGEPAGE:
 		/*
@@ -1471,6 +1473,8 @@ int hugepage_madvise(struct vm_area_stru
 		 */
 		if (*vm_flags & (VM_HUGEPAGE | VM_NO_THP))
 			return -EINVAL;
+		if (mm->def_flags & VM_NOHUGEPAGE)
+			return -EINVAL;
 		*vm_flags &= ~VM_NOHUGEPAGE;
 		*vm_flags |= VM_HUGEPAGE;
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
