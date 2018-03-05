Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEEB16B000D
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:07:58 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i64so5098453wmd.8
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:07:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9sor2401896wme.70.2018.03.05.12.07.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:07:57 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 07/25] slab: make size_index[] array u8
Date: Mon,  5 Mar 2018 23:07:12 +0300
Message-Id: <20180305200730.15812-7-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

All those small numbers are reverse indexes into kmalloc caches array
and can't be negative.

On x86_64 "unsigned int = fls()" can drop CDQE instruction:

	add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-2 (-2)
	Function                                     old     new   delta
	kmalloc_slab                                 101      99      -2

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index a4545a61a7c8..dda966e6bc58 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -971,7 +971,7 @@ EXPORT_SYMBOL(kmalloc_dma_caches);
  * of two cache sizes there. The size of larger slabs can be determined using
  * fls.
  */
-static s8 size_index[24] __ro_after_init = {
+static u8 size_index[24] __ro_after_init = {
 	3,	/* 8 */
 	4,	/* 16 */
 	5,	/* 24 */
@@ -1009,7 +1009,7 @@ static inline int size_index_elem(size_t bytes)
  */
 struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 {
-	int index;
+	unsigned int index;
 
 	if (unlikely(size > KMALLOC_MAX_SIZE)) {
 		WARN_ON_ONCE(!(flags & __GFP_NOWARN));
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
