Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 59C7C6B029E
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:33:19 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id u206so20817201wme.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:33:19 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id jo7si39234128wjc.179.2016.04.05.14.33.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:33:18 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id e128so18595706pfe.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:33:18 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:33:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 12/31] huge tmpfs: extend get_user_pages_fast to shmem pmd
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051429160.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, David Miller <davem@davemloft.net>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

The arch-specific get_user_pages_fast() has a gup_huge_pmd() designed to
optimize the refcounting on anonymous THP and hugetlbfs pages, with one
atomic addition to compound head's common refcount.  That optimization
must be avoided on huge tmpfs team pages, which use normal separate page
refcounting.  We could combine the PageTeam and PageCompound cases into
a single simple loop, but would lose the compound optimization that way.

One cannot go through these functions without wondering why some arches
(x86, mips) like to SetPageReferenced, while the rest do not: an x86
optimization that missed being propagated to the other architectures?
No, see commit 8ee53820edfd ("thp: mmu_notifier_test_young"): it's a
KVM GRU EPT thing, maybe not useful beyond x86.  I've just followed
the established practice in each architecture.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Cc'ed to arch maintainers as an FYI: this patch is not expected to
go into the tree in the next few weeks, and depends upon a PageTeam
definition not yet available outside this huge tmpfs patchset.
Please refer to linux-mm or linux-kernel for more context.

 arch/mips/mm/gup.c  |   15 ++++++++++++++-
 arch/s390/mm/gup.c  |   19 ++++++++++++++++++-
 arch/sparc/mm/gup.c |   19 ++++++++++++++++++-
 arch/x86/mm/gup.c   |   15 ++++++++++++++-
 mm/gup.c            |   19 ++++++++++++++++++-
 5 files changed, 82 insertions(+), 5 deletions(-)

--- a/arch/mips/mm/gup.c
+++ b/arch/mips/mm/gup.c
@@ -81,9 +81,22 @@ static int gup_huge_pmd(pmd_t pmd, unsig
 	VM_BUG_ON(pte_special(pte));
 	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 
-	refs = 0;
 	head = pte_page(pte);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+
+	if (PageTeam(head)) {
+		/* Handle a huge tmpfs team with normal refcounting. */
+		do {
+			get_page(page);
+			SetPageReferenced(page);
+			pages[*nr] = page;
+			(*nr)++;
+			page++;
+		} while (addr += PAGE_SIZE, addr != end);
+		return 1;
+	}
+
+	refs = 0;
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -66,9 +66,26 @@ static inline int gup_huge_pmd(pmd_t *pm
 		return 0;
 	VM_BUG_ON(!pfn_valid(pmd_val(pmd) >> PAGE_SHIFT));
 
-	refs = 0;
 	head = pmd_page(pmd);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+
+	if (PageTeam(head)) {
+		/* Handle a huge tmpfs team with normal refcounting. */
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
+	refs = 0;
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -77,9 +77,26 @@ static int gup_huge_pmd(pmd_t *pmdp, pmd
 	if (write && !pmd_write(pmd))
 		return 0;
 
-	refs = 0;
 	head = pmd_page(pmd);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+
+	if (PageTeam(head)) {
+		/* Handle a huge tmpfs team with normal refcounting. */
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
+	refs = 0;
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -196,9 +196,22 @@ static noinline int gup_huge_pmd(pmd_t p
 	/* hugepages are never "special" */
 	VM_BUG_ON(pmd_flags(pmd) & _PAGE_SPECIAL);
 
-	refs = 0;
 	head = pmd_page(pmd);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+
+	if (PageTeam(head)) {
+		/* Handle a huge tmpfs team with normal refcounting. */
+		do {
+			get_page(page);
+			SetPageReferenced(page);
+			pages[*nr] = page;
+			(*nr)++;
+			page++;
+		} while (addr += PAGE_SIZE, addr != end);
+		return 1;
+	}
+
+	refs = 0;
 	do {
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1247,9 +1247,26 @@ static int gup_huge_pmd(pmd_t orig, pmd_
 	if (write && !pmd_write(orig))
 		return 0;
 
-	refs = 0;
 	head = pmd_page(orig);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+
+	if (PageTeam(head)) {
+		/* Handle a huge tmpfs team with normal refcounting. */
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
+	refs = 0;
 	do {
 		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
