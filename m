Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8164C4408E5
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 03:10:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d62so79491827pfb.13
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 00:10:13 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id g9si6071421plk.482.2017.07.14.00.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 00:10:12 -0700 (PDT)
Message-ID: <59686EEB.8080805@intel.com>
Date: Fri, 14 Jul 2017 15:12:43 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 5/8] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com> <1499863221-16206-6-git-send-email-wei.w.wang@intel.com> <20170712160129-mutt-send-email-mst@kernel.org> <5966241C.9060503@intel.com> <20170712163746-mutt-send-email-mst@kernel.org> <5967246B.9030804@intel.com> <20170713210819-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170713210819-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 07/14/2017 04:19 AM, Michael S. Tsirkin wrote:
> On Thu, Jul 13, 2017 at 03:42:35PM +0800, Wei Wang wrote:
>> On 07/12/2017 09:56 PM, Michael S. Tsirkin wrote:
>>> So the way I see it, there are several issues:
>>>
>>> - internal wait - forces multiple APIs like kick/kick_sync
>>>     note how kick_sync can fail but your code never checks return code
>>> - need to re-write the last descriptor - might not work
>>>     for alternative layouts which always expose descriptors
>>>     immediately
>> Probably it wasn't clear. Please let me explain the two functions here:
>>
>> 1) virtqueue_add_chain_desc(vq, head_id, prev_id,..):
>> grabs a desc from the vq and inserts it to the chain tail (which is indexed
>> by
>> prev_id, probably better to call it tail_id). Then, the new added desc
>> becomes
>> the tail (i.e. the last desc). The _F_NEXT flag is cleared for each desc
>> when it's
>> added to the chain, and set when another desc comes to follow later.
> And this only works if there are multiple rings like
> avail + descriptor ring.
> It won't work e.g. with the proposed new layout where
> writing out a descriptor exposes it immediately.

I think it can support the 1.1 proposal, too. But before getting
into that, I think we first need to deep dive into the implementation
and usage of _first/next/last. The usage would need to lock the vq
from the first to the end (otherwise, the returned info about the number
of available desc in the vq, i.e. num_free, would be invalid):

lock(vq);
add_first();
add_next();
add_last();
unlock(vq);

However, I think the case isn't this simple, since we need to check more 
things
after each add_xx() step. For example, if only one entry is available at 
the time
we start to use the vq, that is, num_free is 0 after add_first(), we 
wouldn't be
able to add_next and add_last. So, it would work like this:

start:
     ...get free page block..
     lock(vq)
retry:
     ret = add_first(..,&num_free,);
     if(ret == -ENOSPC) {
         goto retry;
     } else if (!num_free) {
         add_chain_head();
         unlock(vq);
         kick & wait;
         goto start;
     }
next_one:
     ...get free page block..
     add_next(..,&num_free,);
     if (!num_free) {
         add_chain_head();
         unlock(vq);
         kick & wait;
         goto start;
     } if (num_free == 1) {
         ...get free page block..
         add_last(..);
         unlock(vq);
         kick & wait;
         goto start;
     } else {
         goto next_one;
     }

The above seems unnecessary to me to have three different APIs.
That's the reason to combine them into one virtqueue_add_chain_desc().

-- or, do you have a different thought about using the three APIs?


Implementation Reference:

struct desc_iterator {
     unsigned int head;
     unsigned int tail;
};

add_first(*vq, *desc_iterator, *num_free, ..)
{
     if (vq->vq.num_free < 1)
         return -ENOSPC;
     get_desc(&desc_id);
     desc[desc_id].flag &= ~_F_NEXT;
     desc_iterator->head = desc_id
     desc_iterator->tail = desc_iterator->head;
     *num_free = vq->vq.num_free;
}

add_next(vq, desc_iterator, *num_free,..)
{
     get_desc(&desc_id);
     desc[desc_id].flag &= ~_F_NEXT;
     desc[desc_iterator.tail].next = desc_id;
     desc[desc_iterator->tail].flag |= _F_NEXT;
     desc_iterator->tail = desc_id;
     *num_free = vq->vq.num_free;
}

add_last(vq, desc_iterator,..)
{
     get_desc(&desc_id);
     desc[desc_id].flag &= ~_F_NEXT;
     desc[desc_iterator.tail].next = desc_id;
     desc_iterator->tail = desc_id;

     add_chain_head(); // put the desc_iterator.head to the ring
}


Best,
Wei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
