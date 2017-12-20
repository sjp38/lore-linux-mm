Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25A256B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 12:10:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a5so13165197pgu.1
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 09:10:30 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b1si13299434plc.647.2017.12.20.09.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 09:10:28 -0800 (PST)
Date: Wed, 20 Dec 2017 09:10:19 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v20 0/7] Virtio-balloon Enhancement
Message-ID: <20171220171019.GA12236@bombadil.infradead.org>
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
 <201712192305.AAE21882.MtQHJOFFSFVOLO@I-love.SAKURA.ne.jp>
 <5A3A3CBC.4030202@intel.com>
 <20171220122547.GA1654@bombadil.infradead.org>
 <286AC319A985734F985F78AFA26841F73938CC3E@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F73938CC3E@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>

On Wed, Dec 20, 2017 at 04:13:16PM +0000, Wang, Wei W wrote:
> On Wednesday, December 20, 2017 8:26 PM, Matthew Wilcox wrote:
> > 	unsigned long bit;
> > 	xb_preload(GFP_KERNEL);
> > 	xb_set_bit(xb, 700);
> > 	xb_preload_end();
> > 	bit = xb_find_set(xb, ULONG_MAX, 0);
> > 	assert(bit == 700);
> 
> This above test will result in "!node with bitmap !=NULL", and it goes to the regular "if (bitmap)" path, which finds 700.
> 
> A better test would be
> ...
> xb_set_bit(xb, 700);
> assert(xb_find_set(xb, ULONG_MAX, 800) == ULONG_MAX);
> ...

I decided to write a test case to show you what I meant, then I discovered
the test suite didn't build, then the test I wrote took forever to run, so
I rewrote xb_find_set() using the radix tree iterators.  So I have no idea
what bugs may be in your implementation, but at least this function passes
the current test suite.  Of course, there may be gaps in the test suite.
And since I changed the API to not have the ambiguous return value, I
also changed the test suite, and maybe I introduced a bug.

diff --git a/include/linux/xbitmap.h b/include/linux/xbitmap.h
index ede1029b8a27..96e7e3560a0e 100644
--- a/include/linux/xbitmap.h
+++ b/include/linux/xbitmap.h
@@ -37,8 +37,7 @@ bool xb_test_bit(const struct xb *xb, unsigned long bit);
 void xb_clear_bit(struct xb *xb, unsigned long bit);
 void xb_clear_bit_range(struct xb *xb, unsigned long start,
 			unsigned long nbits);
-unsigned long xb_find_set(struct xb *xb, unsigned long size,
-			  unsigned long offset);
+bool xb_find_set(struct xb *xb, unsigned long max, unsigned long *bit);
 unsigned long xb_find_zero(struct xb *xb, unsigned long size,
 			   unsigned long offset);
 
diff --git a/lib/xbitmap.c b/lib/xbitmap.c
index 0bd3027b082d..58c26c8dd595 100644
--- a/lib/xbitmap.c
+++ b/lib/xbitmap.c
@@ -150,48 +150,39 @@ EXPORT_SYMBOL(xb_test_bit);
 /**
  * xb_find_set - find the next set bit in a range of bits
  * @xb: the xbitmap to search from
- * @offset: the offset in the range to start searching
- * @size: the size of the range
+ * @max: the maximum position to search to
+ * @bit: the first bit to examine, and on exit, the found bit
  *
- * Returns: the found bit or, @size if no set bit is found.
+ * Returns: %true if a set bit was found.  @bit will be updated.
  */
-unsigned long xb_find_set(struct xb *xb, unsigned long size,
-			  unsigned long offset)
+bool xb_find_set(struct xb *xb, unsigned long max, unsigned long *bit)
 {
-	struct radix_tree_root *root = &xb->xbrt;
-	struct radix_tree_node *node;
+	struct radix_tree_iter iter;
 	void __rcu **slot;
 	struct ida_bitmap *bitmap;
-	unsigned long index = offset / IDA_BITMAP_BITS;
-	unsigned long index_end = size / IDA_BITMAP_BITS;
-	unsigned long bit = offset % IDA_BITMAP_BITS;
-
-	if (unlikely(offset >= size))
-		return size;
-
-	while (index <= index_end) {
-		unsigned long ret;
-		unsigned int nbits = size - index * IDA_BITMAP_BITS;
-
-		bitmap = __radix_tree_lookup(root, index, &node, &slot);
-		if (!node) {
-			index = (index | RADIX_TREE_MAP_MASK) + 1;
-			continue;
-		}
-
+	unsigned long index = *bit / IDA_BITMAP_BITS;
+	unsigned int first = *bit % IDA_BITMAP_BITS;
+	unsigned long index_end = max / IDA_BITMAP_BITS;
+
+	radix_tree_for_each_slot(slot, &xb->xbrt, &iter, index) {
+		if (iter.index > index_end)
+			break;
+		bitmap = radix_tree_deref_slot(slot);
 		if (bitmap) {
-			if (nbits > IDA_BITMAP_BITS)
-				nbits = IDA_BITMAP_BITS;
-
-			ret = find_next_bit(bitmap->bitmap, nbits, bit);
-			if (ret != nbits)
-				return ret + index * IDA_BITMAP_BITS;
+			unsigned int nbits = IDA_BITMAP_BITS;
+			if (iter.index == index_end)
+				nbits = max % IDA_BITMAP_BITS + 1;
+
+			first = find_next_bit(bitmap->bitmap, nbits, first);
+			if (first != nbits) {
+				*bit = first + iter.index * IDA_BITMAP_BITS;
+				return true;
+			}
 		}
-		bit = 0;
-		index++;
+		first = 0;
 	}
 
-	return size;
+	return false;
 }
 EXPORT_SYMBOL(xb_find_set);
 
@@ -246,19 +237,30 @@ static DEFINE_XB(xb1);
 
 void xbitmap_check_bit(unsigned long bit)
 {
+	unsigned long nbit = 0;
+
 	xb_preload(GFP_KERNEL);
 	assert(!xb_test_bit(&xb1, bit));
 	assert(xb_set_bit(&xb1, bit) == 0);
 	assert(xb_test_bit(&xb1, bit));
-	assert(xb_clear_bit(&xb1, bit) == 0);
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == bit);
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == bit);
+	nbit++;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == false);
+	assert(nbit == bit + 1);
+	xb_clear_bit(&xb1, bit);
 	assert(xb_empty(&xb1));
-	assert(xb_clear_bit(&xb1, bit) == 0);
+	xb_clear_bit(&xb1, bit);
 	assert(xb_empty(&xb1));
 	xb_preload_end();
 }
 
 static void xbitmap_check_bit_range(void)
 {
+	unsigned long nbit;
+
 	/*
 	 * Regular tests
 	 * set bit 2000, 2001, 2040
@@ -273,14 +275,23 @@ static void xbitmap_check_bit_range(void)
 	assert(!xb_set_bit(&xb1, 2000));
 	assert(!xb_set_bit(&xb1, 2001));
 	assert(!xb_set_bit(&xb1, 2040));
-	assert(xb_find_set(&xb1, 2048, 0) == 2000);
-	assert(xb_find_set(&xb1, 2002, 2000) == 2000);
-	assert(xb_find_set(&xb1, 2041, 2002) == 2040);
-	assert(xb_find_set(&xb1, 2040, 2002) == 2040);
+	nbit = 0;
+	assert(xb_find_set(&xb1, 2048, &nbit) == true);
+	assert(nbit == 2000);
+	assert(xb_find_set(&xb1, 2002, &nbit) == true);
+	assert(nbit == 2000);
+	nbit = 2002;
+	assert(xb_find_set(&xb1, 2041, &nbit) == true);
+	assert(nbit == 2040);
+	nbit = 2002;
+	assert(xb_find_set(&xb1, 2040, &nbit) == true);
+	assert(nbit == 2040);
 	assert(xb_find_zero(&xb1, 2048, 2000) == 2002);
 	assert(xb_find_zero(&xb1, 2060, 2048) == 2048);
 	xb_clear_bit_range(&xb1, 0, 2048);
-	assert(xb_find_set(&xb1, 2048, 0) == 2048);
+	nbit = 0;
+	assert(xb_find_set(&xb1, 2048, &nbit) == false);
+	assert(nbit == 0);
 	xb_preload_end();
 
 	/*
@@ -295,15 +306,22 @@ static void xbitmap_check_bit_range(void)
 	xb_preload_end();
 	xb_preload(GFP_KERNEL);
 	assert(!xb_set_bit(&xb1, ULONG_MAX - 4));
-	assert(xb_find_set(&xb1, ULONG_MAX, ULONG_MAX - 4) == ULONG_MAX - 4);
-	assert(xb_find_set(&xb1, ULONG_MAX + 4, ULONG_MAX - 3) ==
-	       ULONG_MAX + 4);
+	nbit = ULONG_MAX - 4;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
+	assert(nbit == ULONG_MAX - 4);
+	nbit++;
+	assert(xb_find_set(&xb1, ULONG_MAX + 4, &nbit) == false);
+	assert(nbit == ULONG_MAX - 3);
 	assert(xb_find_zero(&xb1, ULONG_MAX + 4, ULONG_MAX - 4) ==
 	       ULONG_MAX + 4);
 	xb_clear_bit_range(&xb1, ULONG_MAX - 4, 4);
-	assert(xb_find_set(&xb1, ULONG_MAX, ULONG_MAX - 10) == ULONG_MAX);
+	nbit = ULONG_MAX - 10;
+	assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == false);
+	assert(nbit == ULONG_MAX - 10);
 	xb_clear_bit_range(&xb1, 0, 2);
-	assert(xb_find_set(&xb1, 2, 0) == 2);
+	nbit = 0;
+	assert(xb_find_set(&xb1, 2, &nbit) == false);
+	assert(nbit == 0);
 	xb_preload_end();
 }
 
@@ -313,6 +331,10 @@ void xbitmap_checks(void)
 	xbitmap_check_bit(0);
 	xbitmap_check_bit(30);
 	xbitmap_check_bit(31);
+	xbitmap_check_bit(62);
+	xbitmap_check_bit(63);
+	xbitmap_check_bit(64);
+	xbitmap_check_bit(700);
 	xbitmap_check_bit(1023);
 	xbitmap_check_bit(1024);
 	xbitmap_check_bit(1025);
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index 34ece7883629..adf36e34dd77 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -1,9 +1,9 @@
 # SPDX-License-Identifier: GPL-2.0
 
 CFLAGS += -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE -fsanitize=address
-LDFLAGS += -fsanitize=address
-LDLIBS+= -lpthread -lurcu
-TARGETS = main idr-test multiorder
+LDFLAGS += -fsanitize=address $(LDLIBS)
+LDLIBS := -lpthread -lurcu
+TARGETS = main idr-test multiorder xbitmap
 CORE_OFILES := radix-tree.o idr.o linux.o test.o find_bit.o
 OFILES = main.o $(CORE_OFILES) regression1.o regression2.o regression3.o \
 	 tag_check.o multiorder.o idr-test.o iteration_check.o benchmark.o \
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index c3bc3f364f68..426f32f28547 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -17,6 +17,4 @@
 #define pr_debug printk
 #define pr_cont printk
 
-#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
-
 #endif /* _KERNEL_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
