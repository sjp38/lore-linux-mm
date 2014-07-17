Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id ED4356B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 13:03:27 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id s7so1958071lbd.36
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 10:03:26 -0700 (PDT)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id di1si4266156lac.65.2014.07.17.10.03.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 10:03:26 -0700 (PDT)
Received: by mail-la0-f53.google.com with SMTP id gl10so1924232lab.40
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 10:03:25 -0700 (PDT)
From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v2] mm/highmem: make kmap cache coloring aware
Date: Thu, 17 Jul 2014 21:03:18 +0400
Message-Id: <1405616598-14798-1-git-send-email-jcmvbkbc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-xtensa@linux-xtensa.org, linux-kernel@vger.kernel.org, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Max Filippov <jcmvbkbc@gmail.com>

From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>

Provide hooks that allow architectures with aliasing cache to align
mapping address of high pages according to their color. Such architectures
may enforce similar coloring of low- and high-memory page mappings and
reuse existing cache management functions to support highmem.

Signed-off-by: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
[ Max: extract architecture-independent part of the original patch, clean
  up checkpatch and build warnings. ]
Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
Changes v1->v2:
- fix description

 mm/highmem.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index b32b70c..6898a8b 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -44,6 +44,14 @@ DEFINE_PER_CPU(int, __kmap_atomic_idx);
  */
 #ifdef CONFIG_HIGHMEM
 
+#ifndef ARCH_PKMAP_COLORING
+#define set_pkmap_color(pg, cl)		/* */
+#define get_last_pkmap_nr(p, cl)	(p)
+#define get_next_pkmap_nr(p, cl)	(((p) + 1) & LAST_PKMAP_MASK)
+#define is_no_more_pkmaps(p, cl)	(!(p))
+#define get_next_pkmap_counter(c, cl)	((c) - 1)
+#endif
+
 unsigned long totalhigh_pages __read_mostly;
 EXPORT_SYMBOL(totalhigh_pages);
 
@@ -161,19 +169,24 @@ static inline unsigned long map_new_virtual(struct page *page)
 {
 	unsigned long vaddr;
 	int count;
+	int color __maybe_unused;
+
+	set_pkmap_color(page, color);
+	last_pkmap_nr = get_last_pkmap_nr(last_pkmap_nr, color);
 
 start:
 	count = LAST_PKMAP;
 	/* Find an empty entry */
 	for (;;) {
-		last_pkmap_nr = (last_pkmap_nr + 1) & LAST_PKMAP_MASK;
-		if (!last_pkmap_nr) {
+		last_pkmap_nr = get_next_pkmap_nr(last_pkmap_nr, color);
+		if (is_no_more_pkmaps(last_pkmap_nr, color)) {
 			flush_all_zero_pkmaps();
 			count = LAST_PKMAP;
 		}
 		if (!pkmap_count[last_pkmap_nr])
 			break;	/* Found a usable entry */
-		if (--count)
+		count = get_next_pkmap_counter(count, color);
+		if (count > 0)
 			continue;
 
 		/*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
