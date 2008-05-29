Message-Id: <20080529122602.062780000@nick.local0.net>
References: <20080529122050.823438000@nick.local0.net>
Date: Thu, 29 May 2008 22:20:51 +1000
From: npiggin@suse.de
Subject: [patch 1/5] x86: implement pte_special
Content-Disposition: inline; filename=x86-implement-pte_special.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: shaggy@austin.ibm.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Implement the pte_special bit for x86. This is required to support lockless
get_user_pages, because we need to know whether or not we can refcount a
particular page given only its pte (and no vma).

Signed-off-by: Nick Piggin <npiggin@suse.de>
Cc: shaggy@austin.ibm.com
Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org
Cc: apw@shadowen.org

---
 include/asm-x86/pgtable.h |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

Index: linux-2.6/include/asm-x86/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-x86/pgtable.h
+++ linux-2.6/include/asm-x86/pgtable.h
@@ -17,6 +17,7 @@
 #define _PAGE_BIT_UNUSED1	9	/* available for programmer */
 #define _PAGE_BIT_UNUSED2	10
 #define _PAGE_BIT_UNUSED3	11
+#define _PAGE_BIT_SPECIAL	_PAGE_BIT_UNUSED1
 #define _PAGE_BIT_PAT_LARGE	12	/* On 2MB or 1GB pages */
 #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
 
@@ -39,6 +40,8 @@
 #define _PAGE_UNUSED3	(_AC(1, L)<<_PAGE_BIT_UNUSED3)
 #define _PAGE_PAT	(_AC(1, L)<<_PAGE_BIT_PAT)
 #define _PAGE_PAT_LARGE (_AC(1, L)<<_PAGE_BIT_PAT_LARGE)
+#define _PAGE_SPECIAL	(_AC(1, L)<<_PAGE_BIT_SPECIAL)
+#define __HAVE_ARCH_PTE_SPECIAL
 
 #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
 #define _PAGE_NX	(_AC(1, ULL) << _PAGE_BIT_NX)
@@ -199,7 +202,7 @@ static inline int pte_exec(pte_t pte)
 
 static inline int pte_special(pte_t pte)
 {
-	return 0;
+	return pte_val(pte) & _PAGE_SPECIAL;
 }
 
 static inline int pmd_large(pmd_t pte)
@@ -265,7 +268,7 @@ static inline pte_t pte_clrglobal(pte_t 
 
 static inline pte_t pte_mkspecial(pte_t pte)
 {
-	return pte;
+	return __pte(pte_val(pte) | _PAGE_SPECIAL);
 }
 
 extern pteval_t __supported_pte_mask;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
