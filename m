Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 945C76B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 19:56:12 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p0B0u87q022859
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 16:56:10 -0800
Received: from gwj23 (gwj23.prod.google.com [10.200.10.23])
	by kpbe13.cbf.corp.google.com with ESMTP id p0B0skLE022089
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 16:56:07 -0800
Received: by gwj23 with SMTP id 23so9671889gwj.4
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 16:56:06 -0800 (PST)
Date: Mon, 10 Jan 2011 16:55:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm] thp: transparent hugepage core fixlet
Message-ID: <alpine.LSU.2.00.1101101652200.11559@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If you configure THP in addition to HUGETLB_PAGE on x86_32 without PAE,
the p?d-folding works out that munlock_vma_pages_range() can crash to
follow_page()'s pud_huge() BUG_ON(flags & FOLL_GET): it needs the same
VM_HUGETLB check already there on the pmd_huge() line.  Conveniently,
openSUSE provides a "blogd" which tests this out at startup!

Signed-off-by: Hugh Dickins <hughd@google.com>
---
This massive rework belongs just after thp-transparent-hugepage-core.patch

 mm/memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm.orig/mm/memory.c	2011-01-10 16:31:29.000000000 -0800
+++ mmotm/mm/memory.c	2011-01-10 16:33:16.000000000 -0800
@@ -1288,7 +1288,7 @@ struct page *follow_page(struct vm_area_
 	pud = pud_offset(pgd, address);
 	if (pud_none(*pud))
 		goto no_page_table;
-	if (pud_huge(*pud)) {
+	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
 		BUG_ON(flags & FOLL_GET);
 		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
 		goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
