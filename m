Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64AB26B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 12:34:33 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id u81so37808629uau.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 09:34:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c69si9811373qkj.135.2017.03.03.09.34.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 09:34:32 -0800 (PST)
Date: Fri, 3 Mar 2017 18:34:22 +0100
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170303183422.6358ee8f@nial.brq.redhat.com>
In-Reply-To: <20170303082723.GB31499@dhcp22.suse.cz>
References: <20170227154304.GK26504@dhcp22.suse.cz>
	<1488462828-174523-1-git-send-email-imammedo@redhat.com>
	<20170302142816.GK1404@dhcp22.suse.cz>
	<20170302180315.78975d4b@nial.brq.redhat.com>
	<20170303082723.GB31499@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y.
 Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz

On Fri, 3 Mar 2017 09:27:23 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 02-03-17 18:03:15, Igor Mammedov wrote:
> > On Thu, 2 Mar 2017 15:28:16 +0100
> > Michal Hocko <mhocko@kernel.org> wrote:
> >   
> > > On Thu 02-03-17 14:53:48, Igor Mammedov wrote:
> > > [...]  
> > > > When trying to support memory unplug on guest side in RHEL7,
> > > > experience shows otherwise. Simplistic udev rule which onlines
> > > > added block doesn't work in case one wants to online it as movable.
> > > > 
> > > > Hotplugged blocks in current kernel should be onlined in reverse
> > > > order to online blocks as movable depending on adjacent blocks zone.    
> > > 
> > > Could you be more specific please? Setting online_movable from the udev
> > > rule should just work regardless of the ordering or the state of other
> > > memblocks. If that doesn't work I would call it a bug.  
> > It's rather an implementation constrain than a bug
> > for details and workaround patch see
> >  [1] https://bugzilla.redhat.com/show_bug.cgi?id=1314306#c7  
> 
> "You are not authorized to access bug #1314306"
Sorry,
I've made it public, related comments and patch should be accessible now
(code snippets in BZ are based on older kernel but logic is still the same upstream)
 
> could you paste the reasoning here please?
sure here is reproducer:
start VM with CLI:
  qemu-system-x86_64  -enable-kvm -m size=1G,slots=2,maxmem=4G -numa node \
  -object memory-backend-ram,id=m1,size=1G -device pc-dimm,node=0,memdev=m1 \
  /path/to/guest_image

then in guest dimm1 blocks are from 32-39

  echo online_movable > /sys/devices/system/memory/memory32/state
-bash: echo: write error: Invalid argument

in current mainline kernel it triggers following code path:

online_pages()
  ...
       if (online_type == MMOP_ONLINE_KERNEL) {                                 
                if (!zone_can_shift(pfn, nr_pages, ZONE_NORMAL, &zone_shift))    
                        return -EINVAL;

  zone_can_shift()
    ...
        if (idx < target) {                                                      
                /* pages must be at end of current zone */                       
                if (pfn + nr_pages != zone_end_pfn(zone))                        
                        return false;            

since we are trying to online as movable not the last section in
ZONE_NORMAL.

Here is what makes hotplugged memory end up in ZONE_NORMAL:
 acpi_memory_enable_device() -> add_memory -> add_memory_resource ->
   -> arch/x86/mm/init_64.c  

     /*
      * Memory is added always to NORMAL zone. This means you will never get
      * additional DMA/DMA32 memory.
      */
     int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
     {
        ...
        struct zone *zone = pgdat->node_zones +
                zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);

i.e. all hot-plugged memory modules always go to ZONE_NORMAL
and only the first/last block in zone is allowed to be moved
to another zone. Patch [1] tries to fix issue by assigning
removable memory resource to movable zone so hotplugged+removable
blocks look like:
  movable normal, movable, movable
instead of current:
  normal, normal, normal movable

but then with this fixed as suggested, auto online by default
should work just fine in kernel with normal and movable zones
without any need for user-space.

> > patch attached there is limited by another memory hotplug
> > issue, which is NORMAL/MOVABLE zone balance, if kernel runs
> > on configuration where the most of memory is hot-removable
> > kernel might experience lack of memory in zone NORMAL.  
> 
> yes and that is an inherent problem of movable memory.
> 
> > > > Which means simple udev rule isn't usable since it gets event from
> > > > the first to the last hotplugged block order. So now we would have
> > > > to write a daemon that would
> > > >  - watch for all blocks in hotplugged memory appear (how would it know)
> > > >  - online them in right order (order might also be different depending
> > > >    on kernel version)
> > > >    -- it becomes even more complicated in NUMA case when there are
> > > >       multiple zones and kernel would have to provide user-space
> > > >       with information about zone maps
> > > > 
> > > > In short current experience shows that userspace approach
> > > >  - doesn't solve issues that Vitaly has been fixing (i.e. onlining
> > > >    fast and/or under memory pressure) when udev (or something else
> > > >    might be killed)    
> > > 
> > > yeah and that is why the patch does the onlining from the kernel.  
> > onlining in this patch is limited to hyperv and patch breaks
> > auto-online on x86 kvm/vmware/baremetal as they reuse the same
> > hotplug path.  
> 
> Those can use the udev or do you see any reason why they couldn't?
Reasons are above, under >>>> and >> quotations, patch breaks
what Vitaly's fixed (including kvm/vmware usecases) i.e. udev/some
user-space process could be killed if hotplugged memory isn't onlined
fast enough leading to service termination and/or memory not
being onlined at all (if udev is killed)

Currently udev rule is not usable and one needs a daemon
which would correctly do onlining and keep zone balance
even for simple case usecase of 1 normal and 1 movable zone.
And it gets more complicated in case of multiple numa nodes
with multiple zones.

> > > > > Can you imagine any situation when somebody actually might want to have
> > > > > this knob enabled? From what I understand it doesn't seem to be the
> > > > > case.    
> > > > For x86:
> > > >  * this config option is enabled by default in recent Fedora,    
> > > 
> > > How do you want to support usecases which really want to online memory
> > > as movable? Do you expect those users to disable the option because
> > > unless I am missing something the in kernel auto onlining only supporst
> > > regular onlining.  
> >
> > current auto onlining config option does what it's been designed for,
> > i.e. it onlines hotplugged memory.
> > It's possible for non average Fedora user to override default
> > (commit 86dd995d6) if she/he needs non default behavior
> > (i.e. user knows how to online manually and/or can write
> > a daemon that would handle all of nuances of kernel in use).
> > 
> > For the rest when Fedora is used in cloud and user increases memory
> > via management interface of whatever cloud she/he uses, it just works.
> > 
> > So it's choice of distribution to pick its own default that makes
> > majority of user-base happy and this patch removes it without taking
> > that in consideration.  
> 
> You still can have a udev rule to achive the same thing for
> non-ballooning based hotplug.
not in case when system is under load, udev path might be slow
and udev might be killed by OOM leading to permanent disablement
of memory onlining.
 
> > How to online memory is different issue not related to this patch,
> > current default onlining as ZONE_NORMAL works well for scaling
> > up VMs.
> > 
> > Memory unplug is rather new and it doesn't work reliably so far,
> > moving onlining to user-space won't really help. Further work
> > is need to be done so that it would work reliably.  
> 
> The main problem I have with this is that this is a limited usecase
> driven configuration knob which doesn't work properly for other usecases
> (namely movable online once your distribution choses to set the config
> option to auto online).
it works for default usecase in Fedora and non-default
movable can be used with
 1) removable memory auto-online as movable in kernel, like
    patch [1] would make movable hotplugged memory
    (when I have time I'll try to work on it)
 2) (or in worst case due to lack of alternative) explicitly
    disabled auto-online on kernel CLI + onlining daemon 
    (since udev isn't working in current kernel due to ordering issue)

> There is a userspace solution for this so this
> shouldn't have been merged in the first place!
Sorry, currently user-space udev solution doesn't work nor
will it work reliably in extreme conditions.

> It sneaked a proper review
> process (linux-api wasn't CC to get a broader attenttion) which is
> really sad.
get_maintainer.pl doesn't lists linux-api for 31bc3858ea3e,
MAINTAINERS should be fixed if linux-api were to be CCed.

> So unless this causes a major regression which would be hard to fix I
> will submit the patch for inclusion.
it will be a major regression due to lack of daemon that
could online fast and can't be killed on OOM. So this
clean up patch does break used feature without providing
a viable alternative.

I wouldn't object to removing config option as in this patch
if memory were onlined for x86 by default but that's not the case yet.


[1] https://bugzilla.redhat.com/attachment.cgi?id=1146332

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
