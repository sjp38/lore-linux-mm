Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD386B0292
	for <linux-mm@kvack.org>; Sat, 22 Jul 2017 21:45:27 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f196so3249393oic.3
        for <linux-mm@kvack.org>; Sat, 22 Jul 2017 18:45:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s64si3059680oif.357.2017.07.22.18.45.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jul 2017 18:45:26 -0700 (PDT)
Date: Sun, 23 Jul 2017 04:45:19 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v12 5/8] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20170723044036-mutt-send-email-mst@kernel.org>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-6-git-send-email-wei.w.wang@intel.com>
 <20170712160129-mutt-send-email-mst@kernel.org>
 <5966241C.9060503@intel.com>
 <20170712163746-mutt-send-email-mst@kernel.org>
 <5967246B.9030804@intel.com>
 <20170713210819-mutt-send-email-mst@kernel.org>
 <59686EEB.8080805@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59686EEB.8080805@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Fri, Jul 14, 2017 at 03:12:43PM +0800, Wei Wang wrote:
> On 07/14/2017 04:19 AM, Michael S. Tsirkin wrote:
> > On Thu, Jul 13, 2017 at 03:42:35PM +0800, Wei Wang wrote:
> > > On 07/12/2017 09:56 PM, Michael S. Tsirkin wrote:
> > > > So the way I see it, there are several issues:
> > > > 
> > > > - internal wait - forces multiple APIs like kick/kick_sync
> > > >     note how kick_sync can fail but your code never checks return code
> > > > - need to re-write the last descriptor - might not work
> > > >     for alternative layouts which always expose descriptors
> > > >     immediately
> > > Probably it wasn't clear. Please let me explain the two functions here:
> > > 
> > > 1) virtqueue_add_chain_desc(vq, head_id, prev_id,..):
> > > grabs a desc from the vq and inserts it to the chain tail (which is indexed
> > > by
> > > prev_id, probably better to call it tail_id). Then, the new added desc
> > > becomes
> > > the tail (i.e. the last desc). The _F_NEXT flag is cleared for each desc
> > > when it's
> > > added to the chain, and set when another desc comes to follow later.
> > And this only works if there are multiple rings like
> > avail + descriptor ring.
> > It won't work e.g. with the proposed new layout where
> > writing out a descriptor exposes it immediately.
> 
> I think it can support the 1.1 proposal, too. But before getting
> into that, I think we first need to deep dive into the implementation
> and usage of _first/next/last. The usage would need to lock the vq
> from the first to the end (otherwise, the returned info about the number
> of available desc in the vq, i.e. num_free, would be invalid):
> 
> lock(vq);
> add_first();
> add_next();
> add_last();
> unlock(vq);
> 
> However, I think the case isn't this simple, since we need to check more
> things
> after each add_xx() step. For example, if only one entry is available at the
> time
> we start to use the vq, that is, num_free is 0 after add_first(), we
> wouldn't be
> able to add_next and add_last. So, it would work like this:
> 
> start:
>     ...get free page block..
>     lock(vq)
> retry:
>     ret = add_first(..,&num_free,);
>     if(ret == -ENOSPC) {
>         goto retry;
>     } else if (!num_free) {
>         add_chain_head();
>         unlock(vq);
>         kick & wait;
>         goto start;
>     }
> next_one:
>     ...get free page block..
>     add_next(..,&num_free,);
>     if (!num_free) {
>         add_chain_head();
>         unlock(vq);
>         kick & wait;
>         goto start;
>     } if (num_free == 1) {
>         ...get free page block..
>         add_last(..);
>         unlock(vq);
>         kick & wait;
>         goto start;
>     } else {
>         goto next_one;
>     }
> 
> The above seems unnecessary to me to have three different APIs.
> That's the reason to combine them into one virtqueue_add_chain_desc().
> 
> -- or, do you have a different thought about using the three APIs?
> 
> 
> Implementation Reference:
> 
> struct desc_iterator {
>     unsigned int head;
>     unsigned int tail;
> };
> 
> add_first(*vq, *desc_iterator, *num_free, ..)
> {
>     if (vq->vq.num_free < 1)
>         return -ENOSPC;
>     get_desc(&desc_id);
>     desc[desc_id].flag &= ~_F_NEXT;
>     desc_iterator->head = desc_id
>     desc_iterator->tail = desc_iterator->head;
>     *num_free = vq->vq.num_free;
> }
> 
> add_next(vq, desc_iterator, *num_free,..)
> {
>     get_desc(&desc_id);
>     desc[desc_id].flag &= ~_F_NEXT;
>     desc[desc_iterator.tail].next = desc_id;
>     desc[desc_iterator->tail].flag |= _F_NEXT;
>     desc_iterator->tail = desc_id;
>     *num_free = vq->vq.num_free;
> }
> 
> add_last(vq, desc_iterator,..)
> {
>     get_desc(&desc_id);
>     desc[desc_id].flag &= ~_F_NEXT;
>     desc[desc_iterator.tail].next = desc_id;
>     desc_iterator->tail = desc_id;
> 
>     add_chain_head(); // put the desc_iterator.head to the ring
> }
> 
> 
> Best,
> Wei

OK I thought this over. While we might need these new APIs in
the future, I think that at the moment, there's a way to implement
this feature that is significantly simpler. Just add each s/g
as a separate input buffer.

This needs zero new APIs.

I know that follow-up patches need to add a header in front
so you might be thinking: how am I going to add this
header? The answer is quite simple - add it as a separate
out header.

Host will be able to distinguish between header and pages
by looking at the direction, and - should we want to add
IN data to header - additionally size (<4K => header).

We will be able to look at extended APIs separately down
the road.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
