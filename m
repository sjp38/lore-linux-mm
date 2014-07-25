Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9B33E6B0038
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 15:44:17 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id pv20so3450993lab.15
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 12:44:17 -0700 (PDT)
Received: from mail-la0-x22a.google.com (mail-la0-x22a.google.com [2a00:1450:4010:c03::22a])
        by mx.google.com with ESMTPS id jb6si37629877lbc.32.2014.07.25.12.44.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 12:44:16 -0700 (PDT)
Received: by mail-la0-f42.google.com with SMTP id pv20so3450973lab.15
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 12:44:15 -0700 (PDT)
From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v3 2/2] xtensa: support aliasing cache in kmap
Date: Fri, 25 Jul 2014 23:43:47 +0400
Message-Id: <1406317427-10215-3-git-send-email-jcmvbkbc@gmail.com>
In-Reply-To: <1406317427-10215-1-git-send-email-jcmvbkbc@gmail.com>
References: <1406317427-10215-1-git-send-email-jcmvbkbc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xtensa@linux-xtensa.org
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Steven Hill <Steven.Hill@imgtec.com>, Max Filippov <jcmvbkbc@gmail.com>

Define ARCH_PKMAP_COLORING and provide corresponding macro definitions
on cores with aliasing data cache.

Instead of single last_pkmap_nr maintain an array last_pkmap_nr_arr of
pkmap counters for each page color. Make sure that kmap maps physical
page at virtual address with color matching its physical address.

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
Changes v2->v3:
- switch to new function names/prototypes;
- implement get_pkmap_wait_queue_head, add kmap_waitqueues_init.

Changes v1->v2:
- new file.

 arch/xtensa/include/asm/highmem.h | 40 +++++++++++++++++++++++++++++++++++++--
 arch/xtensa/mm/highmem.c          | 18 ++++++++++++++++++
 2 files changed, 56 insertions(+), 2 deletions(-)

diff --git a/arch/xtensa/include/asm/highmem.h b/arch/xtensa/include/asm/highmem.h
index 2653ef5..2c7901e 100644
--- a/arch/xtensa/include/asm/highmem.h
+++ b/arch/xtensa/include/asm/highmem.h
@@ -12,19 +12,55 @@
 #ifndef _XTENSA_HIGHMEM_H
 #define _XTENSA_HIGHMEM_H
 
+#include <linux/wait.h>
 #include <asm/cacheflush.h>
 #include <asm/fixmap.h>
 #include <asm/kmap_types.h>
 #include <asm/pgtable.h>
 
-#define PKMAP_BASE		(FIXADDR_START - PMD_SIZE)
-#define LAST_PKMAP		PTRS_PER_PTE
+#define PKMAP_BASE		((FIXADDR_START - \
+				  (LAST_PKMAP + 1) * PAGE_SIZE) & PMD_MASK)
+#define LAST_PKMAP		(PTRS_PER_PTE * DCACHE_N_COLORS)
 #define LAST_PKMAP_MASK		(LAST_PKMAP - 1)
 #define PKMAP_NR(virt)		(((virt) - PKMAP_BASE) >> PAGE_SHIFT)
 #define PKMAP_ADDR(nr)		(PKMAP_BASE + ((nr) << PAGE_SHIFT))
 
 #define kmap_prot		PAGE_KERNEL
 
+#if DCACHE_WAY_SIZE > PAGE_SIZE
+#define get_pkmap_color get_pkmap_color
+static inline int get_pkmap_color(struct page *page)
+{
+	return DCACHE_ALIAS(page_to_phys(page));
+}
+
+extern unsigned int last_pkmap_nr_arr[];
+
+static inline unsigned int get_next_pkmap_nr(unsigned int color)
+{
+	last_pkmap_nr_arr[color] =
+		(last_pkmap_nr_arr[color] + DCACHE_N_COLORS) & LAST_PKMAP_MASK;
+	return last_pkmap_nr_arr[color] + color;
+}
+
+static inline int no_more_pkmaps(unsigned int pkmap_nr, unsigned int color)
+{
+	return pkmap_nr < DCACHE_N_COLORS;
+}
+
+static inline int get_pkmap_entries_count(unsigned int color)
+{
+	return LAST_PKMAP / DCACHE_N_COLORS;
+}
+
+extern wait_queue_head_t pkmap_map_wait_arr[];
+
+static inline wait_queue_head_t *get_pkmap_wait_queue_head(unsigned int color)
+{
+	return pkmap_map_wait_arr + color;
+}
+#endif
+
 extern pte_t *pkmap_page_table;
 
 void *kmap_high(struct page *page);
diff --git a/arch/xtensa/mm/highmem.c b/arch/xtensa/mm/highmem.c
index 466abae..8cfb71e 100644
--- a/arch/xtensa/mm/highmem.c
+++ b/arch/xtensa/mm/highmem.c
@@ -14,6 +14,23 @@
 
 static pte_t *kmap_pte;
 
+#if DCACHE_WAY_SIZE > PAGE_SIZE
+unsigned int last_pkmap_nr_arr[DCACHE_N_COLORS];
+wait_queue_head_t pkmap_map_wait_arr[DCACHE_N_COLORS];
+
+static void __init kmap_waitqueues_init(void)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(pkmap_map_wait_arr); ++i)
+		init_waitqueue_head(pkmap_map_wait_arr + i);
+}
+#else
+static inline void kmap_waitqueues_init(void)
+{
+}
+#endif
+
 static inline enum fixed_addresses kmap_idx(int type, unsigned long color)
 {
 	return (type + KM_TYPE_NR * smp_processor_id()) * DCACHE_N_COLORS +
@@ -72,4 +89,5 @@ void __init kmap_init(void)
 	/* cache the first kmap pte */
 	kmap_vstart = __fix_to_virt(FIX_KMAP_BEGIN);
 	kmap_pte = kmap_get_fixmap_pte(kmap_vstart);
+	kmap_waitqueues_init();
 }
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
