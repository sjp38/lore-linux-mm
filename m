Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5661D440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:19:31 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g53so27568537qtc.6
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:19:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u19si5761515qka.294.2017.07.13.13.19.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 13:19:30 -0700 (PDT)
Date: Thu, 13 Jul 2017 23:19:22 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v12 5/8] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20170713210819-mutt-send-email-mst@kernel.org>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-6-git-send-email-wei.w.wang@intel.com>
 <20170712160129-mutt-send-email-mst@kernel.org>
 <5966241C.9060503@intel.com>
 <20170712163746-mutt-send-email-mst@kernel.org>
 <5967246B.9030804@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5967246B.9030804@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Thu, Jul 13, 2017 at 03:42:35PM +0800, Wei Wang wrote:
> On 07/12/2017 09:56 PM, Michael S. Tsirkin wrote:
> > 
> > So the way I see it, there are several issues:
> > 
> > - internal wait - forces multiple APIs like kick/kick_sync
> >    note how kick_sync can fail but your code never checks return code
> > - need to re-write the last descriptor - might not work
> >    for alternative layouts which always expose descriptors
> >    immediately
> 
> Probably it wasn't clear. Please let me explain the two functions here:
> 
> 1) virtqueue_add_chain_desc(vq, head_id, prev_id,..):
> grabs a desc from the vq and inserts it to the chain tail (which is indexed
> by
> prev_id, probably better to call it tail_id). Then, the new added desc
> becomes
> the tail (i.e. the last desc). The _F_NEXT flag is cleared for each desc
> when it's
> added to the chain, and set when another desc comes to follow later.

And this only works if there are multiple rings like
avail + descriptor ring.
It won't work e.g. with the proposed new layout where
writing out a descriptor exposes it immediately.

> 2) virtqueue_add_chain(vq, head_id,..): expose the chain to the other end.
> 
> So, if people want to add a desc and immediately expose it to the other end,
> i.e. build a single desc chain, they can just add and expose:
> 
> virtqueue_add_chain_desc(..);
> virtqueue_add_chain(..,head_id);
> 
> Would you see any issues here?

The way the new APIs poll used ring internally.

> 
> > - some kind of iterator type would be nicer instead of
> >    maintaining head/prev explicitly
> 
> Why would we need to iterate the chain?

In your patches prev/tail are iterators - they keep track of
where you are in the chain.

> I think it would be simpler to use
> a wrapper struct:
> 
> struct virtqueue_desc_chain {
>     unsigned int head;  // head desc id of the chain
>     unsigned int tail;     // tail desc id of the chain
> }
> 
> The new desc will be put to desc[tail].next, and we don't need to walk
> from the head desc[head].next when inserting a new desc to the chain, right?
> 
> 
> > 
> > As for the use, it would be better to do
> > 
> > if (!add_next(vq, ...)) {
> > 	add_last(vq, ...)
> > 	kick
> > 	wait
> > }
> 
> "!add_next(vq, ...)" means that the vq is full?


No - it means there's only 1 entry left for the last descriptor.


> If so, what would add_last()
> do then?
> 
> > Using VIRTQUEUE_DESC_ID_INIT seems to avoid a branch in the driver, but
> > in fact it merely puts the branch in the virtio code.
> > 
> 
> Actually it wasn't intended to improve performance. It is used to indicate
> the "init" state
> of the chain. So, when virtqueue_add_chain_desc(, head_id,..) finds head
> id=INIT, it will
> assign the grabbed desc id to &head_id. In some sense, it is equivalent to
> add_first().
> 
> Do you have a different opinion here?
> 
> Best,
> Wei
> 

It is but let's make it explicit here - an API function is better
than a special value.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
