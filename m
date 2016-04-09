Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id B42E56B025E
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 17:06:20 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id n1so97260297pfn.2
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 14:06:20 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id p20si8914566pfa.90.2016.04.09.14.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Apr 2016 14:06:20 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id hb4so11420709pac.1
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 14:06:19 -0700 (PDT)
From: Rui Salvaterra <rsalvaterra@gmail.com>
Subject: [PATCH v2 1/2] lib: lz4: fixed zram with lz4 on big endian machines
Date: Sat,  9 Apr 2016 22:05:34 +0100
Message-Id: <1460235935-1003-2-git-send-email-rsalvaterra@gmail.com>
In-Reply-To: <1460235935-1003-1-git-send-email-rsalvaterra@gmail.com>
References: <1460235935-1003-1-git-send-email-rsalvaterra@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, sergey.senozhatsky@gmail.com, sergey.senozhatsky.work@gmail.com, gregkh@linuxfoundation.org, eunb.song@samsung.com, minchan@kernel.org, chanho.min@lge.com, kyungsik.lee@lge.com, Rui Salvaterra <rsalvaterra@gmail.com>, stable@vger.kernel.org

Based on Sergey's test patch [1], this fixes zram with lz4 compression
on big endian cpus.

Note that the 64-bit preprocessor test is not a cleanup, it's part of
the fix, since those identifiers are bogus (for example, __ppc64__
isn't defined anywhere else in the kernel, which means we'd fall into
the 32-bit definitions on ppc64).

Tested on ppc64 with no regression on x86_64.

[1] http://marc.info/?l=linux-kernel&m=145994470805853&w=4

Cc: stable@vger.kernel.org
Suggested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Rui Salvaterra <rsalvaterra@gmail.com>
---
 lib/lz4/lz4defs.h | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/lib/lz4/lz4defs.h b/lib/lz4/lz4defs.h
index abcecdc..0710a62 100644
--- a/lib/lz4/lz4defs.h
+++ b/lib/lz4/lz4defs.h
@@ -11,8 +11,7 @@
 /*
  * Detects 64 bits mode
  */
-#if (defined(__x86_64__) || defined(__x86_64) || defined(__amd64__) \
-	|| defined(__ppc64__) || defined(__LP64__))
+#if defined(CONFIG_64BIT)
 #define LZ4_ARCH64 1
 #else
 #define LZ4_ARCH64 0
@@ -35,6 +34,10 @@ typedef struct _U64_S { u64 v; } U64_S;
 
 #define PUT4(s, d) (A32(d) = A32(s))
 #define PUT8(s, d) (A64(d) = A64(s))
+
+#define LZ4_READ_LITTLEENDIAN_16(d, s, p)	\
+	(d = s - A16(p))
+
 #define LZ4_WRITE_LITTLEENDIAN_16(p, v)	\
 	do {	\
 		A16(p) = v; \
@@ -51,10 +54,13 @@ typedef struct _U64_S { u64 v; } U64_S;
 #define PUT8(s, d) \
 	put_unaligned(get_unaligned((const u64 *) s), (u64 *) d)
 
-#define LZ4_WRITE_LITTLEENDIAN_16(p, v)	\
-	do {	\
-		put_unaligned(v, (u16 *)(p)); \
-		p += 2; \
+#define LZ4_READ_LITTLEENDIAN_16(d, s, p)	\
+	(d = s - get_unaligned_le16(p))
+
+#define LZ4_WRITE_LITTLEENDIAN_16(p, v)			\
+	do {						\
+		put_unaligned_le16(v, (u16 *)(p));	\
+		p += 2;					\
 	} while (0)
 #endif
 
@@ -140,9 +146,6 @@ typedef struct _U64_S { u64 v; } U64_S;
 
 #endif
 
-#define LZ4_READ_LITTLEENDIAN_16(d, s, p) \
-	(d = s - get_unaligned_le16(p))
-
 #define LZ4_WILDCOPY(s, d, e)		\
 	do {				\
 		LZ4_COPYPACKET(s, d);	\
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
