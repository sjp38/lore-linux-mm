Message-Id: <20070925233006.586143945@sgi.com>
References: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:48 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 05/14] i386: Resolve dependency of asm-i386/pgtable.h on highmem.h
Content-Disposition: inline; filename=vcompound_fix_i386_pgtable_mess
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

pgtable.h does not include highmem.h but uses various constants from
highmem.h. We cannot include highmem.h because highmem.h will in turn
include many other include files that also depend on pgtable.h

So move the definitions from highmem.h into pgtable.h.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/asm-i386/highmem.h |    6 ------
 include/asm-i386/pgtable.h |    8 ++++++++
 2 files changed, 8 insertions(+), 6 deletions(-)

Index: linux-2.6.23-rc8-mm1/include/asm-i386/highmem.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/asm-i386/highmem.h	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/include/asm-i386/highmem.h	2007-09-25 15:17:31.000000000 -0700
@@ -38,11 +38,6 @@ extern pte_t *pkmap_page_table;
  * easily, subsequent pte tables have to be allocated in one physical
  * chunk of RAM.
  */
-#ifdef CONFIG_X86_PAE
-#define LAST_PKMAP 512
-#else
-#define LAST_PKMAP 1024
-#endif
 /*
  * Ordering is:
  *
@@ -58,7 +53,6 @@ extern pte_t *pkmap_page_table;
  * VMALLOC_START
  * high_memory
  */
-#define PKMAP_BASE ( (FIXADDR_BOOT_START - PAGE_SIZE*(LAST_PKMAP + 1)) & PMD_MASK )
 #define LAST_PKMAP_MASK (LAST_PKMAP-1)
 #define PKMAP_NR(virt)  ((virt-PKMAP_BASE) >> PAGE_SHIFT)
 #define PKMAP_ADDR(nr)  (PKMAP_BASE + ((nr) << PAGE_SHIFT))
Index: linux-2.6.23-rc8-mm1/include/asm-i386/pgtable.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/asm-i386/pgtable.h	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/include/asm-i386/pgtable.h	2007-09-25 15:17:31.000000000 -0700
@@ -78,6 +78,14 @@ void paging_init(void);
 #define VMALLOC_OFFSET	(8*1024*1024)
 #define VMALLOC_START	(((unsigned long) high_memory + \
 			2*VMALLOC_OFFSET-1) & ~(VMALLOC_OFFSET-1))
+#ifdef CONFIG_X86_PAE
+#define LAST_PKMAP 512
+#else
+#define LAST_PKMAP 1024
+#endif
+
+#define PKMAP_BASE ( (FIXADDR_BOOT_START - PAGE_SIZE*(LAST_PKMAP + 1)) & PMD_MASK )
+
 #ifdef CONFIG_HIGHMEM
 # define VMALLOC_END	(PKMAP_BASE-2*PAGE_SIZE)
 #else

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
