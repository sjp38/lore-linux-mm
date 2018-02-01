Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C1F6E6B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 04:40:53 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m3so13226798pgd.20
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 01:40:53 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e6-v6si959090plo.702.2018.02.01.01.40.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 01:40:52 -0800 (PST)
Message-ID: <5A72E13A.9030701@intel.com>
Date: Thu, 01 Feb 2018 17:43:22 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v25 2/2] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1516871646-22741-1-git-send-email-wei.w.wang@intel.com> <1516871646-22741-3-git-send-email-wei.w.wang@intel.com> <20180125154708-mutt-send-email-mst@kernel.org> <5A6A871C.6040408@intel.com> <20180126042649-mutt-send-email-mst@kernel.org> <5A6AA107.3000607@intel.com> <20180131011423-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180131011423-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>

On 01/31/2018 07:44 AM, Michael S. Tsirkin wrote:
> On Fri, Jan 26, 2018 at 11:31:19AM +0800, Wei Wang wrote:
>> On 01/26/2018 10:42 AM, Michael S. Tsirkin wrote:
>>> On Fri, Jan 26, 2018 at 09:40:44AM +0800, Wei Wang wrote:
>>>> On 01/25/2018 09:49 PM, Michael S. Tsirkin wrote:
>>>>> On Thu, Jan 25, 2018 at 05:14:06PM +0800, Wei Wang wrote:
>>>>>
>>>> The controversy is that the free list is not static
>>>> once the lock is dropped, so everything is dynamically changing, including
>>>> the state that was recorded. The method we are using is more prudent, IMHO.
>>>> How about taking the fundamental solution, and seek to improve incrementally
>>>> in the future?
>>>>
>>>>
>>>> Best,
>>>> Wei
>>> I'd like to see kicks happen outside the spinlock. kick with a spinlock
>>> taken looks like a scalability issue that won't be easy to
>>> reproduce but hurt workloads at random unexpected times.
>>>
>> Is that "kick inside the spinlock" the only concern you have? I think we can
>> remove the kick actually. If we check how the host side works, it is
>> worthwhile to let the host poll the virtqueue after it receives the cmd id
>> from the guest (kick for cmd id isn't within the lock).
>>
>>
>> Best,
>> Wei
> So really there are different ways to put free page hints to use.
>
> The current interface requires host to do dirty tracking
> for all memory, and it's more or less useless for
> things like freeing host memory.
>
> So while your project's needs seem to be addressed, I'm
> still a bit disappointed that so little collaboration
> happened with e.g. Nitesh's project, to the point where
> you don't even CC him on patches.

Isn't "nilal@redhat.com" Nitesh? Actually it's been cc-ed long time ago.

I think we should at least see the performance numbers and a working 
prototype from them (I remember they lack the host side implementation).

Btw, this feature is requested by many customers of Linux (not our own 
project's need). They want to use this feature to optimize their *live 
migration*. Hope the community could understand our need.


> So I'm kind of trying to bridge this a bit - I would
> like the interfaces that we build to at least superficially
> look like they might be reusable for other uses of hinting.
>
> Imagine that you don't have dirty tracking on the host.
> What would it take to still use hinting information,
> e.g. to call MADV_FREE on the pages guest gives us?
>
> I think you need to kick and you need to wait for
> host to consume the hint before page is reused.
> And we know madvise takes a lot of time sometimes,
> so locking out the free list does not sound like a
> good idea.
>
> That's why I was talking about kick out of lock,
> so that eventually we can reuse that for hinting
> and actually wait for an interrupt.
>
> So how about we take a bunch of pages out of the free list, move them to
> the balloon, kick (and optionally wait for host to consume), them move
> them back? Preferably to end of the list? This will also make things
> like sorting them much easier as you can just put them in a binary tree
> or something.
>
> For when we need to be careful to make sure we don't
> create an OOM situation with this out of thin air,
> and for when you can't give everything to host in one go,
> you might want some kind of notifier that tells you
> that you need to return pages to the free list ASAP.
>
> How'd this sound?
>

I think the above is a duplicate function of ballooning, though there 
are some differences. Please see below my concerns and different thoughts:

1) From the previous discussion, the only acceptable method to get pages 
from mm is to do alloc() (btw, we are not getting pages in this patch, 
we are getting hints). The above sounds like we are going to take pages 
from the free list without mm's awareness. I'm not sure if you would be 
ready to convince the mm folks that this idea is allowed.

2) If the guest has 8G free memory, how much can virtio-balloon take 
with the above method? For example, if virtio-balloon only takes 1G, 
with 7G left in mm. The next moment, it is possible that something comes 
out and needs to use 7.5GB. I think it is barely possible to ensure that 
the amount of memory we take to virtio-balloon won't affect the system.

3) Hints means the pages are quite likely to be free pages (no 
guarantee). If the pages given to host are going to be freed, then we 
really couldn't call them hints, they are true free pages. Ballooning 
needs true free pages, while live migration needs hints, would you agree 
with this? From the perspective of features, they are two different 
features, and should be gated with two feature bits and separated 
implementations. Mixing them would cause many unexpected issues (e.g. 
the case when the two features function at the same time)

4) If we want to add another function of ballooning, how is this better 
than the existing ballooning? The difference I can see is the current 
ballooning takes free pages via alloc(), while the above hacks into the 
free page list.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
