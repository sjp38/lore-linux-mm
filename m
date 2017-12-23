Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3796B0277
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 22:30:14 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id j6so14641273pll.4
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 19:30:14 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 31si17600373plj.389.2017.12.22.19.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Dec 2017 19:30:13 -0800 (PST)
Date: Fri, 22 Dec 2017 19:29:59 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v20 3/7 RESEND] xbitmap: add more operations
Message-ID: <20171223032959.GA11578@bombadil.infradead.org>
References: <1513823406-43632-1-git-send-email-wei.w.wang@intel.com>
 <20171221210327.GB25009@bombadil.infradead.org>
 <201712231159.ECI73411.tFFFJOHOVMOLQS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712231159.ECI73411.tFFFJOHOVMOLQS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com

On Sat, Dec 23, 2017 at 11:59:54AM +0900, Tetsuo Handa wrote:
> Matthew Wilcox wrote:
> > +	bit %= IDA_BITMAP_BITS;
> > +	radix_tree_iter_init(&iter, index);
> > +	slot = idr_get_free_cmn(root, &iter, GFP_NOWAIT | __GFP_NOWARN, index);
> > +	if (IS_ERR(slot)) {
> > +		if (slot == ERR_PTR(-ENOSPC))
> > +			return 0;	/* Already set */
> 
> Why already set? I guess something is there, but is it guaranteed that
> there is a bitmap with the "bit" set?

Yes.  For radix trees tagged with IDR_RT_MARKER, newly created slots
have the IDR_FREE tag set.  We only clear the IDR_FREE tag once the
bitmap is full.  So if we try to find a free slot and the tag is clear,
we know the bitmap is full.

> > +	bitmap = rcu_dereference_raw(*slot);
> > +	if (!bitmap) {
> > +		bitmap = this_cpu_xchg(ida_bitmap, NULL);
> > +		if (!bitmap)
> > +			return -ENOMEM;
> 
> I can't understand this. I can understand if it were
> 
>   BUG_ON(!bitmap);
> 
> because you called xb_preload().
> 
> But
> 
> 	/*
> 	 * Regular test 2
> 	 * set bit 2000, 2001, 2040
> 	 * Next 1 in [0, 2048)		--> 2000
> 	 * Next 1 in [2000, 2002)	--> 2000
> 	 * Next 1 in [2002, 2041)	--> 2040
> 	 * Next 1 in [2002, 2040)	--> none
> 	 * Next 0 in [2000, 2048)	--> 2002
> 	 * Next 0 in [2048, 2060)	--> 2048
> 	 */
> 	xb_preload(GFP_KERNEL);
> 	assert(!xb_set_bit(&xb1, 2000));
> 	assert(!xb_set_bit(&xb1, 2001));
> 	assert(!xb_set_bit(&xb1, 2040));
[...]
> 	xb_preload_end();
> 
> you are not calling xb_preload() prior to each xb_set_bit() call.
> This means that, if each xb_set_bit() is not surrounded with
> xb_preload()/xb_preload_end(), there is possibility of hitting
> this_cpu_xchg(ida_bitmap, NULL) == NULL.

This is just a lazy test.  We "know" that the bits in the range 1024-2047
will all land in the same bitmap, so there's no need to preload for each
of them.

> If bitmap == NULL at this_cpu_xchg(ida_bitmap, NULL) is allowed,
> you can use kzalloc(sizeof(*bitmap), GFP_NOWAIT | __GFP_NOWARN)
> and get rid of xb_preload()/xb_preload_end().

No, we can't.  GFP_NOWAIT | __GFP_NOWARN won't try very hard to allocate
memory.  There's no reason to fail the call if the user is in a context
where they can try harder to free memory.

> You are using idr_get_free_cmn(GFP_NOWAIT | __GFP_NOWARN), which
> means that the caller has to be prepared for allocation failure
> when calling xb_set_bit(). Thus, there is no need to use preload
> in order to avoid failing to allocate "bitmap".

xb_preload also preloads radix tree nodes.

> Also, please clarify why it is OK to just return here.
> I don't know what
> 
>   radix_tree_iter_replace(root, &iter, slot, bitmap);
> 
> is doing. If you created a slot but did not assign "bitmap",
> what the caller of xb_test_bit() etc. will find? If there is an
> assumption about this slot, won't this cause a problem?

xb_test_bit will find NULL if bitmap wasn't assigned.  That doesn't
harm anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
