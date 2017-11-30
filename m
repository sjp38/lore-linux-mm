Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81E5C6B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 05:35:00 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id u126so2598950oif.23
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 02:35:00 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g196si1220740oib.31.2017.11.30.02.34.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 02:34:59 -0800 (PST)
Subject: Re: [PATCH v18 05/10] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
	<1511963726-34070-6-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1511963726-34070-6-git-send-email-wei.w.wang@intel.com>
Message-Id: <201711301934.CDC21800.FSLtJFFOOVQHMO@I-love.SAKURA.ne.jp>
Date: Thu, 30 Nov 2017 19:34:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Wei Wang wrote:
>  /**
> + * xb_clear_bit - clear a range of bits in the xbitmap

Name mismatch.

> + * @start: the start of the bit range, inclusive
> + * @end: the end of the bit range, inclusive
> + *
> + * This function is used to clear a bit in the xbitmap. If all the bits of the
> + * bitmap are 0, the bitmap will be freed.
> + */
> +void xb_clear_bit_range(struct xb *xb, unsigned long start, unsigned long end)
> +{
> +	struct radix_tree_root *root = &xb->xbrt;
> +	struct radix_tree_node *node;
> +	void **slot;
> +	struct ida_bitmap *bitmap;
> +	unsigned int nbits;
> +
> +	for (; start < end; start = (start | (IDA_BITMAP_BITS - 1)) + 1) {
> +		unsigned long index = start / IDA_BITMAP_BITS;
> +		unsigned long bit = start % IDA_BITMAP_BITS;
> +
> +		bitmap = __radix_tree_lookup(root, index, &node, &slot);
> +		if (radix_tree_exception(bitmap)) {
> +			unsigned long ebit = bit + 2;
> +			unsigned long tmp = (unsigned long)bitmap;
> +
> +			nbits = min(end - start + 1, BITS_PER_LONG - ebit);

"nbits = min(end - start + 1," seems to expect that start == end is legal
for clearing only 1 bit. But this function is no-op if start == end.
Please clarify what "inclusive" intended.

> +
> +			if (ebit >= BITS_PER_LONG)
> +				continue;

(I don't understand how radix tree works, but generally this patchset looks fuzzy
to me about boundary cases. Thus, I want to confirm that this is not an overlook.)
Why is making "ebit >= BITS_PER_LONG" (e.g. start == 62) case a no-op correct?
Aren't there bits which should have been cleared in this case?

> +			bitmap_clear(&tmp, ebit, nbits);
> +			if (tmp == RADIX_TREE_EXCEPTIONAL_ENTRY)
> +				__radix_tree_delete(root, node, slot);
> +			else
> +				rcu_assign_pointer(*slot, (void *)tmp);
> +		} else if (bitmap) {
> +			nbits = min(end - start + 1, IDA_BITMAP_BITS - bit);
> +
> +			if (nbits != IDA_BITMAP_BITS)
> +				bitmap_clear(bitmap->bitmap, bit, nbits);
> +
> +			if (nbits == IDA_BITMAP_BITS ||
> +			    bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {
> +				kfree(bitmap);
> +				__radix_tree_delete(root, node, slot);
> +			}
> +		}
> +	}
> +}



> +static inline __always_inline void bitmap_clear(unsigned long *map,
> +						unsigned int start,
> +						unsigned int nbits)
> +{
> +	if (__builtin_constant_p(nbits) && nbits == 1)
> +		__clear_bit(start, map);
> +	else if (__builtin_constant_p(start & 7) && IS_ALIGNED(start, 8) &&
> +		 __builtin_constant_p(nbits & 7) && IS_ALIGNED(nbits, 8))

It looks strange to apply __builtin_constant_p test to variables after "& 7".

> +		memset((char *)map + start / 8, 0, nbits / 8);
> +	else
> +		__bitmap_clear(map, start, nbits);
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
