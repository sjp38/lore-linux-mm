Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E65B76B06DB
	for <linux-mm@kvack.org>; Sat, 12 May 2018 02:15:07 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s7-v6so3010618pgp.15
        for <linux-mm@kvack.org>; Fri, 11 May 2018 23:15:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u196-v6sor1738993pgc.38.2018.05.11.23.15.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 May 2018 23:15:06 -0700 (PDT)
Date: Sat, 12 May 2018 11:47:12 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v3] mm: Change return type to vm_fault_t
Message-ID: <20180512061712.GA26660@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, hughd@google.com, dan.j.williams@intel.com, rientjes@google.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@infradead.org

Use new return type vm_fault_t for fault handler
in struct vm_operations_struct. For now, this is
just documenting that the function returns a
VM_FAULT value rather than an errno.  Once all
instances are converted, vm_fault_t will become
a distinct type.

commit 1c8f422059ae ("mm: change return type to
vm_fault_t")

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
v2: updated the change log

v3: added <linux/mm_types.h> changes
    into the same patch

 include/linux/mm_types.h | 2 +-
 mm/hugetlb.c             | 2 +-
 mm/mmap.c                | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2161234..11acfdb 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -627,7 +627,7 @@ struct vm_special_mapping {
 	 * If non-NULL, then this is called to resolve page faults
 	 * on the special mapping.  If used, .pages is not checked.
 	 */
-	int (*fault)(const struct vm_special_mapping *sm,
+	vm_fault_t (*fault)(const struct vm_special_mapping *sm,
 		     struct vm_area_struct *vma,
 		     struct vm_fault *vmf);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2186791..7e00bd3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3159,7 +3159,7 @@ static unsigned long hugetlb_vm_op_pagesize(struct vm_area_struct *vma)
  * hugegpage VMA.  do_page_fault() is supposed to trap this, so BUG is we get
  * this far.
  */
-static int hugetlb_vm_op_fault(struct vm_fault *vmf)
+static vm_fault_t hugetlb_vm_op_fault(struct vm_fault *vmf)
 {
 	BUG();
 	return 0;
diff --git a/mm/mmap.c b/mm/mmap.c
index 188f195..bdd4ba9a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3228,7 +3228,7 @@ void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
 		mm->data_vm += npages;
 }
 
-static int special_mapping_fault(struct vm_fault *vmf);
+static vm_fault_t special_mapping_fault(struct vm_fault *vmf);
 
 /*
  * Having a close hook prevents vma merging regardless of flags.
@@ -3267,7 +3267,7 @@ static int special_mapping_mremap(struct vm_area_struct *new_vma)
 	.fault = special_mapping_fault,
 };
 
-static int special_mapping_fault(struct vm_fault *vmf)
+static vm_fault_t special_mapping_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	pgoff_t pgoff;
-- 
1.9.1
