Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC136B0069
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 15:33:31 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id h16so10108814wrf.0
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 12:33:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l124sor54547wmg.23.2017.09.25.12.33.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 12:33:30 -0700 (PDT)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH v3 1/2] xxHash: create arch dependent 32/64-bit xxhash()
Date: Mon, 25 Sep 2017 22:33:19 +0300
Message-Id: <20170925193320.10009-2-nefelim4ag@gmail.com>
In-Reply-To: <20170925193320.10009-1-nefelim4ag@gmail.com>
References: <20170925193320.10009-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, borntraeger@de.ibm.com, kvm@vger.kernel.org, Timofey Titovets <nefelim4ag@gmail.com>

xxh32() - fast on both 32/64-bit platforms
xxh64() - fast only on 64-bit platform

Create xxhash() which will pickup fastest version
on compile time.

As result depends on cpu word size,
the main proporse of that - in memory hashing.

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Linux-kernel <linux-kernel@vger.kernel.org>
Cc: Linux-kvm <kvm@vger.kernel.org>
---
 include/linux/xxhash.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/include/linux/xxhash.h b/include/linux/xxhash.h
index 9e1f42cb57e9..2a04ee5c5219 100644
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
+	return xxh64(input, length, seed);
+#else
+	return xxh32(input, length, seed);
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
