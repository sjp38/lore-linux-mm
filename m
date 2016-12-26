Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B56FB6B0038
	for <linux-mm@kvack.org>; Sun, 25 Dec 2016 23:18:12 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id b22so149809345pfd.0
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 20:18:12 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id r12si14432852pli.82.2016.12.25.20.18.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 25 Dec 2016 20:18:11 -0800 (PST)
Received: from epcas1p4.samsung.com (unknown [182.195.41.48])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OIR00Q82YM9Q400@mailout2.samsung.com> for linux-mm@kvack.org;
 Mon, 26 Dec 2016 13:18:09 +0900 (KST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH] lib: bitmap: introduce bitmap_find_next_zero_area_and_size
Date: Mon, 26 Dec 2016 13:18:11 +0900
Message-id: <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
References: 
 <CGME20161226041809epcas5p1981244de55764c10f1a80d80346f3664@epcas5p1.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: labbott@redhat.com, mina86@mina86.com, m.szyprowski@samsung.com, gregory.0xf0@gmail.com, laurent.pinchart@ideasonboard.com, akinobu.mita@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com, Jaewon Kim <jaewon31.kim@samsung.com>

There was no bitmap API which returns both next zero index and size of zeros
from that index.

This is helpful to look fragmentation. This is an test code to look size of zeros.
Test result is '10+9+994=>1013 found of total: 1024'

unsigned long search_idx, found_idx, nr_found_tot;
unsigned long bitmap_max;
unsigned int nr_found;
unsigned long *bitmap;

search_idx = nr_found_tot = 0;
bitmap_max = 1024;
bitmap = kzalloc(BITS_TO_LONGS(bitmap_max) * sizeof(long),
		 GFP_KERNEL);

/* test bitmap_set offset, count */
bitmap_set(bitmap, 10, 1);
bitmap_set(bitmap, 20, 10);

for (;;) {
	found_idx = bitmap_find_next_zero_area_and_size(bitmap,
				bitmap_max, search_idx, &nr_found);
	if (found_idx >= bitmap_max)
		break;
	if (nr_found_tot == 0)
		printk("%u", nr_found);
	else
		printk("+%u", nr_found);
	nr_found_tot += nr_found;
	search_idx = found_idx + nr_found;
}
printk("=>%lu found of total: %lu\n", nr_found_tot, bitmap_max);

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 include/linux/bitmap.h |  6 ++++++
 lib/bitmap.c           | 25 +++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/include/linux/bitmap.h b/include/linux/bitmap.h
index 3b77588..b724a6c 100644
--- a/include/linux/bitmap.h
+++ b/include/linux/bitmap.h
@@ -46,6 +46,7 @@
  * bitmap_clear(dst, pos, nbits)		Clear specified bit area
  * bitmap_find_next_zero_area(buf, len, pos, n, mask)	Find bit free area
  * bitmap_find_next_zero_area_off(buf, len, pos, n, mask)	as above
+ * bitmap_find_next_zero_area_and_size(buf, len, pos, n, mask)	Find bit free area and its size
  * bitmap_shift_right(dst, src, n, nbits)	*dst = *src >> n
  * bitmap_shift_left(dst, src, n, nbits)	*dst = *src << n
  * bitmap_remap(dst, src, old, new, nbits)	*dst = map(old, new)(src)
@@ -123,6 +124,11 @@ extern unsigned long bitmap_find_next_zero_area_off(unsigned long *map,
 						    unsigned long align_mask,
 						    unsigned long align_offset);
 
+extern unsigned long bitmap_find_next_zero_area_and_size(unsigned long *map,
+							 unsigned long size,
+							 unsigned long start,
+							 unsigned int *nr);
+
 /**
  * bitmap_find_next_zero_area - find a contiguous aligned zero area
  * @map: The address to base the search on
diff --git a/lib/bitmap.c b/lib/bitmap.c
index 0b66f0e..d02817c 100644
--- a/lib/bitmap.c
+++ b/lib/bitmap.c
@@ -332,6 +332,31 @@ unsigned long bitmap_find_next_zero_area_off(unsigned long *map,
 }
 EXPORT_SYMBOL(bitmap_find_next_zero_area_off);
 
+/**
+ * bitmap_find_next_zero_area_and_size - find a contiguous aligned zero area
+ * @map: The address to base the search on
+ * @size: The bitmap size in bits
+ * @start: The bitnumber to start searching at
+ * @nr: The number of zeroed bits we've found
+ */
+unsigned long bitmap_find_next_zero_area_and_size(unsigned long *map,
+					     unsigned long size,
+					     unsigned long start,
+					     unsigned int *nr)
+{
+	unsigned long index, i;
+
+	*nr = 0;
+	index = find_next_zero_bit(map, size, start);
+
+	if (index >= size)
+		return index;
+	i = find_next_bit(map, size, index);
+	*nr = i - index;
+	return index;
+}
+EXPORT_SYMBOL(bitmap_find_next_zero_area_and_size);
+
 /*
  * Bitmap printing & parsing functions: first version by Nadia Yvette Chambers,
  * second version by Paul Jackson, third by Joe Korty.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
