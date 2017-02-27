Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA8556B0389
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 05:02:13 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id a189so88001948qkc.4
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 02:02:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f1si10709780qkc.75.2017.02.27.02.02.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 02:02:13 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
References: <20170227092817.23571-1-mhocko@kernel.org>
Date: Mon, 27 Feb 2017 11:02:09 +0100
In-Reply-To: <20170227092817.23571-1-mhocko@kernel.org> (Michal Hocko's
	message of "Mon, 27 Feb 2017 10:28:17 +0100")
Message-ID: <87lgssvtni.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, Michal Hocko <mhocko@suse.com>

Michal Hocko <mhocko@kernel.org> writes:

> From: Michal Hocko <mhocko@suse.com>
>
> This knob has been added by 31bc3858ea3e ("memory-hotplug: add automatic
> onlining policy for the newly added memory") mainly to cover memory
> hotplug based balooning solutions currently implemented for HyperV
> and Xen. Both of them want to online the memory as soon after
> registering as possible otherwise they can register too much memory
> which cannot be used and trigger the oom killer (we need ~1.5% of the
> registered memory so a large increase can consume all the available
> memory). hv_mem_hot_add even waits for the userspace to online the
> memory if the auto onlining is disabled to mitigate that problem.
>
> Adding yet another knob and a config option just doesn't make much sense
> IMHO. How is a random user supposed to know when to enable this option?
> Ballooning drivers know much better that they want to do an immediate
> online rather than waiting for the userspace to do that. If the memory
> is onlined for a different purpose then we already have a notification
> for the userspace and udev can handle the onlining. So the knob as well
> as the config option for the default behavior just doesn't make any
> sense. Let's remove them and allow user of add_memory to request the
> online status explicitly. Not only it makes more sense it also removes a
> lot of clutter.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>
> Hi,
> I am sending this as an RFC because this is a user visible change. Maybe
> we won't be able to remove the sysfs knob which would be sad, especially
> when it has been added without a wider discussion and IMHO it is just
> wrong. Is there any reason why a kernel command line parameter wouldn't
> work just fine?
>
> Even in that case I believe that we should remove
> CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE knob. It just adds to an already
> messy config space. Does anybody depend on the policy during the early
> boot before the userspace can set the sysfs knob? Or why those users cannot
> simply use the kernel command line parameter.
>
> I also believe that the wait-for-userspace in hyperV should just die. It
> should do the unconditional onlining. Same as Xen. I do not see any
> reason why those should depend on the userspace. This should be just
> fixed regardless of the sysfs/config part. I can separate this out of course.
>
> Thoughts/Concerns?

I don't have anything new to add to the discussion happened last week
but I'd like to summarize my arguments against this change:

1) This patch doesn't solve any issue. Configuration option is not an
issue by itself, it is an option for distros to decide what they want to
ship: udev rule with known issues (legacy mode) or enable the new
option. Distro makers and users building their kernels should be able to
answer this simple question "do you want to automatically online all
newly added memory or not". There are distros already which ship kernels
with CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE enabled (Fedora 24 and 25 as
far as I remember, maybe someone else).

2) This patch creates an imbalance between Xen/Hyper-V on one side and
KVM/Vmware on another. KVM/Vmware use pure ACPI memory hotplug and this
memory won't get onlined. I don't understand how this problem is
supposed to be solved by distros. They'll *have to* continue shipping
a udev rule which has and always will have issues.

3) Kernel command line is not a viable choice, it is rather a debug
method. Having all newly added memory online as soon as possible is a
major use-case not something a couple of users wants (and this is
proved by major distros shipping the unconditional 'offline->online'
rule with udev).

A couple of other thoughts:
1) Having all newly added memory online ASAP is probably what people
want for all virtual machines. Unfortunately, we have additional
complexity with memory zones (ZONE_NORMAL, ZONE_MOVABLE) and in some
cases manual intervention is required. Especially, when further unplug
is expected.

2) Adding new memory can (in some extreme cases) still fail as we need
some *other* memory before we're able to online the newly added
block. This is an issue to be solved and it is doable (IMO) with some
pre-allocation.

I'd also like to notice that this patch doesn't re-introduce the issue I
was fixing with in-kernel memory onlining as all memory added through
the Hyper-V driver will be auto-onlined unconditionally. What I disagree
with here is taking away choice without fixing any real world issues.

[snip]

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
