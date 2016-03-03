Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 72FC06B025A
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 09:48:38 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 63so16046082pfe.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 06:48:38 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id m17si139025pfj.147.2016.03.03.06.48.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 06:48:37 -0800 (PST)
Received: by mail-pa0-x232.google.com with SMTP id fy10so15923947pac.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 06:48:37 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v3 5/5] mm/zsmalloc: reduce the number of huge classes
Date: Thu,  3 Mar 2016 23:46:03 +0900
Message-Id: <1457016363-11339-6-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

The existing limit of max 4 pages per zspage sets a tight limit
on ->huge classes, which results in increased memory consumption.

On x86_64, PAGE_SHIFT 12, ->huge class_size range is 3280-4096.
Each ->huge zspage has only one order-0 page and can store only
one object, so in the huge classes increase zsmalloc memory usage.
For instance, we store 3408 bytes objects as PAGE_SIZE objects,
while in fact each of those objects has 4096 - 3408 = 688 bytes
of spare space, so 5 objects will have 5*688 bytes of spare
space - enough to store an additional 3408 bytes objects with out
requesting a new order-0 page. In general, turning a ->huge class
into a normal will save PAGE_SIZE bytes every time
"PAGE_SIZE/(PAGE_SIZE - CLASS_SIZE)"-th object is stored.

The maximum number of order-0 pages in zspages is limited by
ZS_MAX_ZSPAGE_ORDER (zspage can have up to 1 << ZS_MAX_ZSPAGE_ORDER
order-0 pages). Increasing ZS_MAX_ZSPAGE_ORDER permits us to have
less ->huge classes, because some of them now can form a 'normal'
zspage consisting of several order-0 pages, however, a larger
ZS_MAX_ZSPAGE_ORDER will change characteristics of 'normal'
classes. For instance, with ZS_MAX_ZSPAGE_ORDER set to 4, class-176
will grow to 11 order-0 pages per zspage from its current limit of 4
order-0 pages per zspage. While the new value gives better density,
because in 11 order-0 pages we can store 4096 * 11 / 176 == 256
objects and 256 * 176 == 11 * 4096 (zero wasted bytes in every FULL
zspage), the increased class's memory requirement is considered to
have a negative impact (bigger than the gain). To avoid this, new
ZS_MAX_HUGE_ZSPAGE_ORDER and ZS_MAX_PAGES_PER_HUGE_ZSPAGE defines
are introduced, which will be used for ->huge classes only; 'normal'
classes will still be configured using the existing ZS_MAX_ZSPAGE_ORDER
and ZS_MAX_PAGES_PER_ZSPAGE.

Class configuration in get_pages_per_zspage(), thus, now has a
fallback scenario -- we attempt to configure class as a normal
class first using ZS_MAX_ZSPAGE_ORDER limit and only if that
class ended up being ->huge we attempt to configure it using
ZS_MAX_HUGE_ZSPAGE_ORDER limit.

ZS_MAX_HUGE_ZSPAGE_ORDER set to 4 give us a new ->huge classes
size range of: 3856-4096 bytes (on a PAGE_SHIFT 12 system).

TESTS
=====

1) copy linux directory with source and object files

/sys/block/zram0/mm_stat

BASE
2613661696 1786896890 1812230144        0 1812230144     4313      106        2

PATCHED
2616717312 1766397396 1793818624        0 1793818624     3569      147        1

pool stats for this test:

BASE
...
   168  2720           0            0         12405      12405       8270                2        0
   190  3072           0            1          7328       7327       5496                3        0
   202  3264           0            1           150        148        120                4        0
   254  4096           0            0        325705     325705     325705                1        0

 Total                46           53        638809     638101     442439                         6

PATCHED
...
   202  3264           0            1          5065       5062       4052                4        0
   206  3328           0            1          2512       2506       2041               13        0
   207  3344           0            1           759        754        621                9        0
   208  3360           0            1           765        749        630               14        0
   211  3408           0            1          2454       2449       2045                5        0
   212  3424           0            1           836        829        704               16        0
   214  3456           0            1          1742       1735       1474               11        0
   217  3504           0            1          2765       2760       2370                6        0
   219  3536           1            0          1890       1887       1638               13        0
   222  3584           0            0          2720       2720       2380                7        0
   223  3600           0            1           918        906        810               15        0
   225  3632           0            1          1908       1902       1696                8        0
   228  3680           0            1          2860       2857       2574                9        0
   230  3712           0            1          1892       1883       1720               10        0
   232  3744           0            1          1812       1801       1661               11        0
   234  3776           1            0          1794       1793       1656               12        0
   235  3792           0            1           882        875        819               13        0
   236  3808           0            1           870        860        812               14        0
   238  3840           1            0          1664       1663       1560               15        0
   254  4096           0            0        289864     289864     289864                1        0

 Total                25           83        639985     638847     437944                        17

= memory saving: (1812230144 - 1793818624) / 4096 = 4495 order-0 pages

2) run a test script

 a) for i in {2..7} do
   -- create text files (50% of disk size), create binary files (50% of disk size)
   -- truncate all files to 1/$i of original size; remove files;

 b) create text files (50% of disk size), create binary files (50% of disk size)
    - compress (gzip -9) text files
    - create a copy of every compressed file, using original files' names,
      so gunzip will have to overwrite files during decompression
    - decompress archives, overwriting already existing files

Showing only zs_get_total_pages() and zram->max_used_pages stats (/sys/block/zram0/mm_stat)

                                  BASE                      PATCHED
INITIAL STATE           1620959232 / 1620959232     1539022848 / 1539022848
TRUNCATE BIN 1/2        1128337408 / 1621217280     1114112000 / 1539305472
TRUNCATE TEXT 1/2        627945472 / 1621217280      613818368 / 1539305472

INITIAL STATE           1626198016 / 1626198016     1544245248 / 1544245248
TRUNCATE BIN 1/3        1028653056 / 1626238976     1029984256 / 1544269824
TRUNCATE TEXT 1/3        355729408 / 1626238976      357408768 / 1544269824

INITIAL STATE           1626730496 / 1626730496     1544654848 / 1544654848
TRUNCATE BIN 1/4        1021796352 / 1626763264     1021341696 / 1544663040
TRUNCATE TEXT 1/4        264744960 / 1626763264      265011200 / 1544663040

INITIAL STATE           1626726400 / 1626763264     1544794112 / 1544794112
TRUNCATE BIN 1/5        1021652992 / 1626763264     1021386752 / 1544802304
TRUNCATE TEXT 1/5        214376448 / 1626763264      214519808 / 1544802304

INITIAL STATE           1626853376 / 1626853376     1544835072 / 1544835072
TRUNCATE BIN 1/6        1021714432 / 1626853376     1021464576 / 1544863744
TRUNCATE TEXT 1/6        180908032 / 1626853376      181075968 / 1544863744

INITIAL STATE           1626726400 / 1626853376     1544822784 / 1544863744
TRUNCATE BIN 1/7        1021595648 / 1626853376     1021612032 / 1544863744
TRUNCATE TEXT 1/7        156188672 / 1626853376      156327936 / 1544863744

INITIAL STATE           1626796032 / 1626873856     1544904704 / 1544953856
COMPRESS TEXT           1763684352 / 1768726528     1681707008 / 1686708224
DECOMPRESS TEXT         1628348416 / 1768726528     1546612736 / 1686708224

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 35 +++++++++++++++++++++++++----------
 1 file changed, 25 insertions(+), 10 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 06a7d87..d5aae38 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -73,13 +73,6 @@
  */
 #define ZS_ALIGN		8
 
-/*
- * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
- * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
- */
-#define ZS_MAX_ZSPAGE_ORDER 2
-#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
-
 #define ZS_HANDLE_SIZE (sizeof(unsigned long))
 
 /*
@@ -95,7 +88,7 @@
 
 #ifndef MAX_PHYSMEM_BITS
 #ifdef CONFIG_HIGHMEM64G
-#define MAX_PHYSMEM_BITS 36
+#define MAX_PHYSMEM_BITS	36
 #else /* !CONFIG_HIGHMEM64G */
 /*
  * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
@@ -104,8 +97,19 @@
 #define MAX_PHYSMEM_BITS BITS_PER_LONG
 #endif
 #endif
+
 #define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
 
+
+/*
+ * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
+ * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
+ */
+#define ZS_MAX_ZSPAGE_ORDER	2
+#define ZS_MAX_HUGE_ZSPAGE_ORDER	4
+#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
+#define ZS_MAX_PAGES_PER_HUGE_ZSPAGE (_AC(1, UL) << ZS_MAX_HUGE_ZSPAGE_ORDER)
+
 /*
  * Memory for allocating for handle keeps object position by
  * encoding <page, obj_idx> and the encoded value has a room
@@ -752,13 +756,13 @@ out:
  * link together 3 PAGE_SIZE sized pages to form a zspage
  * since then we can perfectly fit in 8 such objects.
  */
-static int get_pages_per_zspage(int class_size)
+static int __get_pages_per_zspage(int class_size, int max_pages)
 {
 	int i, max_usedpc = 0;
 	/* zspage order which gives maximum used size per KB */
 	int max_usedpc_order = 1;
 
-	for (i = 1; i <= ZS_MAX_PAGES_PER_ZSPAGE; i++) {
+	for (i = 1; i <= max_pages; i++) {
 		int zspage_size;
 		int waste, usedpc;
 
@@ -775,6 +779,17 @@ static int get_pages_per_zspage(int class_size)
 	return max_usedpc_order;
 }
 
+static int get_pages_per_zspage(int class_size)
+{
+	int num = __get_pages_per_zspage(class_size,
+			ZS_MAX_PAGES_PER_ZSPAGE);
+
+	if (num == 1 && get_maxobj_per_zspage(class_size, num) == 1)
+		num = __get_pages_per_zspage(class_size,
+				ZS_MAX_PAGES_PER_HUGE_ZSPAGE);
+	return num;
+}
+
 /*
  * A single 'zspage' is composed of many system pages which are
  * linked together using fields in struct page. This function finds
-- 
2.8.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
