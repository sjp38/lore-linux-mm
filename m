Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 557156B003C
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 11:32:48 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 6/8] thp: move maybe_pmd_mkwrite() out of mk_huge_pmd()
Date: Tue, 11 Jun 2013 18:35:17 +0300
Message-Id: <1370964919-16187-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1370964919-16187-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1370964919-16187-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It's confusing that mk_huge_pmd() has semantics different from mk_pte()
or mk_pmd(). I spent some time on debugging issue cased by this
inconsistency.

Let's move maybe_pmd_mkwrite() out of mk_huge_pmd() and adjust
prototype to match mk_pte().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 mm/huge_memory.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3622e0be..5cd63f0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -695,11 +695,10 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
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
@@ -732,7 +731,8 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		pte_free(mm, pgtable);
 	} else {
 		pmd_t entry;
-		entry = mk_huge_pmd(page, vma);
+		entry = mk_huge_pmd(page, vma->vm_page_prot);
+		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		page_add_new_anon_rmap(page, vma, haddr);
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
 		set_pmd_at(mm, haddr, pmd, entry);
@@ -1215,7 +1215,8 @@ alloc:
 		goto out_mn;
 	} else {
 		pmd_t entry;
-		entry = mk_huge_pmd(new_page, vma);
+		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
+		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		pmdp_clear_flush(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
@@ -2361,7 +2362,8 @@ static void collapse_huge_page(struct mm_struct *mm,
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
