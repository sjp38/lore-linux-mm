Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 830ED6B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 00:41:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id x205so3774227pgx.19
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 21:41:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x22-v6sor5816023pln.60.2018.04.24.21.41.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 21:41:30 -0700 (PDT)
Date: Wed, 25 Apr 2018 10:13:26 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v2] mm: huge_memory: Change return type to vm_fault_t
Message-ID: <20180425044326.GA21504@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, zi.yan@cs.rutgers.edu, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, ross.zwisler@linux.intel.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, shli@fb.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Use new return type vm_fault_t for fault handler. For
now, this is just documenting that the function returns
a VM_FAULT value rather than an errno. Once all instances
are converted, vm_fault_t will become a distinct type.

Commit 1c8f422059ae ("mm: change return type to vm_fault_t")

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
v2: Updated the change log

 include/linux/huge_mm.h | 5 +++--
 mm/huge_memory.c        | 4 ++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a8a1262..d3bbf6b 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -3,6 +3,7 @@
 #define _LINUX_HUGE_MM_H
 
 #include <linux/sched/coredump.h>
+#include <linux/mm_types.h>
 
 #include <linux/fs.h> /* only for vma_is_dax() */
 
@@ -46,9 +47,9 @@ extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
-int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, pfn_t pfn, bool write);
-int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 			pud_t *pud, pfn_t pfn, bool write);
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 87ab9b8..1fe4705 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -755,7 +755,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	spin_unlock(ptl);
 }
 
-int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
@@ -815,7 +815,7 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 	spin_unlock(ptl);
 }
 
-int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 			pud_t *pud, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
-- 
1.9.1
