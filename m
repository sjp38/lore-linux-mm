Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2B96B0388
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 10:09:26 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id x4so932030wme.3
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 07:09:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a19si6393716wra.291.2017.02.23.07.09.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 07:09:23 -0800 (PST)
Date: Thu, 23 Feb 2017 16:09:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
Message-ID: <20170223150920.GB29056@dhcp22.suse.cz>
References: <20170221172234.8047.33382.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
 <878toy1sgd.fsf@vitty.brq.redhat.com>
 <20170223125643.GA29064@dhcp22.suse.cz>
 <87bmttyqxf.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bmttyqxf.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com

On Thu 23-02-17 14:31:24, Vitaly Kuznetsov wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Wed 22-02-17 10:32:34, Vitaly Kuznetsov wrote:
> > [...]
> >> > There is a workaround in that a user could online the memory or have
> >> > a udev rule to online the memory by using the sysfs interface. The
> >> > sysfs interface to online memory goes through device_online() which
> >> > should updated the dev->offline flag. I'm not sure that having kernel
> >> > memory hotplug rely on userspace actions is the correct way to go.
> >> 
> >> Using udev rule for memory onlining is possible when you disable
> >> memhp_auto_online but in some cases it doesn't work well, e.g. when we
> >> use memory hotplug to address memory pressure the loop through userspace
> >> is really slow and memory consuming, we may hit OOM before we manage to
> >> online newly added memory.
> >
> > How does the in-kernel implementation prevents from that?
> >
> 
> Onlining memory on hot-plug is much more reliable, e.g. if we were able
> to add it in add_memory_resource() we'll also manage to online it.

How does that differ from initiating online from the users?

> With
> udev rule we may end up adding many blocks and then (as udev is
> asynchronous) failing to online any of them.

Why would it fail?

> In-kernel operation is synchronous.

which doesn't mean anything as the context is preemptible AFAICS.

> >> In addition to that, systemd/udev folks
> >> continuosly refused to add this udev rule to udev calling it stupid as
> >> it actually is an unconditional and redundant ping-pong between kernel
> >> and udev.
> >
> > This is a policy and as such it doesn't belong to the kernel. The whole
> > auto-enable in the kernel is just plain wrong IMHO and we shouldn't have
> > merged it.
> 
> I disagree.
> 
> First of all it's not a policy, it is a default. We have many other
> defaults in kernel. When I add a network card or a storage, for example,
> I don't need to go anywhere and 'enable' it before I'm able to use
> it from userspace. An for memory (and CPUs) we, for some unknown reason
> opted for something completely different. If someone is plugging new
> memory into a box he probably wants to use it, I don't see much value in
> waiting for a special confirmation from him. 

This was not my decision so I can only guess but to me it makes sense.
Both memory and cpus can be physically present and offline which is a
perfectly reasonable state. So having a two phase physicall hotadd is
just built on top of physical vs. logical distinction. I completely
understand that some usecases will really like to online the whole node
as soon as it appears present. But an automatic in-kernel implementation
has its down sites - e.g. if this operation fails in the middle you will
not know about that unless you check all the memblocks in sysfs. This is
really a poor interface.

> Second, this feature is optional. If you want to keep old behavior just
> don't enable it.

It just adds unnecessary configuration noise as well

> Third, this solves real world issues. With Hyper-V it is very easy to
> show udev failing on stress. 

What is the reason for this failures. Do you have any link handy?

> No other solution to the issue was ever suggested.

you mean like using ballooning for the memory overcommit like other more
reasonable virtualization solutions?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
