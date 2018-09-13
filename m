Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id F18578E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 17:19:42 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id d17-v6so7022025wrr.14
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:19:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k13-v6sor5020492wmd.18.2018.09.13.14.19.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Sep 2018 14:19:41 -0700 (PDT)
From: Timofey Titovets <timofey.titovets@synesis.ru>
Subject: [PATCH V7 1/2] xxHash: create arch dependent 32/64-bit xxhash()
Date: Fri, 14 Sep 2018 00:19:22 +0300
Message-Id: <20180913211923.7696-2-timofey.titovets@synesis.ru>
In-Reply-To: <20180913211923.7696-1-timofey.titovets@synesis.ru>
References: <20180913211923.7696-1-timofey.titovets@synesis.ru>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pavel.Tatashin@microsoft.com, rppt@linux.vnet.ibm.com, Timofey Titovets <nefelim4ag@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, leesioh <solee@os.korea.ac.kr>

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
2.19.0
