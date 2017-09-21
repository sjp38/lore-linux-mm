Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD6E56B0253
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 19:18:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 97so7775302wrb.1
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 16:18:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b105sor866045wrd.76.2017.09.21.16.18.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 16:18:30 -0700 (PDT)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH v2 1/2] xxHash: create arch dependent 32/64-bit xxhash()
Date: Fri, 22 Sep 2017 02:18:17 +0300
Message-Id: <20170921231818.10271-2-nefelim4ag@gmail.com>
In-Reply-To: <20170921231818.10271-1-nefelim4ag@gmail.com>
References: <20170921231818.10271-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Timofey Titovets <nefelim4ag@gmail.com>

xxh32() - fast on both 32/64-bit platforms
xxh64() - fast only on 64-bit platform

Create xxhash() which will pickup fastest version
on compile time.

Add type xxhash_t to map correct hash size.

As result depends on cpu word size,
the main proporse of that - in memory hashing.

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Cc: Linux-kernel <linux-kernel@vger.kernel.org>
---
 include/linux/xxhash.h | 24 ++++++++++++++++++++++++
 lib/xxhash.c           | 10 ++++++++++
 2 files changed, 34 insertions(+)

diff --git a/include/linux/xxhash.h b/include/linux/xxhash.h
index 9e1f42cb57e9..195a0ae10e9b 100644
--- a/include/linux/xxhash.h
+++ b/include/linux/xxhash.h
@@ -76,6 +76,7 @@
 #define XXHASH_H

 #include <linux/types.h>
+#include <linux/bitops.h> /* BITS_PER_LONG */

 /*-****************************
  * Simple Hash Functions
@@ -107,6 +108,29 @@ uint32_t xxh32(const void *input, size_t length, uint32_t seed);
  */
 uint64_t xxh64(const void *input, size_t length, uint64_t seed);

+#if BITS_PER_LONG == 64
+typedef	u64	xxhash_t;
+#else
+typedef	u32	xxhash_t;
+#endif
+
+/**
+ * xxhash() - calculate 32/64-bit hash based on cpu word size
+ *
+ * @input:  The data to hash.
+ * @length: The length of the data to hash.
+ * @seed:   The seed can be used to alter the result predictably.
+ *
+ * This function always work as xxh32() for 32-bit systems
+ * and as xxh64() for 64-bit systems.
+ * Because result depends on cpu work size,
+ * the main proporse of that function is for  in memory hashing.
+ *
+ * Return:  32/64-bit hash of the data.
+ */
+
+xxhash_t xxhash(const void *input, size_t length, uint64_t seed);
+
 /*-****************************
  * Streaming Hash Functions
  *****************************/
diff --git a/lib/xxhash.c b/lib/xxhash.c
index aa61e2a3802f..7dd1105fcc30 100644
--- a/lib/xxhash.c
+++ b/lib/xxhash.c
@@ -236,6 +236,16 @@ uint64_t xxh64(const void *input, const size_t len, const uint64_t seed)
 }
 EXPORT_SYMBOL(xxh64);

+xxhash_t xxhash(const void *input, size_t length, uint64_t seed)
+{
+#if BITS_PER_LONG == 64
+	return xxh64(input, length, seed);
+#else
+	return xxh32(input, length, seed);
+#endif
+}
+EXPORT_SYMBOL(xxhash);
+
 /*-**************************************************
  * Advanced Hash Functions
  ***************************************************/
--
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
