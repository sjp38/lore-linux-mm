Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 395416B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 09:18:11 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e9so858730pgv.17
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 06:18:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m15si13583866pgt.327.2017.12.21.06.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Dec 2017 06:18:09 -0800 (PST)
Date: Thu, 21 Dec 2017 06:18:05 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v20 3/7 RESEND] xbitmap: add more operations
Message-ID: <20171221141805.GA27695@bombadil.infradead.org>
References: <1513823406-43632-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513823406-43632-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, penguin-kernel@I-love.SAKURA.ne.jp


First of all, the test-suite doesn't build, so I don't know whether you
ran it or not.  Then I added the xb_find_set() call below, and it fails
the assert, so you should probably fix that.

diff --git a/lib/xbitmap.c b/lib/xbitmap.c
index f03a0f9f9e29..b29af08a7597 100644
--- a/lib/xbitmap.c
+++ b/lib/xbitmap.c
@@ -249,11 +249,12 @@ void xbitmap_check_bit(unsigned long bit)
 	assert(!xb_test_bit(&xb1, bit));
 	assert(xb_set_bit(&xb1, bit) == 0);
 	assert(xb_test_bit(&xb1, bit));
-	assert(xb_clear_bit(&xb1, bit) == 0);
+	xb_clear_bit(&xb1, bit);
 	assert(xb_empty(&xb1));
-	assert(xb_clear_bit(&xb1, bit) == 0);
+	xb_clear_bit(&xb1, bit);
 	assert(xb_empty(&xb1));
 	xb_preload_end();
+	assert(xb_find_set(&xb1, ULONG_MAX, 0) == bit);
 }
 
 static void xbitmap_check_bit_range(void)
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

On Thu, Dec 21, 2017 at 10:30:06AM +0800, Wei Wang wrote:
> v20 RESEND Changes:
> 	- fixed the !node path
> 	- added the test cases for the !node path
> 	- change __builtin_constant_p(start & 7) to __builtin_constant_p(start) 

Why would you do such a thing?  Just copy the kernel definitions.

> diff --git a/include/linux/xbitmap.h b/include/linux/xbitmap.h
> index 108f929..ede1029 100644
> --- a/include/linux/xbitmap.h
> +++ b/include/linux/xbitmap.h
> @@ -35,6 +35,12 @@ static inline void xb_init(struct xb *xb)
>  int xb_set_bit(struct xb *xb, unsigned long bit);
>  bool xb_test_bit(const struct xb *xb, unsigned long bit);
>  void xb_clear_bit(struct xb *xb, unsigned long bit);
> +void xb_clear_bit_range(struct xb *xb, unsigned long start,
> +			unsigned long nbits);

This is xb_zero().  I thought we talked about this before?

> +unsigned long xb_find_set(struct xb *xb, unsigned long size,
> +			  unsigned long offset);
> +unsigned long xb_find_zero(struct xb *xb, unsigned long size,
> +			   unsigned long offset);

Since you're using xb_find_zero(), I think we need the tags from the IDR.
At that point, I'm not sure there's a point in keeping the xbitmap and the
IDR as separate data structures.

> +/**
> + * xb_find_set - find the next set bit in a range of bits
> + * @xb: the xbitmap to search from
> + * @offset: the offset in the range to start searching
> + * @size: the size of the range
> + *
> + * Returns: the found bit or, @size if no set bit is found.
> + */
> +unsigned long xb_find_set(struct xb *xb, unsigned long size,
> +			  unsigned long offset)
> +{
> +	struct radix_tree_root *root = &xb->xbrt;
> +	struct radix_tree_node *node;
> +	void __rcu **slot;
> +	struct ida_bitmap *bitmap;
> +	unsigned long index = offset / IDA_BITMAP_BITS;
> +	unsigned long index_end = size / IDA_BITMAP_BITS;
> +	unsigned long bit = offset % IDA_BITMAP_BITS;
> +
> +	if (unlikely(offset >= size))
> +		return size;
> +
> +	while (index <= index_end) {
> +		unsigned long ret;
> +		unsigned int nbits = size - index * IDA_BITMAP_BITS;
> +
> +		bitmap = __radix_tree_lookup(root, index, &node, &slot);
> +
> +		if (!node && !bitmap)
> +			return size;
> +
> +		if (bitmap) {
> +			if (nbits > IDA_BITMAP_BITS)
> +				nbits = IDA_BITMAP_BITS;
> +
> +			ret = find_next_bit(bitmap->bitmap, nbits, bit);
> +			if (ret != nbits)
> +				return ret + index * IDA_BITMAP_BITS;
> +		}
> +		bit = 0;
> +		index++;
> +	}
> +
> +	return size;
> +}
> +EXPORT_SYMBOL(xb_find_set);

This is going to be slower than the implementation I sent yesterday.  If I
call:
	xb_init(xb);
	xb_set_bit(xb, ULONG_MAX);
	xb_find_set(xb, ULONG_MAX, 0);

it's going to call __radix_tree_lookup() 16 quadrillion times.
My implementation will walk the tree precisely once.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
