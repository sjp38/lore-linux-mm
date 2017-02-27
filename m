Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA566B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 05:49:48 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id u188so127682722qkc.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 02:49:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b47si11506854qtc.27.2017.02.27.02.49.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 02:49:47 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
References: <20170227092817.23571-1-mhocko@kernel.org>
	<87lgssvtni.fsf@vitty.brq.redhat.com>
	<20170227102132.GI14029@dhcp22.suse.cz>
Date: Mon, 27 Feb 2017 11:49:43 +0100
In-Reply-To: <20170227102132.GI14029@dhcp22.suse.cz> (Michal Hocko's message
	of "Mon, 27 Feb 2017 11:21:32 +0100")
Message-ID: <87efyjx60o.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org

Michal Hocko <mhocko@kernel.org> writes:

> On Mon 27-02-17 11:02:09, Vitaly Kuznetsov wrote:
> [...]
>> I don't have anything new to add to the discussion happened last week
>> but I'd like to summarize my arguments against this change:
>> 
>> 1) This patch doesn't solve any issue. Configuration option is not an
>> issue by itself, it is an option for distros to decide what they want to
>> ship: udev rule with known issues (legacy mode) or enable the new
>> option. Distro makers and users building their kernels should be able to
>> answer this simple question "do you want to automatically online all
>> newly added memory or not".
>
> OK, so could you be more specific? Distributions have no clue about
> which HW their kernel runs on so how can they possibly make a sensible
> decision here?

They at least have an idea if they ship udev rule or not. I can also
imagine different choices for non-x86 architectures but I don't know
enough about them to have an opinion.

>
>> There are distros already which ship kernels
>> with CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE enabled (Fedora 24 and 25 as
>> far as I remember, maybe someone else).
>> 
>> 2) This patch creates an imbalance between Xen/Hyper-V on one side and
>> KVM/Vmware on another. KVM/Vmware use pure ACPI memory hotplug and this
>> memory won't get onlined. I don't understand how this problem is
>> supposed to be solved by distros. They'll *have to* continue shipping
>> a udev rule which has and always will have issues.
>
> They have notifications for udev to online that memory and AFAICU
> neither KVM nor VMware are using memory hotplut for ballooning - unlike
> HyperV and Xen.
>

No, Hyper-V doesn't use memory hotplug for ballooning purposes. It is
just a memory hotplug. The fact that the code is located in hv_balloon
is just a coincidence.

The difference with real hardware is how the operation is performed:
with real hardware you need to take a DIMM, go to your server room, open
the box, insert DIMM, go back to your seat. Asking to do some manual
action to actually enable memory is kinda OK. The beauty of hypervisors
is that everything happens automatically (e.g. when the VM is running
out of memory).

>> 3) Kernel command line is not a viable choice, it is rather a debug
>> method.
>
> Why?
>

Because we usually have just a few things there (root=, console=) and
the rest is used when something goes wrong or for 'special' cases, not
for the majority of users.

>> Having all newly added memory online as soon as possible is a
>> major use-case not something a couple of users wants (and this is
>> proved by major distros shipping the unconditional 'offline->online'
>> rule with udev).
>
> I would argue because this really depends on the usecase. a) somebody
> might want to online memory as movable and that really depends on which
> node we are talking about because not all of them can be movable

This is possible and that's why I introduce kernel command line options
back then. To simplify, I argue that the major use-case is 'online ASAP,
never offline' and for other use-cases we have options, both for distros
(config) and for users (command-line)


> b) it
> is easier to handle potential errors from userspace than the kernel.
>

Yes, probably, but memory hotplug was around for quite some time and I
didn't see anything but the dump udev rule (offline->online) without any
handling. And I think that we should rather focus on fixing potential
issues and making failures less probable (e.g. it's really hard to come
up with something different from 'failed->retry').

>> A couple of other thoughts:
>> 1) Having all newly added memory online ASAP is probably what people
>> want for all virtual machines. Unfortunately, we have additional
>> complexity with memory zones (ZONE_NORMAL, ZONE_MOVABLE) and in some
>> cases manual intervention is required. Especially, when further unplug
>> is expected.
>
> and that is why we do not want to hardwire this into the kernel and we
> have a notification to handle this in userspace.

Yes and I don't know about any plans to remove this notification. In
case some really complex handling is required just don't turn on the
automatic onlining.

Memory hotplug in real x86 hardware is rare, memory hotplug for VMs is
ubiquitous.

>
>> 2) Adding new memory can (in some extreme cases) still fail as we need
>> some *other* memory before we're able to online the newly added
>> block. This is an issue to be solved and it is doable (IMO) with some
>> pre-allocation.
>
> you cannot preallocate for all the possible memory that can be added.

For all, no, but for 1 next block - yes, and then I'll preallocate for
the next one.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
