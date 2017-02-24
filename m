Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 469786B0389
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 09:41:51 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id w37so12297453wrc.0
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 06:41:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si10565712wrs.262.2017.02.24.06.41.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Feb 2017 06:41:49 -0800 (PST)
Date: Fri, 24 Feb 2017 15:41:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
Message-ID: <20170224144147.GJ19161@dhcp22.suse.cz>
References: <20170223125643.GA29064@dhcp22.suse.cz>
 <87bmttyqxf.fsf@vitty.brq.redhat.com>
 <20170223150920.GB29056@dhcp22.suse.cz>
 <877f4gzz4d.fsf@vitty.brq.redhat.com>
 <20170223161241.GG29056@dhcp22.suse.cz>
 <8737f4zwx5.fsf@vitty.brq.redhat.com>
 <20170223174106.GB13822@dhcp22.suse.cz>
 <87tw7kydto.fsf@vitty.brq.redhat.com>
 <20170224133714.GH19161@dhcp22.suse.cz>
 <87efyny90q.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87efyny90q.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com, kys@microsoft.com

On Fri 24-02-17 15:10:29, Vitaly Kuznetsov wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Thu 23-02-17 19:14:27, Vitaly Kuznetsov wrote:
[...]
> >> Virtual guests under stress were getting into OOM easily and the OOM
> >> killer was even killing the udev process trying to online the
> >> memory.
> >
> > Do you happen to have any OOM report? I am really surprised that udev
> > would be an oom victim because that process is really small. Who is
> > consuming all the memory then?
> 
> It's been a while since I worked on this and unfortunatelly I don't have
> a log. From what I remember, the kernel itself was consuming all memory
> so *all* processes were victims.

This suggests that something is terminally broken!
 
> > Have you measured how much memory do we need to allocate to add one
> > memblock?
> 
> No, it's actually a good idea if we decide to do some sort of pre-allocation.
> 
> Just did a quick (and probably dirty) test, increasing guest memory from
> 4G to 8G (32 x 128mb blocks) require 68Mb of memory, so it's roughly 2Mb
> per block. It's really easy to trigger OOM for small guests.

So we need ~1.5% of the added memory. That doesn't sound like something
to trigger OOM killer too easily. Assuming that increase is not way too
large. Going from 256M (your earlier example) to 8G looks will eat half
the memory which is still quite far away from the OOM. I would call such
an increase a bad memory balancing, though, to be honest. A more
reasonable memory balancing would go and double the available memory
IMHO. Anway, I still think that hotplug is a terrible way to do memory
ballooning.

[...]
> >> the completion was done by observing for the MEM_ONLINE event. This, of
> >> course, was slowing things down significantly and waiting for a
> >> userspace action in kernel is not a nice thing to have (not speaking
> >> about all other memory adding methods which had the same issue). Just
> >> removing this wait was leading us to the same OOM as the hypervisor was
> >> adding more and more memory and eventually even add_memory() was
> >> failing, udev and other processes were killed,...
> >
> > Yes, I agree that waiting on a user action from the kernel is very far
> > from ideal.
> >
> >> With the feature in place we have new memory available right after we do
> >> add_memory(), everything is serialized.
> >
> > What prevented you from onlining the memory explicitly from
> > hv_mem_hot_add path? Why do you need a user visible policy for that at
> > all? You could also add a parameter to add_memory that would do the same
> > thing. Or am I missing something?
> 
> We have different mechanisms for adding memory, I'm aware of at least 3:
> ACPI, Xen, Hyper-V. The issue I'm addressing is general enough, I'm
> pretty sure I can reproduce the issue on Xen, for example - just boot a
> small guest and try adding tons of memory. Why should we have different
> defaults for different technologies? 

Just make them all online the memory explicitly. I really do not see why
this should be decided by poor user. Put it differently, when should I
disable auto online when using hyperV or other of the mentioned
technologies? CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE should simply die and
I would even be for killing the whole memhp_auto_online thing along the
way. This simply doesn't make any sense to me.
 
> And, BTW, the link to the previous discussion:
> https://groups.google.com/forum/#!msg/linux.kernel/AxvyuQjr4GY/TLC-K0sL_NEJ

I remember this discussion and objected to the approach back then as
well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
