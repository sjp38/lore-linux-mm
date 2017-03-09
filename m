Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED7392808C6
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 07:54:06 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u108so20235956wrb.3
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 04:54:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si8620665wrb.170.2017.03.09.04.54.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 04:54:04 -0800 (PST)
Date: Thu, 9 Mar 2017 13:54:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170309125400.GI11592@dhcp22.suse.cz>
References: <20170227154304.GK26504@dhcp22.suse.cz>
 <1488462828-174523-1-git-send-email-imammedo@redhat.com>
 <20170302142816.GK1404@dhcp22.suse.cz>
 <20170302180315.78975d4b@nial.brq.redhat.com>
 <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
 <20170307134004.58343e14@nial.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307134004.58343e14@nial.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz

On Tue 07-03-17 13:40:04, Igor Mammedov wrote:
> On Mon, 6 Mar 2017 15:54:17 +0100
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 03-03-17 18:34:22, Igor Mammedov wrote:
[...]
> > > in current mainline kernel it triggers following code path:
> > > 
> > > online_pages()
> > >   ...
> > >        if (online_type == MMOP_ONLINE_KERNEL) {                                 
> > >                 if (!zone_can_shift(pfn, nr_pages, ZONE_NORMAL, &zone_shift))    
> > >                         return -EINVAL;  
> > 
> > Are you sure? I would expect MMOP_ONLINE_MOVABLE here
> pretty much, reproducer is above so try and see for yourself

I will play with this...
 
[...]
> > > get_maintainer.pl doesn't lists linux-api for 31bc3858ea3e,
> > > MAINTAINERS should be fixed if linux-api were to be CCed.  
> > 
> > user visible APIs _should_ be discussed at this mailing list regardless
> > what get_maintainer.pl says. This is not about who is the maintainer but
> > about getting as wide audience for things that would have to be
> > maintained basically for ever.
>
> How would random contributor know which list to CC?

This should have been brought up during the review process which was
less than sufficient in this case.

> > > > So unless this causes a major regression which would be hard to fix I
> > > > will submit the patch for inclusion.  
> > > it will be a major regression due to lack of daemon that
> > > could online fast and can't be killed on OOM. So this
> > > clean up patch does break used feature without providing
> > > a viable alternative.  
> > 
> > So let's discuss the current memory hotplug shortcomings and get rid of
> > the crud which developed on top. I will start by splitting up the patch
> > into 3 parts. Do the auto online thing from the HyperV and xen balloning
> > drivers and dropping the config option and finally drop the sysfs knob.
> > The last patch might be NAKed and I can live with that as long as the
> > reasoning is proper and there is a general consensus on that.
> PS: CC me on that patches too
> 
> It's major regression if you remove auto online in kernels that
> run on top of x86 kvm/vmware hypervisors, making API cleanups
> while breaking useful functionality doesn't make sense.
> 
> I would ACK config option removal if auto online keeps working
> for all x86 hypervisors (hyperv/xen isn't the only who needs it)
> and keep kernel CLI option to override default.
> 
> That doesn't mean that others will agree with flipping default,
> that's why config option has been added.
> 
> Now to sum up what's been discussed on this thread, there were 2
> different issues discussed:
>   1) memory hotplug: remove in kernel auto online for all
>                      except of hyperv/xen
> 
>        - suggested RFC is not acceptable from virt point of view
>          as it regresses guests on top of x86 kvm/vmware which
>          both use ACPI based memory hotplug.
> 
>        - udev/userspace solution doesn't work in practice as it's
>          too slow and unreliable when system is under load which
>          is quite common in virt usecase. That's why auto online
>          has been introduced in the first place.

Please try to be more specific why "too slow" is a problem. Also how
much slower are we talking about?
 
>   2) memory unplug: online memory as movable
> 
>        - doesn't work currently with udev rule due to kernel
>          issues https://bugzilla.redhat.com/show_bug.cgi?id=1314306#c7

These should be fixed
 
>        - could be fixed both for in kernel auto online and udev
>          with following patch:
>          https://bugzilla.redhat.com/attachment.cgi?id=1146332
>          but fixing it this way exposes zone disbalance issues,
>          which are not present in current kernel as blocks are
>          onlined in Zone Normal. So this is area to work and
>          improve on.
> 
>        - currently if one wants to use online_movable,
>          one has to either
>            * disable auto online in kernel OR

which might not just work because an unmovable allocation could have
made the memblock pinned.

>            * remove udev rule that distro ships
>          AND write custom daemon that will be able to online
>          block in right zone/order. So currently whole
>          online_movable thing isn't working by default
>          regardless of who onlines memory.

my epxperience with onlining full nodes as movable shows this works just
fine (with all the limitations of the movable zones but that is a
separate thing). I haven't played with configurations where movable
zones are sharing the node with other zones.

>          I'm in favor of implementing that in kernel as it keeps
>          kernel internals inside kernel and doesn't need
>          kernel API to be involved (memory blocks in sysfs,
>          online_kernel, online_movable)
>          There would be no need in userspace which would have to
>          deal with kernel zoo and maintain that as well.

The kernel is supposed to provide a proper API and that is sysfs
currently. I am not entirely happy about it either but pulling a lot of
code into the kernel is not the rigth thing to do. Especially when
different usecases require different treatment.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
