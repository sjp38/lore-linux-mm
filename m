Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC836B0266
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:15 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e70so2783479wmc.6
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g25sor297798wmc.87.2017.11.23.14.17.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:14 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 06/23] slab: make size_index[] array u8
Date: Fri, 24 Nov 2017 01:16:11 +0300
Message-Id: <20171123221628.8313-6-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

All those small numbers are reverse indexes into kmalloc caches array
and can't be negative.

On x86_64 "unsigned int = fls()" can drop CDQE:

	add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-2 (-2)
	Function                                     old     new   delta
	kmalloc_slab                                 101      99      -2

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 1d46602c881e..4405af3ee8eb 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -927,7 +927,7 @@ EXPORT_SYMBOL(kmalloc_dma_caches);
  * of two cache sizes there. The size of larger slabs can be determined using
  * fls.
  */
-static s8 size_index[24] = {
+static u8 size_index[24] = {
 	3,	/* 8 */
 	4,	/* 16 */
 	5,	/* 24 */
@@ -965,7 +965,7 @@ static inline int size_index_elem(size_t bytes)
  */
 struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 {
-	int index;
+	unsigned int index;
 
 	if (unlikely(size > KMALLOC_MAX_SIZE)) {
 		WARN_ON_ONCE(!(flags & __GFP_NOWARN));
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
