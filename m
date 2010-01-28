Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0B81D6B00C3
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 09:57:57 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 21 of 31] split_huge_page_mm/vma
Message-Id: <7b48266c6c48b8d8e7d4.1264689215@v2.random>
In-Reply-To: <patchbomb.1264689194@v2.random>
References: <patchbomb.1264689194@v2.random>
Date: Thu, 28 Jan 2010 15:33:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

split_huge_page_mm/vma compat code. Each one of those would need to be expanded
to hundred of lines of complex code without a fully reliable
split_huge_page_mm/vma functionality.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---

diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
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
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
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
diff --git a/mm/mincore.c b/mm/mincore.c
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -132,6 +132,7 @@ static long do_mincore(unsigned long add
 	if (pud_none_or_clear_bad(pud))
 		goto none_mapped;
 	pmd = pmd_offset(pud, addr);
+	split_huge_page_vma(vma, pmd);
 	if (pmd_none_or_clear_bad(pmd))
 		goto none_mapped;
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
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
diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -42,6 +42,7 @@ static pmd_t *get_old_pmd(struct mm_stru
 		return NULL;
 
 	pmd = pmd_offset(pud, addr);
+	split_huge_page_mm(mm, addr, pmd);
 	if (pmd_none_or_clear_bad(pmd))
 		return NULL;
 
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
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
