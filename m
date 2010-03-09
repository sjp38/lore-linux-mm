Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DCC676B008A
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 14:44:15 -0500 (EST)
Message-Id: <20100309194316.304894100@redhat.com>
Date: Tue, 09 Mar 2010 20:39:30 +0100
From: aarcange@redhat.com
Subject: [patch 29/35] verify pmd_trans_huge isnt leaking
References: <20100309193901.207868642@redhat.com>
Content-Disposition: inline; filename=debug_pte_trans_huge
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

pte_trans_huge must not leak in certain vmas like the mmio special pfn or
filebacked mappings.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/memory.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1427,6 +1427,7 @@ int __get_user_pages(struct task_struct 
 			pmd = pmd_offset(pud, pg);
 			if (pmd_none(*pmd))
 				return i ? : -EFAULT;
+			VM_BUG_ON(pmd_trans_huge(*pmd));
 			pte = pte_offset_map(pmd, pg);
 			if (pte_none(*pte)) {
 				pte_unmap(pte);
@@ -1628,8 +1629,10 @@ pte_t *get_locked_pte(struct mm_struct *
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
@@ -1848,6 +1851,7 @@ static inline int remap_pmd_range(struct
 	pmd = pmd_alloc(mm, pud, addr);
 	if (!pmd)
 		return -ENOMEM;
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	do {
 		next = pmd_addr_end(addr, end);
 		if (remap_pte_range(mm, pmd, addr, next,
@@ -3323,6 +3327,7 @@ static int follow_pte(struct mm_struct *
 		goto out;
 
 	pmd = pmd_offset(pud, address);
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto out;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
