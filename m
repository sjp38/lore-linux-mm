Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A277A6B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 07:40:15 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id o135so1084793qke.3
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 04:40:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p189si17818775qkf.269.2017.03.07.04.40.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 04:40:13 -0800 (PST)
Date: Tue, 7 Mar 2017 13:40:04 +0100
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170307134004.58343e14@nial.brq.redhat.com>
In-Reply-To: <20170306145417.GG27953@dhcp22.suse.cz>
References: <20170227154304.GK26504@dhcp22.suse.cz>
	<1488462828-174523-1-git-send-email-imammedo@redhat.com>
	<20170302142816.GK1404@dhcp22.suse.cz>
	<20170302180315.78975d4b@nial.brq.redhat.com>
	<20170303082723.GB31499@dhcp22.suse.cz>
	<20170303183422.6358ee8f@nial.brq.redhat.com>
	<20170306145417.GG27953@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y.
 Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Igor Mammedov <imammedo@redhat.com>

On Mon, 6 Mar 2017 15:54:17 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 03-03-17 18:34:22, Igor Mammedov wrote:
> > On Fri, 3 Mar 2017 09:27:23 +0100
> > Michal Hocko <mhocko@kernel.org> wrote:
> >   
> > > On Thu 02-03-17 18:03:15, Igor Mammedov wrote:  
> > > > On Thu, 2 Mar 2017 15:28:16 +0100
> > > > Michal Hocko <mhocko@kernel.org> wrote:
> > > >     
> > > > > On Thu 02-03-17 14:53:48, Igor Mammedov wrote:
[...]

> > > > > memblocks. If that doesn't work I would call it a bug.    
> > > > It's rather an implementation constrain than a bug
> > > > for details and workaround patch see
> > > >  [1] https://bugzilla.redhat.com/show_bug.cgi?id=1314306#c7    
> > > 
> > > "You are not authorized to access bug #1314306"  
> > Sorry,
> > I've made it public, related comments and patch should be accessible now
> > (code snippets in BZ are based on older kernel but logic is still the same upstream)
> >    
> > > could you paste the reasoning here please?  
> > sure here is reproducer:
> > start VM with CLI:
> >   qemu-system-x86_64  -enable-kvm -m size=1G,slots=2,maxmem=4G -numa node \
> >   -object memory-backend-ram,id=m1,size=1G -device pc-dimm,node=0,memdev=m1 \
> >   /path/to/guest_image
> > 
> > then in guest dimm1 blocks are from 32-39
> > 
> >   echo online_movable > /sys/devices/system/memory/memory32/state
> > -bash: echo: write error: Invalid argument
> > 
> > in current mainline kernel it triggers following code path:
> > 
> > online_pages()
> >   ...
> >        if (online_type == MMOP_ONLINE_KERNEL) {                                 
> >                 if (!zone_can_shift(pfn, nr_pages, ZONE_NORMAL, &zone_shift))    
> >                         return -EINVAL;  
> 
> Are you sure? I would expect MMOP_ONLINE_MOVABLE here
pretty much, reproducer is above so try and see for yourself

[...]
> [...]
> > > > > > Which means simple udev rule isn't usable since it gets event from
> > > > > > the first to the last hotplugged block order. So now we would have
> > > > > > to write a daemon that would
> > > > > >  - watch for all blocks in hotplugged memory appear (how would it know)
> > > > > >  - online them in right order (order might also be different depending
> > > > > >    on kernel version)
> > > > > >    -- it becomes even more complicated in NUMA case when there are
> > > > > >       multiple zones and kernel would have to provide user-space
> > > > > >       with information about zone maps
> > > > > > 
> > > > > > In short current experience shows that userspace approach
> > > > > >  - doesn't solve issues that Vitaly has been fixing (i.e. onlining
> > > > > >    fast and/or under memory pressure) when udev (or something else
> > > > > >    might be killed)      
> > > > > 
> > > > > yeah and that is why the patch does the onlining from the kernel.    
> > > > onlining in this patch is limited to hyperv and patch breaks
> > > > auto-online on x86 kvm/vmware/baremetal as they reuse the same
> > > > hotplug path.    
> > > 
> > > Those can use the udev or do you see any reason why they couldn't?  
> >
> > Reasons are above, under >>>> and >> quotations, patch breaks
> > what Vitaly's fixed (including kvm/vmware usecases) i.e. udev/some
> > user-space process could be killed if hotplugged memory isn't onlined
> > fast enough leading to service termination and/or memory not
> > being onlined at all (if udev is killed)  
> 
> OK, so from the discussion so far I have learned that this would be
> problem _only_ if we are trying to hotplug a _lot_ of memory at once
> (~1.5% of the online memory is needed).  I am kind of skeptical this is
> a reasonable usecase. Who is going to hotadd 8G to 256M machine (which
> would eat half of the available memory which is still quite far from
> OOM)? Even if the memory balloning uses hotplug then such a grow sounds
> a bit excessive.
Slow and killable udev issue doesn't really depends on
amount of hotplugged memory since it's onlined in blocks
(128M for x64). Considering that it's currently onlined
as zone normal, kernel doesn't have any issues adding more
follow up blocks of memory.

> > Currently udev rule is not usable and one needs a daemon
> > which would correctly do onlining and keep zone balance
> > even for simple case usecase of 1 normal and 1 movable zone.
> > And it gets more complicated in case of multiple numa nodes
> > with multiple zones.  
> 
> That sounds to be more related to the current implementation than
> anything else and as such is not a reason to invent specific user
> visible api. Btw. you are talking about movable zones byt the auto
> onlining doesn't allow to auto online movable memory. So either I miss
> your point or I am utterly confused.
in current state neither does udev rule as memory is onlined
as NORMAL (x64 variant at least), which is the same as auto online
does now.

We are discussing 2 different issues here and thread got pretty
hard to follow. I'll try to sum up at results the end.

> [...]
> > > > Memory unplug is rather new and it doesn't work reliably so far,
> > > > moving onlining to user-space won't really help. Further work
> > > > is need to be done so that it would work reliably.    
> > > 
> > > The main problem I have with this is that this is a limited usecase
> > > driven configuration knob which doesn't work properly for other usecases
> > > (namely movable online once your distribution choses to set the config
> > > option to auto online).  
> >
> > it works for default usecase in Fedora and non-default
> > movable can be used with
> >  1) removable memory auto-online as movable in kernel, like
> >     patch [1] would make movable hotplugged memory
> >     (when I have time I'll try to work on it)
> >  2) (or in worst case due to lack of alternative) explicitly
> >     disabled auto-online on kernel CLI + onlining daemon 
> >     (since udev isn't working in current kernel due to ordering issue)  
> 
> So I fail to see how this can work. Say the default will auto online
> all the added memory. This will be all in Zone Normal because the auto
> onlining doesn't do online_movable. Now I would like to online the
> memory as movable but that might fail because some kernel objects might
> be already sitting there so the offline would fail.
same happens with udev rule as currently it can online from
the first to last hotplugged block only as Zone Normal.
see
  arch/x86/mm/init_64.c:
      acpi_memory_enable_device() -> add_memory -> add_memory_resource

both auto online and udev could be fixed by patch
https://bugzilla.redhat.com/attachment.cgi?id=1146332
to online reomovable memory as movable.

> > > There is a userspace solution for this so this
> > > shouldn't have been merged in the first place!  
> > Sorry, currently user-space udev solution doesn't work nor
> > will it work reliably in extreme conditions.
> >   
> > > It sneaked a proper review
> > > process (linux-api wasn't CC to get a broader attenttion) which is
> > > really sad.  
> >
> > get_maintainer.pl doesn't lists linux-api for 31bc3858ea3e,
> > MAINTAINERS should be fixed if linux-api were to be CCed.  
> 
> user visible APIs _should_ be discussed at this mailing list regardless
> what get_maintainer.pl says. This is not about who is the maintainer but
> about getting as wide audience for things that would have to be
> maintained basically for ever.
How would random contributor know which list to CC?

> > > So unless this causes a major regression which would be hard to fix I
> > > will submit the patch for inclusion.  
> > it will be a major regression due to lack of daemon that
> > could online fast and can't be killed on OOM. So this
> > clean up patch does break used feature without providing
> > a viable alternative.  
> 
> So let's discuss the current memory hotplug shortcomings and get rid of
> the crud which developed on top. I will start by splitting up the patch
> into 3 parts. Do the auto online thing from the HyperV and xen balloning
> drivers and dropping the config option and finally drop the sysfs knob.
> The last patch might be NAKed and I can live with that as long as the
> reasoning is proper and there is a general consensus on that.
PS: CC me on that patches too

It's major regression if you remove auto online in kernels that
run on top of x86 kvm/vmware hypervisors, making API cleanups
while breaking useful functionality doesn't make sense.

I would ACK config option removal if auto online keeps working
for all x86 hypervisors (hyperv/xen isn't the only who needs it)
and keep kernel CLI option to override default.

That doesn't mean that others will agree with flipping default,
that's why config option has been added.

Now to sum up what's been discussed on this thread, there were 2
different issues discussed:
  1) memory hotplug: remove in kernel auto online for all
                     except of hyperv/xen

       - suggested RFC is not acceptable from virt point of view
         as it regresses guests on top of x86 kvm/vmware which
         both use ACPI based memory hotplug.

       - udev/userspace solution doesn't work in practice as it's
         too slow and unreliable when system is under load which
         is quite common in virt usecase. That's why auto online
         has been introduced in the first place.

  2) memory unplug: online memory as movable

       - doesn't work currently with udev rule due to kernel
         issues https://bugzilla.redhat.com/show_bug.cgi?id=1314306#c7

       - could be fixed both for in kernel auto online and udev
         with following patch:
         https://bugzilla.redhat.com/attachment.cgi?id=1146332
         but fixing it this way exposes zone disbalance issues,
         which are not present in current kernel as blocks are
         onlined in Zone Normal. So this is area to work and
         improve on.

       - currently if one wants to use online_movable,
         one has to either
           * disable auto online in kernel OR
           * remove udev rule that distro ships
         AND write custom daemon that will be able to online
         block in right zone/order. So currently whole
         online_movable thing isn't working by default
         regardless of who onlines memory.

         I'm in favor of implementing that in kernel as it keeps
         kernel internals inside kernel and doesn't need
         kernel API to be involved (memory blocks in sysfs,
         online_kernel, online_movable)
         There would be no need in userspace which would have to
         deal with kernel zoo and maintain that as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
