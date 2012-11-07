Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 072126B005A
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 10:00:10 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v5 02/11] thp: zap_huge_pmd(): zap huge zero pmd
Date: Wed,  7 Nov 2012 17:00:54 +0200
Message-Id: <1352300463-12627-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't have a real page to zap in huge zero page case. Let's just
clear pmd and remove it from tlb.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e5ce979..ff834ea 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1058,15 +1058,20 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		pmd_t orig_pmd;
 		pgtable = pgtable_trans_huge_withdraw(tlb->mm);
 		orig_pmd = pmdp_get_and_clear(tlb->mm, addr, pmd);
-		page = pmd_page(orig_pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
-		page_remove_rmap(page);
-		VM_BUG_ON(page_mapcount(page) < 0);
-		add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
-		VM_BUG_ON(!PageHead(page));
-		tlb->mm->nr_ptes--;
-		spin_unlock(&tlb->mm->page_table_lock);
-		tlb_remove_page(tlb, page);
+		if (is_huge_zero_pmd(orig_pmd)) {
+			tlb->mm->nr_ptes--;
+			spin_unlock(&tlb->mm->page_table_lock);
+		} else {
+			page = pmd_page(orig_pmd);
+			page_remove_rmap(page);
+			VM_BUG_ON(page_mapcount(page) < 0);
+			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+			VM_BUG_ON(!PageHead(page));
+			tlb->mm->nr_ptes--;
+			spin_unlock(&tlb->mm->page_table_lock);
+			tlb_remove_page(tlb, page);
+		}
 		pte_free(tlb->mm, pgtable);
 		ret = 1;
 	}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
