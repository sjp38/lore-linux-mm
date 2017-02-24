Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 704336B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 11:23:21 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r18so10523751wmd.1
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:23:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i18si2999088wme.82.2017.02.24.08.23.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Feb 2017 08:23:20 -0800 (PST)
Date: Fri, 24 Feb 2017 17:23:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
Message-ID: <20170224162317.GN19161@dhcp22.suse.cz>
References: <20170223161241.GG29056@dhcp22.suse.cz>
 <8737f4zwx5.fsf@vitty.brq.redhat.com>
 <20170223174106.GB13822@dhcp22.suse.cz>
 <87tw7kydto.fsf@vitty.brq.redhat.com>
 <20170224133714.GH19161@dhcp22.suse.cz>
 <87efyny90q.fsf@vitty.brq.redhat.com>
 <20170224144147.GJ19161@dhcp22.suse.cz>
 <87a89by6hd.fsf@vitty.brq.redhat.com>
 <20170224153227.GL19161@dhcp22.suse.cz>
 <8760jzy3iu.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8760jzy3iu.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com, kys@microsoft.com

On Fri 24-02-17 17:09:13, Vitaly Kuznetsov wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Fri 24-02-17 16:05:18, Vitaly Kuznetsov wrote:
> >> Michal Hocko <mhocko@kernel.org> writes:
> >> 
> >> > On Fri 24-02-17 15:10:29, Vitaly Kuznetsov wrote:
> > [...]
> >> >> Just did a quick (and probably dirty) test, increasing guest memory from
> >> >> 4G to 8G (32 x 128mb blocks) require 68Mb of memory, so it's roughly 2Mb
> >> >> per block. It's really easy to trigger OOM for small guests.
> >> >
> >> > So we need ~1.5% of the added memory. That doesn't sound like something
> >> > to trigger OOM killer too easily. Assuming that increase is not way too
> >> > large. Going from 256M (your earlier example) to 8G looks will eat half
> >> > the memory which is still quite far away from the OOM.
> >> 
> >> And if the kernel itself takes 128Mb of ram (which is not something
> >> extraordinary with many CPUs) we have zero left. Go to something bigger
> >> than 8G and you die.
> >
> > Again, if you have 128M and jump to 8G then your memory balancing is
> > most probably broken.
> >
> 
> I don't understand what balancing you're talking about.

balancing = dynamic memory resizing depending on the demand both
internal (inside guest) and outside (on the host to balance memory
between different guests).

> I have a small
> guest and I want to add more memory to it and the result is ... OOM. Not
> something I expected.

Which is not all that unexpected if you use a technology which has to
allocated in order to add more memory.

> >> > I would call such
> >> > an increase a bad memory balancing, though, to be honest. A more
> >> > reasonable memory balancing would go and double the available memory
> >> > IMHO. Anway, I still think that hotplug is a terrible way to do memory
> >> > ballooning.
> >> 
> >> That's what we have in *all* modern hypervisors. And I don't see why
> >> it's bad.
> >
> > Go and re-read the original thread. Dave has given many good arguments.
> >
> 
> Are we discussing taking away the memory hotplug feature from all
> hypervisors here?

No. I just consider it a bad idea because it has many problems and will
never be 100% reliable.

[...]
> >> I don't understand why CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is
> >
> > Because this is something a user has to think about and doesn't have a
> > reasonable way to decide. Our config space is also way too large!
> 
> Config space is for distros, not users.

Maybe you haven't noticed but there are people compiling their kernels
as well. But even distros are not really in a great position to answer
this question because it depends on the specific usecase.

> >> disturbing and why do we need to take this choice away from distros. I
> >> don't understand what we're gaining by replacing it with
> >> per-memory-add-technology defaults.
> >
> > Because those technologies know that they want to have the memory online
> > as soon as possible. Jeez, just look at the hv code. It waits for the
> > userspace to online memory before going further. Why would it ever want
> > to have the tunable in "offline" state? This just doesn't make any
> > sense. Look at how things get simplified if we get rid of this clutter
> 
> While this will most probably work for me I still disagree with the
> concept of 'one size fits all' here and the default 'false' for ACPI,
> we're taking away the feature from KVM/Vmware folks so they'll again
> come up with the udev rule which has known issues.

Well, AFAIU acpi_memory_device_add is a standard way how to announce
physical memory added to the system. Where does the KVM/VMware depend on
this to do memory ballooning?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
