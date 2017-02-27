Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFC216B038B
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:18:00 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id s186so132541597qkb.5
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 05:18:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r19si11732511qke.145.2017.02.27.05.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 05:18:00 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
References: <20170227092817.23571-1-mhocko@kernel.org>
	<87lgssvtni.fsf@vitty.brq.redhat.com>
	<20170227102132.GI14029@dhcp22.suse.cz>
	<87efyjx60o.fsf@vitty.brq.redhat.com>
	<20170227125636.GB26504@dhcp22.suse.cz>
Date: Mon, 27 Feb 2017 14:17:56 +0100
In-Reply-To: <20170227125636.GB26504@dhcp22.suse.cz> (Michal Hocko's message
	of "Mon, 27 Feb 2017 13:56:37 +0100")
Message-ID: <87wpcbvkl7.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org

Michal Hocko <mhocko@kernel.org> writes:

> On Mon 27-02-17 11:49:43, Vitaly Kuznetsov wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>> 
>> > On Mon 27-02-17 11:02:09, Vitaly Kuznetsov wrote:
>> > [...]
>> >> I don't have anything new to add to the discussion happened last week
>> >> but I'd like to summarize my arguments against this change:
>> >> 
>> >> 1) This patch doesn't solve any issue. Configuration option is not an
>> >> issue by itself, it is an option for distros to decide what they want to
>> >> ship: udev rule with known issues (legacy mode) or enable the new
>> >> option. Distro makers and users building their kernels should be able to
>> >> answer this simple question "do you want to automatically online all
>> >> newly added memory or not".
>> >
>> > OK, so could you be more specific? Distributions have no clue about
>> > which HW their kernel runs on so how can they possibly make a sensible
>> > decision here?
>> 
>> They at least have an idea if they ship udev rule or not. I can also
>> imagine different choices for non-x86 architectures but I don't know
>> enough about them to have an opinion.
>
> I really do not follow. If they know whether they ship the udev rule
> then why do they need a kernel help at all? Anyway this global policy
> actually breaks some usecases. Say you would have a default set to
> online. What should user do if _some_ nodes should be online_movable?
> Or, say that HyperV or other hotplug based ballooning implementation
> really want to online the movable memory in order to have a realiable
> hotremove. Now you have a global policy which goes against it.
>

While I think that hotremove is a special case which really requires
manual intervention (at least to decide which memory goes NORMAL and
which MOVABLE), MEMORY_HOTPLUG_DEFAULT_ONLINE is probably not for it.

[snip]

>
>> The difference with real hardware is how the operation is performed:
>> with real hardware you need to take a DIMM, go to your server room, open
>> the box, insert DIMM, go back to your seat. Asking to do some manual
>> action to actually enable memory is kinda OK. The beauty of hypervisors
>> is that everything happens automatically (e.g. when the VM is running
>> out of memory).
>
> I do not see your point. Either you have some (semi)automatic way to
> balance memory in guest based on the memory pressure (let's call it
> ballooning) or this is an administration operation (say you buy more
> DIMs or pay more to your virtualization provider) and then it is up to
> the guest owner to tell what to do about that memory. In other words you
> really do not want to wait in the first case as you are under memory
> pressure which is _actively_ managed or this is much more relaxed
> environment.

I don't see a contradiction between what I say and what you say here :-)
Yes, there are case when we're not in a hurry and there are cases when
we can't wait.

>
>> >> 3) Kernel command line is not a viable choice, it is rather a debug
>> >> method.
>> >
>> > Why?
>> >
>> 
>> Because we usually have just a few things there (root=, console=) and
>> the rest is used when something goes wrong or for 'special' cases, not
>> for the majority of users.
>
> auto online or even memory hotplug seems something that requires
> a special HW/configuration already so I fail to see your point. It is
> normal to put kernel parameters to override the default. And AFAIU
> default offline is a sensible default for the standard memory hotplug.
>

It depends how we define 'standard'. The point I'm trying to make is
that it's really common for VMs to use this technique while in hardware
(x86) world it is a rare occasion. The 'sensible default' may differ.

> [...]
>
>> >> 2) Adding new memory can (in some extreme cases) still fail as we need
>> >> some *other* memory before we're able to online the newly added
>> >> block. This is an issue to be solved and it is doable (IMO) with some
>> >> pre-allocation.
>> >
>> > you cannot preallocate for all the possible memory that can be added.
>> 
>> For all, no, but for 1 next block - yes, and then I'll preallocate for
>> the next one.
>
> You are still thinking in the scope of your particular use case and I
> believe the whole thing is shaped around that very same thing and that
> is why it should have been rejected in the first place. Especially when
> that use case can be handled without user visible configuration knob.

I think my use case is broad enough. At least it applies to all
virtualization technoligies and not only to Hyper-V. But yes, I agree
that adding a parameter to add_memory() solves my particular use case as
well.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
