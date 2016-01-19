Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8196B0254
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 09:25:48 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id ho8so191455970pac.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 06:25:48 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id s7si45978258pfi.10.2016.01.19.06.25.40
        for <linux-mm@kvack.org>;
        Tue, 19 Jan 2016 06:25:40 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 2/8] radix tree test harness
Date: Tue, 19 Jan 2016 09:25:27 -0500
Message-Id: <1453213533-6040-3-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

This code is mostly from Andrew Morton; tarball downloaded
from http://ozlabs.org/~akpm/rtth.tar.gz with sha1sum
0ce679db9ec047296b5d1ff7a1dfaa03a7bef1bd

Some small modifications were necessary to the test harness to fix the
build with the current Linux source code.

I also made minor modifications to automatically test the radix-tree.c
and radix-tree.h files that are in the current source tree, as opposed
to a copied and slightly modified version.  I am sure more could be
done to tidy up the harness, as well as adding more tests.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 tools/testing/radix-tree/.gitignore                |   2 +
 tools/testing/radix-tree/Makefile                  |  20 ++
 tools/testing/radix-tree/find_next_bit.c           |  57 ++++
 tools/testing/radix-tree/linux.c                   |  60 ++++
 tools/testing/radix-tree/linux/bitops.h            | 150 ++++++++++
 tools/testing/radix-tree/linux/bitops/__ffs.h      |  43 +++
 tools/testing/radix-tree/linux/bitops/ffs.h        |  41 +++
 tools/testing/radix-tree/linux/bitops/ffz.h        |  12 +
 tools/testing/radix-tree/linux/bitops/find.h       |  13 +
 tools/testing/radix-tree/linux/bitops/fls.h        |  41 +++
 tools/testing/radix-tree/linux/bitops/fls64.h      |  14 +
 tools/testing/radix-tree/linux/bitops/hweight.h    |  11 +
 tools/testing/radix-tree/linux/bitops/le.h         |  53 ++++
 tools/testing/radix-tree/linux/bitops/non-atomic.h | 111 +++++++
 tools/testing/radix-tree/linux/bug.h               |   1 +
 tools/testing/radix-tree/linux/cpu.h               |  35 +++
 tools/testing/radix-tree/linux/export.h            |   2 +
 tools/testing/radix-tree/linux/gfp.h               |   8 +
 tools/testing/radix-tree/linux/init.h              |   0
 tools/testing/radix-tree/linux/kernel.h            |  34 +++
 tools/testing/radix-tree/linux/kmemleak.h          |   1 +
 tools/testing/radix-tree/linux/mempool.h           |  17 ++
 tools/testing/radix-tree/linux/notifier.h          |   8 +
 tools/testing/radix-tree/linux/percpu.h            |   7 +
 tools/testing/radix-tree/linux/preempt.h           |   5 +
 tools/testing/radix-tree/linux/radix-tree.h        |   1 +
 tools/testing/radix-tree/linux/rcupdate.h          |   9 +
 tools/testing/radix-tree/linux/slab.h              |  28 ++
 tools/testing/radix-tree/linux/string.h            |   0
 tools/testing/radix-tree/linux/types.h             |  28 ++
 tools/testing/radix-tree/main.c                    | 271 +++++++++++++++++
 tools/testing/radix-tree/rcupdate.c                |  86 ++++++
 tools/testing/radix-tree/regression.h              |   7 +
 tools/testing/radix-tree/regression1.c             | 221 ++++++++++++++
 tools/testing/radix-tree/regression2.c             | 126 ++++++++
 tools/testing/radix-tree/tag_check.c               | 332 +++++++++++++++++++++
 tools/testing/radix-tree/test.c                    | 218 ++++++++++++++
 tools/testing/radix-tree/test.h                    |  40 +++
 38 files changed, 2113 insertions(+)
 create mode 100644 tools/testing/radix-tree/.gitignore
 create mode 100644 tools/testing/radix-tree/Makefile
 create mode 100644 tools/testing/radix-tree/find_next_bit.c
 create mode 100644 tools/testing/radix-tree/linux.c
 create mode 100644 tools/testing/radix-tree/linux/bitops.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/__ffs.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/ffs.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/ffz.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/find.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/fls.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/fls64.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/hweight.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/le.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/non-atomic.h
 create mode 100644 tools/testing/radix-tree/linux/bug.h
 create mode 100644 tools/testing/radix-tree/linux/cpu.h
 create mode 100644 tools/testing/radix-tree/linux/export.h
 create mode 100644 tools/testing/radix-tree/linux/gfp.h
 create mode 100644 tools/testing/radix-tree/linux/init.h
 create mode 100644 tools/testing/radix-tree/linux/kernel.h
 create mode 100644 tools/testing/radix-tree/linux/kmemleak.h
 create mode 100644 tools/testing/radix-tree/linux/mempool.h
 create mode 100644 tools/testing/radix-tree/linux/notifier.h
 create mode 100644 tools/testing/radix-tree/linux/percpu.h
 create mode 100644 tools/testing/radix-tree/linux/preempt.h
 create mode 120000 tools/testing/radix-tree/linux/radix-tree.h
 create mode 100644 tools/testing/radix-tree/linux/rcupdate.h
 create mode 100644 tools/testing/radix-tree/linux/slab.h
 create mode 100644 tools/testing/radix-tree/linux/string.h
 create mode 100644 tools/testing/radix-tree/linux/types.h
 create mode 100644 tools/testing/radix-tree/main.c
 create mode 100644 tools/testing/radix-tree/rcupdate.c
 create mode 100644 tools/testing/radix-tree/regression.h
 create mode 100644 tools/testing/radix-tree/regression1.c
 create mode 100644 tools/testing/radix-tree/regression2.c
 create mode 100644 tools/testing/radix-tree/tag_check.c
 create mode 100644 tools/testing/radix-tree/test.c
 create mode 100644 tools/testing/radix-tree/test.h

diff --git a/tools/testing/radix-tree/.gitignore b/tools/testing/radix-tree/.gitignore
new file mode 100644
index 0000000..11d888c
--- /dev/null
+++ b/tools/testing/radix-tree/.gitignore
@@ -0,0 +1,2 @@
+main
+radix-tree.c
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
new file mode 100644
index 0000000..582c8c6
--- /dev/null
+++ b/tools/testing/radix-tree/Makefile
@@ -0,0 +1,20 @@
+
+CFLAGS += -I. -g -Wall -D_LGPL_SOURCE
+LDFLAGS += -lpthread -lurcu
+TARGETS = main
+OFILES = main.o radix-tree.o linux.o test.o tag_check.o find_next_bit.o \
+	 regression1.o regression2.o
+
+targets: $(TARGETS)
+
+main:	$(OFILES)
+	$(CC) $(CFLAGS) $(LDFLAGS) $(OFILES) -o main
+
+clean:
+	$(RM) -f $(TARGETS) *.o radix-tree.c
+
+$(OFILES): *.h */*.h
+
+radix-tree.c: ../../../lib/radix-tree.c
+	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
+
diff --git a/tools/testing/radix-tree/find_next_bit.c b/tools/testing/radix-tree/find_next_bit.c
new file mode 100644
index 0000000..d1c2178
--- /dev/null
+++ b/tools/testing/radix-tree/find_next_bit.c
@@ -0,0 +1,57 @@
+/* find_next_bit.c: fallback find next bit implementation
+ *
+ * Copyright (C) 2004 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/types.h>
+#include <linux/bitops.h>
+
+#define BITOP_WORD(nr)		((nr) / BITS_PER_LONG)
+
+/*
+ * Find the next set bit in a memory region.
+ */
+unsigned long find_next_bit(const unsigned long *addr, unsigned long size,
+			    unsigned long offset)
+{
+	const unsigned long *p = addr + BITOP_WORD(offset);
+	unsigned long result = offset & ~(BITS_PER_LONG-1);
+	unsigned long tmp;
+
+	if (offset >= size)
+		return size;
+	size -= result;
+	offset %= BITS_PER_LONG;
+	if (offset) {
+		tmp = *(p++);
+		tmp &= (~0UL << offset);
+		if (size < BITS_PER_LONG)
+			goto found_first;
+		if (tmp)
+			goto found_middle;
+		size -= BITS_PER_LONG;
+		result += BITS_PER_LONG;
+	}
+	while (size & ~(BITS_PER_LONG-1)) {
+		if ((tmp = *(p++)))
+			goto found_middle;
+		result += BITS_PER_LONG;
+		size -= BITS_PER_LONG;
+	}
+	if (!size)
+		return result;
+	tmp = *p;
+
+found_first:
+	tmp &= (~0UL >> (BITS_PER_LONG - size));
+	if (tmp == 0UL)		/* Are any bits set? */
+		return result + size;	/* Nope. */
+found_middle:
+	return result + __ffs(tmp);
+}
diff --git a/tools/testing/radix-tree/linux.c b/tools/testing/radix-tree/linux.c
new file mode 100644
index 0000000..1548237
--- /dev/null
+++ b/tools/testing/radix-tree/linux.c
@@ -0,0 +1,60 @@
+#include <stdlib.h>
+#include <string.h>
+#include <malloc.h>
+#include <unistd.h>
+#include <assert.h>
+
+#include <linux/mempool.h>
+#include <linux/slab.h>
+#include <urcu/uatomic.h>
+
+int nr_allocated;
+
+void *mempool_alloc(mempool_t *pool, int gfp_mask)
+{
+	return pool->alloc(gfp_mask, pool->data);
+}
+
+void mempool_free(void *element, mempool_t *pool)
+{
+	pool->free(element, pool->data);
+}
+
+mempool_t *mempool_create(int min_nr, mempool_alloc_t *alloc_fn,
+			mempool_free_t *free_fn, void *pool_data)
+{
+	mempool_t *ret = malloc(sizeof(*ret));
+
+	ret->alloc = alloc_fn;
+	ret->free = free_fn;
+	ret->data = pool_data;
+	return ret;
+}
+
+void *kmem_cache_alloc(struct kmem_cache *cachep, int flags)
+{
+	void *ret = malloc(cachep->size);
+	if (cachep->ctor)
+		cachep->ctor(ret);
+	uatomic_inc(&nr_allocated);
+	return ret;
+}
+
+void kmem_cache_free(struct kmem_cache *cachep, void *objp)
+{
+	assert(objp);
+	uatomic_dec(&nr_allocated);
+	memset(objp, 0, cachep->size);
+	free(objp);
+}
+
+struct kmem_cache *
+kmem_cache_create(const char *name, size_t size, size_t offset,
+	unsigned long flags, void (*ctor)(void *))
+{
+	struct kmem_cache *ret = malloc(sizeof(*ret));
+
+	ret->size = size;
+	ret->ctor = ctor;
+	return ret;
+}
diff --git a/tools/testing/radix-tree/linux/bitops.h b/tools/testing/radix-tree/linux/bitops.h
new file mode 100644
index 0000000..71d58427
--- /dev/null
+++ b/tools/testing/radix-tree/linux/bitops.h
@@ -0,0 +1,150 @@
+#ifndef _ASM_GENERIC_BITOPS_NON_ATOMIC_H_
+#define _ASM_GENERIC_BITOPS_NON_ATOMIC_H_
+
+#include <linux/types.h>
+
+#define BITOP_MASK(nr)		(1UL << ((nr) % BITS_PER_LONG))
+#define BITOP_WORD(nr)		((nr) / BITS_PER_LONG)
+
+/**
+ * __set_bit - Set a bit in memory
+ * @nr: the bit to set
+ * @addr: the address to start counting from
+ *
+ * Unlike set_bit(), this function is non-atomic and may be reordered.
+ * If it's called on the same region of memory simultaneously, the effect
+ * may be that only one operation succeeds.
+ */
+static inline void __set_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+
+	*p  |= mask;
+}
+
+static inline void __clear_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+
+	*p &= ~mask;
+}
+
+/**
+ * __change_bit - Toggle a bit in memory
+ * @nr: the bit to change
+ * @addr: the address to start counting from
+ *
+ * Unlike change_bit(), this function is non-atomic and may be reordered.
+ * If it's called on the same region of memory simultaneously, the effect
+ * may be that only one operation succeeds.
+ */
+static inline void __change_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+
+	*p ^= mask;
+}
+
+/**
+ * __test_and_set_bit - Set a bit and return its old value
+ * @nr: Bit to set
+ * @addr: Address to count from
+ *
+ * This operation is non-atomic and can be reordered.
+ * If two examples of this operation race, one can appear to succeed
+ * but actually fail.  You must protect multiple accesses with a lock.
+ */
+static inline int __test_and_set_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old | mask;
+	return (old & mask) != 0;
+}
+
+/**
+ * __test_and_clear_bit - Clear a bit and return its old value
+ * @nr: Bit to clear
+ * @addr: Address to count from
+ *
+ * This operation is non-atomic and can be reordered.
+ * If two examples of this operation race, one can appear to succeed
+ * but actually fail.  You must protect multiple accesses with a lock.
+ */
+static inline int __test_and_clear_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old & ~mask;
+	return (old & mask) != 0;
+}
+
+/* WARNING: non atomic and it can be reordered! */
+static inline int __test_and_change_bit(int nr,
+					    volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old ^ mask;
+	return (old & mask) != 0;
+}
+
+/**
+ * test_bit - Determine whether a bit is set
+ * @nr: bit number to test
+ * @addr: Address to start counting from
+ */
+static inline int test_bit(int nr, const volatile unsigned long *addr)
+{
+	return 1UL & (addr[BITOP_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
+}
+
+/**
+ * __ffs - find first bit in word.
+ * @word: The word to search
+ *
+ * Undefined if no bit exists, so code should check against 0 first.
+ */
+static inline unsigned long __ffs(unsigned long word)
+{
+	int num = 0;
+
+	if ((word & 0xffffffff) == 0) {
+		num += 32;
+		word >>= 32;
+	}
+	if ((word & 0xffff) == 0) {
+		num += 16;
+		word >>= 16;
+	}
+	if ((word & 0xff) == 0) {
+		num += 8;
+		word >>= 8;
+	}
+	if ((word & 0xf) == 0) {
+		num += 4;
+		word >>= 4;
+	}
+	if ((word & 0x3) == 0) {
+		num += 2;
+		word >>= 2;
+	}
+	if ((word & 0x1) == 0)
+		num += 1;
+	return num;
+}
+
+unsigned long find_next_bit(const unsigned long *addr,
+			    unsigned long size,
+			    unsigned long offset);
+
+#endif /* _ASM_GENERIC_BITOPS_NON_ATOMIC_H_ */
diff --git a/tools/testing/radix-tree/linux/bitops/__ffs.h b/tools/testing/radix-tree/linux/bitops/__ffs.h
new file mode 100644
index 0000000..9a3274a
--- /dev/null
+++ b/tools/testing/radix-tree/linux/bitops/__ffs.h
@@ -0,0 +1,43 @@
+#ifndef _ASM_GENERIC_BITOPS___FFS_H_
+#define _ASM_GENERIC_BITOPS___FFS_H_
+
+#include <asm/types.h>
+
+/**
+ * __ffs - find first bit in word.
+ * @word: The word to search
+ *
+ * Undefined if no bit exists, so code should check against 0 first.
+ */
+static inline unsigned long __ffs(unsigned long word)
+{
+	int num = 0;
+
+#if BITS_PER_LONG == 64
+	if ((word & 0xffffffff) == 0) {
+		num += 32;
+		word >>= 32;
+	}
+#endif
+	if ((word & 0xffff) == 0) {
+		num += 16;
+		word >>= 16;
+	}
+	if ((word & 0xff) == 0) {
+		num += 8;
+		word >>= 8;
+	}
+	if ((word & 0xf) == 0) {
+		num += 4;
+		word >>= 4;
+	}
+	if ((word & 0x3) == 0) {
+		num += 2;
+		word >>= 2;
+	}
+	if ((word & 0x1) == 0)
+		num += 1;
+	return num;
+}
+
+#endif /* _ASM_GENERIC_BITOPS___FFS_H_ */
diff --git a/tools/testing/radix-tree/linux/bitops/ffs.h b/tools/testing/radix-tree/linux/bitops/ffs.h
new file mode 100644
index 0000000..fbbb43a
--- /dev/null
+++ b/tools/testing/radix-tree/linux/bitops/ffs.h
@@ -0,0 +1,41 @@
+#ifndef _ASM_GENERIC_BITOPS_FFS_H_
+#define _ASM_GENERIC_BITOPS_FFS_H_
+
+/**
+ * ffs - find first bit set
+ * @x: the word to search
+ *
+ * This is defined the same way as
+ * the libc and compiler builtin ffs routines, therefore
+ * differs in spirit from the above ffz (man ffs).
+ */
+static inline int ffs(int x)
+{
+	int r = 1;
+
+	if (!x)
+		return 0;
+	if (!(x & 0xffff)) {
+		x >>= 16;
+		r += 16;
+	}
+	if (!(x & 0xff)) {
+		x >>= 8;
+		r += 8;
+	}
+	if (!(x & 0xf)) {
+		x >>= 4;
+		r += 4;
+	}
+	if (!(x & 3)) {
+		x >>= 2;
+		r += 2;
+	}
+	if (!(x & 1)) {
+		x >>= 1;
+		r += 1;
+	}
+	return r;
+}
+
+#endif /* _ASM_GENERIC_BITOPS_FFS_H_ */
diff --git a/tools/testing/radix-tree/linux/bitops/ffz.h b/tools/testing/radix-tree/linux/bitops/ffz.h
new file mode 100644
index 0000000..6744bd4
--- /dev/null
+++ b/tools/testing/radix-tree/linux/bitops/ffz.h
@@ -0,0 +1,12 @@
+#ifndef _ASM_GENERIC_BITOPS_FFZ_H_
+#define _ASM_GENERIC_BITOPS_FFZ_H_
+
+/*
+ * ffz - find first zero in word.
+ * @word: The word to search
+ *
+ * Undefined if no zero exists, so code should check against ~0UL first.
+ */
+#define ffz(x)  __ffs(~(x))
+
+#endif /* _ASM_GENERIC_BITOPS_FFZ_H_ */
diff --git a/tools/testing/radix-tree/linux/bitops/find.h b/tools/testing/radix-tree/linux/bitops/find.h
new file mode 100644
index 0000000..72a51e5
--- /dev/null
+++ b/tools/testing/radix-tree/linux/bitops/find.h
@@ -0,0 +1,13 @@
+#ifndef _ASM_GENERIC_BITOPS_FIND_H_
+#define _ASM_GENERIC_BITOPS_FIND_H_
+
+extern unsigned long find_next_bit(const unsigned long *addr, unsigned long
+		size, unsigned long offset);
+
+extern unsigned long find_next_zero_bit(const unsigned long *addr, unsigned
+		long size, unsigned long offset);
+
+#define find_first_bit(addr, size) find_next_bit((addr), (size), 0)
+#define find_first_zero_bit(addr, size) find_next_zero_bit((addr), (size), 0)
+
+#endif /*_ASM_GENERIC_BITOPS_FIND_H_ */
diff --git a/tools/testing/radix-tree/linux/bitops/fls.h b/tools/testing/radix-tree/linux/bitops/fls.h
new file mode 100644
index 0000000..850859b
--- /dev/null
+++ b/tools/testing/radix-tree/linux/bitops/fls.h
@@ -0,0 +1,41 @@
+#ifndef _ASM_GENERIC_BITOPS_FLS_H_
+#define _ASM_GENERIC_BITOPS_FLS_H_
+
+/**
+ * fls - find last (most-significant) bit set
+ * @x: the word to search
+ *
+ * This is defined the same way as ffs.
+ * Note fls(0) = 0, fls(1) = 1, fls(0x80000000) = 32.
+ */
+
+static inline int fls(int x)
+{
+	int r = 32;
+
+	if (!x)
+		return 0;
+	if (!(x & 0xffff0000u)) {
+		x <<= 16;
+		r -= 16;
+	}
+	if (!(x & 0xff000000u)) {
+		x <<= 8;
+		r -= 8;
+	}
+	if (!(x & 0xf0000000u)) {
+		x <<= 4;
+		r -= 4;
+	}
+	if (!(x & 0xc0000000u)) {
+		x <<= 2;
+		r -= 2;
+	}
+	if (!(x & 0x80000000u)) {
+		x <<= 1;
+		r -= 1;
+	}
+	return r;
+}
+
+#endif /* _ASM_GENERIC_BITOPS_FLS_H_ */
diff --git a/tools/testing/radix-tree/linux/bitops/fls64.h b/tools/testing/radix-tree/linux/bitops/fls64.h
new file mode 100644
index 0000000..1b6b17c
--- /dev/null
+++ b/tools/testing/radix-tree/linux/bitops/fls64.h
@@ -0,0 +1,14 @@
+#ifndef _ASM_GENERIC_BITOPS_FLS64_H_
+#define _ASM_GENERIC_BITOPS_FLS64_H_
+
+#include <asm/types.h>
+
+static inline int fls64(__u64 x)
+{
+	__u32 h = x >> 32;
+	if (h)
+		return fls(h) + 32;
+	return fls(x);
+}
+
+#endif /* _ASM_GENERIC_BITOPS_FLS64_H_ */
diff --git a/tools/testing/radix-tree/linux/bitops/hweight.h b/tools/testing/radix-tree/linux/bitops/hweight.h
new file mode 100644
index 0000000..fbbc383
--- /dev/null
+++ b/tools/testing/radix-tree/linux/bitops/hweight.h
@@ -0,0 +1,11 @@
+#ifndef _ASM_GENERIC_BITOPS_HWEIGHT_H_
+#define _ASM_GENERIC_BITOPS_HWEIGHT_H_
+
+#include <asm/types.h>
+
+extern unsigned int hweight32(unsigned int w);
+extern unsigned int hweight16(unsigned int w);
+extern unsigned int hweight8(unsigned int w);
+extern unsigned long hweight64(__u64 w);
+
+#endif /* _ASM_GENERIC_BITOPS_HWEIGHT_H_ */
diff --git a/tools/testing/radix-tree/linux/bitops/le.h b/tools/testing/radix-tree/linux/bitops/le.h
new file mode 100644
index 0000000..b9c7e5d
--- /dev/null
+++ b/tools/testing/radix-tree/linux/bitops/le.h
@@ -0,0 +1,53 @@
+#ifndef _ASM_GENERIC_BITOPS_LE_H_
+#define _ASM_GENERIC_BITOPS_LE_H_
+
+#include <asm/types.h>
+#include <asm/byteorder.h>
+
+#define BITOP_WORD(nr)		((nr) / BITS_PER_LONG)
+#define BITOP_LE_SWIZZLE	((BITS_PER_LONG-1) & ~0x7)
+
+#if defined(__LITTLE_ENDIAN)
+
+#define generic_test_le_bit(nr, addr) test_bit(nr, addr)
+#define generic___set_le_bit(nr, addr) __set_bit(nr, addr)
+#define generic___clear_le_bit(nr, addr) __clear_bit(nr, addr)
+
+#define generic_test_and_set_le_bit(nr, addr) test_and_set_bit(nr, addr)
+#define generic_test_and_clear_le_bit(nr, addr) test_and_clear_bit(nr, addr)
+
+#define generic___test_and_set_le_bit(nr, addr) __test_and_set_bit(nr, addr)
+#define generic___test_and_clear_le_bit(nr, addr) __test_and_clear_bit(nr, addr)
+
+#define generic_find_next_zero_le_bit(addr, size, offset) find_next_zero_bit(addr, size, offset)
+
+#elif defined(__BIG_ENDIAN)
+
+#define generic_test_le_bit(nr, addr) \
+	test_bit((nr) ^ BITOP_LE_SWIZZLE, (addr))
+#define generic___set_le_bit(nr, addr) \
+	__set_bit((nr) ^ BITOP_LE_SWIZZLE, (addr))
+#define generic___clear_le_bit(nr, addr) \
+	__clear_bit((nr) ^ BITOP_LE_SWIZZLE, (addr))
+
+#define generic_test_and_set_le_bit(nr, addr) \
+	test_and_set_bit((nr) ^ BITOP_LE_SWIZZLE, (addr))
+#define generic_test_and_clear_le_bit(nr, addr) \
+	test_and_clear_bit((nr) ^ BITOP_LE_SWIZZLE, (addr))
+
+#define generic___test_and_set_le_bit(nr, addr) \
+	__test_and_set_bit((nr) ^ BITOP_LE_SWIZZLE, (addr))
+#define generic___test_and_clear_le_bit(nr, addr) \
+	__test_and_clear_bit((nr) ^ BITOP_LE_SWIZZLE, (addr))
+
+extern unsigned long generic_find_next_zero_le_bit(const unsigned long *addr,
+		unsigned long size, unsigned long offset);
+
+#else
+#error "Please fix <asm/byteorder.h>"
+#endif
+
+#define generic_find_first_zero_le_bit(addr, size) \
+        generic_find_next_zero_le_bit((addr), (size), 0)
+
+#endif /* _ASM_GENERIC_BITOPS_LE_H_ */
diff --git a/tools/testing/radix-tree/linux/bitops/non-atomic.h b/tools/testing/radix-tree/linux/bitops/non-atomic.h
new file mode 100644
index 0000000..46a825c
--- /dev/null
+++ b/tools/testing/radix-tree/linux/bitops/non-atomic.h
@@ -0,0 +1,111 @@
+#ifndef _ASM_GENERIC_BITOPS_NON_ATOMIC_H_
+#define _ASM_GENERIC_BITOPS_NON_ATOMIC_H_
+
+#include <asm/types.h>
+
+#define BITOP_MASK(nr)		(1UL << ((nr) % BITS_PER_LONG))
+#define BITOP_WORD(nr)		((nr) / BITS_PER_LONG)
+
+/**
+ * __set_bit - Set a bit in memory
+ * @nr: the bit to set
+ * @addr: the address to start counting from
+ *
+ * Unlike set_bit(), this function is non-atomic and may be reordered.
+ * If it's called on the same region of memory simultaneously, the effect
+ * may be that only one operation succeeds.
+ */
+static inline void __set_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+
+	*p  |= mask;
+}
+
+static inline void __clear_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+
+	*p &= ~mask;
+}
+
+/**
+ * __change_bit - Toggle a bit in memory
+ * @nr: the bit to change
+ * @addr: the address to start counting from
+ *
+ * Unlike change_bit(), this function is non-atomic and may be reordered.
+ * If it's called on the same region of memory simultaneously, the effect
+ * may be that only one operation succeeds.
+ */
+static inline void __change_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+
+	*p ^= mask;
+}
+
+/**
+ * __test_and_set_bit - Set a bit and return its old value
+ * @nr: Bit to set
+ * @addr: Address to count from
+ *
+ * This operation is non-atomic and can be reordered.
+ * If two examples of this operation race, one can appear to succeed
+ * but actually fail.  You must protect multiple accesses with a lock.
+ */
+static inline int __test_and_set_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old | mask;
+	return (old & mask) != 0;
+}
+
+/**
+ * __test_and_clear_bit - Clear a bit and return its old value
+ * @nr: Bit to clear
+ * @addr: Address to count from
+ *
+ * This operation is non-atomic and can be reordered.
+ * If two examples of this operation race, one can appear to succeed
+ * but actually fail.  You must protect multiple accesses with a lock.
+ */
+static inline int __test_and_clear_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old & ~mask;
+	return (old & mask) != 0;
+}
+
+/* WARNING: non atomic and it can be reordered! */
+static inline int __test_and_change_bit(int nr,
+					    volatile unsigned long *addr)
+{
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old ^ mask;
+	return (old & mask) != 0;
+}
+
+/**
+ * test_bit - Determine whether a bit is set
+ * @nr: bit number to test
+ * @addr: Address to start counting from
+ */
+static inline int test_bit(int nr, const volatile unsigned long *addr)
+{
+	return 1UL & (addr[BITOP_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
+}
+
+#endif /* _ASM_GENERIC_BITOPS_NON_ATOMIC_H_ */
diff --git a/tools/testing/radix-tree/linux/bug.h b/tools/testing/radix-tree/linux/bug.h
new file mode 100644
index 0000000..ccbe444
--- /dev/null
+++ b/tools/testing/radix-tree/linux/bug.h
@@ -0,0 +1 @@
+#define WARN_ON_ONCE(x)		assert(x)
diff --git a/tools/testing/radix-tree/linux/cpu.h b/tools/testing/radix-tree/linux/cpu.h
new file mode 100644
index 0000000..b0edb1b
--- /dev/null
+++ b/tools/testing/radix-tree/linux/cpu.h
@@ -0,0 +1,35 @@
+
+#define hotcpu_notifier(a, b)
+
+#define CPU_ONLINE		0x0002 /* CPU (unsigned)v is up */
+#define CPU_UP_PREPARE		0x0003 /* CPU (unsigned)v coming up */
+#define CPU_UP_CANCELED		0x0004 /* CPU (unsigned)v NOT coming up */
+#define CPU_DOWN_PREPARE	0x0005 /* CPU (unsigned)v going down */
+#define CPU_DOWN_FAILED		0x0006 /* CPU (unsigned)v NOT going down */
+#define CPU_DEAD		0x0007 /* CPU (unsigned)v dead */
+#define CPU_DYING		0x0008 /* CPU (unsigned)v not running any task,
+					* not handling interrupts, soon dead.
+					* Called on the dying cpu, interrupts
+					* are already disabled. Must not
+					* sleep, must not fail */
+#define CPU_POST_DEAD		0x0009 /* CPU (unsigned)v dead, cpu_hotplug
+					* lock is dropped */
+#define CPU_STARTING		0x000A /* CPU (unsigned)v soon running.
+					* Called on the new cpu, just before
+					* enabling interrupts. Must not sleep,
+					* must not fail */
+#define CPU_DYING_IDLE		0x000B /* CPU (unsigned)v dying, reached
+					* idle loop. */
+#define CPU_BROKEN		0x000C /* CPU (unsigned)v did not die properly,
+					* perhaps due to preemption. */
+#define CPU_TASKS_FROZEN	0x0010
+
+#define CPU_ONLINE_FROZEN	(CPU_ONLINE | CPU_TASKS_FROZEN)
+#define CPU_UP_PREPARE_FROZEN	(CPU_UP_PREPARE | CPU_TASKS_FROZEN)
+#define CPU_UP_CANCELED_FROZEN  (CPU_UP_CANCELED | CPU_TASKS_FROZEN)
+#define CPU_DOWN_PREPARE_FROZEN (CPU_DOWN_PREPARE | CPU_TASKS_FROZEN)
+#define CPU_DOWN_FAILED_FROZEN  (CPU_DOWN_FAILED | CPU_TASKS_FROZEN)
+#define CPU_DEAD_FROZEN		(CPU_DEAD | CPU_TASKS_FROZEN)
+#define CPU_DYING_FROZEN	(CPU_DYING | CPU_TASKS_FROZEN)
+#define CPU_STARTING_FROZEN	(CPU_STARTING | CPU_TASKS_FROZEN)
+
diff --git a/tools/testing/radix-tree/linux/export.h b/tools/testing/radix-tree/linux/export.h
new file mode 100644
index 0000000..b6afd13
--- /dev/null
+++ b/tools/testing/radix-tree/linux/export.h
@@ -0,0 +1,2 @@
+
+#define EXPORT_SYMBOL(sym)
diff --git a/tools/testing/radix-tree/linux/gfp.h b/tools/testing/radix-tree/linux/gfp.h
new file mode 100644
index 0000000..01f1eab
--- /dev/null
+++ b/tools/testing/radix-tree/linux/gfp.h
@@ -0,0 +1,8 @@
+#ifndef _GFP_H
+#define _GFP_H
+
+#define __GFP_BITS_SHIFT 22
+#define __GFP_BITS_MASK ((gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
+#define __GFP_WAIT 1
+
+#endif
diff --git a/tools/testing/radix-tree/linux/init.h b/tools/testing/radix-tree/linux/init.h
new file mode 100644
index 0000000..e69de29
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
new file mode 100644
index 0000000..27d5fe4
--- /dev/null
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -0,0 +1,34 @@
+#ifndef _KERNEL_H
+#define _KERNEL_H
+
+#include <assert.h>
+#include <string.h>
+#include <stdio.h>
+#include <stddef.h>
+#include <limits.h>
+
+#ifndef NULL
+#define NULL	0
+#endif
+
+#define BUG_ON(expr)	assert(!(expr))
+#define __init
+#define panic(expr)
+#define printk printf
+#define __force
+#define likely(c) (c)
+#define unlikely(c) (c)
+#define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
+
+#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
+
+#define container_of(ptr, type, member) ({                      \
+	const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
+	(type *)( (char *)__mptr - offsetof(type, member) );})
+#define min(a, b) ((a) < (b) ? (a) : (b))
+
+static inline int in_interrupt(void)
+{
+	return 0;
+}
+#endif /* _KERNEL_H */
diff --git a/tools/testing/radix-tree/linux/kmemleak.h b/tools/testing/radix-tree/linux/kmemleak.h
new file mode 100644
index 0000000..155f112
--- /dev/null
+++ b/tools/testing/radix-tree/linux/kmemleak.h
@@ -0,0 +1 @@
+static inline void kmemleak_update_trace(const void *ptr) { }
diff --git a/tools/testing/radix-tree/linux/mempool.h b/tools/testing/radix-tree/linux/mempool.h
new file mode 100644
index 0000000..650a1ac
--- /dev/null
+++ b/tools/testing/radix-tree/linux/mempool.h
@@ -0,0 +1,17 @@
+
+#include <linux/slab.h>
+
+typedef void *(mempool_alloc_t)(int gfp_mask, void *pool_data);
+typedef void (mempool_free_t)(void *element, void *pool_data);
+
+typedef struct {
+	mempool_alloc_t *alloc;
+	mempool_free_t *free;
+	void *data;
+} mempool_t;
+
+void *mempool_alloc(mempool_t *pool, int gfp_mask);
+void mempool_free(void *element, mempool_t *pool);
+mempool_t *mempool_create(int min_nr, mempool_alloc_t *alloc_fn,
+			mempool_free_t *free_fn, void *pool_data);
+
diff --git a/tools/testing/radix-tree/linux/notifier.h b/tools/testing/radix-tree/linux/notifier.h
new file mode 100644
index 0000000..70e4797
--- /dev/null
+++ b/tools/testing/radix-tree/linux/notifier.h
@@ -0,0 +1,8 @@
+#ifndef _NOTIFIER_H
+#define _NOTIFIER_H
+
+struct notifier_block;
+
+#define NOTIFY_OK              0x0001          /* Suits me */
+
+#endif
diff --git a/tools/testing/radix-tree/linux/percpu.h b/tools/testing/radix-tree/linux/percpu.h
new file mode 100644
index 0000000..5837f1d
--- /dev/null
+++ b/tools/testing/radix-tree/linux/percpu.h
@@ -0,0 +1,7 @@
+
+#define DEFINE_PER_CPU(type, val) type val
+
+#define __get_cpu_var(var)	var
+#define this_cpu_ptr(var)	var
+#define per_cpu_ptr(ptr, cpu)   ({ (void)(cpu); (ptr); })
+#define per_cpu(var, cpu)	(*per_cpu_ptr(&(var), cpu))
diff --git a/tools/testing/radix-tree/linux/preempt.h b/tools/testing/radix-tree/linux/preempt.h
new file mode 100644
index 0000000..c50529e
--- /dev/null
+++ b/tools/testing/radix-tree/linux/preempt.h
@@ -0,0 +1,5 @@
+/* */
+
+#define preempt_disable() do { } while (0)
+#define preempt_enable() do { } while (0)
+
diff --git a/tools/testing/radix-tree/linux/radix-tree.h b/tools/testing/radix-tree/linux/radix-tree.h
new file mode 120000
index 0000000..1e6f41f
--- /dev/null
+++ b/tools/testing/radix-tree/linux/radix-tree.h
@@ -0,0 +1 @@
+../../../../include/linux/radix-tree.h
\ No newline at end of file
diff --git a/tools/testing/radix-tree/linux/rcupdate.h b/tools/testing/radix-tree/linux/rcupdate.h
new file mode 100644
index 0000000..f7129ea
--- /dev/null
+++ b/tools/testing/radix-tree/linux/rcupdate.h
@@ -0,0 +1,9 @@
+#ifndef _RCUPDATE_H
+#define _RCUPDATE_H
+
+#include <urcu.h>
+
+#define rcu_dereference_raw(p) rcu_dereference(p)
+#define rcu_dereference_protected(p, cond) rcu_dereference(p)
+
+#endif
diff --git a/tools/testing/radix-tree/linux/slab.h b/tools/testing/radix-tree/linux/slab.h
new file mode 100644
index 0000000..57282506
--- /dev/null
+++ b/tools/testing/radix-tree/linux/slab.h
@@ -0,0 +1,28 @@
+#ifndef SLAB_H
+#define SLAB_H
+
+#include <linux/types.h>
+
+#define GFP_KERNEL 1
+#define SLAB_HWCACHE_ALIGN 1
+#define SLAB_PANIC 2
+#define SLAB_RECLAIM_ACCOUNT    0x00020000UL            /* Objects are reclaimable */
+
+static inline int gfpflags_allow_blocking(gfp_t mask)
+{
+	return 1;
+}
+
+struct kmem_cache {
+	int size;
+	void (*ctor)(void *);
+};
+
+void *kmem_cache_alloc(struct kmem_cache *cachep, int flags);
+void kmem_cache_free(struct kmem_cache *cachep, void *objp);
+
+struct kmem_cache *
+kmem_cache_create(const char *name, size_t size, size_t offset,
+	unsigned long flags, void (*ctor)(void *));
+
+#endif		/* SLAB_H */
diff --git a/tools/testing/radix-tree/linux/string.h b/tools/testing/radix-tree/linux/string.h
new file mode 100644
index 0000000..e69de29
diff --git a/tools/testing/radix-tree/linux/types.h b/tools/testing/radix-tree/linux/types.h
new file mode 100644
index 0000000..72a9d85
--- /dev/null
+++ b/tools/testing/radix-tree/linux/types.h
@@ -0,0 +1,28 @@
+#ifndef _TYPES_H
+#define _TYPES_H
+
+#define __rcu
+#define __read_mostly
+
+#define BITS_PER_LONG (sizeof(long) * 8)
+
+struct list_head {
+	struct list_head *next, *prev;
+};
+
+static inline void INIT_LIST_HEAD(struct list_head *list)
+{
+	list->next = list;
+	list->prev = list;
+}
+
+typedef struct {
+	unsigned int x;
+} spinlock_t;
+
+#define uninitialized_var(x) x = x
+
+typedef unsigned gfp_t;
+#include <linux/gfp.h>
+
+#endif
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
new file mode 100644
index 0000000..6b8a412
--- /dev/null
+++ b/tools/testing/radix-tree/main.c
@@ -0,0 +1,271 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <time.h>
+#include <assert.h>
+
+#include <linux/slab.h>
+#include <linux/radix-tree.h>
+
+#include "test.h"
+#include "regression.h"
+
+void __gang_check(unsigned long middle, long down, long up, int chunk, int hop)
+{
+	long idx;
+	RADIX_TREE(tree, GFP_KERNEL);
+
+	middle = 1 << 30;
+
+	for (idx = -down; idx < up; idx++)
+		item_insert(&tree, middle + idx);
+
+	item_check_absent(&tree, middle - down - 1);
+	for (idx = -down; idx < up; idx++)
+		item_check_present(&tree, middle + idx);
+	item_check_absent(&tree, middle + up);
+
+	item_gang_check_present(&tree, middle - down,
+			up + down, chunk, hop);
+	item_full_scan(&tree, middle - down, down + up, chunk);
+	item_kill_tree(&tree);
+}
+
+void gang_check(void)
+{
+	__gang_check(1 << 30, 128, 128, 35, 2);
+	__gang_check(1 << 31, 128, 128, 32, 32);
+	__gang_check(1 << 31, 128, 128, 32, 100);
+	__gang_check(1 << 31, 128, 128, 17, 7);
+	__gang_check(0xffff0000, 0, 65536, 17, 7);
+	__gang_check(0xfffffffe, 1, 1, 17, 7);
+}
+
+void __big_gang_check(void)
+{
+	unsigned long start;
+	int wrapped = 0;
+
+	start = 0;
+	do {
+		unsigned long old_start;
+
+//		printf("0x%08lx\n", start);
+		__gang_check(start, rand() % 113 + 1, rand() % 71,
+				rand() % 157, rand() % 91 + 1);
+		old_start = start;
+		start += rand() % 1000000;
+		start %= 1ULL << 33;
+		if (start < old_start)
+			wrapped = 1;
+	} while (!wrapped);
+}
+
+void big_gang_check(void)
+{
+	int i;
+
+	for (i = 0; i < 1000; i++) {
+		__big_gang_check();
+		srand(time(0));
+		printf("%d ", i);
+		fflush(stdout);
+	}
+}
+
+void add_and_check(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+
+	item_insert(&tree, 44);
+	item_check_present(&tree, 44);
+	item_check_absent(&tree, 43);
+	item_kill_tree(&tree);
+}
+
+void dynamic_height_check(void)
+{
+	int i;
+	RADIX_TREE(tree, GFP_KERNEL);
+	tree_verify_min_height(&tree, 0);
+
+	item_insert(&tree, 42);
+	tree_verify_min_height(&tree, 42);
+
+	item_insert(&tree, 1000000);
+	tree_verify_min_height(&tree, 1000000);
+
+	assert(item_delete(&tree, 1000000));
+	tree_verify_min_height(&tree, 42);
+
+	assert(item_delete(&tree, 42));
+	tree_verify_min_height(&tree, 0);
+
+	for (i = 0; i < 1000; i++) {
+		item_insert(&tree, i);
+		tree_verify_min_height(&tree, i);
+	}
+
+	i--;
+	for (;;) {
+		assert(item_delete(&tree, i));
+		if (i == 0) {
+			tree_verify_min_height(&tree, 0);
+			break;
+		}
+		i--;
+		tree_verify_min_height(&tree, i);
+	}
+
+	item_kill_tree(&tree);
+}
+
+void check_copied_tags(struct radix_tree_root *tree, unsigned long start, unsigned long end, unsigned long *idx, int count, int fromtag, int totag)
+{
+	int i;
+
+	for (i = 0; i < count; i++) {
+/*		if (i % 1000 == 0)
+			putchar('.'); */
+		if (idx[i] < start || idx[i] > end) {
+			if (item_tag_get(tree, idx[i], totag)) {
+				printf("%lu-%lu: %lu, tags %d-%d\n", start, end, idx[i], item_tag_get(tree, idx[i], fromtag), item_tag_get(tree, idx[i], totag));
+			}
+			assert(!item_tag_get(tree, idx[i], totag));
+			continue;
+		}
+		if (item_tag_get(tree, idx[i], fromtag) ^
+			item_tag_get(tree, idx[i], totag)) {
+			printf("%lu-%lu: %lu, tags %d-%d\n", start, end, idx[i], item_tag_get(tree, idx[i], fromtag), item_tag_get(tree, idx[i], totag));
+		}
+		assert(!(item_tag_get(tree, idx[i], fromtag) ^
+			 item_tag_get(tree, idx[i], totag)));
+	}
+}
+
+#define ITEMS 50000
+
+void copy_tag_check(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	unsigned long idx[ITEMS];
+	unsigned long start, end, count = 0, tagged, cur, tmp;
+	int i;
+
+//	printf("generating radix tree indices...\n");
+	start = rand();
+	end = rand();
+	if (start > end && (rand() % 10)) {
+		cur = start;
+		start = end;
+		end = cur;
+	}
+	/* Specifically create items around the start and the end of the range
+	 * with high probability to check for off by one errors */
+	cur = rand();
+	if (cur & 1) {
+		item_insert(&tree, start);
+		if (cur & 2) {
+			if (start <= end)
+				count++;
+			item_tag_set(&tree, start, 0);
+		}
+	}
+	if (cur & 4) {
+		item_insert(&tree, start-1);
+		if (cur & 8)
+			item_tag_set(&tree, start-1, 0);
+	}
+	if (cur & 16) {
+		item_insert(&tree, end);
+		if (cur & 32) {
+			if (start <= end)
+				count++;
+			item_tag_set(&tree, end, 0);
+		}
+	}
+	if (cur & 64) {
+		item_insert(&tree, end+1);
+		if (cur & 128)
+			item_tag_set(&tree, end+1, 0);
+	}
+
+	for (i = 0; i < ITEMS; i++) {
+		do {
+			idx[i] = rand();
+		} while (item_lookup(&tree, idx[i]));
+
+		item_insert(&tree, idx[i]);
+		if (rand() & 1) {
+			item_tag_set(&tree, idx[i], 0);
+			if (idx[i] >= start && idx[i] <= end)
+				count++;
+		}
+/*		if (i % 1000 == 0)
+			putchar('.'); */
+	}
+
+//	printf("\ncopying tags...\n");
+	cur = start;
+	tagged = radix_tree_range_tag_if_tagged(&tree, &cur, end, ITEMS, 0, 1);
+
+//	printf("checking copied tags\n");
+	assert(tagged == count);
+	check_copied_tags(&tree, start, end, idx, ITEMS, 0, 1);
+
+	/* Copy tags in several rounds */
+//	printf("\ncopying tags...\n");
+	cur = start;
+	do {
+		tmp = rand() % (count/10+2);
+		tagged = radix_tree_range_tag_if_tagged(&tree, &cur, end, tmp, 0, 2);
+	} while (tmp == tagged);
+
+//	printf("%lu %lu %lu\n", tagged, tmp, count);
+//	printf("checking copied tags\n");
+	check_copied_tags(&tree, start, end, idx, ITEMS, 0, 2);
+	assert(tagged < tmp);
+	verify_tag_consistency(&tree, 0);
+	verify_tag_consistency(&tree, 1);
+	verify_tag_consistency(&tree, 2);
+//	printf("\n");
+	item_kill_tree(&tree);
+}
+
+static void single_thread_tests(void)
+{
+	int i;
+
+	tag_check();
+	printf("after tag_check: %d allocated\n", nr_allocated);
+	gang_check();
+	printf("after gang_check: %d allocated\n", nr_allocated);
+	add_and_check();
+	printf("after add_and_check: %d allocated\n", nr_allocated);
+	dynamic_height_check();
+	printf("after dynamic_height_check: %d allocated\n", nr_allocated);
+	big_gang_check();
+	printf("after big_gang_check: %d allocated\n", nr_allocated);
+	for (i = 0; i < 2000; i++) {
+		copy_tag_check();
+		printf("%d ", i);
+		fflush(stdout);
+	}
+	printf("after copy_tag_check: %d allocated\n", nr_allocated);
+}
+
+int main(void)
+{
+	rcu_register_thread();
+	radix_tree_init();
+
+	regression1_test();
+	regression2_test();
+	single_thread_tests();
+
+	sleep(1);
+	printf("after sleep(1): %d allocated\n", nr_allocated);
+	rcu_unregister_thread();
+
+	exit(0);
+}
diff --git a/tools/testing/radix-tree/rcupdate.c b/tools/testing/radix-tree/rcupdate.c
new file mode 100644
index 0000000..31a2d14
--- /dev/null
+++ b/tools/testing/radix-tree/rcupdate.c
@@ -0,0 +1,86 @@
+#include <linux/rcupdate.h>
+#include <pthread.h>
+#include <stdio.h>
+#include <assert.h>
+
+static pthread_mutex_t rculock = PTHREAD_MUTEX_INITIALIZER;
+static struct rcu_head *rcuhead_global = NULL;
+static __thread int nr_rcuhead = 0;
+static __thread struct rcu_head *rcuhead = NULL;
+static __thread struct rcu_head *rcutail = NULL;
+
+static pthread_cond_t rcu_worker_cond = PTHREAD_COND_INITIALIZER;
+
+/* switch to urcu implementation when it is merged. */
+void call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *head))
+{
+	head->func = func;
+	head->next = rcuhead;
+	rcuhead = head;
+	if (!rcutail)
+		rcutail = head;
+	nr_rcuhead++;
+	if (nr_rcuhead >= 1000) {
+		int signal = 0;
+
+		pthread_mutex_lock(&rculock);
+		if (!rcuhead_global)
+			signal = 1;
+		rcutail->next = rcuhead_global;
+		rcuhead_global = head;
+		pthread_mutex_unlock(&rculock);
+
+		nr_rcuhead = 0;
+		rcuhead = NULL;
+		rcutail = NULL;
+
+		if (signal) {
+			pthread_cond_signal(&rcu_worker_cond);
+		}
+	}
+}
+
+static void *rcu_worker(void *arg)
+{
+	struct rcu_head *r;
+
+	rcupdate_thread_init();
+
+	while (1) {
+		pthread_mutex_lock(&rculock);
+		while (!rcuhead_global) {
+			pthread_cond_wait(&rcu_worker_cond, &rculock);
+		}
+		r = rcuhead_global;
+		rcuhead_global = NULL;
+
+		pthread_mutex_unlock(&rculock);
+
+		synchronize_rcu();
+
+		while (r) {
+			struct rcu_head *tmp = r->next;
+			r->func(r);
+			r = tmp;
+		}
+	}
+
+	rcupdate_thread_exit();
+
+	return NULL;
+}
+
+static pthread_t worker_thread;
+void rcupdate_init(void)
+{
+	pthread_create(&worker_thread, NULL, rcu_worker, NULL);
+}
+
+void rcupdate_thread_init(void)
+{
+	rcu_register_thread();
+}
+void rcupdate_thread_exit(void)
+{
+	rcu_unregister_thread();
+}
diff --git a/tools/testing/radix-tree/regression.h b/tools/testing/radix-tree/regression.h
new file mode 100644
index 0000000..bb1c2ab
--- /dev/null
+++ b/tools/testing/radix-tree/regression.h
@@ -0,0 +1,7 @@
+#ifndef __REGRESSION_H__
+#define __REGRESSION_H__
+
+void regression1_test(void);
+void regression2_test(void);
+
+#endif
diff --git a/tools/testing/radix-tree/regression1.c b/tools/testing/radix-tree/regression1.c
new file mode 100644
index 0000000..d471d3b
--- /dev/null
+++ b/tools/testing/radix-tree/regression1.c
@@ -0,0 +1,221 @@
+/*
+ * Regression1
+ * Description:
+ * Salman Qazi describes the following radix-tree bug:
+ *
+ * In the following case, we get can get a deadlock:
+ *
+ * 0.  The radix tree contains two items, one has the index 0.
+ * 1.  The reader (in this case find_get_pages) takes the rcu_read_lock.
+ * 2.  The reader acquires slot(s) for item(s) including the index 0 item.
+ * 3.  The non-zero index item is deleted, and as a consequence the other item
+ *     is moved to the root of the tree. The place where it used to be is queued
+ *     for deletion after the readers finish.
+ * 3b. The zero item is deleted, removing it from the direct slot, it remains in
+ *     the rcu-delayed indirect node.
+ * 4.  The reader looks at the index 0 slot, and finds that the page has 0 ref
+ *     count
+ * 5.  The reader looks at it again, hoping that the item will either be freed
+ *     or the ref count will increase. This never happens, as the slot it is
+ *     looking at will never be updated. Also, this slot can never be reclaimed
+ *     because the reader is holding rcu_read_lock and is in an infinite loop.
+ *
+ * The fix is to re-use the same "indirect" pointer case that requires a slot
+ * lookup retry into a general "retry the lookup" bit.
+ *
+ * Running:
+ * This test should run to completion in a few seconds. The above bug would
+ * cause it to hang indefinitely.
+ *
+ * Upstream commit:
+ * Not yet
+ */
+#include <linux/kernel.h>
+#include <linux/gfp.h>
+#include <linux/slab.h>
+#include <linux/radix-tree.h>
+#include <linux/rcupdate.h>
+#include <stdlib.h>
+#include <pthread.h>
+#include <stdio.h>
+#include <assert.h>
+
+#include "regression.h"
+
+static RADIX_TREE(mt_tree, GFP_KERNEL);
+static pthread_mutex_t mt_lock;
+
+struct page {
+	pthread_mutex_t lock;
+	struct rcu_head rcu;
+	int count;
+	unsigned long index;
+};
+
+static struct page *page_alloc(void)
+{
+	struct page *p;
+	p = malloc(sizeof(struct page));
+	p->count = 1;
+	p->index = 1;
+	pthread_mutex_init(&p->lock, NULL);
+
+	return p;
+}
+
+static void page_rcu_free(struct rcu_head *rcu)
+{
+	struct page *p = container_of(rcu, struct page, rcu);
+	assert(!p->count);
+	pthread_mutex_destroy(&p->lock);
+	free(p);
+}
+
+static void page_free(struct page *p)
+{
+	call_rcu(&p->rcu, page_rcu_free);
+}
+
+static unsigned find_get_pages(unsigned long start,
+			    unsigned int nr_pages, struct page **pages)
+{
+	unsigned int i;
+	unsigned int ret;
+	unsigned int nr_found;
+
+	rcu_read_lock();
+restart:
+	nr_found = radix_tree_gang_lookup_slot(&mt_tree,
+				(void ***)pages, NULL, start, nr_pages);
+	ret = 0;
+	for (i = 0; i < nr_found; i++) {
+		struct page *page;
+repeat:
+		page = radix_tree_deref_slot((void **)pages[i]);
+		if (unlikely(!page))
+			continue;
+
+		if (radix_tree_exception(page)) {
+			if (radix_tree_deref_retry(page)) {
+				/*
+				 * Transient condition which can only trigger
+				 * when entry at index 0 moves out of or back
+				 * to root: none yet gotten, safe to restart.
+				 */
+				assert((start | i) == 0);
+				goto restart;
+			}
+			/*
+			 * No exceptional entries are inserted in this test.
+			 */
+			assert(0);
+		}
+
+		pthread_mutex_lock(&page->lock);
+		if (!page->count) {
+			pthread_mutex_unlock(&page->lock);
+			goto repeat;
+		}
+		/* don't actually update page refcount */
+		pthread_mutex_unlock(&page->lock);
+
+		/* Has the page moved? */
+		if (unlikely(page != *((void **)pages[i]))) {
+			goto repeat;
+		}
+
+		pages[ret] = page;
+		ret++;
+	}
+	rcu_read_unlock();
+	return ret;
+}
+
+static pthread_barrier_t worker_barrier;
+
+static void *regression1_fn(void *arg)
+{
+	rcu_register_thread();
+
+	if (pthread_barrier_wait(&worker_barrier) ==
+			PTHREAD_BARRIER_SERIAL_THREAD) {
+		int j;
+
+		for (j = 0; j < 1000000; j++) {
+			struct page *p;
+
+			p = page_alloc();
+			pthread_mutex_lock(&mt_lock);
+			radix_tree_insert(&mt_tree, 0, p);
+			pthread_mutex_unlock(&mt_lock);
+
+			p = page_alloc();
+			pthread_mutex_lock(&mt_lock);
+			radix_tree_insert(&mt_tree, 1, p);
+			pthread_mutex_unlock(&mt_lock);
+
+			pthread_mutex_lock(&mt_lock);
+			p = radix_tree_delete(&mt_tree, 1);
+			pthread_mutex_lock(&p->lock);
+			p->count--;
+			pthread_mutex_unlock(&p->lock);
+			pthread_mutex_unlock(&mt_lock);
+			page_free(p);
+
+			pthread_mutex_lock(&mt_lock);
+			p = radix_tree_delete(&mt_tree, 0);
+			pthread_mutex_lock(&p->lock);
+			p->count--;
+			pthread_mutex_unlock(&p->lock);
+			pthread_mutex_unlock(&mt_lock);
+			page_free(p);
+		}
+	} else {
+		int j;
+
+		for (j = 0; j < 100000000; j++) {
+			struct page *pages[10];
+
+			find_get_pages(0, 10, pages);
+		}
+	}
+
+	rcu_unregister_thread();
+
+	return NULL;
+}
+
+static pthread_t *threads;
+void regression1_test(void)
+{
+	int nr_threads;
+	int i;
+	long arg;
+
+	/* Regression #1 */
+	printf("running regression test 1, should finish in under a minute\n");
+	nr_threads = 2;
+	pthread_barrier_init(&worker_barrier, NULL, nr_threads);
+
+	threads = malloc(nr_threads * sizeof(pthread_t *));
+
+	for (i = 0; i < nr_threads; i++) {
+		arg = i;
+		if (pthread_create(&threads[i], NULL, regression1_fn, (void *)arg)) {
+			perror("pthread_create");
+			exit(1);
+		}
+	}
+
+	for (i = 0; i < nr_threads; i++) {
+		if (pthread_join(threads[i], NULL)) {
+			perror("pthread_join");
+			exit(1);
+		}
+	}
+
+	free(threads);
+
+	printf("regression test 1, done\n");
+}
+
diff --git a/tools/testing/radix-tree/regression2.c b/tools/testing/radix-tree/regression2.c
new file mode 100644
index 0000000..5d2fa28
--- /dev/null
+++ b/tools/testing/radix-tree/regression2.c
@@ -0,0 +1,126 @@
+/*
+ * Regression2
+ * Description:
+ * Toshiyuki Okajima describes the following radix-tree bug:
+ *
+ * In the following case, we can get a hangup on
+ *   radix_radix_tree_gang_lookup_tag_slot.
+ *
+ * 0.  The radix tree contains RADIX_TREE_MAP_SIZE items. And the tag of
+ *     a certain item has PAGECACHE_TAG_DIRTY.
+ * 1.  radix_tree_range_tag_if_tagged(, start, end, , PAGECACHE_TAG_DIRTY,
+ *     PAGECACHE_TAG_TOWRITE) is called to add PAGECACHE_TAG_TOWRITE tag
+ *     for the tag which has PAGECACHE_TAG_DIRTY. However, there is no tag with
+ *     PAGECACHE_TAG_DIRTY within the range from start to end. As the result,
+ *     There is no tag with PAGECACHE_TAG_TOWRITE but the root tag has
+ *     PAGECACHE_TAG_TOWRITE.
+ * 2.  An item is added into the radix tree and then the level of it is
+ *     extended into 2 from 1. At that time, the new radix tree node succeeds
+ *     the tag status of the root tag. Therefore the tag of the new radix tree
+ *     node has PAGECACHE_TAG_TOWRITE but there is not slot with
+ *     PAGECACHE_TAG_TOWRITE tag in the child node of the new radix tree node.
+ * 3.  The tag of a certain item is cleared with PAGECACHE_TAG_DIRTY.
+ * 4.  All items within the index range from 0 to RADIX_TREE_MAP_SIZE - 1 are
+ *     released. (Only the item which index is RADIX_TREE_MAP_SIZE exist in the
+ *     radix tree.) As the result, the slot of the radix tree node is NULL but
+ *     the tag which corresponds to the slot has PAGECACHE_TAG_TOWRITE.
+ * 5.  radix_tree_gang_lookup_tag_slot(PAGECACHE_TAG_TOWRITE) calls
+ *     __lookup_tag. __lookup_tag returns with 0. And __lookup_tag doesn't
+ *     change the index that is the input and output parameter. Because the 1st
+ *     slot of the radix tree node is NULL, but the tag which corresponds to
+ *     the slot has PAGECACHE_TAG_TOWRITE.
+ *     Therefore radix_tree_gang_lookup_tag_slot tries to get some items by
+ *     calling __lookup_tag, but it cannot get any items forever.
+ *
+ * The fix is to change that radix_tree_tag_if_tagged doesn't tag the root tag
+ * if it doesn't set any tags within the specified range.
+ *
+ * Running:
+ * This test should run to completion immediately. The above bug would cause it
+ * to hang indefinitely.
+ *
+ * Upstream commit:
+ * Not yet
+ */
+#include <linux/kernel.h>
+#include <linux/gfp.h>
+#include <linux/slab.h>
+#include <linux/radix-tree.h>
+#include <stdlib.h>
+#include <stdio.h>
+
+#include "regression.h"
+
+#ifdef __KERNEL__
+#define RADIX_TREE_MAP_SHIFT    (CONFIG_BASE_SMALL ? 4 : 6)
+#else
+#define RADIX_TREE_MAP_SHIFT    3       /* For more stressful testing */
+#endif
+
+#define RADIX_TREE_MAP_SIZE     (1UL << RADIX_TREE_MAP_SHIFT)
+#define PAGECACHE_TAG_DIRTY     0
+#define PAGECACHE_TAG_WRITEBACK 1
+#define PAGECACHE_TAG_TOWRITE   2
+
+static RADIX_TREE(mt_tree, GFP_KERNEL);
+unsigned long page_count = 0;
+
+struct page {
+	unsigned long index;
+};
+
+static struct page *page_alloc(void)
+{
+	struct page *p;
+	p = malloc(sizeof(struct page));
+	p->index = page_count++;
+
+	return p;
+}
+
+void regression2_test(void)
+{
+	int i;
+	struct page *p;
+	int max_slots = RADIX_TREE_MAP_SIZE;
+	unsigned long int start, end;
+	struct page *pages[1];
+
+	printf("running regression test 2 (should take milliseconds)\n");
+	/* 0. */
+	for (i = 0; i <= max_slots - 1; i++) {
+		p = page_alloc();
+		radix_tree_insert(&mt_tree, i, p);
+	}
+	radix_tree_tag_set(&mt_tree, max_slots - 1, PAGECACHE_TAG_DIRTY);
+
+	/* 1. */
+	start = 0;
+	end = max_slots - 2;
+	radix_tree_range_tag_if_tagged(&mt_tree, &start, end, 1,
+				PAGECACHE_TAG_DIRTY, PAGECACHE_TAG_TOWRITE);
+
+	/* 2. */
+	p = page_alloc();
+	radix_tree_insert(&mt_tree, max_slots, p);
+
+	/* 3. */
+	radix_tree_tag_clear(&mt_tree, max_slots - 1, PAGECACHE_TAG_DIRTY);
+
+	/* 4. */
+	for (i = max_slots - 1; i >= 0; i--)
+		radix_tree_delete(&mt_tree, i);
+
+	/* 5. */
+	// NOTE: start should not be 0 because radix_tree_gang_lookup_tag_slot
+	//       can return.
+	start = 1;
+	end = max_slots - 2;
+	radix_tree_gang_lookup_tag_slot(&mt_tree, (void ***)pages, start, end,
+		PAGECACHE_TAG_TOWRITE);
+
+	/* We remove all the remained nodes */
+	radix_tree_delete(&mt_tree, max_slots);
+
+	printf("regression test 2, done\n");
+}
diff --git a/tools/testing/radix-tree/tag_check.c b/tools/testing/radix-tree/tag_check.c
new file mode 100644
index 0000000..83136be
--- /dev/null
+++ b/tools/testing/radix-tree/tag_check.c
@@ -0,0 +1,332 @@
+#include <stdlib.h>
+#include <assert.h>
+#include <stdio.h>
+#include <string.h>
+
+#include <linux/slab.h>
+#include <linux/radix-tree.h>
+
+#include "test.h"
+
+
+static void
+__simple_checks(struct radix_tree_root *tree, unsigned long index, int tag)
+{
+	int ret;
+
+	item_check_absent(tree, index);
+	assert(item_tag_get(tree, index, tag) == 0);
+
+	item_insert(tree, index);
+	assert(item_tag_get(tree, index, tag) == 0);
+	item_tag_set(tree, index, tag);
+	ret = item_tag_get(tree, index, tag);
+	assert(ret != 0);
+	ret = item_delete(tree, index);
+	assert(ret != 0);
+	item_insert(tree, index);
+	ret = item_tag_get(tree, index, tag);
+	assert(ret == 0);
+	ret = item_delete(tree, index);
+	assert(ret != 0);
+	ret = item_delete(tree, index);
+	assert(ret == 0);
+}
+
+void simple_checks(void)
+{
+	unsigned long index;
+	RADIX_TREE(tree, GFP_KERNEL);
+
+	for (index = 0; index < 10000; index++) {
+		__simple_checks(&tree, index, 0);
+		__simple_checks(&tree, index, 1);
+	}
+	verify_tag_consistency(&tree, 0);
+	verify_tag_consistency(&tree, 1);
+	printf("before item_kill_tree: %d allocated\n", nr_allocated);
+	item_kill_tree(&tree);
+	printf("after item_kill_tree: %d allocated\n", nr_allocated);
+}
+
+/*
+ * Check that tags propagate correctly when extending a tree.
+ */
+static void extend_checks(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+
+	item_insert(&tree, 43);
+	assert(item_tag_get(&tree, 43, 0) == 0);
+	item_tag_set(&tree, 43, 0);
+	assert(item_tag_get(&tree, 43, 0) == 1);
+	item_insert(&tree, 1000000);
+	assert(item_tag_get(&tree, 43, 0) == 1);
+
+	item_insert(&tree, 0);
+	item_tag_set(&tree, 0, 0);
+	item_delete(&tree, 1000000);
+	assert(item_tag_get(&tree, 43, 0) != 0);
+	item_delete(&tree, 43);
+	assert(item_tag_get(&tree, 43, 0) == 0);	/* crash */
+	assert(item_tag_get(&tree, 0, 0) == 1);
+
+	verify_tag_consistency(&tree, 0);
+
+	item_kill_tree(&tree);
+}
+
+/*
+ * Check that tags propagate correctly when contracting a tree.
+ */
+static void contract_checks(void)
+{
+	struct item *item;
+	int tmp;
+	RADIX_TREE(tree, GFP_KERNEL);
+
+	tmp = 1<<RADIX_TREE_MAP_SHIFT;
+	item_insert(&tree, tmp);
+	item_insert(&tree, tmp+1);
+	item_tag_set(&tree, tmp, 0);
+	item_tag_set(&tree, tmp, 1);
+	item_tag_set(&tree, tmp+1, 0);
+	item_delete(&tree, tmp+1);
+	item_tag_clear(&tree, tmp, 1);
+
+	assert(radix_tree_gang_lookup_tag(&tree, (void **)&item, 0, 1, 0) == 1);
+	assert(radix_tree_gang_lookup_tag(&tree, (void **)&item, 0, 1, 1) == 0);
+
+	assert(item_tag_get(&tree, tmp, 0) == 1);
+	assert(item_tag_get(&tree, tmp, 1) == 0);
+
+	verify_tag_consistency(&tree, 0);
+	item_kill_tree(&tree);
+}
+
+/*
+ * Stupid tag thrasher
+ *
+ * Create a large linear array corresponding to the tree.   Each element in
+ * the array is coherent with each node in the tree
+ */
+
+enum {
+	NODE_ABSENT = 0,
+	NODE_PRESENT = 1,
+	NODE_TAGGED = 2,
+};
+
+#define THRASH_SIZE		1000 * 1000
+#define N 127
+#define BATCH	33
+
+static void gang_check(struct radix_tree_root *tree,
+			char *thrash_state, int tag)
+{
+	struct item *items[BATCH];
+	int nr_found;
+	unsigned long index = 0;
+	unsigned long last_index = 0;
+
+	while ((nr_found = radix_tree_gang_lookup_tag(tree, (void **)items,
+					index, BATCH, tag))) {
+		int i;
+
+		for (i = 0; i < nr_found; i++) {
+			struct item *item = items[i];
+
+			while (last_index < item->index) {
+				assert(thrash_state[last_index] != NODE_TAGGED);
+				last_index++;
+			}
+			assert(thrash_state[last_index] == NODE_TAGGED);
+			last_index++;
+		}
+		index = items[nr_found - 1]->index + 1;
+	}
+}
+
+static void do_thrash(struct radix_tree_root *tree, char *thrash_state, int tag)
+{
+	int insert_chunk;
+	int delete_chunk;
+	int tag_chunk;
+	int untag_chunk;
+	int total_tagged = 0;
+	int total_present = 0;
+
+	for (insert_chunk = 1; insert_chunk < THRASH_SIZE; insert_chunk *= N)
+	for (delete_chunk = 1; delete_chunk < THRASH_SIZE; delete_chunk *= N)
+	for (tag_chunk = 1; tag_chunk < THRASH_SIZE; tag_chunk *= N)
+	for (untag_chunk = 1; untag_chunk < THRASH_SIZE; untag_chunk *= N) {
+		int i;
+		unsigned long index;
+		int nr_inserted = 0;
+		int nr_deleted = 0;
+		int nr_tagged = 0;
+		int nr_untagged = 0;
+		int actual_total_tagged;
+		int actual_total_present;
+
+		for (i = 0; i < insert_chunk; i++) {
+			index = rand() % THRASH_SIZE;
+			if (thrash_state[index] != NODE_ABSENT)
+				continue;
+			item_check_absent(tree, index);
+			item_insert(tree, index);
+			assert(thrash_state[index] != NODE_PRESENT);
+			thrash_state[index] = NODE_PRESENT;
+			nr_inserted++;
+			total_present++;
+		}
+
+		for (i = 0; i < delete_chunk; i++) {
+			index = rand() % THRASH_SIZE;
+			if (thrash_state[index] == NODE_ABSENT)
+				continue;
+			item_check_present(tree, index);
+			if (item_tag_get(tree, index, tag)) {
+				assert(thrash_state[index] == NODE_TAGGED);
+				total_tagged--;
+			} else {
+				assert(thrash_state[index] == NODE_PRESENT);
+			}
+			item_delete(tree, index);
+			assert(thrash_state[index] != NODE_ABSENT);
+			thrash_state[index] = NODE_ABSENT;
+			nr_deleted++;
+			total_present--;
+		}
+
+		for (i = 0; i < tag_chunk; i++) {
+			index = rand() % THRASH_SIZE;
+			if (thrash_state[index] != NODE_PRESENT) {
+				if (item_lookup(tree, index))
+					assert(item_tag_get(tree, index, tag));
+				continue;
+			}
+			item_tag_set(tree, index, tag);
+			item_tag_set(tree, index, tag);
+			assert(thrash_state[index] != NODE_TAGGED);
+			thrash_state[index] = NODE_TAGGED;
+			nr_tagged++;
+			total_tagged++;
+		}
+
+		for (i = 0; i < untag_chunk; i++) {
+			index = rand() % THRASH_SIZE;
+			if (thrash_state[index] != NODE_TAGGED)
+				continue;
+			item_check_present(tree, index);
+			assert(item_tag_get(tree, index, tag));
+			item_tag_clear(tree, index, tag);
+			item_tag_clear(tree, index, tag);
+			assert(thrash_state[index] != NODE_PRESENT);
+			thrash_state[index] = NODE_PRESENT;
+			nr_untagged++;
+			total_tagged--;
+		}
+
+		actual_total_tagged = 0;
+		actual_total_present = 0;
+		for (index = 0; index < THRASH_SIZE; index++) {
+			switch (thrash_state[index]) {
+			case NODE_ABSENT:
+				item_check_absent(tree, index);
+				break;
+			case NODE_PRESENT:
+				item_check_present(tree, index);
+				assert(!item_tag_get(tree, index, tag));
+				actual_total_present++;
+				break;
+			case NODE_TAGGED:
+				item_check_present(tree, index);
+				assert(item_tag_get(tree, index, tag));
+				actual_total_present++;
+				actual_total_tagged++;
+				break;
+			}
+		}
+
+		gang_check(tree, thrash_state, tag);
+
+		printf("%d(%d) %d(%d) %d(%d) %d(%d) / "
+				"%d(%d) present, %d(%d) tagged\n",
+			insert_chunk, nr_inserted,
+			delete_chunk, nr_deleted,
+			tag_chunk, nr_tagged,
+			untag_chunk, nr_untagged,
+			total_present, actual_total_present,
+			total_tagged, actual_total_tagged);
+	}
+}
+
+static void thrash_tags(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+	char *thrash_state;
+
+	thrash_state = malloc(THRASH_SIZE);
+	memset(thrash_state, 0, THRASH_SIZE);
+
+	do_thrash(&tree, thrash_state, 0);
+
+	verify_tag_consistency(&tree, 0);
+	item_kill_tree(&tree);
+	free(thrash_state);
+}
+
+static void leak_check(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+
+	item_insert(&tree, 1000000);
+	item_delete(&tree, 1000000);
+	item_kill_tree(&tree);
+}
+
+static void __leak_check(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+
+	printf("%d: nr_allocated=%d\n", __LINE__, nr_allocated);
+	item_insert(&tree, 1000000);
+	printf("%d: nr_allocated=%d\n", __LINE__, nr_allocated);
+	item_delete(&tree, 1000000);
+	printf("%d: nr_allocated=%d\n", __LINE__, nr_allocated);
+	item_kill_tree(&tree);
+	printf("%d: nr_allocated=%d\n", __LINE__, nr_allocated);
+}
+
+static void single_check(void)
+{
+	struct item *items[BATCH];
+	RADIX_TREE(tree, GFP_KERNEL);
+	int ret;
+
+	item_insert(&tree, 0);
+	item_tag_set(&tree, 0, 0);
+	ret = radix_tree_gang_lookup_tag(&tree, (void **)items, 0, BATCH, 0);
+	assert(ret == 1);
+	ret = radix_tree_gang_lookup_tag(&tree, (void **)items, 1, BATCH, 0);
+	assert(ret == 0);
+	verify_tag_consistency(&tree, 0);
+	verify_tag_consistency(&tree, 1);
+	item_kill_tree(&tree);
+}
+
+void tag_check(void)
+{
+	single_check();
+	extend_checks();
+	contract_checks();
+	printf("after extend_checks: %d allocated\n", nr_allocated);
+	__leak_check();
+	leak_check();
+	printf("after leak_check: %d allocated\n", nr_allocated);
+	simple_checks();
+	printf("after simple_checks: %d allocated\n", nr_allocated);
+	thrash_tags();
+	printf("after thrash_tags: %d allocated\n", nr_allocated);
+}
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
new file mode 100644
index 0000000..c9b0bd7
--- /dev/null
+++ b/tools/testing/radix-tree/test.c
@@ -0,0 +1,218 @@
+#include <stdlib.h>
+#include <assert.h>
+#include <stdio.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/bitops.h>
+
+#include "test.h"
+
+struct item *
+item_tag_set(struct radix_tree_root *root, unsigned long index, int tag)
+{
+	return radix_tree_tag_set(root, index, tag);
+}
+
+struct item *
+item_tag_clear(struct radix_tree_root *root, unsigned long index, int tag)
+{
+	return radix_tree_tag_clear(root, index, tag);
+}
+
+int item_tag_get(struct radix_tree_root *root, unsigned long index, int tag)
+{
+	return radix_tree_tag_get(root, index, tag);
+}
+
+int __item_insert(struct radix_tree_root *root, struct item *item)
+{
+	return radix_tree_insert(root, item->index, item);
+}
+
+int item_insert(struct radix_tree_root *root, unsigned long index)
+{
+	return __item_insert(root, item_create(index));
+}
+
+int item_delete(struct radix_tree_root *root, unsigned long index)
+{
+	struct item *item = radix_tree_delete(root, index);
+
+	if (item) {
+		assert(item->index == index);
+		free(item);
+		return 1;
+	}
+	return 0;
+}
+
+struct item *item_create(unsigned long index)
+{
+	struct item *ret = malloc(sizeof(*ret));
+
+	ret->index = index;
+	return ret;
+}
+
+void item_check_present(struct radix_tree_root *root, unsigned long index)
+{
+	struct item *item;
+
+	item = radix_tree_lookup(root, index);
+	assert(item != 0);
+	assert(item->index == index);
+}
+
+struct item *item_lookup(struct radix_tree_root *root, unsigned long index)
+{
+	return radix_tree_lookup(root, index);
+}
+
+void item_check_absent(struct radix_tree_root *root, unsigned long index)
+{
+	struct item *item;
+
+	item = radix_tree_lookup(root, index);
+	assert(item == 0);
+}
+
+/*
+ * Scan only the passed (start, start+nr] for present items
+ */
+void item_gang_check_present(struct radix_tree_root *root,
+			unsigned long start, unsigned long nr,
+			int chunk, int hop)
+{
+	struct item *items[chunk];
+	unsigned long into;
+
+	for (into = 0; into < nr; ) {
+		int nfound;
+		int nr_to_find = chunk;
+		int i;
+
+		if (nr_to_find > (nr - into))
+			nr_to_find = nr - into;
+
+		nfound = radix_tree_gang_lookup(root, (void **)items,
+						start + into, nr_to_find);
+		assert(nfound == nr_to_find);
+		for (i = 0; i < nfound; i++)
+			assert(items[i]->index == start + into + i);
+		into += hop;
+	}
+}
+
+/*
+ * Scan the entire tree, only expecting present items (start, start+nr]
+ */
+void item_full_scan(struct radix_tree_root *root, unsigned long start,
+			unsigned long nr, int chunk)
+{
+	struct item *items[chunk];
+	unsigned long into = 0;
+	unsigned long this_index = start;
+	int nfound;
+	int i;
+
+//	printf("%s(0x%08lx, 0x%08lx, %d)\n", __FUNCTION__, start, nr, chunk);
+
+	while ((nfound = radix_tree_gang_lookup(root, (void **)items, into,
+					chunk))) {
+//		printf("At 0x%08lx, nfound=%d\n", into, nfound);
+		for (i = 0; i < nfound; i++) {
+			assert(items[i]->index == this_index);
+			this_index++;
+		}
+//		printf("Found 0x%08lx->0x%08lx\n",
+//			items[0]->index, items[nfound-1]->index);
+		into = this_index;
+	}
+	if (chunk)
+		assert(this_index == start + nr);
+	nfound = radix_tree_gang_lookup(root, (void **)items,
+					this_index, chunk);
+	assert(nfound == 0);
+}
+
+static int verify_node(struct radix_tree_node *slot, unsigned int tag,
+			unsigned int height, int tagged)
+{
+	int anyset = 0;
+	int i;
+	int j;
+
+	/* Verify consistency at this level */
+	for (i = 0; i < RADIX_TREE_TAG_LONGS; i++) {
+		if (slot->tags[tag][i]) {
+			anyset = 1;
+			break;
+		}
+	}
+	if (tagged != anyset) {
+		printf("tag: %u, height %u, tagged: %d, anyset: %d\n", tag, height, tagged, anyset);
+		for (j = 0; j < RADIX_TREE_MAX_TAGS; j++) {
+			printf("tag %d: ", j);
+			for (i = 0; i < RADIX_TREE_TAG_LONGS; i++)
+				printf("%016lx ", slot->tags[j][i]);
+			printf("\n");
+		}
+		return 1;
+	}
+	assert(tagged == anyset);
+
+	/* Go for next level */
+	if (height > 1) {
+		for (i = 0; i < RADIX_TREE_MAP_SIZE; i++)
+			if (slot->slots[i])
+				if (verify_node(slot->slots[i], tag, height - 1,
+					    !!test_bit(i, slot->tags[tag]))) {
+					printf("Failure at off %d\n", i);
+					for (j = 0; j < RADIX_TREE_MAX_TAGS; j++) {
+						printf("tag %d: ", j);
+						for (i = 0; i < RADIX_TREE_TAG_LONGS; i++)
+							printf("%016lx ", slot->tags[j][i]);
+						printf("\n");
+					}
+					return 1;
+				}
+	}
+	return 0;
+}
+
+void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag)
+{
+	if (!root->height)
+		return;
+	verify_node(indirect_to_ptr(root->rnode),
+			tag, root->height, !!root_tag_get(root, tag));
+}
+
+void item_kill_tree(struct radix_tree_root *root)
+{
+	struct item *items[32];
+	int nfound;
+
+	while ((nfound = radix_tree_gang_lookup(root, (void **)items, 0, 32))) {
+		int i;
+
+		for (i = 0; i < nfound; i++) {
+			void *ret;
+
+			ret = radix_tree_delete(root, items[i]->index);
+			assert(ret == items[i]);
+			free(items[i]);
+		}
+	}
+	assert(radix_tree_gang_lookup(root, (void **)items, 0, 32) == 0);
+	assert(root->rnode == NULL);
+}
+
+void tree_verify_min_height(struct radix_tree_root *root, int maxindex)
+{
+	assert(radix_tree_maxindex(root->height) >= maxindex);
+	if (root->height > 1)
+		assert(radix_tree_maxindex(root->height-1) < maxindex);
+	else if (root->height == 1)
+		assert(radix_tree_maxindex(root->height-1) <= maxindex);
+}
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
new file mode 100644
index 0000000..4e1d95f
--- /dev/null
+++ b/tools/testing/radix-tree/test.h
@@ -0,0 +1,40 @@
+#include <linux/gfp.h>
+#include <linux/types.h>
+#include <linux/radix-tree.h>
+#include <linux/rcupdate.h>
+
+struct item {
+	unsigned long index;
+};
+
+struct item *item_create(unsigned long index);
+int __item_insert(struct radix_tree_root *root, struct item *item);
+int item_insert(struct radix_tree_root *root, unsigned long index);
+int item_delete(struct radix_tree_root *root, unsigned long index);
+struct item *item_lookup(struct radix_tree_root *root, unsigned long index);
+
+void item_check_present(struct radix_tree_root *root, unsigned long index);
+void item_check_absent(struct radix_tree_root *root, unsigned long index);
+void item_gang_check_present(struct radix_tree_root *root,
+			unsigned long start, unsigned long nr,
+			int chunk, int hop);
+void item_full_scan(struct radix_tree_root *root, unsigned long start,
+			unsigned long nr, int chunk);
+void item_kill_tree(struct radix_tree_root *root);
+
+void tag_check(void);
+
+struct item *
+item_tag_set(struct radix_tree_root *root, unsigned long index, int tag);
+struct item *
+item_tag_clear(struct radix_tree_root *root, unsigned long index, int tag);
+int item_tag_get(struct radix_tree_root *root, unsigned long index, int tag);
+void tree_verify_min_height(struct radix_tree_root *root, int maxindex);
+void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag);
+
+extern int nr_allocated;
+
+/* Normally private parts of lib/radix-tree.c */
+void *indirect_to_ptr(void *ptr);
+int root_tag_get(struct radix_tree_root *root, unsigned int tag);
+unsigned long radix_tree_maxindex(unsigned int height);
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
