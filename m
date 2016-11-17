Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7E46B02E0
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:25:55 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id w132so75494389ita.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:25:55 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id y15si221447ioe.241.2016.11.16.14.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:04 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 08/29] tools: Add more bitmap functions
Date: Wed, 16 Nov 2016 16:16:35 -0800
Message-Id: <1479341856-30320-11-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

I need the following functions for the radix tree:

bitmap_fill
find_next_zero_bit
bitmap_empty
bitmap_full

Copy the implementations from include/linux/bitmap.h and lib/find_bit.c
---
 tools/include/linux/bitmap.h | 26 ++++++++++++++++++++++++++
 tools/lib/find_bit.c         |  8 ++++++++
 2 files changed, 34 insertions(+)

diff --git a/tools/include/linux/bitmap.h b/tools/include/linux/bitmap.h
index 43c1c50..eef41d5 100644
--- a/tools/include/linux/bitmap.h
+++ b/tools/include/linux/bitmap.h
@@ -35,6 +35,32 @@ static inline void bitmap_zero(unsigned long *dst, int nbits)
 	}
 }
 
+static inline void bitmap_fill(unsigned long *dst, unsigned int nbits)
+{
+	unsigned int nlongs = BITS_TO_LONGS(nbits);
+	if (!small_const_nbits(nbits)) {
+		unsigned int len = (nlongs - 1) * sizeof(unsigned long);
+		memset(dst, 0xff,  len);
+	}
+	dst[nlongs - 1] = BITMAP_LAST_WORD_MASK(nbits);
+}
+
+static inline int bitmap_empty(const unsigned long *src, unsigned nbits)
+{
+	if (small_const_nbits(nbits))
+		return ! (*src & BITMAP_LAST_WORD_MASK(nbits));
+
+	return find_first_bit(src, nbits) == nbits;
+}
+
+static inline int bitmap_full(const unsigned long *src, unsigned int nbits)
+{
+	if (small_const_nbits(nbits))
+		return ! (~(*src) & BITMAP_LAST_WORD_MASK(nbits));
+
+	return find_first_zero_bit(src, nbits) == nbits;
+}
+
 static inline int bitmap_weight(const unsigned long *src, int nbits)
 {
 	if (small_const_nbits(nbits))
diff --git a/tools/lib/find_bit.c b/tools/lib/find_bit.c
index 9122a9e..de26b6f 100644
--- a/tools/lib/find_bit.c
+++ b/tools/lib/find_bit.c
@@ -66,6 +66,14 @@ unsigned long find_next_bit(const unsigned long *addr, unsigned long size,
 }
 #endif
 
+#ifndef find_next_zero_bit
+unsigned long find_next_zero_bit(const unsigned long *addr, unsigned long size,
+				unsigned long offset)
+{
+	return _find_next_bit(addr, size, offset, ~0UL);
+}
+#endif
+
 #ifndef find_first_bit
 /*
  * Find the first set bit in a memory region.
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
