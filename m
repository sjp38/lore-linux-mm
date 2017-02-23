Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D24B06B0387
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 11:12:46 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id s27so18099884wrb.5
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:12:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o64si7007946wmo.90.2017.02.23.08.12.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 08:12:45 -0800 (PST)
Date: Thu, 23 Feb 2017 17:12:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
Message-ID: <20170223161241.GG29056@dhcp22.suse.cz>
References: <20170221172234.8047.33382.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
 <878toy1sgd.fsf@vitty.brq.redhat.com>
 <20170223125643.GA29064@dhcp22.suse.cz>
 <87bmttyqxf.fsf@vitty.brq.redhat.com>
 <20170223150920.GB29056@dhcp22.suse.cz>
 <877f4gzz4d.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877f4gzz4d.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com

On Thu 23-02-17 16:49:06, Vitaly Kuznetsov wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Thu 23-02-17 14:31:24, Vitaly Kuznetsov wrote:
> >> Michal Hocko <mhocko@kernel.org> writes:
> >> 
> >> > On Wed 22-02-17 10:32:34, Vitaly Kuznetsov wrote:
> >> > [...]
> >> >> > There is a workaround in that a user could online the memory or have
> >> >> > a udev rule to online the memory by using the sysfs interface. The
> >> >> > sysfs interface to online memory goes through device_online() which
> >> >> > should updated the dev->offline flag. I'm not sure that having kernel
> >> >> > memory hotplug rely on userspace actions is the correct way to go.
> >> >> 
> >> >> Using udev rule for memory onlining is possible when you disable
> >> >> memhp_auto_online but in some cases it doesn't work well, e.g. when we
> >> >> use memory hotplug to address memory pressure the loop through userspace
> >> >> is really slow and memory consuming, we may hit OOM before we manage to
> >> >> online newly added memory.
> >> >
> >> > How does the in-kernel implementation prevents from that?
> >> >
> >> 
> >> Onlining memory on hot-plug is much more reliable, e.g. if we were able
> >> to add it in add_memory_resource() we'll also manage to online it.
> >
> > How does that differ from initiating online from the users?
> >
> >> With
> >> udev rule we may end up adding many blocks and then (as udev is
> >> asynchronous) failing to online any of them.
> >
> > Why would it fail?
> >
> >> In-kernel operation is synchronous.
> >
> > which doesn't mean anything as the context is preemptible AFAICS.
> >
> 
> It actually does,
> 
> imagine the following example: you run a small guest (256M of memory)
> and now there is a request to add 1000 128mb blocks to it. 

Is a grow from 256M -> 128GB really something that happens in real life?
Don't get me wrong but to me this sounds quite exaggerated. Hotmem add
which is an operation which has to allocate memory has to scale with the
currently available memory IMHO.

> In case you
> do it the old way you're very likely to get OOM somewhere in the middle
> as you keep adding blocks which requere kernel memory and nobody is
> onlining it (or, at least you're racing with the onliner). With
> in-kernel implementation we're going to online the first block when it's
> added and only then go to the second.

Yes, adding a memory will cost you some memory and that is why I am
really skeptical when memory hotplug is used under a strong memory
pressure. This can lead to OOMs even when you online one block at the
time.

[...]
> > This was not my decision so I can only guess but to me it makes sense.
> > Both memory and cpus can be physically present and offline which is a
> > perfectly reasonable state. So having a two phase physicall hotadd is
> > just built on top of physical vs. logical distinction. I completely
> > understand that some usecases will really like to online the whole node
> > as soon as it appears present. But an automatic in-kernel implementation
> > has its down sites - e.g. if this operation fails in the middle you will
> > not know about that unless you check all the memblocks in sysfs. This is
> > really a poor interface.
> 
> And how do you know that some blocks failed to online with udev?

Because the udev will run a code which can cope with that - retry if the
error is recoverable or simply report with all the details. Compare that
to crawling the system log to see that something has broken...

> Who
> handles these failures and how? And, the last but not least, why do
> these failures happen?

I haven't heard reports about the failures and from looking into the
code those are possible but very unlikely.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
