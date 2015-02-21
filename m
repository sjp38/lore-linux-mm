Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id AD5F46B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:12:25 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so12888872pab.4
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:12:25 -0800 (PST)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id qd9si3575174pbc.73.2015.02.20.20.12.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:12:24 -0800 (PST)
Received: by pdbfp1 with SMTP id fp1so12046225pdb.5
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:12:24 -0800 (PST)
Date: Fri, 20 Feb 2015 20:12:22 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 13/24] huge tmpfs: extend get_user_pages_fast to shmem pmd
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202011070.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Factor out one small part of the shmem pmd handling: the arch-specific
get_user_pages_fast() has special code to cope with the peculiar
refcounting on anonymous THP tail pages (and on hugetlbfs tail pages):
which must be avoided in the straightforward shmem pmd case.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 arch/mips/mm/gup.c  |   17 ++++++++++++-----
 arch/s390/mm/gup.c  |   22 +++++++++++++++++++++-
 arch/sparc/mm/gup.c |   22 +++++++++++++++++++++-
 arch/x86/mm/gup.c   |   17 ++++++++++++-----
 mm/gup.c            |   22 +++++++++++++++++++++-
 5 files changed, 87 insertions(+), 13 deletions(-)

--- thpfs.orig/arch/mips/mm/gup.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/arch/mips/mm/gup.c	2015-02-20 19:34:26.971957306 -0800
@@ -64,7 +64,8 @@ static inline void get_head_page_multipl
 {
 	VM_BUG_ON(page != compound_head(page));
 	VM_BUG_ON(page_count(page) == 0);
-	atomic_add(nr, &page->_count);
+	if (nr)
+		atomic_add(nr, &page->_count);
 	SetPageReferenced(page);
 }
 
@@ -85,13 +86,19 @@ static int gup_huge_pmd(pmd_t pmd, unsig
 	head = pte_page(pte);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	do {
-		VM_BUG_ON(compound_head(page) != head);
-		pages[*nr] = page;
-		if (PageTail(page))
+		if (PageTail(page)) {
+			VM_BUG_ON(compound_head(page) != head);
 			get_huge_page_tail(page);
+			refs++;
+		} else {
+			/*
+			 * Handle head or huge tmpfs with normal refcounting.
+			 */
+			get_page(page);
+		}
+		pages[*nr] = page;
 		(*nr)++;
 		page++;
-		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
 	get_head_page_multiple(head, refs);
--- thpfs.orig/arch/s390/mm/gup.c	2014-01-19 18:40:07.000000000 -0800
+++ thpfs/arch/s390/mm/gup.c	2015-02-20 19:34:26.971957306 -0800
@@ -61,10 +61,30 @@ static inline int gup_huge_pmd(pmd_t *pm
 		return 0;
 	VM_BUG_ON(!pfn_valid(pmd_val(pmd) >> PAGE_SHIFT));
 
-	refs = 0;
 	head = pmd_page(pmd);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+
+	if (!PageHead(head)) {
+		/*
+		 * Handle a huge tmpfs team with normal refcounting.
+		 */
+		do {
+			if (!page_cache_get_speculative(page))
+				return 0;
+			if (unlikely(pmd_val(pmd) != pmd_val(*pmdp))) {
+				put_page(page);
+				return 0;
+			}
+			pages[*nr] = page;
+			(*nr)++;
+			page++;
+		} while (addr += PAGE_SIZE, addr != end);
+		return 1;
+	}
+
 	tail = page;
+	refs = 0;
+
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
--- thpfs.orig/arch/sparc/mm/gup.c	2014-12-07 14:21:05.000000000 -0800
+++ thpfs/arch/sparc/mm/gup.c	2015-02-20 19:34:26.975957297 -0800
@@ -79,10 +79,30 @@ static int gup_huge_pmd(pmd_t *pmdp, pmd
 	if (write && !pmd_write(pmd))
 		return 0;
 
-	refs = 0;
 	head = pmd_page(pmd);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+
+	if (!PageHead(head)) {
+		/*
+		 * Handle a huge tmpfs team with normal refcounting.
+		 */
+		do {
+			if (!page_cache_get_speculative(page))
+				return 0;
+			if (unlikely(pmd_val(pmd) != pmd_val(*pmdp))) {
+				put_page(page);
+				return 0;
+			}
+			pages[*nr] = page;
+			(*nr)++;
+			page++;
+		} while (addr += PAGE_SIZE, addr != end);
+		return 1;
+	}
+
 	tail = page;
+	refs = 0;
+
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
--- thpfs.orig/arch/x86/mm/gup.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/arch/x86/mm/gup.c	2015-02-20 19:34:26.975957297 -0800
@@ -110,7 +110,8 @@ static inline void get_head_page_multipl
 {
 	VM_BUG_ON_PAGE(page != compound_head(page), page);
 	VM_BUG_ON_PAGE(page_count(page) == 0, page);
-	atomic_add(nr, &page->_count);
+	if (nr)
+		atomic_add(nr, &page->_count);
 	SetPageReferenced(page);
 }
 
@@ -135,13 +136,19 @@ static noinline int gup_huge_pmd(pmd_t p
 	head = pte_page(pte);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
-		pages[*nr] = page;
-		if (PageTail(page))
+		if (PageTail(page)) {
+			VM_BUG_ON_PAGE(compound_head(page) != head, page);
 			get_huge_page_tail(page);
+			refs++;
+		} else {
+			/*
+			 * Handle head or huge tmpfs with normal refcounting.
+			 */
+			get_page(page);
+		}
+		pages[*nr] = page;
 		(*nr)++;
 		page++;
-		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 	get_head_page_multiple(head, refs);
 
--- thpfs.orig/mm/gup.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/gup.c	2015-02-20 19:34:26.975957297 -0800
@@ -795,10 +795,30 @@ static int gup_huge_pmd(pmd_t orig, pmd_
 	if (write && !pmd_write(orig))
 		return 0;
 
-	refs = 0;
 	head = pmd_page(orig);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+
+	if (!PageHead(head)) {
+		/*
+		 * Handle a huge tmpfs team with normal refcounting.
+		 */
+		do {
+			if (!page_cache_get_speculative(page))
+				return 0;
+			if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
+				put_page(page);
+				return 0;
+			}
+			pages[*nr] = page;
+			(*nr)++;
+			page++;
+		} while (addr += PAGE_SIZE, addr != end);
+		return 1;
+	}
+
 	tail = page;
+	refs = 0;
+
 	do {
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
