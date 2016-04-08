Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEDB6B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 11:24:18 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id e128so77839096pfe.3
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 08:24:18 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id m76si1314415pfj.133.2016.04.08.08.24.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 08:24:17 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id r187so9764432pfr.2
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 08:24:17 -0700 (PDT)
From: Rui Salvaterra <rsalvaterra@gmail.com>
Subject: [PATCH] lib: lz4: fixed zram with lz4 on big endian machines
Date: Fri,  8 Apr 2016 16:23:24 +0100
Message-Id: <1460129004-2011-1-git-send-email-rsalvaterra@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, sergey.senozhatsky@gmail.com, sergey.senozhatsky.work@gmail.com, gregkh@linuxfoundation.org, eunb.song@samsung.com, minchan@kernel.org, chanho.min@lge.com, kyungsik.lee@lge.com, Rui Salvaterra <rsalvaterra@gmail.com>, stable@vger.kernel.org

Based on Sergey's test patch [1], this fixes zram with lz4 compression on big endian cpus. Tested on ppc64 with no regression on x86_64.

[1] http://marc.info/?l=linux-kernel&m=145994470805853&w=4

Cc: stable@vger.kernel.org
Signed-off-by: Rui Salvaterra <rsalvaterra@gmail.com>
---
 lib/lz4/lz4defs.h | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/lib/lz4/lz4defs.h b/lib/lz4/lz4defs.h
index abcecdc..a98c08c 100644
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
@@ -25,9 +24,7 @@
 typedef struct _U16_S { u16 v; } U16_S;
 typedef struct _U32_S { u32 v; } U32_S;
 typedef struct _U64_S { u64 v; } U64_S;
-#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)		\
-	|| defined(CONFIG_ARM) && __LINUX_ARM_ARCH__ >= 6	\
-	&& defined(ARM_EFFICIENT_UNALIGNED_ACCESS)
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
 
 #define A16(x) (((U16_S *)(x))->v)
 #define A32(x) (((U32_S *)(x))->v)
@@ -35,6 +32,10 @@ typedef struct _U64_S { u64 v; } U64_S;
 
 #define PUT4(s, d) (A32(d) = A32(s))
 #define PUT8(s, d) (A64(d) = A64(s))
+
+#define LZ4_READ_LITTLEENDIAN_16(d, s, p)	\
+	(d = s - A16(p))
+
 #define LZ4_WRITE_LITTLEENDIAN_16(p, v)	\
 	do {	\
 		A16(p) = v; \
@@ -51,12 +52,15 @@ typedef struct _U64_S { u64 v; } U64_S;
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
-#endif
+#endif /* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */
 
 #define COPYLENGTH 8
 #define ML_BITS  4
@@ -138,10 +142,7 @@ typedef struct _U64_S { u64 v; } U64_S;
 #define LZ4_NBCOMMONBYTES(val) (__builtin_ctz(val) >> 3)
 #endif
 
-#endif
-
-#define LZ4_READ_LITTLEENDIAN_16(d, s, p) \
-	(d = s - get_unaligned_le16(p))
+#endif /* LZ4_ARCH64 */
 
 #define LZ4_WILDCOPY(s, d, e)		\
 	do {				\
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
