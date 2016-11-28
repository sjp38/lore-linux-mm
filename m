Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id F31E76B02D3
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:34 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j65so260945781iof.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:34 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id k3si17473992itk.53.2016.11.28.11.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:39 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 13/33] radix tree test suite: Use common find-bit code
Date: Mon, 28 Nov 2016 13:50:51 -0800
Message-Id: <1480369871-5271-48-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Remove the old find_next_bit code in favour of linking in the find_bit
code from tools/lib.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 tools/testing/radix-tree/Makefile                  |  7 ++-
 tools/testing/radix-tree/find_next_bit.c           | 57 ----------------------
 tools/testing/radix-tree/linux/bitops.h            | 40 +++++++++------
 tools/testing/radix-tree/linux/bitops/non-atomic.h | 13 +++--
 tools/testing/radix-tree/linux/kernel.h            | 11 +++++
 5 files changed, 48 insertions(+), 80 deletions(-)
 delete mode 100644 tools/testing/radix-tree/find_next_bit.c

diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index 08283a8..3635e4d 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -18,7 +18,12 @@ main:	$(OFILES)
 clean:
 	$(RM) -f $(TARGETS) *.o radix-tree.c
 
-$(OFILES): *.h */*.h ../../../include/linux/radix-tree.h ../../include/linux/*.h
+find_next_bit.o: ../../lib/find_bit.c
+	$(CC) $(CFLAGS) -c -o $@ $<
+
+$(OFILES): *.h */*.h \
+	../../include/linux/*.h \
+	../../../include/linux/radix-tree.h
 
 radix-tree.c: ../../../lib/radix-tree.c
 	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
diff --git a/tools/testing/radix-tree/find_next_bit.c b/tools/testing/radix-tree/find_next_bit.c
deleted file mode 100644
index d1c2178..0000000
--- a/tools/testing/radix-tree/find_next_bit.c
+++ /dev/null
@@ -1,57 +0,0 @@
-/* find_next_bit.c: fallback find next bit implementation
- *
- * Copyright (C) 2004 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#include <linux/types.h>
-#include <linux/bitops.h>
-
-#define BITOP_WORD(nr)		((nr) / BITS_PER_LONG)
-
-/*
- * Find the next set bit in a memory region.
- */
-unsigned long find_next_bit(const unsigned long *addr, unsigned long size,
-			    unsigned long offset)
-{
-	const unsigned long *p = addr + BITOP_WORD(offset);
-	unsigned long result = offset & ~(BITS_PER_LONG-1);
-	unsigned long tmp;
-
-	if (offset >= size)
-		return size;
-	size -= result;
-	offset %= BITS_PER_LONG;
-	if (offset) {
-		tmp = *(p++);
-		tmp &= (~0UL << offset);
-		if (size < BITS_PER_LONG)
-			goto found_first;
-		if (tmp)
-			goto found_middle;
-		size -= BITS_PER_LONG;
-		result += BITS_PER_LONG;
-	}
-	while (size & ~(BITS_PER_LONG-1)) {
-		if ((tmp = *(p++)))
-			goto found_middle;
-		result += BITS_PER_LONG;
-		size -= BITS_PER_LONG;
-	}
-	if (!size)
-		return result;
-	tmp = *p;
-
-found_first:
-	tmp &= (~0UL >> (BITS_PER_LONG - size));
-	if (tmp == 0UL)		/* Are any bits set? */
-		return result + size;	/* Nope. */
-found_middle:
-	return result + __ffs(tmp);
-}
diff --git a/tools/testing/radix-tree/linux/bitops.h b/tools/testing/radix-tree/linux/bitops.h
index 71d58427..a13e9bc 100644
--- a/tools/testing/radix-tree/linux/bitops.h
+++ b/tools/testing/radix-tree/linux/bitops.h
@@ -2,9 +2,14 @@
 #define _ASM_GENERIC_BITOPS_NON_ATOMIC_H_
 
 #include <linux/types.h>
+#include <linux/bitops/find.h>
+#include <linux/bitops/hweight.h>
+#include <linux/kernel.h>
 
-#define BITOP_MASK(nr)		(1UL << ((nr) % BITS_PER_LONG))
-#define BITOP_WORD(nr)		((nr) / BITS_PER_LONG)
+#define BIT_MASK(nr)		(1UL << ((nr) % BITS_PER_LONG))
+#define BIT_WORD(nr)		((nr) / BITS_PER_LONG)
+#define BITS_PER_BYTE		8
+#define BITS_TO_LONGS(nr)	DIV_ROUND_UP(nr, BITS_PER_BYTE * sizeof(long))
 
 /**
  * __set_bit - Set a bit in memory
@@ -17,16 +22,16 @@
  */
 static inline void __set_bit(int nr, volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
 
 	*p  |= mask;
 }
 
 static inline void __clear_bit(int nr, volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
 
 	*p &= ~mask;
 }
@@ -42,8 +47,8 @@ static inline void __clear_bit(int nr, volatile unsigned long *addr)
  */
 static inline void __change_bit(int nr, volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
 
 	*p ^= mask;
 }
@@ -59,8 +64,8 @@ static inline void __change_bit(int nr, volatile unsigned long *addr)
  */
 static inline int __test_and_set_bit(int nr, volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
 	unsigned long old = *p;
 
 	*p = old | mask;
@@ -78,8 +83,8 @@ static inline int __test_and_set_bit(int nr, volatile unsigned long *addr)
  */
 static inline int __test_and_clear_bit(int nr, volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
 	unsigned long old = *p;
 
 	*p = old & ~mask;
@@ -90,8 +95,8 @@ static inline int __test_and_clear_bit(int nr, volatile unsigned long *addr)
 static inline int __test_and_change_bit(int nr,
 					    volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
 	unsigned long old = *p;
 
 	*p = old ^ mask;
@@ -105,7 +110,7 @@ static inline int __test_and_change_bit(int nr,
  */
 static inline int test_bit(int nr, const volatile unsigned long *addr)
 {
-	return 1UL & (addr[BITOP_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
+	return 1UL & (addr[BIT_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
 }
 
 /**
@@ -147,4 +152,9 @@ unsigned long find_next_bit(const unsigned long *addr,
 			    unsigned long size,
 			    unsigned long offset);
 
+static inline unsigned long hweight_long(unsigned long w)
+{
+	return sizeof(w) == 4 ? hweight32(w) : hweight64(w);
+}
+
 #endif /* _ASM_GENERIC_BITOPS_NON_ATOMIC_H_ */
diff --git a/tools/testing/radix-tree/linux/bitops/non-atomic.h b/tools/testing/radix-tree/linux/bitops/non-atomic.h
index 46a825c..6a1bcb9 100644
--- a/tools/testing/radix-tree/linux/bitops/non-atomic.h
+++ b/tools/testing/radix-tree/linux/bitops/non-atomic.h
@@ -3,7 +3,6 @@
 
 #include <asm/types.h>
 
-#define BITOP_MASK(nr)		(1UL << ((nr) % BITS_PER_LONG))
 #define BITOP_WORD(nr)		((nr) / BITS_PER_LONG)
 
 /**
@@ -17,7 +16,7 @@
  */
 static inline void __set_bit(int nr, volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
+	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
 
 	*p  |= mask;
@@ -25,7 +24,7 @@ static inline void __set_bit(int nr, volatile unsigned long *addr)
 
 static inline void __clear_bit(int nr, volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
+	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
 
 	*p &= ~mask;
@@ -42,7 +41,7 @@ static inline void __clear_bit(int nr, volatile unsigned long *addr)
  */
 static inline void __change_bit(int nr, volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
+	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
 
 	*p ^= mask;
@@ -59,7 +58,7 @@ static inline void __change_bit(int nr, volatile unsigned long *addr)
  */
 static inline int __test_and_set_bit(int nr, volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
+	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
 	unsigned long old = *p;
 
@@ -78,7 +77,7 @@ static inline int __test_and_set_bit(int nr, volatile unsigned long *addr)
  */
 static inline int __test_and_clear_bit(int nr, volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
+	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
 	unsigned long old = *p;
 
@@ -90,7 +89,7 @@ static inline int __test_and_clear_bit(int nr, volatile unsigned long *addr)
 static inline int __test_and_change_bit(int nr,
 					    volatile unsigned long *addr)
 {
-	unsigned long mask = BITOP_MASK(nr);
+	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
 	unsigned long old = *p;
 
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index dbe4b92..23e77f5 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -47,4 +47,15 @@ static inline int in_interrupt(void)
 {
 	return 0;
 }
+
+/*
+ * This looks more complex than it should be. But we need to
+ * get the type for the ~ right in round_down (it needs to be
+ * as wide as the result!), and we want to evaluate the macro
+ * arguments just once each.
+ */
+#define __round_mask(x, y) ((__typeof__(x))((y)-1))
+#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
+#define round_down(x, y) ((x) & ~__round_mask(x, y))
+
 #endif /* _KERNEL_H */
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
