Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7395A6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 00:05:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l73so150565670pfj.8
        for <linux-mm@kvack.org>; Mon, 22 May 2017 21:05:40 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id t126si19539799pgb.362.2017.05.22.21.05.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 21:05:39 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id f27so24501904pfe.0
        for <linux-mm@kvack.org>; Mon, 22 May 2017 21:05:39 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH 2/6] powerpc/vmemmap: Reshuffle vmemmap_free()
Date: Tue, 23 May 2017 14:05:20 +1000
Message-Id: <20170523040524.13717-2-oohall@gmail.com>
In-Reply-To: <20170523040524.13717-1-oohall@gmail.com>
References: <20170523040524.13717-1-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org, Oliver O'Halloran <oohall@gmail.com>

Removes an indentation level and shuffles some code around to make the
following patch cleaner. No functional changes.

Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
v1 -> v2: Remove broken initialiser
---
 arch/powerpc/mm/init_64.c | 48 ++++++++++++++++++++++++-----------------------
 1 file changed, 25 insertions(+), 23 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index ec84b31c6c86..8851e4f5dbab 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -234,13 +234,15 @@ static unsigned long vmemmap_list_free(unsigned long start)
 void __ref vmemmap_free(unsigned long start, unsigned long end)
 {
 	unsigned long page_size = 1 << mmu_psize_defs[mmu_vmemmap_psize].shift;
+	unsigned long page_order = get_order(page_size);
 
 	start = _ALIGN_DOWN(start, page_size);
 
 	pr_debug("vmemmap_free %lx...%lx\n", start, end);
 
 	for (; start < end; start += page_size) {
-		unsigned long addr;
+		unsigned long nr_pages, addr;
+		struct page *page;
 
 		/*
 		 * the section has already be marked as invalid, so
@@ -251,29 +253,29 @@ void __ref vmemmap_free(unsigned long start, unsigned long end)
 			continue;
 
 		addr = vmemmap_list_free(start);
-		if (addr) {
-			struct page *page = pfn_to_page(addr >> PAGE_SHIFT);
-
-			if (PageReserved(page)) {
-				/* allocated from bootmem */
-				if (page_size < PAGE_SIZE) {
-					/*
-					 * this shouldn't happen, but if it is
-					 * the case, leave the memory there
-					 */
-					WARN_ON_ONCE(1);
-				} else {
-					unsigned int nr_pages =
-						1 << get_order(page_size);
-					while (nr_pages--)
-						free_reserved_page(page++);
-				}
-			} else
-				free_pages((unsigned long)(__va(addr)),
-							get_order(page_size));
-
-			vmemmap_remove_mapping(start, page_size);
+		if (!addr)
+			continue;
+
+		page = pfn_to_page(addr >> PAGE_SHIFT);
+		nr_pages = 1 << page_order;
+
+		if (PageReserved(page)) {
+			/* allocated from bootmem */
+			if (page_size < PAGE_SIZE) {
+				/*
+				 * this shouldn't happen, but if it is
+				 * the case, leave the memory there
+				 */
+				WARN_ON_ONCE(1);
+			} else {
+				while (nr_pages--)
+					free_reserved_page(page++);
+			}
+		} else {
+			free_pages((unsigned long)(__va(addr)), page_order);
 		}
+
+		vmemmap_remove_mapping(start, page_size);
 	}
 }
 #endif
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
