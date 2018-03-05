Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D83066B000D
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:07:59 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e127so4614564wmg.7
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:07:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u128sor2368892wmu.50.2018.03.05.12.07.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:07:58 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 08/25] slab: make size_index_elem() unsigned int
Date: Mon,  5 Mar 2018 23:07:13 +0300
Message-Id: <20180305200730.15812-8-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

size_index_elem() always works with small sizes (kmalloc caches are 32-bit)
and returns small indexes.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab_common.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index dda966e6bc58..8abb2a46ae85 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -998,7 +998,7 @@ static u8 size_index[24] __ro_after_init = {
 	2	/* 192 */
 };
 
-static inline int size_index_elem(size_t bytes)
+static inline unsigned int size_index_elem(unsigned int bytes)
 {
 	return (bytes - 1) / 8;
 }
@@ -1067,13 +1067,13 @@ const struct kmalloc_info_struct kmalloc_info[] __initconst = {
  */
 void __init setup_kmalloc_cache_index_table(void)
 {
-	int i;
+	unsigned int i;
 
 	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
 		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
 
 	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8) {
-		int elem = size_index_elem(i);
+		unsigned int elem = size_index_elem(i);
 
 		if (elem >= ARRAY_SIZE(size_index))
 			break;
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
