Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 839226B0275
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 22:00:05 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id w189so14745683iof.18
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 19:00:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c16si6695883iod.254.2017.12.22.19.00.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Dec 2017 19:00:03 -0800 (PST)
Subject: Re: [PATCH v20 3/7 RESEND] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1513823406-43632-1-git-send-email-wei.w.wang@intel.com>
	<20171221210327.GB25009@bombadil.infradead.org>
In-Reply-To: <20171221210327.GB25009@bombadil.infradead.org>
Message-Id: <201712231159.ECI73411.tFFFJOHOVMOLQS@I-love.SAKURA.ne.jp>
Date: Sat, 23 Dec 2017 11:59:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com

Matthew Wilcox wrote:
> +/**
> + * xb_set_bit() - Set a bit in the XBitmap.
> + * @xb: The XBitmap.
> + * @bit: Index of the bit to set.
> + *
> + * This function is used to set a bit in the xbitmap.
> + *
> + * Return: 0 on success. -ENOMEM if memory could not be allocated.
> + */
> +int xb_set_bit(struct xb *xb, unsigned long bit)
> +{
> +	unsigned long index = bit / IDA_BITMAP_BITS;
> +	struct radix_tree_root *root = &xb->xbrt;
> +	struct radix_tree_iter iter;
> +	void __rcu **slot;
> +	struct ida_bitmap *bitmap;
> +
> +	bit %= IDA_BITMAP_BITS;
> +	radix_tree_iter_init(&iter, index);
> +	slot = idr_get_free_cmn(root, &iter, GFP_NOWAIT | __GFP_NOWARN, index);
> +	if (IS_ERR(slot)) {
> +		if (slot == ERR_PTR(-ENOSPC))
> +			return 0;	/* Already set */

Why already set? I guess something is there, but is it guaranteed that
there is a bitmap with the "bit" set?

> +		return -ENOMEM;
> +	}
> +	bitmap = rcu_dereference_raw(*slot);
> +	if (!bitmap) {
> +		bitmap = this_cpu_xchg(ida_bitmap, NULL);
> +		if (!bitmap)
> +			return -ENOMEM;

I can't understand this. I can understand if it were

  BUG_ON(!bitmap);

because you called xb_preload().

But

	/*
	 * Regular test 2
	 * set bit 2000, 2001, 2040
	 * Next 1 in [0, 2048)		--> 2000
	 * Next 1 in [2000, 2002)	--> 2000
	 * Next 1 in [2002, 2041)	--> 2040
	 * Next 1 in [2002, 2040)	--> none
	 * Next 0 in [2000, 2048)	--> 2002
	 * Next 0 in [2048, 2060)	--> 2048
	 */
	xb_preload(GFP_KERNEL);
	assert(!xb_set_bit(&xb1, 2000));
	assert(!xb_set_bit(&xb1, 2001));
	assert(!xb_set_bit(&xb1, 2040));
	nbit = 0;
	assert(xb_find_set(&xb1, 2048, &nbit) == true);
	assert(nbit == 2000);
	assert(xb_find_set(&xb1, 2002, &nbit) == true);
	assert(nbit == 2000);
	nbit = 2002;
	assert(xb_find_set(&xb1, 2041, &nbit) == true);
	assert(nbit == 2040);
	nbit = 2002;
	assert(xb_find_set(&xb1, 2040, &nbit) == true);
	assert(nbit == 2040);
	nbit = 2000;
	assert(xb_find_zero(&xb1, 2048, &nbit) == true);
	assert(nbit == 2002);
	nbit = 2048;
	assert(xb_find_zero(&xb1, 2060, &nbit) == true);
	assert(nbit == 2048);
	xb_zero(&xb1, 0, 2047);
	nbit = 0;
	assert(xb_find_set(&xb1, 2048, &nbit) == false);
	assert(nbit == 0);
	xb_preload_end();

you are not calling xb_preload() prior to each xb_set_bit() call.
This means that, if each xb_set_bit() is not surrounded with
xb_preload()/xb_preload_end(), there is possibility of hitting
this_cpu_xchg(ida_bitmap, NULL) == NULL.

If bitmap == NULL at this_cpu_xchg(ida_bitmap, NULL) is allowed,
you can use kzalloc(sizeof(*bitmap), GFP_NOWAIT | __GFP_NOWARN)
and get rid of xb_preload()/xb_preload_end().

You are using idr_get_free_cmn(GFP_NOWAIT | __GFP_NOWARN), which
means that the caller has to be prepared for allocation failure
when calling xb_set_bit(). Thus, there is no need to use preload
in order to avoid failing to allocate "bitmap".



Also, please clarify why it is OK to just return here.
I don't know what

  radix_tree_iter_replace(root, &iter, slot, bitmap);

is doing. If you created a slot but did not assign "bitmap",
what the caller of xb_test_bit() etc. will find? If there is an
assumption about this slot, won't this cause a problem?

> +		memset(bitmap, 0, sizeof(*bitmap));
> +		radix_tree_iter_replace(root, &iter, slot, bitmap);
> +	}
> +
> +	__set_bit(bit, bitmap->bitmap);
> +	if (bitmap_full(bitmap->bitmap, IDA_BITMAP_BITS))
> +		radix_tree_iter_tag_clear(root, &iter, IDR_FREE);
> +	return 0;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
