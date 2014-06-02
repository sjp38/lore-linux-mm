Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id C94E96B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 17:36:48 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id hz1so2322241pad.5
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 14:36:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id bm3si17550010pad.232.2014.06.02.14.36.47
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 14:36:47 -0700 (PDT)
Subject: [PATCH 01/10] mm: pagewalk: consolidate vma->vm_start checks
From: Dave Hansen <dave@sr71.net>
Date: Mon, 02 Jun 2014 14:36:45 -0700
References: <20140602213644.925A26D0@viggo.jf.intel.com>
In-Reply-To: <20140602213644.925A26D0@viggo.jf.intel.com>
Message-Id: <20140602213645.290B349F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

We check vma->vm_start against the address being walked twice.
Consolidate the locations down to a single one.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/mm/pagewalk.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff -puN mm/pagewalk.c~pagewalk-always-skip-hugetlbfs-except-when-explicitly-handled mm/pagewalk.c
--- a/mm/pagewalk.c~pagewalk-always-skip-hugetlbfs-except-when-explicitly-handled	2014-06-02 14:20:18.938791410 -0700
+++ b/mm/pagewalk.c	2014-06-02 14:20:18.941791545 -0700
@@ -192,13 +192,12 @@ int walk_page_range(unsigned long addr,
 		 * - VM_PFNMAP vma's
 		 */
 		vma = find_vma(walk->mm, addr);
-		if (vma) {
+		if (vma && (vma->vm_start <= addr)) {
 			/*
 			 * There are no page structures backing a VM_PFNMAP
 			 * range, so do not allow split_huge_page_pmd().
 			 */
-			if ((vma->vm_start <= addr) &&
-			    (vma->vm_flags & VM_PFNMAP)) {
+			if (vma->vm_flags & VM_PFNMAP) {
 				next = vma->vm_end;
 				pgd = pgd_offset(walk->mm, next);
 				continue;
@@ -209,8 +208,7 @@ int walk_page_range(unsigned long addr,
 			 * architecture and we can't handled it in the same
 			 * manner as non-huge pages.
 			 */
-			if (walk->hugetlb_entry && (vma->vm_start <= addr) &&
-			    is_vm_hugetlb_page(vma)) {
+			if (walk->hugetlb_entry && is_vm_hugetlb_page(vma)) {
 				if (vma->vm_end < next)
 					next = vma->vm_end;
 				/*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
