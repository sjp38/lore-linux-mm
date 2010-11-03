Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6E5088D0008
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:29:36 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 24 of 66] split_huge_page_mm/vma
Message-Id: <1983416b12c8937b0759.1288798079@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:27:59 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

split_huge_page_pmd compat code. Each one of those would need to be expanded to
hundred of lines of complex code without a fully reliable
split_huge_page_pmd design.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -179,6 +179,7 @@ static void mark_screen_rdonly(struct mm
 	if (pud_none_or_clear_bad(pud))
 		goto out;
 	pmd = pmd_offset(pud, 0xA0000);
+	split_huge_page_pmd(mm, pmd);
 	if (pmd_none_or_clear_bad(pmd))
 		goto out;
 	pte = pte_offset_map_lock(mm, pmd, 0xA0000, &ptl);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -514,6 +514,7 @@ static inline int check_pmd_range(struct
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		split_huge_page_pmd(vma->vm_mm, pmd);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		if (check_pte_range(vma, pmd, addr, next, nodes,
diff --git a/mm/mincore.c b/mm/mincore.c
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -154,6 +154,7 @@ static void mincore_pmd_range(struct vm_
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		split_huge_page_pmd(vma->vm_mm, pmd);
 		if (pmd_none_or_clear_bad(pmd))
 			mincore_unmapped_range(vma, addr, next, vec);
 		else
diff --git a/mm/mprotect.c b/mm/mprotect.c
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -88,6 +88,7 @@ static inline void change_pmd_range(stru
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		split_huge_page_pmd(mm, pmd);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		change_pte_range(mm, pmd, addr, next, newprot, dirty_accountable);
diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -41,6 +41,7 @@ static pmd_t *get_old_pmd(struct mm_stru
 		return NULL;
 
 	pmd = pmd_offset(pud, addr);
+	split_huge_page_pmd(mm, pmd);
 	if (pmd_none_or_clear_bad(pmd))
 		return NULL;
 
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -34,6 +34,7 @@ static int walk_pmd_range(pud_t *pud, un
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		split_huge_page_pmd(walk->mm, pmd);
 		if (pmd_none_or_clear_bad(pmd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
