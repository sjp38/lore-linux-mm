Date: Thu, 29 Mar 2007 09:58:48 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 2/2] mips: reinstate move_pte
Message-ID: <20070329075847.GB6852@wotan.suse.de>
References: <20070329075805.GA6852@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070329075805.GA6852@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
Cc: tee@sgi.com, holt@sgi.com
List-ID: <linux-mm.kvack.org>

Restore move_pte for MIPS, so that any given virtual address vaddr that maps
a ZERO_PAGE will map ZERO_PAGE(vaddr).

This has a circular dependancy on the previous patch, which normally means
they belong in the same patch, but I thought this case is clearer if split
out.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/asm-mips/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-mips/pgtable.h
+++ linux-2.6/include/asm-mips/pgtable.h
@@ -69,6 +69,16 @@ extern unsigned long zero_page_mask;
 #define ZERO_PAGE(vaddr) \
 	(virt_to_page((void *)(empty_zero_page + (((unsigned long)(vaddr)) & zero_page_mask))))
 
+#define __HAVE_ARCH_MOVE_PTE
+#define move_pte(pte, prot, old_addr, new_addr)				\
+({									\
+	pte_t newpte = (pte);						\
+	if (pte_present(pte) && 					\
+		pte_pfn(pte) == page_to_pfn(ZERO_PAGE(old_addr)))	\
+		newpte = mk_pte(ZERO_PAGE(new_addr), (prot));		\
+	newpte;
+})
+
 extern void paging_init(void);
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
