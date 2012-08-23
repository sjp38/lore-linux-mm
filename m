Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 736556B0069
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 13:19:00 -0400 (EDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 23 Aug 2012 18:18:58 +0100
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7NHIojT11731186
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 17:18:50 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7NHItln018787
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:18:56 -0600
Message-Id: <20120823171854.900446400@de.ibm.com>
Date: Thu, 23 Aug 2012 19:17:39 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [RFC patch 6/7] thp, s390: disable thp for kvm host on System z
References: <20120823171733.595087166@de.ibm.com>
Content-Disposition: inline; filename=linux-3.5-thp-s390-kvm.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com
Cc: linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

This patch is part of the architecture backend for thp on System z.
It disables thp for kvm hosts, because there is no kvm host hugepage
support so far. Existing thp mappings are split using follow_page()
with FOLL_SPLIT, and future thp mappings are prevented by setting
VM_NOHUGEPAGE in mm->def_flags.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 arch/s390/mm/pgtable.c |   30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -787,6 +787,30 @@ void tlb_remove_table(struct mmu_gather
 		tlb_table_flush(tlb);
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+void thp_split_vma(struct vm_area_struct *vma)
+{
+	unsigned long addr;
+	struct page *page;
+
+	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
+		page = follow_page(vma, addr, FOLL_SPLIT);
+	}
+}
+
+void thp_split_mm(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma = mm->mmap;
+
+	while (vma != NULL) {
+		thp_split_vma(vma);
+		vma->vm_flags &= ~VM_HUGEPAGE;
+		vma->vm_flags |= VM_NOHUGEPAGE;
+		vma = vma->vm_next;
+	}
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 /*
  * switch on pgstes for its userspace process (for kvm)
  */
@@ -824,6 +848,12 @@ int s390_enable_sie(void)
 	if (!mm)
 		return -ENOMEM;
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	/* split thp mappings and disable thp for future mappings */
+	thp_split_mm(mm);
+	mm->def_flags |= VM_NOHUGEPAGE;
+#endif
+
 	/* Now lets check again if something happened */
 	task_lock(tsk);
 	if (!tsk->mm || atomic_read(&tsk->mm->mm_users) > 1 ||

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
