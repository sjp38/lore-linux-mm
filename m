Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 72FBA831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 08:15:20 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u65so1351548wmu.12
        for <linux-mm@kvack.org>; Thu, 04 May 2017 05:15:20 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id i207si1280469wmf.3.2017.05.04.05.15.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 05:15:18 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <20170504112159.GC31540@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <83d4556c-b21c-7ae5-6e83-4621a74f9fd5@huawei.com>
Date: Thu, 4 May 2017 15:14:10 +0300
MIME-Version: 1.0
In-Reply-To: <20170504112159.GC31540@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>

On 04/05/17 14:21, Michal Hocko wrote:
> On Wed 03-05-17 15:06:36, Igor Stoppa wrote:

[...]

>> * In most, if not all, the cases that could be enhanced, the code will
>> be calling kmalloc/vmalloc, indicating GFP_KERNEL as the desired type of
>> memory.
> 
> How do you tell that the seal is active?

The simpler way would be to define the seal as something that is applied
only after late init has concluded.

IOW, if the kernel has already started user-space, the seal is in place.

I do acknowledge that this conflicts with the current implementation of
SE Linux, but it might be possible to extend SE Linux to have a
predefined configuration file that is loaded during kernel init.

In general this is not acceptable, but OTOH IMA does it, so there could
be ground also for advocating similar (optional) behavior for SE Linux.

Should that not be possible,then yes, I should provide some way (ioctl,
sysfs/something else) that can be used to apply the seal.

In such case there should be also some helper function which allows to
confirm that the seal is absent/present.

> I have also asked about the
> life time of these objects in the previous email thread. Do you expect
> those objects get freed one by one or mostly at once? Is this supposed
> to be boot time only or such allocations might happen anytime?

Yes, you did. I didn't mean to ignore the question.
I thought this question would be answered by the current RFC :-(

Alright, here's one more attempt at explaining what I have in mind.
And I might be wrong, so that would explain why it's not clear.

Once the seal is in place, the objects are effectively read-only, so the
lifetime is basically the same as the kernel text.
Since I am after providing the same functionality of
post-init-read-only, but for dynamically allocated data, I would stick
to the same behavior: once the data is read-only, it stays so forever,
or till reset/poweroff, whichever comes first.

I wonder if you are thinking about loadable modules or maybe livepatch.
My proposal, in its current form, is only about what is done when the
kernel initialization is performed. So it would not take those cases
under its umbrella. Actually it might be incompatible with livepatch, if
any of the read-only data is supposed to be updated.

Since it's meant to improve the current level of integrity, I would
prefer to have a progressive approach and address modules/livepatch in a
later phase, if this is not seen as a show stopper.

[...]

> The most immediate suggestion would be to extend SLAB caches with a new
> sealing feature.

Yes, I got few hours ago the same advice also from Dave Hansen (thanks,
btw) [1].

I had just not considered the option.

> Roughly it would mean that once kmem_cache_seal() is
> called on a cache it would changed page tables to used slab pages to RO
> state. This would obviously need some fiddling to make those pages not
> usable for new allocations from sealed pages. It would also mean some
> changes to kfree path but I guess this is doable.

Ok, as it probably has already become evident, I have just started
peeking into the memory subsystem, so this is the sort of guidance I was
hoping I could receive =) - thank you

Question: I see that some pages can be moved around. Would this apply to
the slab-based solution, or can I assume that once I have certain
physical pages sealed, they will not be altered anymore?

>> * While I do not strictly need a new memory zone, memory zones are what
>> kmalloc understands at the moment: AFAIK, it is not possible to tell
>> kmalloc from which memory pool it should fish out the memory, other than
>> having a reference to a memory zone.
> 
> As I've said already. I think that a zone is a completely wrong
> approach. How would it help anyway. It is the allocator on top of the
> page allocator which has to do clever things to support sealing.


Ok, as long as there is a way forward that fits my needs and has the
possibility to be merged upstream, I'm fine with it.

I suppose zones are the first thing one meets when reading the code, so
they are probably the first target that comes to mind.
That's what happened to me.

I will probably come back with further questions, but I can then start
putting together some prototype of what you described.

I am fine with providing a generic solution, but I must make sure that
it works with slub. I suppose what you proposed will do it, right?

TBH, from what little I have been reading so far, I find a bit confusing
the fact that there are some header files referring separately to slab,
slub and slob, but then common code still refers to slab (slab.h slab.c
and slab_common.c, for example)


[1] https://marc.info/?l=linux-kernel&m=149388596106305&w=2


---
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
