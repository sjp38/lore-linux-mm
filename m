Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id AAFA96B0038
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:01:35 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id hr17so75008lab.16
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 12:01:34 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id sp4si5376987lbb.9.2014.07.22.12.01.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 12:01:33 -0700 (PDT)
Received: by mail-la0-f50.google.com with SMTP id gf5so71133lab.23
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 12:01:33 -0700 (PDT)
From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH 7/8] xtensa: support aliasing cache in kmap
Date: Tue, 22 Jul 2014 23:01:12 +0400
Message-Id: <1406055673-10100-8-git-send-email-jcmvbkbc@gmail.com>
In-Reply-To: <1406055673-10100-1-git-send-email-jcmvbkbc@gmail.com>
References: <1406055673-10100-1-git-send-email-jcmvbkbc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xtensa@linux-xtensa.org
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>, linux-kernel@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, David Rientjes <rientjes@google.com>

Define ARCH_PKMAP_COLORING and provide corresponding macro definitions
on cores with aliasing data cache.

Instead of single last_pkmap_nr maintain an array last_pkmap_nr_arr of
pkmap counters for each page color. Make sure that kmap maps physical
page at virtual address with color matching its physical address.

Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
 arch/xtensa/include/asm/highmem.h | 18 ++++++++++++++++--
 arch/xtensa/mm/highmem.c          |  1 +
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/arch/xtensa/include/asm/highmem.h b/arch/xtensa/include/asm/highmem.h
index 2653ef5..a5c3380 100644
--- a/arch/xtensa/include/asm/highmem.h
+++ b/arch/xtensa/include/asm/highmem.h
@@ -17,14 +17,28 @@
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
+#define ARCH_PKMAP_COLORING
+#define set_pkmap_color(pg, cl)		((cl) = DCACHE_ALIAS(page_to_phys(pg)))
+#define get_last_pkmap_nr(p, cl)	(last_pkmap_nr_arr[cl] + (cl))
+#define get_next_pkmap_nr(p, cl)	\
+	((last_pkmap_nr_arr[cl] = ((last_pkmap_nr_arr[cl] + DCACHE_N_COLORS) & \
+				   LAST_PKMAP_MASK)) + (cl))
+#define no_more_pkmaps(p, cl)		((p) < DCACHE_N_COLORS)
+#define get_next_pkmap_counter(c, cl)	((c) - DCACHE_N_COLORS)
+
+extern unsigned int last_pkmap_nr_arr[];
+#endif
+
 extern pte_t *pkmap_page_table;
 
 void *kmap_high(struct page *page);
diff --git a/arch/xtensa/mm/highmem.c b/arch/xtensa/mm/highmem.c
index 466abae..3742a37 100644
--- a/arch/xtensa/mm/highmem.c
+++ b/arch/xtensa/mm/highmem.c
@@ -12,6 +12,7 @@
 #include <linux/highmem.h>
 #include <asm/tlbflush.h>
 
+unsigned int last_pkmap_nr_arr[DCACHE_N_COLORS];
 static pte_t *kmap_pte;
 
 static inline enum fixed_addresses kmap_idx(int type, unsigned long color)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
