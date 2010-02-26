Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4BA336B00A5
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:27 -0500 (EST)
Message-Id: <20100226200902.284065683@redhat.com>
Date: Fri, 26 Feb 2010 21:04:54 +0100
From: aarcange@redhat.com
Subject: [patch 21/35] split_huge_page_mm/vma
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=split_huge_page_mm_vma
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

split_huge_page_mm/vma compat code. Each one of those would need to be expanded
to hundred of lines of complex code without a fully reliable
split_huge_page_mm/vma functionality.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 arch/x86/kernel/vm86_32.c |    1 +
 mm/mempolicy.c            |    1 +
 mm/mincore.c              |    1 +
 mm/mprotect.c             |    1 +
 mm/mremap.c               |    1 +
 mm/pagewalk.c             |    1 +
 6 files changed, 6 insertions(+)

--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -179,6 +179,7 @@ static void mark_screen_rdonly(struct mm
 	if (pud_none_or_clear_bad(pud))
 		goto out;
 	pmd = pmd_offset(pud, 0xA0000);
+	split_huge_page_mm(mm, 0xA0000, pmd);
 	if (pmd_none_or_clear_bad(pmd))
 		goto out;
 	pte = pte_offset_map_lock(mm, pmd, 0xA0000, &ptl);
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -446,6 +446,7 @@ static inline int check_pmd_range(struct
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		split_huge_page_vma(vma, pmd);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		if (check_pte_range(vma, pmd, addr, next, nodes,
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -132,6 +132,7 @@ static long do_mincore(unsigned long add
 	if (pud_none_or_clear_bad(pud))
 		goto none_mapped;
 	pmd = pmd_offset(pud, addr);
+	split_huge_page_vma(vma, pmd);
 	if (pmd_none_or_clear_bad(pmd))
 		goto none_mapped;
 
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -89,6 +89,7 @@ static inline void change_pmd_range(stru
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		split_huge_page_mm(mm, addr, pmd);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		change_pte_range(mm, pmd, addr, next, newprot, dirty_accountable);
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -42,6 +42,7 @@ static pmd_t *get_old_pmd(struct mm_stru
 		return NULL;
 
 	pmd = pmd_offset(pud, addr);
+	split_huge_page_mm(mm, addr, pmd);
 	if (pmd_none_or_clear_bad(pmd))
 		return NULL;
 
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -34,6 +34,7 @@ static int walk_pmd_range(pud_t *pud, un
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		split_huge_page_mm(walk->mm, addr, pmd);
 		if (pmd_none_or_clear_bad(pmd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
