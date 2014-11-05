Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 88CB06B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 15:07:53 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id fp1so1406952pdb.13
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 12:07:53 -0800 (PST)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id ro9si3955166pab.72.2014.11.05.12.07.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 12:07:52 -0800 (PST)
Received: by mail-pd0-f182.google.com with SMTP id fp1so1395407pdb.27
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 12:07:51 -0800 (PST)
From: Gregory Fong <gregory.0xf0@gmail.com>
Subject: [PATCH 1/2] lib: bitmap: Added alignment offset for bitmap_find_next_zero_area()
Date: Wed,  5 Nov 2014 12:07:54 -0800
Message-Id: <1415218078-10078-1-git-send-email-gregory.0xf0@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, f.fainelli@gmail.com, Michal Nazarewicz <m.nazarewicz@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Gregory Fong <gregory.0xf0@gmail.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Masanari Iida <standby24x7@gmail.com>, open list <linux-kernel@vger.kernel.org>

From: Michal Nazarewicz <m.nazarewicz@samsung.com>

This commit adds a bitmap_find_next_zero_area_off() function which
works like bitmap_find_next_zero_area() function expect it allows an
offset to be specified when alignment is checked.  This lets caller
request a bit such that its number plus the offset is aligned
according to the mask.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
CC: Michal Nazarewicz <mina86@mina86.com>
[gregory.0xf0@gmail.com: Retrieved from
https://patchwork.linuxtv.org/patch/6254/ and updated documentation]
Signed-off-by: Gregory Fong <gregory.0xf0@gmail.com>
---
 include/linux/bitmap.h | 36 +++++++++++++++++++++++++++++++-----
 lib/bitmap.c           | 24 +++++++++++++-----------
 2 files changed, 44 insertions(+), 16 deletions(-)

diff --git a/include/linux/bitmap.h b/include/linux/bitmap.h
index e1c8d08..34e020c 100644
--- a/include/linux/bitmap.h
+++ b/include/linux/bitmap.h
@@ -45,6 +45,7 @@
  * bitmap_set(dst, pos, nbits)			Set specified bit area
  * bitmap_clear(dst, pos, nbits)		Clear specified bit area
  * bitmap_find_next_zero_area(buf, len, pos, n, mask)	Find bit free area
+ * bitmap_find_next_zero_area_off(buf, len, pos, n, mask)	as above
  * bitmap_shift_right(dst, src, n, nbits)	*dst = *src >> n
  * bitmap_shift_left(dst, src, n, nbits)	*dst = *src << n
  * bitmap_remap(dst, src, old, new, nbits)	*dst = map(old, new)(src)
@@ -114,11 +115,36 @@ extern int __bitmap_weight(const unsigned long *bitmap, unsigned int nbits);
 
 extern void bitmap_set(unsigned long *map, unsigned int start, int len);
 extern void bitmap_clear(unsigned long *map, unsigned int start, int len);
-extern unsigned long bitmap_find_next_zero_area(unsigned long *map,
-					 unsigned long size,
-					 unsigned long start,
-					 unsigned int nr,
-					 unsigned long align_mask);
+
+extern unsigned long bitmap_find_next_zero_area_off(unsigned long *map,
+						    unsigned long size,
+						    unsigned long start,
+						    unsigned int nr,
+						    unsigned long align_mask,
+						    unsigned long align_offset);
+
+/**
+ * bitmap_find_next_zero_area - find a contiguous aligned zero area
+ * @map: The address to base the search on
+ * @size: The bitmap size in bits
+ * @start: The bitnumber to start searching at
+ * @nr: The number of zeroed bits we're looking for
+ * @align_mask: Alignment mask for zero area
+ *
+ * The @align_mask should be one less than a power of 2; the effect is that
+ * the bit offset of all zero areas this function finds is multiples of that
+ * power of 2. A @align_mask of 0 means no alignment is required.
+ */
+static inline unsigned long
+bitmap_find_next_zero_area(unsigned long *map,
+			   unsigned long size,
+			   unsigned long start,
+			   unsigned int nr,
+			   unsigned long align_mask)
+{
+	return bitmap_find_next_zero_area_off(map, size, start, nr,
+					      align_mask, 0);
+}
 
 extern int bitmap_scnprintf(char *buf, unsigned int len,
 			const unsigned long *src, int nbits);
diff --git a/lib/bitmap.c b/lib/bitmap.c
index b499ab6..969ae8f 100644
--- a/lib/bitmap.c
+++ b/lib/bitmap.c
@@ -326,30 +326,32 @@ void bitmap_clear(unsigned long *map, unsigned int start, int len)
 }
 EXPORT_SYMBOL(bitmap_clear);
 
-/*
- * bitmap_find_next_zero_area - find a contiguous aligned zero area
+/**
+ * bitmap_find_next_zero_area_off - find a contiguous aligned zero area
  * @map: The address to base the search on
  * @size: The bitmap size in bits
  * @start: The bitnumber to start searching at
  * @nr: The number of zeroed bits we're looking for
  * @align_mask: Alignment mask for zero area
+ * @align_offset: Alignment offset for zero area.
  *
  * The @align_mask should be one less than a power of 2; the effect is that
- * the bit offset of all zero areas this function finds is multiples of that
- * power of 2. A @align_mask of 0 means no alignment is required.
+ * the bit offset of all zero areas this function finds plus @align_offset
+ * is multiple of that power of 2.
  */
-unsigned long bitmap_find_next_zero_area(unsigned long *map,
-					 unsigned long size,
-					 unsigned long start,
-					 unsigned int nr,
-					 unsigned long align_mask)
+unsigned long bitmap_find_next_zero_area_off(unsigned long *map,
+					     unsigned long size,
+					     unsigned long start,
+					     unsigned int nr,
+					     unsigned long align_mask,
+					     unsigned long align_offset)
 {
 	unsigned long index, end, i;
 again:
 	index = find_next_zero_bit(map, size, start);
 
 	/* Align allocation */
-	index = __ALIGN_MASK(index, align_mask);
+	index = __ALIGN_MASK(index + align_offset, align_mask) - align_offset;
 
 	end = index + nr;
 	if (end > size)
@@ -361,7 +363,7 @@ again:
 	}
 	return index;
 }
-EXPORT_SYMBOL(bitmap_find_next_zero_area);
+EXPORT_SYMBOL(bitmap_find_next_zero_area_off);
 
 /*
  * Bitmap printing & parsing functions: first version by Nadia Yvette Chambers,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
