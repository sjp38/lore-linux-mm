Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6890E8D0018
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:15 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 32 of 66] verify pmd_trans_huge isn't leaking
Message-Id: <72703601b72dc596d978.1288798087@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:07 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

pte_trans_huge must not leak in certain vmas like the mmio special pfn or
filebacked mappings.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1428,6 +1428,7 @@ int __get_user_pages(struct task_struct 
 			pmd = pmd_offset(pud, pg);
 			if (pmd_none(*pmd))
 				return i ? : -EFAULT;
+			VM_BUG_ON(pmd_trans_huge(*pmd));
 			pte = pte_offset_map(pmd, pg);
 			if (pte_none(*pte)) {
 				pte_unmap(pte);
@@ -1640,8 +1641,10 @@ pte_t *__get_locked_pte(struct mm_struct
 	pud_t * pud = pud_alloc(mm, pgd, addr);
 	if (pud) {
 		pmd_t * pmd = pmd_alloc(mm, pud, addr);
-		if (pmd)
+		if (pmd) {
+			VM_BUG_ON(pmd_trans_huge(*pmd));
 			return pte_alloc_map_lock(mm, pmd, addr, ptl);
+		}
 	}
 	return NULL;
 }
@@ -1860,6 +1863,7 @@ static inline int remap_pmd_range(struct
 	pmd = pmd_alloc(mm, pud, addr);
 	if (!pmd)
 		return -ENOMEM;
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	do {
 		next = pmd_addr_end(addr, end);
 		if (remap_pte_range(mm, pmd, addr, next,
@@ -3428,6 +3432,7 @@ static int __follow_pte(struct mm_struct
 		goto out;
 
 	pmd = pmd_offset(pud, address);
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto out;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
