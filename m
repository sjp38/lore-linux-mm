Date: Tue, 3 Jun 2008 12:29:02 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/1] x86: get_user_pages_lockless support 1GB hugepages
Message-ID: <20080603102902.GA23454@wotan.suse.de>
References: <20080603095956.781009952@amd.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080603095956.781009952@amd.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com, Dave Kleikamp <shaggy@austin.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Badari Pulavarty <pbadari@us.ibm.com>, Zach Brown <zach.brown@oracle.com>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

Hi,

This patch couples lockless get_user_pages with the 1GB hugepages for
x86: if one is merged upstream first, this patch has to be merged with
the other.

---

x86: support 1GB hugepages with get_user_pages_lockless()

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/arch/x86/mm/gup.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/gup.c
+++ linux-2.6/arch/x86/mm/gup.c
@@ -122,7 +122,7 @@ static noinline int gup_huge_pmd(pmd_t p
 
 	refs = 0;
 	head = pte_page(pte);
-	page = head + ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
+	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
@@ -160,6 +160,38 @@ static int gup_pmd_range(pud_t pud, unsi
 	return 1;
 }
 
+static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
+		unsigned long end, int write, struct page **pages, int *nr)
+{
+	unsigned long mask;
+	pte_t pte = *(pte_t *)&pud;
+	struct page *head, *page;
+	int refs;
+
+	mask = _PAGE_PRESENT|_PAGE_USER;
+	if (write)
+		mask |= _PAGE_RW;
+	if ((pte_val(pte) & mask) != mask)
+		return 0;
+	/* hugepages are never "special" */
+	VM_BUG_ON(pte_val(pte) & _PAGE_SPECIAL);
+	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+
+	refs = 0;
+	head = pte_page(pte);
+	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+	do {
+		VM_BUG_ON(compound_head(page) != head);
+		pages[*nr] = page;
+		(*nr)++;
+		page++;
+		refs++;
+	} while (addr += PAGE_SIZE, addr != end);
+	get_head_page_multiple(head, refs);
+
+	return 1;
+}
+
 static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end, int write, struct page **pages, int *nr)
 {
 	unsigned long next;
@@ -172,8 +204,13 @@ static int gup_pud_range(pgd_t pgd, unsi
 		next = pud_addr_end(addr, end);
 		if (pud_none(pud))
 			return 0;
-		if (!gup_pmd_range(pud, addr, next, write, pages, nr))
-			return 0;
+		if (unlikely(pud_large(pud))) {
+			if (!gup_huge_pud(pud, addr, next, write, pages, nr))
+				return 0;
+		} else {
+			if (!gup_pmd_range(pud, addr, next, write, pages, nr))
+				return 0;
+		}
 	} while (pudp++, addr = next, addr != end);
 
 	return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
