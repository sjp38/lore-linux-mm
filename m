Date: Thu, 6 Mar 2008 18:45:20 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BUG] 2.6.25-rc4 hang/softlockups after freeing hugepages
Message-ID: <20080306174520.GA29047@elte.hu>
References: <1204824183.5294.62.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1204824183.5294.62.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Adam Litke <agl@us.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> Test platform: HP Proliant DL585 server - 4 socket, dual core AMD with 
> 32GB memory.

does the patch below change the problem in any way? (it fixes a rare 
hugetlbfs related memory leak)

	Ingo

------------------>
Subject: x86: redo cded932b75ab0a5f9181e
From: Ingo Molnar <mingo@elte.hu>
Date: Mon Mar 03 13:55:32 CET 2008

redo commit cded932b75ab0a5f9181e.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 include/asm-x86/pgtable_32.h |    4 +++-
 include/asm-x86/pgtable_64.h |    6 ++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

Index: linux-x86.q/include/asm-x86/pgtable_32.h
===================================================================
--- linux-x86.q.orig/include/asm-x86/pgtable_32.h
+++ linux-x86.q/include/asm-x86/pgtable_32.h
@@ -91,7 +91,9 @@ extern unsigned long pg0[];
 /* To avoid harmful races, pmd_none(x) should check only the lower when PAE */
 #define pmd_none(x)	(!(unsigned long)pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
-#define	pmd_bad(x)	((pmd_val(x) & (~PAGE_MASK & ~_PAGE_USER)) != _KERNPG_TABLE)
+#define	pmd_bad(x)	((pmd_val(x) \
+			  & ~(PAGE_MASK | _PAGE_USER | _PAGE_PSE | _PAGE_NX)) \
+			 != _KERNPG_TABLE)
 
 
 #define pages_to_mb(x) ((x) >> (20-PAGE_SHIFT))
Index: linux-x86.q/include/asm-x86/pgtable_64.h
===================================================================
--- linux-x86.q.orig/include/asm-x86/pgtable_64.h
+++ linux-x86.q/include/asm-x86/pgtable_64.h
@@ -153,12 +153,14 @@ static inline unsigned long pgd_bad(pgd_
 
 static inline unsigned long pud_bad(pud_t pud)
 {
-	return pud_val(pud) & ~(PTE_MASK | _KERNPG_TABLE | _PAGE_USER);
+	return pud_val(pud) &
+		~(PTE_MASK | _KERNPG_TABLE | _PAGE_USER | _PAGE_PSE | _PAGE_NX);
 }
 
 static inline unsigned long pmd_bad(pmd_t pmd)
 {
-	return pmd_val(pmd) & ~(PTE_MASK | _KERNPG_TABLE | _PAGE_USER);
+	return pmd_val(pmd) &
+		~(PTE_MASK | _KERNPG_TABLE | _PAGE_USER | _PAGE_PSE | _PAGE_NX);
 }
 
 #define pte_none(x)	(!pte_val(x))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
