Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0719C6B0253
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 09:59:10 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 8so21598818pfv.12
        for <linux-mm@kvack.org>; Sat, 23 Dec 2017 06:59:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 1si15597672plw.572.2017.12.23.06.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 23 Dec 2017 06:59:08 -0800 (PST)
Date: Sat, 23 Dec 2017 06:58:59 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v20 3/7 RESEND] xbitmap: add more operations
Message-ID: <20171223145859.GA24464@bombadil.infradead.org>
References: <1513823406-43632-1-git-send-email-wei.w.wang@intel.com>
 <20171221210327.GB25009@bombadil.infradead.org>
 <201712231159.ECI73411.tFFFJOHOVMOLQS@I-love.SAKURA.ne.jp>
 <20171223032959.GA11578@bombadil.infradead.org>
 <201712232333.BAH82874.FFFtOMHSLVQOOJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712232333.BAH82874.FFFtOMHSLVQOOJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com

On Sat, Dec 23, 2017 at 11:33:45PM +0900, Tetsuo Handa wrote:
> Matthew Wilcox wrote:
> > On Sat, Dec 23, 2017 at 11:59:54AM +0900, Tetsuo Handa wrote:
> > > Matthew Wilcox wrote:
> > > > +	bit %= IDA_BITMAP_BITS;
> > > > +	radix_tree_iter_init(&iter, index);
> > > > +	slot = idr_get_free_cmn(root, &iter, GFP_NOWAIT | __GFP_NOWARN, index);
> > > > +	if (IS_ERR(slot)) {
> > > > +		if (slot == ERR_PTR(-ENOSPC))
> > > > +			return 0;	/* Already set */
> > > 
> > > Why already set? I guess something is there, but is it guaranteed that
> > > there is a bitmap with the "bit" set?
> > 
> > Yes.  For radix trees tagged with IDR_RT_MARKER, newly created slots
> > have the IDR_FREE tag set.  We only clear the IDR_FREE tag once the
> > bitmap is full.  So if we try to find a free slot and the tag is clear,
> > we know the bitmap is full.
> > 
> 
> OK. But does using IDR_FREE tag have more benefit than cost?
> You are doing
> 
> 	if (bitmap_full(bitmap->bitmap, IDA_BITMAP_BITS))
> 		radix_tree_iter_tag_clear(root, &iter, IDR_FREE);
> 
> for each xb_set_bit() call. How likely do we hit ERR_PTR(-ENOSPC) path?
> Isn't removing both bitmap_full() and ERR_PTR(-ENOSPC) better?

You're assuming that the purpose of using IDR_FREE is to save xb_set_bit
from walking the tree unnecessarily.  It isn't; that's just a happy
side-effect.  Its main purpose is to make xb_find_zero() efficient.  If
we have large ranges of set bits, xb_find_zero() will be able to skip them.

> > This is just a lazy test.  We "know" that the bits in the range 1024-2047
> > will all land in the same bitmap, so there's no need to preload for each
> > of them.
> 
> Testcases also serves as how to use that API.
> Assuming such thing leads to incorrect usage.

Sure.  Would you like to submit a patch?

> > > If bitmap == NULL at this_cpu_xchg(ida_bitmap, NULL) is allowed,
> > > you can use kzalloc(sizeof(*bitmap), GFP_NOWAIT | __GFP_NOWARN)
> > > and get rid of xb_preload()/xb_preload_end().
> > 
> > No, we can't.  GFP_NOWAIT | __GFP_NOWARN won't try very hard to allocate
> > memory.  There's no reason to fail the call if the user is in a context
> > where they can try harder to free memory.
> 
> But there is no reason to use GFP_NOWAIT at idr_get_free_cmn() if it is
> safe to use GFP_KERNEL. If we don't require xb_preload() which forces
> idr_get_free_cmn() to use GFP_NOWAIT due to possibility of preemption
> disabled by xb_preload(), we can allow passing gfp flags to xb_set_bit().

The assumption is that the user has done:

	xb_preload(GFP_KERNEL);
	spin_lock(my_lock);
	xb_set_bit(xb, bit);
	spin_unlock(my_lock);
	xb_preload_end();

This is not the world's greatest interface.  Once I have the XArray
finished, we'll be able to ditch the external spinlock and the preload
interface and be able to call:

	xb_set_bit(xb, bit, GFP_KERNEL);

> > xb_preload also preloads radix tree nodes.
> 
> But it after all forces idr_get_free_cmn() to use GFP_NOWAIT, doesn't it?

I think you don't understand how the radix tree allocates nodes.  preloading
means that it will be able to access the nodes which were allocated earlier.

> Speak of initial user (i.e. virtio-balloon), xb_preload() won't be able to
> use GFP_KERNEL in order to avoid OOM lockup. Therefore, I don't see
> advantages with using xb_preload(). If xb_set_bit() receives gfp flags,
> the caller can pass GFP_KERNEL if it is safe to use GFP_KERNEL.

I haven't reviewed how virtio-balloon is using the interfaces.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
