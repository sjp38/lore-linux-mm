Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4424B6B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 06:56:37 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id h200so2347453oib.18
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 03:56:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u73si2847421oie.335.2017.11.03.03.56.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 03:56:35 -0700 (PDT)
Subject: Re: [PATCH v17 1/6] lib/xbitmap: Introduce xbitmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com>
	<1509696786-1597-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1509696786-1597-2-git-send-email-wei.w.wang@intel.com>
Message-Id: <201711031955.FFE57823.VFLMFtFJSOOQHO@I-love.SAKURA.ne.jp>
Date: Fri, 3 Nov 2017 19:55:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

I'm commenting without understanding the logic.

Wei Wang wrote:
> +
> +bool xb_preload(gfp_t gfp);
> +

Want __must_check annotation, for __radix_tree_preload() is marked
with __must_check annotation. By error failing to check result of
xb_preload() will lead to preemption kept disabled unexpectedly.



> +int xb_set_bit(struct xb *xb, unsigned long bit)
> +{
> +	int err;
> +	unsigned long index = bit / IDA_BITMAP_BITS;
> +	struct radix_tree_root *root = &xb->xbrt;
> +	struct radix_tree_node *node;
> +	void **slot;
> +	struct ida_bitmap *bitmap;
> +	unsigned long ebit;
> +
> +	bit %= IDA_BITMAP_BITS;
> +	ebit = bit + 2;
> +
> +	err = __radix_tree_create(root, index, 0, &node, &slot);
> +	if (err)
> +		return err;
> +	bitmap = rcu_dereference_raw(*slot);
> +	if (radix_tree_exception(bitmap)) {
> +		unsigned long tmp = (unsigned long)bitmap;
> +
> +		if (ebit < BITS_PER_LONG) {
> +			tmp |= 1UL << ebit;
> +			rcu_assign_pointer(*slot, (void *)tmp);
> +			return 0;
> +		}
> +		bitmap = this_cpu_xchg(ida_bitmap, NULL);
> +		if (!bitmap)

Please write locking rules, in order to explain how memory
allocated by __radix_tree_create() will not leak.

> +			return -EAGAIN;
> +		memset(bitmap, 0, sizeof(*bitmap));
> +		bitmap->bitmap[0] = tmp >> RADIX_TREE_EXCEPTIONAL_SHIFT;
> +		rcu_assign_pointer(*slot, bitmap);
> +	}
> +
> +	if (!bitmap) {
> +		if (ebit < BITS_PER_LONG) {
> +			bitmap = (void *)((1UL << ebit) |
> +					RADIX_TREE_EXCEPTIONAL_ENTRY);
> +			__radix_tree_replace(root, node, slot, bitmap, NULL,
> +						NULL);
> +			return 0;
> +		}
> +		bitmap = this_cpu_xchg(ida_bitmap, NULL);
> +		if (!bitmap)

Same here.

> +			return -EAGAIN;
> +		memset(bitmap, 0, sizeof(*bitmap));
> +		__radix_tree_replace(root, node, slot, bitmap, NULL, NULL);
> +	}
> +
> +	__set_bit(bit, bitmap->bitmap);
> +	return 0;
> +}



> +void xb_clear_bit(struct xb *xb, unsigned long bit)
> +{
> +	unsigned long index = bit / IDA_BITMAP_BITS;
> +	struct radix_tree_root *root = &xb->xbrt;
> +	struct radix_tree_node *node;
> +	void **slot;
> +	struct ida_bitmap *bitmap;
> +	unsigned long ebit;
> +
> +	bit %= IDA_BITMAP_BITS;
> +	ebit = bit + 2;
> +
> +	bitmap = __radix_tree_lookup(root, index, &node, &slot);
> +	if (radix_tree_exception(bitmap)) {
> +		unsigned long tmp = (unsigned long)bitmap;
> +
> +		if (ebit >= BITS_PER_LONG)
> +			return;
> +		tmp &= ~(1UL << ebit);
> +		if (tmp == RADIX_TREE_EXCEPTIONAL_ENTRY)
> +			__radix_tree_delete(root, node, slot);
> +		else
> +			rcu_assign_pointer(*slot, (void *)tmp);
> +		return;
> +	}
> +
> +	if (!bitmap)
> +		return;
> +
> +	__clear_bit(bit, bitmap->bitmap);
> +	if (bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {

Please write locking rules, in order to explain how double kfree() and/or
use-after-free can be avoided.

> +		kfree(bitmap);
> +		__radix_tree_delete(root, node, slot);
> +	}
> +}



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
> +				bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {

Same here.

> +				kfree(bitmap);
> +				__radix_tree_delete(root, node, slot);
> +			}
> +		}
> +	}
> +}



> +bool xb_test_bit(struct xb *xb, unsigned long bit)
> +{
> +	unsigned long index = bit / IDA_BITMAP_BITS;
> +	const struct radix_tree_root *root = &xb->xbrt;
> +	struct ida_bitmap *bitmap = radix_tree_lookup(root, index);
> +
> +	bit %= IDA_BITMAP_BITS;
> +
> +	if (!bitmap)
> +		return false;
> +	if (radix_tree_exception(bitmap)) {
> +		bit += RADIX_TREE_EXCEPTIONAL_SHIFT;
> +		if (bit > BITS_PER_LONG)

Why not bit >= BITS_PER_LONG here?

> +			return false;
> +		return (unsigned long)bitmap & (1UL << bit);
> +	}
> +
> +	return test_bit(bit, bitmap->bitmap);
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
