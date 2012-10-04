Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 49F806B013E
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 15:46:41 -0400 (EDT)
Date: Thu, 04 Oct 2012 15:46:38 -0400 (EDT)
Message-Id: <20121004.154638.1706593979706946289.davem@davemloft.net>
Subject: [PATCH v2 1/7] sparc64: Only support 4MB huge pages and 8KB base
 pages.
From: David Miller <davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org


Narrowing the scope of the page size configurations will make the
transparent hugepage changes much simpler.

In the end what we really want to do is have the kernel support
multiple huge page sizes and use whatever is appropriate as the
context dictactes.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/Kconfig                  |   36 -------------------------------
 arch/sparc/include/asm/mmu_64.h     |   16 +-------------
 arch/sparc/include/asm/page_64.h    |   12 -----------
 arch/sparc/include/asm/pgtable_64.h |   40 ++++++-----------------------------
 arch/sparc/mm/init_64.c             |    9 ++------
 arch/sparc/mm/tsb.c                 |   17 ---------------
 6 files changed, 9 insertions(+), 121 deletions(-)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 67f1f6f..030f77f 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -226,25 +226,6 @@ config EARLYFB
 	help
 	  Say Y here to enable a faster early framebuffer boot console.
 
-choice
-	prompt "Kernel page size" if SPARC64
-	default SPARC64_PAGE_SIZE_8KB
-
-config SPARC64_PAGE_SIZE_8KB
-	bool "8KB"
-	help
-	  This lets you select the page size of the kernel.
-
-	  8KB and 64KB work quite well, since SPARC ELF sections
-	  provide for up to 64KB alignment.
-
-	  If you don't know what to do, choose 8KB.
-
-config SPARC64_PAGE_SIZE_64KB
-	bool "64KB"
-
-endchoice
-
 config SECCOMP
 	bool "Enable seccomp to safely compute untrusted bytecode"
 	depends on SPARC64 && PROC_FS
@@ -316,23 +297,6 @@ config GENERIC_LOCKBREAK
 	default y
 	depends on SPARC64 && SMP && PREEMPT
 
-choice
-	prompt "SPARC64 Huge TLB Page Size"
-	depends on SPARC64 && HUGETLB_PAGE
-	default HUGETLB_PAGE_SIZE_4MB
-
-config HUGETLB_PAGE_SIZE_4MB
-	bool "4MB"
-
-config HUGETLB_PAGE_SIZE_512K
-	bool "512K"
-
-config HUGETLB_PAGE_SIZE_64K
-	depends on !SPARC64_PAGE_SIZE_64KB
-	bool "64K"
-
-endchoice
-
 config NUMA
 	bool "NUMA support"
 	depends on SPARC64 && SMP
diff --git a/arch/sparc/include/asm/mmu_64.h b/arch/sparc/include/asm/mmu_64.h
index 9067dc5..5fb97e1 100644
--- a/arch/sparc/include/asm/mmu_64.h
+++ b/arch/sparc/include/asm/mmu_64.h
@@ -30,22 +30,8 @@
 #define CTX_PGSZ_MASK		((CTX_PGSZ_BITS << CTX_PGSZ0_SHIFT) | \
 				 (CTX_PGSZ_BITS << CTX_PGSZ1_SHIFT))
 
-#if defined(CONFIG_SPARC64_PAGE_SIZE_8KB)
 #define CTX_PGSZ_BASE	CTX_PGSZ_8KB
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_64KB)
-#define CTX_PGSZ_BASE	CTX_PGSZ_64KB
-#else
-#error No page size specified in kernel configuration
-#endif
-
-#if defined(CONFIG_HUGETLB_PAGE_SIZE_4MB)
-#define CTX_PGSZ_HUGE		CTX_PGSZ_4MB
-#elif defined(CONFIG_HUGETLB_PAGE_SIZE_512K)
-#define CTX_PGSZ_HUGE		CTX_PGSZ_512KB
-#elif defined(CONFIG_HUGETLB_PAGE_SIZE_64K)
-#define CTX_PGSZ_HUGE		CTX_PGSZ_64KB
-#endif
-
+#define CTX_PGSZ_HUGE	CTX_PGSZ_4MB
 #define CTX_PGSZ_KERN	CTX_PGSZ_4MB
 
 /* Thus, when running on UltraSPARC-III+ and later, we use the following
diff --git a/arch/sparc/include/asm/page_64.h b/arch/sparc/include/asm/page_64.h
index f0d09b4..b2df9b8 100644
--- a/arch/sparc/include/asm/page_64.h
+++ b/arch/sparc/include/asm/page_64.h
@@ -3,13 +3,7 @@
 
 #include <linux/const.h>
 
-#if defined(CONFIG_SPARC64_PAGE_SIZE_8KB)
 #define PAGE_SHIFT   13
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_64KB)
-#define PAGE_SHIFT   16
-#else
-#error No page size specified in kernel configuration
-#endif
 
 #define PAGE_SIZE    (_AC(1,UL) << PAGE_SHIFT)
 #define PAGE_MASK    (~(PAGE_SIZE-1))
@@ -21,13 +15,7 @@
 #define DCACHE_ALIASING_POSSIBLE
 #endif
 
-#if defined(CONFIG_HUGETLB_PAGE_SIZE_4MB)
 #define HPAGE_SHIFT		22
-#elif defined(CONFIG_HUGETLB_PAGE_SIZE_512K)
-#define HPAGE_SHIFT		19
-#elif defined(CONFIG_HUGETLB_PAGE_SIZE_64K)
-#define HPAGE_SHIFT		16
-#endif
 
 #ifdef CONFIG_HUGETLB_PAGE
 #define HPAGE_SIZE		(_AC(1,UL) << HPAGE_SHIFT)
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 61210db..387d484 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -160,26 +160,11 @@
 #define _PAGE_SZ8K_4V	  _AC(0x0000000000000000,UL) /* 8K Page              */
 #define _PAGE_SZALL_4V	  _AC(0x0000000000000007,UL) /* All pgsz bits        */
 
-#if PAGE_SHIFT == 13
 #define _PAGE_SZBITS_4U	_PAGE_SZ8K_4U
 #define _PAGE_SZBITS_4V	_PAGE_SZ8K_4V
-#elif PAGE_SHIFT == 16
-#define _PAGE_SZBITS_4U	_PAGE_SZ64K_4U
-#define _PAGE_SZBITS_4V	_PAGE_SZ64K_4V
-#else
-#error Wrong PAGE_SHIFT specified
-#endif
 
-#if defined(CONFIG_HUGETLB_PAGE_SIZE_4MB)
 #define _PAGE_SZHUGE_4U	_PAGE_SZ4MB_4U
 #define _PAGE_SZHUGE_4V	_PAGE_SZ4MB_4V
-#elif defined(CONFIG_HUGETLB_PAGE_SIZE_512K)
-#define _PAGE_SZHUGE_4U	_PAGE_SZ512K_4U
-#define _PAGE_SZHUGE_4V	_PAGE_SZ512K_4V
-#elif defined(CONFIG_HUGETLB_PAGE_SIZE_64K)
-#define _PAGE_SZHUGE_4U	_PAGE_SZ64K_4U
-#define _PAGE_SZHUGE_4V	_PAGE_SZ64K_4V
-#endif
 
 /* These are actually filled in at boot time by sun4{u,v}_pgprot_init() */
 #define __P000	__pgprot(0)
@@ -218,7 +203,6 @@ extern unsigned long _PAGE_CACHE;
 
 extern unsigned long pg_iobits;
 extern unsigned long _PAGE_ALL_SZ_BITS;
-extern unsigned long _PAGE_SZBITS;
 
 extern struct page *mem_map_zero;
 #define ZERO_PAGE(vaddr)	(mem_map_zero)
@@ -231,22 +215,9 @@ extern struct page *mem_map_zero;
 static inline pte_t pfn_pte(unsigned long pfn, pgprot_t prot)
 {
 	unsigned long paddr = pfn << PAGE_SHIFT;
-	unsigned long sz_bits;
-
-	sz_bits = 0UL;
-	if (_PAGE_SZBITS_4U != 0UL || _PAGE_SZBITS_4V != 0UL) {
-		__asm__ __volatile__(
-		"\n661:	sethi		%%uhi(%1), %0\n"
-		"	sllx		%0, 32, %0\n"
-		"	.section	.sun4v_2insn_patch, \"ax\"\n"
-		"	.word		661b\n"
-		"	mov		%2, %0\n"
-		"	nop\n"
-		"	.previous\n"
-		: "=r" (sz_bits)
-		: "i" (_PAGE_SZBITS_4U), "i" (_PAGE_SZBITS_4V));
-	}
-	return __pte(paddr | sz_bits | pgprot_val(prot));
+
+	BUILD_BUG_ON(_PAGE_SZBITS_4U != 0UL || _PAGE_SZBITS_4V != 0UL);
+	return __pte(paddr | pgprot_val(prot));
 }
 #define mk_pte(page, pgprot)	pfn_pte(page_to_pfn(page), (pgprot))
 
@@ -286,6 +257,7 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t prot)
 	 * Note: We encode this into 3 sun4v 2-insn patch sequences.
 	 */
 
+	BUILD_BUG_ON(_PAGE_SZBITS_4U != 0UL || _PAGE_SZBITS_4V != 0UL);
 	__asm__ __volatile__(
 	"\n661:	sethi		%%uhi(%2), %1\n"
 	"	sethi		%%hi(%2), %0\n"
@@ -307,10 +279,10 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t prot)
 	: "=r" (mask), "=r" (tmp)
 	: "i" (_PAGE_PADDR_4U | _PAGE_MODIFIED_4U | _PAGE_ACCESSED_4U |
 	       _PAGE_CP_4U | _PAGE_CV_4U | _PAGE_E_4U | _PAGE_PRESENT_4U |
-	       _PAGE_SZBITS_4U | _PAGE_SPECIAL),
+	       _PAGE_SPECIAL),
 	  "i" (_PAGE_PADDR_4V | _PAGE_MODIFIED_4V | _PAGE_ACCESSED_4V |
 	       _PAGE_CP_4V | _PAGE_CV_4V | _PAGE_E_4V | _PAGE_PRESENT_4V |
-	       _PAGE_SZBITS_4V | _PAGE_SPECIAL));
+	       _PAGE_SPECIAL));
 
 	return __pte((pte_val(pte) & mask) | (pgprot_val(prot) & ~mask));
 }
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 7a9b788..809eecf 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -276,7 +276,6 @@ static inline void tsb_insert(struct tsb *ent, unsigned long tag, unsigned long
 }
 
 unsigned long _PAGE_ALL_SZ_BITS __read_mostly;
-unsigned long _PAGE_SZBITS __read_mostly;
 
 static void flush_dcache(unsigned long pfn)
 {
@@ -2275,8 +2274,7 @@ static void __init sun4u_pgprot_init(void)
 		     __ACCESS_BITS_4U | _PAGE_E_4U);
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
-	kern_linear_pte_xor[0] = (_PAGE_VALID | _PAGE_SZBITS_4U) ^
-		0xfffff80000000000UL;
+	kern_linear_pte_xor[0] = _PAGE_VALID ^ 0xfffff80000000000UL;
 #else
 	kern_linear_pte_xor[0] = (_PAGE_VALID | _PAGE_SZ4MB_4U) ^
 		0xfffff80000000000UL;
@@ -2287,7 +2285,6 @@ static void __init sun4u_pgprot_init(void)
 	for (i = 1; i < 4; i++)
 		kern_linear_pte_xor[i] = kern_linear_pte_xor[0];
 
-	_PAGE_SZBITS = _PAGE_SZBITS_4U;
 	_PAGE_ALL_SZ_BITS =  (_PAGE_SZ4MB_4U | _PAGE_SZ512K_4U |
 			      _PAGE_SZ64K_4U | _PAGE_SZ8K_4U |
 			      _PAGE_SZ32MB_4U | _PAGE_SZ256MB_4U);
@@ -2324,8 +2321,7 @@ static void __init sun4v_pgprot_init(void)
 	_PAGE_CACHE = _PAGE_CACHE_4V;
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
-	kern_linear_pte_xor[0] = (_PAGE_VALID | _PAGE_SZBITS_4V) ^
-		0xfffff80000000000UL;
+	kern_linear_pte_xor[0] = _PAGE_VALID ^ 0xfffff80000000000UL;
 #else
 	kern_linear_pte_xor[0] = (_PAGE_VALID | _PAGE_SZ4MB_4V) ^
 		0xfffff80000000000UL;
@@ -2339,7 +2335,6 @@ static void __init sun4v_pgprot_init(void)
 	pg_iobits = (_PAGE_VALID | _PAGE_PRESENT_4V | __DIRTY_BITS_4V |
 		     __ACCESS_BITS_4V | _PAGE_E_4V);
 
-	_PAGE_SZBITS = _PAGE_SZBITS_4V;
 	_PAGE_ALL_SZ_BITS = (_PAGE_SZ16GB_4V | _PAGE_SZ2GB_4V |
 			     _PAGE_SZ256MB_4V | _PAGE_SZ32MB_4V |
 			     _PAGE_SZ4MB_4V | _PAGE_SZ512K_4V |
diff --git a/arch/sparc/mm/tsb.c b/arch/sparc/mm/tsb.c
index c52add7..70e50ea 100644
--- a/arch/sparc/mm/tsb.c
+++ b/arch/sparc/mm/tsb.c
@@ -90,29 +90,12 @@ void flush_tsb_user(struct tlb_batch *tb)
 	spin_unlock_irqrestore(&mm->context.lock, flags);
 }
 
-#if defined(CONFIG_SPARC64_PAGE_SIZE_8KB)
 #define HV_PGSZ_IDX_BASE	HV_PGSZ_IDX_8K
 #define HV_PGSZ_MASK_BASE	HV_PGSZ_MASK_8K
-#elif defined(CONFIG_SPARC64_PAGE_SIZE_64KB)
-#define HV_PGSZ_IDX_BASE	HV_PGSZ_IDX_64K
-#define HV_PGSZ_MASK_BASE	HV_PGSZ_MASK_64K
-#else
-#error Broken base page size setting...
-#endif
 
 #ifdef CONFIG_HUGETLB_PAGE
-#if defined(CONFIG_HUGETLB_PAGE_SIZE_64K)
-#define HV_PGSZ_IDX_HUGE	HV_PGSZ_IDX_64K
-#define HV_PGSZ_MASK_HUGE	HV_PGSZ_MASK_64K
-#elif defined(CONFIG_HUGETLB_PAGE_SIZE_512K)
-#define HV_PGSZ_IDX_HUGE	HV_PGSZ_IDX_512K
-#define HV_PGSZ_MASK_HUGE	HV_PGSZ_MASK_512K
-#elif defined(CONFIG_HUGETLB_PAGE_SIZE_4MB)
 #define HV_PGSZ_IDX_HUGE	HV_PGSZ_IDX_4MB
 #define HV_PGSZ_MASK_HUGE	HV_PGSZ_MASK_4MB
-#else
-#error Broken huge page size setting...
-#endif
 #endif
 
 static void setup_tsb_params(struct mm_struct *mm, unsigned long tsb_idx, unsigned long tsb_bytes)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
