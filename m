Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id F25C06B13F1
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 02:55:03 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id zs2so7019093bkb.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 23:55:03 -0800 (PST)
Subject: [PATCH 1/4] bitops: implement "optimized" __find_next_bit()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 07 Feb 2012 11:55:00 +0400
Message-ID: <20120207075500.29797.95376.stgit@zurg>
In-Reply-To: <20120207074905.29797.60353.stgit@zurg>
References: <20120207074905.29797.60353.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org

This patch adds  __find_next_bit() -- static-inline variant of find_next_bit()
optimized for small constant size arrays, because find_next_bit() is too heavy
for searching in an array with one/two long elements.
And unlike to find_next_bit() it does not mask tail bits.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/asm-generic/bitops/find.h |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/bitops/find.h b/include/asm-generic/bitops/find.h
index 71c7780..1dd2495 100644
--- a/include/asm-generic/bitops/find.h
+++ b/include/asm-generic/bitops/find.h
@@ -12,6 +12,42 @@ extern unsigned long find_next_bit(const unsigned long *addr, unsigned long
 		size, unsigned long offset);
 #endif
 
+#ifndef __find_next_bit
+/**
+ * __find_next_bit - find the next set bit in a memory region
+ * @addr: The address to base the search on
+ * @size: The bitmap size in bits
+ * @offset: The bitnumber to start searching at
+ *
+ * Unrollable variant of find_next_bit() for constant size arrays.
+ * Tail bits starting from size to roundup(size, BITS_PER_LONG) must be zero.
+ * Returns next bit offset, or size if nothing found.
+ */
+static inline unsigned long __find_next_bit(const unsigned long *addr,
+		unsigned long size, unsigned long offset)
+{
+	if (!__builtin_constant_p(size))
+		return find_next_bit(addr, size, offset);
+
+	if (offset < size) {
+		unsigned long tmp;
+
+		addr += offset / BITS_PER_LONG;
+		tmp = *addr >> (offset % BITS_PER_LONG);
+		if (tmp)
+			return __ffs(tmp) + offset;
+		offset = (offset + BITS_PER_LONG) & ~(BITS_PER_LONG - 1);
+		while (offset < size) {
+			tmp = *++addr;
+			if (tmp)
+				return __ffs(tmp) + offset;
+			offset += BITS_PER_LONG;
+		}
+	}
+	return size;
+}
+#endif
+
 #ifndef find_next_zero_bit
 /**
  * find_next_zero_bit - find the next cleared bit in a memory region

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
