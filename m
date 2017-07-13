Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BBF94440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 03:40:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j186so48943467pge.12
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 00:40:08 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a4si3862694plt.238.2017.07.13.00.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 00:40:07 -0700 (PDT)
Message-ID: <5967246B.9030804@intel.com>
Date: Thu, 13 Jul 2017 15:42:35 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 5/8] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com> <1499863221-16206-6-git-send-email-wei.w.wang@intel.com> <20170712160129-mutt-send-email-mst@kernel.org> <5966241C.9060503@intel.com> <20170712163746-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170712163746-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 07/12/2017 09:56 PM, Michael S. Tsirkin wrote:
>
> So the way I see it, there are several issues:
>
> - internal wait - forces multiple APIs like kick/kick_sync
>    note how kick_sync can fail but your code never checks return code
> - need to re-write the last descriptor - might not work
>    for alternative layouts which always expose descriptors
>    immediately

Probably it wasn't clear. Please let me explain the two functions here:

1) virtqueue_add_chain_desc(vq, head_id, prev_id,..):
grabs a desc from the vq and inserts it to the chain tail (which is 
indexed by
prev_id, probably better to call it tail_id). Then, the new added desc 
becomes
the tail (i.e. the last desc). The _F_NEXT flag is cleared for each desc 
when it's
added to the chain, and set when another desc comes to follow later.

2) virtqueue_add_chain(vq, head_id,..): expose the chain to the other end.

So, if people want to add a desc and immediately expose it to the other end,
i.e. build a single desc chain, they can just add and expose:

virtqueue_add_chain_desc(..);
virtqueue_add_chain(..,head_id);

Would you see any issues here?


> - some kind of iterator type would be nicer instead of
>    maintaining head/prev explicitly

Why would we need to iterate the chain? I think it would be simpler to use
a wrapper struct:

struct virtqueue_desc_chain {
     unsigned int head;  // head desc id of the chain
     unsigned int tail;     // tail desc id of the chain
}

The new desc will be put to desc[tail].next, and we don't need to walk
from the head desc[head].next when inserting a new desc to the chain, right?


>
> As for the use, it would be better to do
>
> if (!add_next(vq, ...)) {
> 	add_last(vq, ...)
> 	kick
> 	wait
> }

"!add_next(vq, ...)" means that the vq is full? If so, what would 
add_last() do then?


> Using VIRTQUEUE_DESC_ID_INIT seems to avoid a branch in the driver, but
> in fact it merely puts the branch in the virtio code.
>

Actually it wasn't intended to improve performance. It is used to 
indicate the "init" state
of the chain. So, when virtqueue_add_chain_desc(, head_id,..) finds head 
id=INIT, it will
assign the grabbed desc id to &head_id. In some sense, it is equivalent 
to add_first().

Do you have a different opinion here?

Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
