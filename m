Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65AD06B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:37:18 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v77so8757869wmv.5
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 05:37:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k7si2499495wmk.40.2017.02.24.05.37.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Feb 2017 05:37:17 -0800 (PST)
Date: Fri, 24 Feb 2017 14:37:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
Message-ID: <20170224133714.GH19161@dhcp22.suse.cz>
References: <20170221172234.8047.33382.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
 <878toy1sgd.fsf@vitty.brq.redhat.com>
 <20170223125643.GA29064@dhcp22.suse.cz>
 <87bmttyqxf.fsf@vitty.brq.redhat.com>
 <20170223150920.GB29056@dhcp22.suse.cz>
 <877f4gzz4d.fsf@vitty.brq.redhat.com>
 <20170223161241.GG29056@dhcp22.suse.cz>
 <8737f4zwx5.fsf@vitty.brq.redhat.com>
 <20170223174106.GB13822@dhcp22.suse.cz>
 <87tw7kydto.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87tw7kydto.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com, kys@microsoft.com

On Thu 23-02-17 19:14:27, Vitaly Kuznetsov wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Thu 23-02-17 17:36:38, Vitaly Kuznetsov wrote:
> >> Michal Hocko <mhocko@kernel.org> writes:
> > [...]
> >> > Is a grow from 256M -> 128GB really something that happens in real life?
> >> > Don't get me wrong but to me this sounds quite exaggerated. Hotmem add
> >> > which is an operation which has to allocate memory has to scale with the
> >> > currently available memory IMHO.
> >> 
> >> With virtual machines this is very real and not exaggerated at
> >> all. E.g. Hyper-V host can be tuned to automatically add new memory when
> >> guest is running out of it. Even 100 blocks can represent an issue.
> >
> > Do you have any reference to a bug report. I am really curious because
> > something really smells wrong and it is not clear that the chosen
> > solution is really the best one.
> 
> Unfortunately I'm not aware of any publicly posted bug reports (CC:
> K. Y. - he may have a reference) but I think I still remember everything
> correctly. Not sure how deep you want me to go into details though...

As much as possible to understand what was really going on...

> Virtual guests under stress were getting into OOM easily and the OOM
> killer was even killing the udev process trying to online the
> memory.

Do you happen to have any OOM report? I am really surprised that udev
would be an oom victim because that process is really small. Who is
consuming all the memory then?

Have you measured how much memory do we need to allocate to add one
memblock?

> There was a workaround for the issue added to the hyper-v driver
> doing memory add:
> 
> hv_mem_hot_add(...) {
> ...
>  add_memory(....);
>  wait_for_completion_timeout(..., 5*HZ);
>  ...
> }

I can still see 
		/*
		 * Wait for the memory block to be onlined when memory onlining
		 * is done outside of kernel (memhp_auto_online). Since the hot
		 * add has succeeded, it is ok to proceed even if the pages in
		 * the hot added region have not been "onlined" within the
		 * allowed time.
		 */
		if (dm_device.ha_waiting)
			wait_for_completion_timeout(&dm_device.ol_waitevent,
						    5*HZ);
 
> the completion was done by observing for the MEM_ONLINE event. This, of
> course, was slowing things down significantly and waiting for a
> userspace action in kernel is not a nice thing to have (not speaking
> about all other memory adding methods which had the same issue). Just
> removing this wait was leading us to the same OOM as the hypervisor was
> adding more and more memory and eventually even add_memory() was
> failing, udev and other processes were killed,...

Yes, I agree that waiting on a user action from the kernel is very far
from ideal.
 
> With the feature in place we have new memory available right after we do
> add_memory(), everything is serialized.

What prevented you from onlining the memory explicitly from
hv_mem_hot_add path? Why do you need a user visible policy for that at
all? You could also add a parameter to add_memory that would do the same
thing. Or am I missing something?
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
