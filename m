Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B84B56B0254
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 08:30:09 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id e127so77714528pfe.3
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 05:30:09 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id ll1si26275230pab.144.2016.02.21.05.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 05:30:08 -0800 (PST)
Received: by mail-pa0-x229.google.com with SMTP id ho8so78201362pac.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 05:30:08 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v2 3/3] mm/zsmalloc: increase ZS_MAX_PAGES_PER_ZSPAGE
Date: Sun, 21 Feb 2016 22:27:54 +0900
Message-Id: <1456061274-20059-4-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

The existing limit of max 4 pages per zspage sets a tight limit
on ->huge classes, which results in increased memory consumption.

On x86_64, PAGE_SHIFT 12, ->huge class_size range is 3280-4096.
The problem with ->huge classes is that in most of the cases they
waste memory, because each ->huge zspage has only one order-0 page
and can store only one object.

For instance, we store 3408 bytes objects as PAGE_SIZE objects,
while in fact each of those objects has 4096 - 3408 = 688 bytes
of spare space, so we need to store 5 objects to have enough spare
space to save the 6th objects with out requesting a new order-0 page.
In general, turning a ->huge class into a normal will save PAGE_SIZE
bytes every time "PAGE_SIZE/(PAGE_SIZE - CLASS_SIZE)"-th object is
stored.

The maximum number of order-0 pages in zspages is limited by
ZS_MAX_ZSPAGE_ORDER (zspage can consist of up to 1<<ZS_MAX_ZSPAGE_ORDER
pages). Increasing ZS_MAX_ZSPAGE_ORDER permits us to have less ->huge
classes, because some of them now can form a 'normal' zspage consisting
of several order-0 pages.

We can't increase ZS_MAX_ZSPAGE_ORDER on every platform: 32-bit
PAE/LPAE and PAGE_SHIFT 16 kernels don't have enough bits left in
OBJ_INDEX_BITS. Other than that, we can increase ZS_MAX_ZSPAGE_ORDER
to 4. This will change the ->huge classes range (on PAGE_SHIFT 12
systems) from 3280-4096 to 3856-4096. This will increase density
and reduce memory wastage/usage.

TESTS (ZS_MAX_ZSPAGE_ORDER 4)
=============================

showing only bottom of /sys/kernel/debug/zsmalloc/zram0/classes

 class  size almost_full almost_empty obj_allocated   obj_used pages_used
 ========================================================================

1) compile glibc -j8

BASE
...
   168  2720           0           14          4500       4479       3000
   190  3072           0           15          3016       2986       2262
   202  3264           2            2            70         61         56
   254  4096           0            0         40213      40213      40213

 Total                63          247        155676     153957      74955

PATCHED
...
   191  3088           1            1           130        116        100
   192  3104           1            1           119        103         91
   194  3136           1            1           260        254        200
   197  3184           0            3           522        503        406
   199  3216           2            3           350        320        275
   200  3232           0            2           114         93         90
   202  3264           2            2           210        202        168
   206  3328           1            5           464        418        377
   207  3344           1            2           121        108         99
   208  3360           0            3           153        119        126
   211  3408           2            4           360        341        300
   212  3424           1            2           133        112        112
   214  3456           0            2           182        170        154
   217  3504           0            4           217        200        186
   219  3536           0            3           135        108        117
   222  3584           0            3           144        132        126
   223  3600           1            1            51         35         45
   225  3632           1            2           108         99         96
   228  3680           0            2           140        129        126
   230  3712           0            3           110         94        100
   232  3744           1            2           132        113        121
   234  3776           1            2           143        128        132
   235  3792           0            3           112         81        104
   236  3808           0            2            75         62         70
   238  3840           0            2           112         91        105
   254  4096           0            0         36112      36112      36112

 Total               127          228        158342     154050      73884

== Consumed 74955-73884 = 1071 less order-0 pages.

2) copy linux-next directory (with object files, 2.5G)

BASE
...
   190  3072           0            1          9092       9091       6819
   202  3264           0            0           240        240        192
   254  4096           0            0        360304     360304     360304

 Total                34           83        687545     686443     480962

PATCHED
...
   191  3088           0            1           455        449        350
   192  3104           1            0           425        421        325
   194  3136           1            0           936        935        720
   197  3184           0            1          1539       1532       1197
   199  3216           0            1          1148       1142        902
   200  3232           0            1           570        560        450
   202  3264           1            0          1245       1244        996
   206  3328           0            1          2896       2887       2353
   207  3344           0            0           825        825        675
   208  3360           0            1           850        845        700
   211  3408           0            1          2694       2692       2245
   212  3424           0            1           931        922        784
   214  3456           1            0          1924       1923       1628
   217  3504           0            0          2968       2968       2544
   219  3536           0            1          2220       2209       1924
   222  3584           0            1          3120       3114       2730
   223  3600           0            1          1088       1081        960
   225  3632           0            1          2133       2130       1896
   228  3680           0            1          3340       3334       3006
   230  3712           0            1          2035       2025       1850
   232  3744           0            1          1980       1972       1815
   234  3776           0            1          2015       2009       1860
   235  3792           0            1          1022       1013        949
   236  3808           1            0           960        958        896
   238  3840           0            0          1968       1968       1845
   254  4096           0            0        319370     319370     319370

 Total                71          137        687877     684436     471265

Consumed 480962 - 471265 = 9697 less order-0 pages.

3) Run a test script (storing text files of various sizes, binary files
   of various sizes)

cat /sys/block/zram0/mm_stat column 3 is zs_get_total_pages() << PAGE_SHIFT

BASE
614477824 425627436 436678656        0 436678656   539608        0        1
614526976 425709397 436813824        0 436813824   539580        0        1
614502400 425694649 436719616        0 436719616   539585        0        1
614510592 425658934 436723712        0 436723712   539583        0        1
614477824 425685915 436740096        0 436740096   539589        0        1

PATCHED
614543360 387655040 395124736        0 395124736   539577        0        1
614445056 387667599 395206656        0 395206656   539614        0        1
614477824 387686121 395059200        0 395059200   539589        0        1
614461440 387748115 395075584        0 395075584   539592        0        1
614486016 387670405 395022336        0 395022336   539588        0        1

== Consumed around 39MB less memory.

P.S. on x86_64, minimum LZO compressed buffer size seems to be around 44
bytes. zsmalloc adds ZS_HANDLE_SIZE (sizeof(unsigned long)) to the object's
size in zs_malloc(). Thus, 32 bytes and 48 bytes classes are unreachable by
LZO on x86_64 PAGE_SHIFT 12 platforms. LZ4, however, seems to have a minimum
compressed buffer size around 26 bytes. So, once again, on x86_64, 32 bytes
class is unreachable, but we need to keep 48 bytes size class. In he worst
case, in theory, if we ever run out of bits in OBJ_INDEX_BITS we can drop 32
bytes and (well, with some consideration) 48 bytes classes, IOW, do
ZS_MIN_ALLOC_SIZE << 1.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 29 ++++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e7f10bd..ab9ed8f 100644
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
@@ -96,6 +89,7 @@
 #ifndef MAX_PHYSMEM_BITS
 #ifdef CONFIG_HIGHMEM64G
 #define MAX_PHYSMEM_BITS 36
+#define ZS_MAX_ZSPAGE_ORDER 2
 #else /* !CONFIG_HIGHMEM64G */
 /*
  * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
@@ -104,9 +98,30 @@
 #define MAX_PHYSMEM_BITS BITS_PER_LONG
 #endif
 #endif
+
 #define _PFN_BITS		(MAX_PHYSMEM_BITS - PAGE_SHIFT)
 
 /*
+ * We don't have enough bits in OBJ_INDEX_BITS on HIGHMEM64G and
+ * PAGE_SHIFT 16 systems to have huge ZS_MAX_ZSPAGE_ORDER there.
+ * This will significantly increase ZS_MIN_ALLOC_SIZE and drop a
+ * number of important (frequently used in general) size classes.
+ */
+#if PAGE_SHIFT > 14
+#define ZS_MAX_ZSPAGE_ORDER 2
+#endif
+
+#ifndef ZS_MAX_ZSPAGE_ORDER
+#define ZS_MAX_ZSPAGE_ORDER 4
+#endif
+
+/*
+ * A single 'zspage' is composed of up to 2^N discontiguous 0-order (single)
+ * pages. ZS_MAX_ZSPAGE_ORDER defines upper limit on N.
+ */
+#define ZS_MAX_PAGES_PER_ZSPAGE (_AC(1, UL) << ZS_MAX_ZSPAGE_ORDER)
+
+/*
  * Memory for allocating for handle keeps object position by
  * encoding <page, obj_idx> and the encoded value has a room
  * in least bit(ie, look at obj_to_location).
-- 
2.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
