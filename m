Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 57DFC6B004D
	for <linux-mm@kvack.org>; Sun, 21 Feb 2010 09:18:47 -0500 (EST)
Message-Id: <20100221141757.257019845@redhat.com>
Date: Sun, 21 Feb 2010 15:10:37 +0100
From: aarcange@redhat.com
Subject: [patch 28/36] adapt to mm_counter in -mm
References: <20100221141009.581909647@redhat.com>
Content-Disposition: inline; filename=mm-rss
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

The interface changed slightly.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -249,7 +249,7 @@ static int __do_huge_pmd_anonymous_page(
 		page_add_new_anon_rmap(page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		prepare_pmd_huge_pte(pgtable, mm);
-		add_mm_counter(mm, anon_rss, HPAGE_PMD_NR);
+		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		spin_unlock(&mm->page_table_lock);
 	}
 
@@ -320,7 +320,7 @@ int copy_huge_pmd(struct mm_struct *dst_
 	VM_BUG_ON(!PageHead(src_page));
 	get_page(src_page);
 	page_dup_rmap(src_page);
-	add_mm_counter(dst_mm, anon_rss, HPAGE_PMD_NR);
+	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
@@ -561,7 +561,7 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 			pmd_clear(pmd);
 			page_remove_rmap(page);
 			VM_BUG_ON(page_mapcount(page) < 0);
-			add_mm_counter(tlb->mm, anon_rss, -HPAGE_PMD_NR);
+			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 			spin_unlock(&tlb->mm->page_table_lock);
 			VM_BUG_ON(!PageHead(page));
 			tlb_remove_page(tlb, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
