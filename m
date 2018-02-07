Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B8F236B02F7
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 05:22:38 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id 96so125783lfs.20
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 02:22:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j24sor247645lfi.99.2018.02.07.02.22.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Feb 2018 02:22:37 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH V6 1/2 RESEND] xxHash: create arch dependent 32/64-bit xxhash()
Date: Wed,  7 Feb 2018 13:22:23 +0300
Message-Id: <20180207102224.28016-2-nefelim4ag@gmail.com>
In-Reply-To: <20180207102224.28016-1-nefelim4ag@gmail.com>
References: <20180207102224.28016-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Timofey Titovets <nefelim4ag@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, leesioh <solee@os.korea.ac.kr>

xxh32() - fast on both 32/64-bit platforms
xxh64() - fast only on 64-bit platform

Create xxhash() which will pickup fastest version
on compile time.

As result depends on cpu word size,
the main proporse of that - in memory hashing.

Changes:
  v2:
    - Create that patch
  v3 -> v6:
    - Nothing, whole patchset version bump

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
CC: Andrea Arcangeli <aarcange@redhat.com>
CC: linux-mm@kvack.org
CC: kvm@vger.kernel.org
CC: leesioh <solee@os.korea.ac.kr>
---
 include/linux/xxhash.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/include/linux/xxhash.h b/include/linux/xxhash.h
index 9e1f42cb57e9..52b073fea17f 100644
--- a/include/linux/xxhash.h
+++ b/include/linux/xxhash.h
@@ -107,6 +107,29 @@ uint32_t xxh32(const void *input, size_t length, uint32_t seed);
  */
 uint64_t xxh64(const void *input, size_t length, uint64_t seed);
 
+/**
+ * xxhash() - calculate wordsize hash of the input with a given seed
+ * @input:  The data to hash.
+ * @length: The length of the data to hash.
+ * @seed:   The seed can be used to alter the result predictably.
+ *
+ * If the hash does not need to be comparable between machines with
+ * different word sizes, this function will call whichever of xxh32()
+ * or xxh64() is faster.
+ *
+ * Return:  wordsize hash of the data.
+ */
+
+static inline unsigned long xxhash(const void *input, size_t length,
+				   uint64_t seed)
+{
+#if BITS_PER_LONG == 64
+       return xxh64(input, length, seed);
+#else
+       return xxh32(input, length, seed);
+#endif
+}
+
 /*-****************************
  * Streaming Hash Functions
  *****************************/
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
