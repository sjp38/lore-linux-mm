Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 377796B0268
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:16 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o14so12667742wrf.6
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q131sor1923195wmd.6.2017.11.23.14.17.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:15 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 07/23] slab: make size_index_elem() unsigned int
Date: Fri, 24 Nov 2017 01:16:12 +0300
Message-Id: <20171123221628.8313-7-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

size_index_elem() always work with small sizes (kmalloc cache are 32-bit)
and return small indexes.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab_common.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 4405af3ee8eb..1cec6225fc4c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -954,7 +954,7 @@ static u8 size_index[24] = {
 	2	/* 192 */
 };
 
-static inline int size_index_elem(size_t bytes)
+static inline unsigned int size_index_elem(unsigned int bytes)
 {
 	return (bytes - 1) / 8;
 }
@@ -1023,13 +1023,13 @@ const struct kmalloc_info_struct kmalloc_info[] __initconst = {
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
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
