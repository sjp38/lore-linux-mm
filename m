Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 08DFE6B00C8
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:27 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 28/34] thp: move maybe_pmd_mkwrite() out of mk_huge_pmd()
Date: Fri,  5 Apr 2013 14:59:52 +0300
Message-Id: <1365163198-29726-29-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It's confusing that mk_huge_pmd() has sematics different from mk_pte()
or mk_pmd().

Let's move maybe_pmd_mkwrite() out of mk_huge_pmd() and adjust
prototype to match mk_pte().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4a1d8d7..0cf2e79 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -691,11 +691,10 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 	return pmd;
 }
 
-static inline pmd_t mk_huge_pmd(struct page *page, struct vm_area_struct *vma)
+static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
 {
 	pmd_t entry;
-	entry = mk_pmd(page, vma->vm_page_prot);
-	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+	entry = mk_pmd(page, prot);
 	entry = pmd_mkhuge(entry);
 	return entry;
 }
@@ -723,7 +722,8 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		pte_free(mm, pgtable);
 	} else {
 		pmd_t entry;
-		entry = mk_huge_pmd(page, vma);
+		entry = mk_huge_pmd(page, vma->vm_page_prot);
+		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		/*
 		 * The spinlocking to take the lru_lock inside
 		 * page_add_new_anon_rmap() acts as a full memory
@@ -1212,7 +1212,8 @@ alloc:
 		goto out_mn;
 	} else {
 		pmd_t entry;
-		entry = mk_huge_pmd(new_page, vma);
+		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
+		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		pmdp_clear_flush(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
@@ -2386,7 +2387,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	__SetPageUptodate(new_page);
 	pgtable = pmd_pgtable(_pmd);
 
-	_pmd = mk_huge_pmd(new_page, vma);
+	_pmd = mk_huge_pmd(new_page, vma->vm_page_prot);
+	_pmd = maybe_pmd_mkwrite(pmd_mkdirty(_pmd), vma);
 
 	/*
 	 * spin_lock() below is not the equivalent of smp_wmb(), so
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
