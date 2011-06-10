Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DF9FB900117
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 05:55:04 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LMK0037FJJOCA@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 10 Jun 2011 10:55:00 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LMK00E5IJJM9K@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Jun 2011 10:54:59 +0100 (BST)
Date: Fri, 10 Jun 2011 11:54:49 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 01/10] lib: bitmap: Added alignment offset for
 bitmap_find_next_zero_area()
In-reply-to: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1307699698-29369-2-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>

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
---
 include/linux/bitmap.h |   24 +++++++++++++++++++-----
 lib/bitmap.c           |   22 ++++++++++++----------
 2 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/include/linux/bitmap.h b/include/linux/bitmap.h
index dcafe0b..50e2c16 100644
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
@@ -114,11 +115,24 @@ extern int __bitmap_weight(const unsigned long *bitmap, int bits);
 
 extern void bitmap_set(unsigned long *map, int i, int len);
 extern void bitmap_clear(unsigned long *map, int start, int nr);
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
index 41baf02..bad4f20 100644
--- a/lib/bitmap.c
+++ b/lib/bitmap.c
@@ -315,30 +315,32 @@ void bitmap_clear(unsigned long *map, int start, int nr)
 }
 EXPORT_SYMBOL(bitmap_clear);
 
-/*
+/**
  * bitmap_find_next_zero_area - find a contiguous aligned zero area
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
@@ -350,7 +352,7 @@ again:
 	}
 	return index;
 }
-EXPORT_SYMBOL(bitmap_find_next_zero_area);
+EXPORT_SYMBOL(bitmap_find_next_zero_area_off);
 
 /*
  * Bitmap printing & parsing functions: first version by Bill Irwin,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
