Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id F0C0A6B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 08:22:03 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id v8so12042011otd.4
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 05:22:03 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u75si5103580oie.427.2017.12.12.05.22.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 05:22:02 -0800 (PST)
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1513079759-14169-1-git-send-email-wei.w.wang@intel.com>
	<1513079759-14169-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1513079759-14169-4-git-send-email-wei.w.wang@intel.com>
Message-Id: <201712122220.IFH05261.LtJOFFSFHVMQOO@I-love.SAKURA.ne.jp>
Date: Tue, 12 Dec 2017 22:20:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Wei Wang wrote:
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
> +
> +			if (ebit >= BITS_PER_LONG)

What happens if we hit this "continue;" when "index == ULONG_MAX / IDA_BITMAP_BITS" ?

Can you eliminate exception path and fold all xbitmap patches into one, and
post only one xbitmap patch without virtio-baloon changes? If exception path
is valuable, you can add exception path after minimum version is merged.
This series is too difficult for me to close corner cases.

> +				continue;
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
> +
> +		/*
> +		 * Already reached the last usable ida bitmap, so just return,
> +		 * otherwise overflow will happen.
> +		 */
> +		if (index == ULONG_MAX / IDA_BITMAP_BITS)
> +			break;
> +	}
> +}



> +/**
> + * xb_find_next_set_bit - find the next set bit in a range
> + * @xb: the xbitmap to search
> + * @start: the start of the range, inclusive
> + * @end: the end of the range, exclusive
> + *
> + * Returns: the index of the found bit, or @end + 1 if no such bit is found.
> + */
> +unsigned long xb_find_next_set_bit(struct xb *xb, unsigned long start,
> +				   unsigned long end)
> +{
> +	return xb_find_next_bit(xb, start, end, 1);
> +}

Won't "exclusive" loose ability to handle ULONG_MAX ? Since this is a
library module, missing ability to handle ULONG_MAX sounds like an omission.
Shouldn't we pass (or return) whether "found or not" flag (e.g. strtoul() in
C library function)?

  bool xb_find_next_set_bit(struct xb *xb, unsigned long start, unsigned long end, unsigned long *result);
  unsigned long xb_find_next_set_bit(struct xb *xb, unsigned long start, unsigned long end, bool *found);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
