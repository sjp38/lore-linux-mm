Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 10FA26B0062
	for <linux-mm@kvack.org>; Sat,  1 Mar 2014 11:03:19 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id fp1so2008666pdb.0
        for <linux-mm@kvack.org>; Sat, 01 Mar 2014 08:03:19 -0800 (PST)
Received: from mail-pb0-x22d.google.com (mail-pb0-x22d.google.com [2607:f8b0:400e:c01::22d])
        by mx.google.com with ESMTPS id s3si1128582pbo.32.2014.03.01.08.03.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 01 Mar 2014 08:03:18 -0800 (PST)
Received: by mail-pb0-f45.google.com with SMTP id uo5so1325533pbc.4
        for <linux-mm@kvack.org>; Sat, 01 Mar 2014 08:03:17 -0800 (PST)
From: Gideon Israel Dsouza <gidisrael@gmail.com>
Subject: [PATCH 1/1] mm: use macros from compiler.h instead of __attribute__((...))
Date: Sat,  1 Mar 2014 21:32:28 +0530
Message-Id: <1393689748-32236-2-git-send-email-gidisrael@gmail.com>
In-Reply-To: <1393689748-32236-1-git-send-email-gidisrael@gmail.com>
References: <1393689748-32236-1-git-send-email-gidisrael@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, geert@linux-m68k.org, Gideon Israel Dsouza <gidisrael@gmail.com>

To increase compiler portability there is <linux/compiler.h> which
provides convenience macros for various gcc constructs.  Eg: __weak for
__attribute__((weak)).  I've replaced all instances of gcc attributes with
the right macro in the memory management (/mm) subsystem.

Signed-off-by: Gideon Israel Dsouza <gidisrael@gmail.com>
---
 mm/hugetlb.c | 3 ++-
 mm/nommu.c   | 3 ++-
 mm/sparse.c  | 6 ++++--
 mm/util.c    | 5 +++--
 mm/vmalloc.c | 4 +++-
 5 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c01cb9f..9a51286 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -22,6 +22,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/page-isolation.h>
+#include <linux/compiler.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -3446,7 +3447,7 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 #else /* !CONFIG_ARCH_WANT_GENERAL_HUGETLB */
 
 /* Can be overriden by architectures */
-__attribute__((weak)) struct page *
+__weak struct page *
 follow_huge_pud(struct mm_struct *mm, unsigned long address,
 	       pud_t *pud, int write)
 {
diff --git a/mm/nommu.c b/mm/nommu.c
index 8740213..9f823ce 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -30,6 +30,7 @@
 #include <linux/syscalls.h>
 #include <linux/audit.h>
 #include <linux/sched/sysctl.h>
+#include <linux/compiler.h>
 
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
@@ -459,7 +460,7 @@ EXPORT_SYMBOL_GPL(vm_unmap_aliases);
  * Implement a stub for vmalloc_sync_all() if the architecture chose not to
  * have one.
  */
-void  __attribute__((weak)) vmalloc_sync_all(void)
+void  __weak vmalloc_sync_all(void)
 {
 }
 
diff --git a/mm/sparse.c b/mm/sparse.c
index 63c3ea5..8cb4bad 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -9,6 +9,8 @@
 #include <linux/export.h>
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
+#include <linux/compiler.h>
+
 #include "internal.h"
 #include <asm/dma.h>
 #include <asm/pgalloc.h>
@@ -459,9 +461,9 @@ static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
 	ms->section_mem_map = 0;
 	return NULL;
 }
-#endif
+endif
 
-void __attribute__((weak)) __meminit vmemmap_populate_print_last(void)
+void __weak __meminit vmemmap_populate_print_last(void)
 {
 }
 
diff --git a/mm/util.c b/mm/util.c
index a24aa22..992b7d4 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -9,6 +9,7 @@
 #include <linux/swapops.h>
 #include <linux/mman.h>
 #include <linux/hugetlb.h>
+#include <linux/compiler.h>
 
 #include <asm/uaccess.h>
 
@@ -307,7 +308,7 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
  * If the architecture not support this function, simply return with no
  * page pinned
  */
-int __attribute__((weak)) __get_user_pages_fast(unsigned long start,
+int __weak __get_user_pages_fast(unsigned long start,
 				 int nr_pages, int write, struct page **pages)
 {
 	return 0;
@@ -338,7 +339,7 @@ EXPORT_SYMBOL_GPL(__get_user_pages_fast);
  * callers need to carefully consider what to use. On many architectures,
  * get_user_pages_fast simply falls back to get_user_pages.
  */
-int __attribute__((weak)) get_user_pages_fast(unsigned long start,
+int __weak get_user_pages_fast(unsigned long start,
 				int nr_pages, int write, struct page **pages)
 {
 	struct mm_struct *mm = current->mm;
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0fdf968..7be0a1a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -28,6 +28,8 @@
 #include <linux/kmemleak.h>
 #include <linux/atomic.h>
 #include <linux/llist.h>
+#include <linux/compiler.h>
+
 #include <asm/uaccess.h>
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
@@ -2181,7 +2183,7 @@ EXPORT_SYMBOL(remap_vmalloc_range);
  * Implement a stub for vmalloc_sync_all() if the architecture chose not to
  * have one.
  */
-void  __attribute__((weak)) vmalloc_sync_all(void)
+void __weak vmalloc_sync_all(void)
 {
 }
 
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
