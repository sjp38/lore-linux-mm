Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 43C736B006E
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:26:18 -0400 (EDT)
Date: Tue, 02 Oct 2012 18:26:15 -0400 (EDT)
Message-Id: <20121002.182615.926279426545688173.davem@davemloft.net>
Subject: [PATCH 1/8] sparc64: Only support 4MB huge pages.
From: David Miller <davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org


Narrowing the scope of huge page support will make the transparent
hugepage changes much simpler.

In the end what we really want to do is have the kernel support
multiple huge page sizes and use whatever is appropriate as the
context dictactes.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/Kconfig                  |   17 -----------------
 arch/sparc/include/asm/mmu_64.h     |    9 +--------
 arch/sparc/include/asm/page_64.h    |    6 ------
 arch/sparc/include/asm/pgtable_64.h |    8 --------
 arch/sparc/mm/tsb.c                 |   10 ----------
 5 files changed, 1 insertion(+), 49 deletions(-)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 67f1f6f..8bd3b12 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -316,23 +316,6 @@ config GENERIC_LOCKBREAK
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
index 9067dc5..b4d685d 100644
--- a/arch/sparc/include/asm/mmu_64.h
+++ b/arch/sparc/include/asm/mmu_64.h
@@ -38,14 +38,7 @@
 #error No page size specified in kernel configuration
 #endif
 
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
index f0d09b4..08bb5f7 100644
--- a/arch/sparc/include/asm/page_64.h
+++ b/arch/sparc/include/asm/page_64.h
@@ -21,13 +21,7 @@
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
index 61210db..51be4a1 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -170,16 +170,8 @@
 #error Wrong PAGE_SHIFT specified
 #endif
 
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
diff --git a/arch/sparc/mm/tsb.c b/arch/sparc/mm/tsb.c
index c52add7..e6b04a4 100644
--- a/arch/sparc/mm/tsb.c
+++ b/arch/sparc/mm/tsb.c
@@ -101,18 +101,8 @@ void flush_tsb_user(struct tlb_batch *tb)
 #endif
 
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
