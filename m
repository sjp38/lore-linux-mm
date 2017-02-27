Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D20586B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 05:21:36 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so36816025wmv.5
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 02:21:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g81si12917082wmf.88.2017.02.27.02.21.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 02:21:35 -0800 (PST)
Date: Mon, 27 Feb 2017 11:21:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170227102132.GI14029@dhcp22.suse.cz>
References: <20170227092817.23571-1-mhocko@kernel.org>
 <87lgssvtni.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lgssvtni.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org

On Mon 27-02-17 11:02:09, Vitaly Kuznetsov wrote:
[...]
> I don't have anything new to add to the discussion happened last week
> but I'd like to summarize my arguments against this change:
> 
> 1) This patch doesn't solve any issue. Configuration option is not an
> issue by itself, it is an option for distros to decide what they want to
> ship: udev rule with known issues (legacy mode) or enable the new
> option. Distro makers and users building their kernels should be able to
> answer this simple question "do you want to automatically online all
> newly added memory or not".

OK, so could you be more specific? Distributions have no clue about
which HW their kernel runs on so how can they possibly make a sensible
decision here?

> There are distros already which ship kernels
> with CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE enabled (Fedora 24 and 25 as
> far as I remember, maybe someone else).
> 
> 2) This patch creates an imbalance between Xen/Hyper-V on one side and
> KVM/Vmware on another. KVM/Vmware use pure ACPI memory hotplug and this
> memory won't get onlined. I don't understand how this problem is
> supposed to be solved by distros. They'll *have to* continue shipping
> a udev rule which has and always will have issues.

They have notifications for udev to online that memory and AFAICU
neither KVM nor VMware are using memory hotplut for ballooning - unlike
HyperV and Xen.

> 3) Kernel command line is not a viable choice, it is rather a debug
> method.

Why?

> Having all newly added memory online as soon as possible is a
> major use-case not something a couple of users wants (and this is
> proved by major distros shipping the unconditional 'offline->online'
> rule with udev).

I would argue because this really depends on the usecase. a) somebody
might want to online memory as movable and that really depends on which
node we are talking about because not all of them can be movable b) it
is easier to handle potential errors from userspace than the kernel.

> A couple of other thoughts:
> 1) Having all newly added memory online ASAP is probably what people
> want for all virtual machines. Unfortunately, we have additional
> complexity with memory zones (ZONE_NORMAL, ZONE_MOVABLE) and in some
> cases manual intervention is required. Especially, when further unplug
> is expected.

and that is why we do not want to hardwire this into the kernel and we
have a notification to handle this in userspace.

> 2) Adding new memory can (in some extreme cases) still fail as we need
> some *other* memory before we're able to online the newly added
> block. This is an issue to be solved and it is doable (IMO) with some
> pre-allocation.

you cannot preallocate for all the possible memory that can be added.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
