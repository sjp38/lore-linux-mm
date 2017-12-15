Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48C226B025E
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 13:49:33 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i7so7573894pgq.7
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 10:49:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w9si5282815plp.783.2017.12.15.10.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 10:49:31 -0800 (PST)
Date: Fri, 15 Dec 2017 10:49:15 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
Message-ID: <20171215184915.GB27160@bombadil.infradead.org>
References: <5A311C5E.7000304@intel.com>
 <201712132316.EJJ57332.MFOSJHOFFVLtQO@I-love.SAKURA.ne.jp>
 <5A31F445.6070504@intel.com>
 <201712150129.BFC35949.FFtFOLSOJOQHVM@I-love.SAKURA.ne.jp>
 <20171214181219.GA26124@bombadil.infradead.org>
 <201712160121.BEJ26052.HOFFOOQFMLtSVJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712160121.BEJ26052.HOFFOOQFMLtSVJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On Sat, Dec 16, 2017 at 01:21:52AM +0900, Tetsuo Handa wrote:
> My understanding is that virtio-balloon wants to handle sparsely spreaded
> unsigned long values (which is PATCH 4/7) and wants to find all chunks of
> consecutive "1" bits efficiently. Therefore, I guess that holding the values
> in ascending order at store time is faster than sorting the values at read
> time. I don't know how to use radix tree API, but I think that B+ tree API
> suits for holding the values in ascending order.
> 
> We wait for Wei to post radix tree version combined into one patch and then
> compare performance between radix tree version and B+ tree version (shown
> below)?

Sure.  We all benefit from some friendly competition.  Even if a
competition between trees might remind one of the Entmoot ;-)

But let's not hold back -- let's figure out some good workloads to use
in our competition.  And we should also decide on the API / locking
constraints.  And of course we should compete based on not just speed,
but also memory consumption (both as a runtime overhead for a given set
of bits and as code size).  If you can replace the IDR, you get to count
that savings against the cost of your implementation.

Here's the API I'm looking at right now.  The user need take no lock;
the locking (spinlock) is handled internally to the implementation.

void xbit_init(struct xbitmap *xb);
int xbit_alloc(struct xbitmap *, unsigned long bit, gfp_t);
int xbit_alloc_range(struct xbitmap *, unsigned long start,
                        unsigned long nbits, gfp_t);
int xbit_set(struct xbitmap *, unsigned long bit, gfp_t);
bool xbit_test(struct xbitmap *, unsigned long bit);
int xbit_clear(struct xbitmap *, unsigned long bit);
int xbit_zero(struct xbitmap *, unsigned long start, unsigned long nbits);
int xbit_fill(struct xbitmap *, unsigned long start, unsigned long nbits,
                        gfp_t);
unsigned long xbit_find_clear(struct xbitmap *, unsigned long start,
                        unsigned long max);
unsigned long xbit_find_set(struct xbitmap *, unsigned long start,
                        unsigned long max);

> static bool set_ulong(struct ulong_list_head *head, const unsigned long value)
> {
> 	if (!ptr) {
> 		ptr = kzalloc(sizeof(*ptr), GFP_NOWAIT | __GFP_NOWARN);
> 		if (!ptr)
> 			goto out1;
> 		ptr->bitmap = kzalloc(BITMAP_LEN / 8,
> 				      GFP_NOWAIT | __GFP_NOWARN);
> 		if (!ptr->bitmap)
> 			goto out2;
> 		if (btree_insertl(&head->btree, ~segment, ptr,
> 				   GFP_NOWAIT | __GFP_NOWARN))
> 			goto out3;
> out3:
> 	kfree(ptr->bitmap);
> out2:
> 	kfree(ptr);
> out1:
> 	return false;
> }

And what is the user supposed to do if this returns false?  How do they
make headway?  The xb_ API is clear -- you call xb_prealloc and that
ensures forward progress.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
