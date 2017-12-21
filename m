Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 296C36B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 09:38:02 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id d76so11047336oig.12
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 06:38:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 95si1854997otr.30.2017.12.21.06.38.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Dec 2017 06:38:00 -0800 (PST)
Subject: Re: [PATCH v20 3/7 RESEND] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1513823406-43632-1-git-send-email-wei.w.wang@intel.com>
	<20171221141805.GA27695@bombadil.infradead.org>
In-Reply-To: <20171221141805.GA27695@bombadil.infradead.org>
Message-Id: <201712212337.JFC57368.tLFOJFVSFHMOOQ@I-love.SAKURA.ne.jp>
Date: Thu, 21 Dec 2017 23:37:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com

Matthew Wilcox wrote:
> > +/**
> > + * xb_find_set - find the next set bit in a range of bits
> > + * @xb: the xbitmap to search from
> > + * @offset: the offset in the range to start searching
> > + * @size: the size of the range
> > + *
> > + * Returns: the found bit or, @size if no set bit is found.
> > + */
> > +unsigned long xb_find_set(struct xb *xb, unsigned long size,
> > +			  unsigned long offset)
> > +{
> > +	struct radix_tree_root *root = &xb->xbrt;
> > +	struct radix_tree_node *node;
> > +	void __rcu **slot;
> > +	struct ida_bitmap *bitmap;
> > +	unsigned long index = offset / IDA_BITMAP_BITS;
> > +	unsigned long index_end = size / IDA_BITMAP_BITS;
> > +	unsigned long bit = offset % IDA_BITMAP_BITS;
> > +
> > +	if (unlikely(offset >= size))
> > +		return size;
> > +
> > +	while (index <= index_end) {
> > +		unsigned long ret;
> > +		unsigned int nbits = size - index * IDA_BITMAP_BITS;
> > +
> > +		bitmap = __radix_tree_lookup(root, index, &node, &slot);
> > +
> > +		if (!node && !bitmap)
> > +			return size;
> > +
> > +		if (bitmap) {
> > +			if (nbits > IDA_BITMAP_BITS)
> > +				nbits = IDA_BITMAP_BITS;
> > +
> > +			ret = find_next_bit(bitmap->bitmap, nbits, bit);
> > +			if (ret != nbits)
> > +				return ret + index * IDA_BITMAP_BITS;
> > +		}
> > +		bit = 0;
> > +		index++;
> > +	}
> > +
> > +	return size;
> > +}
> > +EXPORT_SYMBOL(xb_find_set);
> 
> This is going to be slower than the implementation I sent yesterday.  If I
> call:
> 	xb_init(xb);
> 	xb_set_bit(xb, ULONG_MAX);
> 	xb_find_set(xb, ULONG_MAX, 0);
> 
> it's going to call __radix_tree_lookup() 16 quadrillion times.
> My implementation will walk the tree precisely once.
> 
Yes. Wei's patch still can not work.
We should start reviewing Matthew's implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
