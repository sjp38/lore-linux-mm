Date: Thu, 16 Jan 2003 22:03:27 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: i386 pgd_index() doesn't parenthesize its arg
Message-ID: <20030117060327.GQ919@holomorphy.com>
References: <20030117055128.GP919@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030117055128.GP919@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

PAE's pte_none() and pte_pfn() evaluate their arguments twice;
analogous fixes have been made to other things; c.f. pgtable.h's long
list of one-line inlines with parentheses still around their args.


===== include/asm-i386/pgtable-3level.h 1.8 vs edited =====
--- 1.8/include/asm-i386/pgtable-3level.h	Fri Jul 26 06:23:51 2002
+++ edited/include/asm-i386/pgtable-3level.h	Thu Jan 16 21:59:08 2003
@@ -89,8 +89,8 @@
 }
 
 #define pte_page(x)	pfn_to_page(pte_pfn(x))
-#define pte_none(x)	(!(x).pte_low && !(x).pte_high)
-#define pte_pfn(x)	(((x).pte_low >> PAGE_SHIFT) | ((x).pte_high << (32 - PAGE_SHIFT)))
+static inline int pte_none(pte_t pte) { return !pte.pte_low && !pte.pte_high; }
+static inline unsigned long pte_pfn(pte_t pte) { return (pte.pte_low >> PAGE_SHIFT) | (pte.pte_high << (32 - PAGE_SHIFT)); }
 
 static inline pte_t pfn_pte(unsigned long page_nr, pgprot_t pgprot)
 {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
