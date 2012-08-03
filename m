Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id A218F6B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 08:56:46 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so736035vbk.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 05:56:45 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 3 Aug 2012 20:56:45 +0800
Message-ID: <CAJd=RBB=jKD+9JcuBmBGC8R8pAQ-QoWHexMNMsXpb9zV548h5g@mail.gmail.com>
Subject: [patch] hugetlb: correct page offset index for sharing pmd
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

The computation of page offset index is open coded, and incorrect, to
be used in scanning prio tree, as huge page offset is required, and is
fixed with the well defined routine.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/arch/x86/mm/hugetlbpage.c	Fri Aug  3 20:34:58 2012
+++ b/arch/x86/mm/hugetlbpage.c	Fri Aug  3 20:40:16 2012
@@ -72,12 +72,15 @@ static void huge_pmd_share(struct mm_str
 	if (!vma_shareable(vma, addr))
 		return;

+	idx = linear_page_index(vma, addr);
+
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;

-		saddr = page_table_shareable(svma, vma, addr, idx);
+		saddr = page_table_shareable(svma, vma, addr,
+						idx * (PMD_SIZE/PAGE_SIZE));
 		if (saddr) {
 			spte = huge_pte_offset(svma->vm_mm, saddr);
 			if (spte) {
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
