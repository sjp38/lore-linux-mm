Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 11E4F6B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 19:33:34 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so35175753lbb.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 16:33:34 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id uh6si24505128lbc.47.2016.06.20.16.33.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 16:33:32 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id a2so7308606lfe.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 16:33:32 -0700 (PDT)
From: Yury Norov <yury.norov@gmail.com>
Subject: [PATCH] mm: slab.h: use ilog2() in kmalloc_index()
Date: Tue, 21 Jun 2016 02:33:06 +0300
Message-Id: <1466465586-22096-1-git-send-email-yury.norov@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: masmart@yandex.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: cl@linux.com, enberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux@rasmusvillemoes.dk, Yury Norov <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>

kmalloc_index() uses simple straightforward way to calculate
bit position of nearest or equal upper power of 2.
This effectively results in generation of 24 episodes of
compare-branch instructions in assembler.

There is shorter way to calculate this: fls(size - 1).

The patch removes hard-coded calculation of kmalloc slab and
uses ilog2() instead that works on top of fls(). ilog2 is used
with intention that compiler also might optimize constant case
during compile time if it detects that.

BUG() is moved to the beginning of function. We left it here to
provide identical behaviour to previous version. It may be removed
if there's no requirement in it anymore.

While we're at this, fix comment that describes return value.

Reported-by: Alexey Klimov <klimov.linux@gmail.com>
Signed-off-by: Yury Norov <yury.norov@gmail.com>
Signed-off-by: Alexey Klimov <klimov.linux@gmail.com>
---
 include/linux/slab.h | 41 +++++++++--------------------------------
 1 file changed, 9 insertions(+), 32 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index aeb3e6d..294ef52 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -267,13 +267,16 @@ extern struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
 /*
  * Figure out which kmalloc slab an allocation of a certain size
  * belongs to.
- * 0 = zero alloc
- * 1 =  65 .. 96 bytes
- * 2 = 129 .. 192 bytes
- * n = 2^(n-1)+1 .. 2^n
+ * 0 if zero alloc, or
+ * 1 if size is 65 .. 96 bytes, or
+ * 2 if size is 129 .. 192 bytes, or
+ * n if 2^(n - 1) < size <= 2^n
  */
 static __always_inline int kmalloc_index(size_t size)
 {
+	/* Bigger size is a bug */
+	BUG_ON(size > (1 << 26));
+
 	if (!size)
 		return 0;
 
@@ -284,34 +287,8 @@ static __always_inline int kmalloc_index(size_t size)
 		return 1;
 	if (KMALLOC_MIN_SIZE <= 64 && size > 128 && size <= 192)
 		return 2;
-	if (size <=          8) return 3;
-	if (size <=         16) return 4;
-	if (size <=         32) return 5;
-	if (size <=         64) return 6;
-	if (size <=        128) return 7;
-	if (size <=        256) return 8;
-	if (size <=        512) return 9;
-	if (size <=       1024) return 10;
-	if (size <=   2 * 1024) return 11;
-	if (size <=   4 * 1024) return 12;
-	if (size <=   8 * 1024) return 13;
-	if (size <=  16 * 1024) return 14;
-	if (size <=  32 * 1024) return 15;
-	if (size <=  64 * 1024) return 16;
-	if (size <= 128 * 1024) return 17;
-	if (size <= 256 * 1024) return 18;
-	if (size <= 512 * 1024) return 19;
-	if (size <= 1024 * 1024) return 20;
-	if (size <=  2 * 1024 * 1024) return 21;
-	if (size <=  4 * 1024 * 1024) return 22;
-	if (size <=  8 * 1024 * 1024) return 23;
-	if (size <=  16 * 1024 * 1024) return 24;
-	if (size <=  32 * 1024 * 1024) return 25;
-	if (size <=  64 * 1024 * 1024) return 26;
-	BUG();
-
-	/* Will never be reached. Needed because the compiler may complain */
-	return -1;
+
+	return ilog2(size - 1) + 1;
 }
 #endif /* !CONFIG_SLOB */
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
