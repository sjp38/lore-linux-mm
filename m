Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3146B0008
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 15:32:37 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a1-v6so850300lfa.16
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 12:32:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s143-v6sor534388lfs.79.2018.04.18.12.32.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 12:32:36 -0700 (PDT)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH V6 1/2 RESEND] xxHash: create arch dependent 32/64-bit xxhash()
Date: Wed, 18 Apr 2018 22:32:19 +0300
Message-Id: <20180418193220.4603-2-timofey.titovets@synesis.ru>
In-Reply-To: <20180418193220.4603-1-timofey.titovets@synesis.ru>
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Timofey Titovets <nefelim4ag@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, leesioh <solee@os.korea.ac.kr>

From: Timofey Titovets <nefelim4ag@gmail.com>

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
