Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0816B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 03:27:26 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y51so37392684wry.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 00:27:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 195si1953873wmw.70.2017.03.03.00.27.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 00:27:25 -0800 (PST)
Date: Fri, 3 Mar 2017 09:27:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170303082723.GB31499@dhcp22.suse.cz>
References: <20170227154304.GK26504@dhcp22.suse.cz>
 <1488462828-174523-1-git-send-email-imammedo@redhat.com>
 <20170302142816.GK1404@dhcp22.suse.cz>
 <20170302180315.78975d4b@nial.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302180315.78975d4b@nial.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org

On Thu 02-03-17 18:03:15, Igor Mammedov wrote:
> On Thu, 2 Mar 2017 15:28:16 +0100
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Thu 02-03-17 14:53:48, Igor Mammedov wrote:
> > [...]
> > > When trying to support memory unplug on guest side in RHEL7,
> > > experience shows otherwise. Simplistic udev rule which onlines
> > > added block doesn't work in case one wants to online it as movable.
> > > 
> > > Hotplugged blocks in current kernel should be onlined in reverse
> > > order to online blocks as movable depending on adjacent blocks zone.  
> > 
> > Could you be more specific please? Setting online_movable from the udev
> > rule should just work regardless of the ordering or the state of other
> > memblocks. If that doesn't work I would call it a bug.
> It's rather an implementation constrain than a bug
> for details and workaround patch see
>  [1] https://bugzilla.redhat.com/show_bug.cgi?id=1314306#c7

"You are not authorized to access bug #1314306"

could you paste the reasoning here please?

> patch attached there is limited by another memory hotplug
> issue, which is NORMAL/MOVABLE zone balance, if kernel runs
> on configuration where the most of memory is hot-removable
> kernel might experience lack of memory in zone NORMAL.

yes and that is an inherent problem of movable memory.

> > > Which means simple udev rule isn't usable since it gets event from
> > > the first to the last hotplugged block order. So now we would have
> > > to write a daemon that would
> > >  - watch for all blocks in hotplugged memory appear (how would it know)
> > >  - online them in right order (order might also be different depending
> > >    on kernel version)
> > >    -- it becomes even more complicated in NUMA case when there are
> > >       multiple zones and kernel would have to provide user-space
> > >       with information about zone maps
> > > 
> > > In short current experience shows that userspace approach
> > >  - doesn't solve issues that Vitaly has been fixing (i.e. onlining
> > >    fast and/or under memory pressure) when udev (or something else
> > >    might be killed)  
> > 
> > yeah and that is why the patch does the onlining from the kernel.
> onlining in this patch is limited to hyperv and patch breaks
> auto-online on x86 kvm/vmware/baremetal as they reuse the same
> hotplug path.

Those can use the udev or do you see any reason why they couldn't?

> > > > Can you imagine any situation when somebody actually might want to have
> > > > this knob enabled? From what I understand it doesn't seem to be the
> > > > case.  
> > > For x86:
> > >  * this config option is enabled by default in recent Fedora,  
> > 
> > How do you want to support usecases which really want to online memory
> > as movable? Do you expect those users to disable the option because
> > unless I am missing something the in kernel auto onlining only supporst
> > regular onlining.
>
> current auto onlining config option does what it's been designed for,
> i.e. it onlines hotplugged memory.
> It's possible for non average Fedora user to override default
> (commit 86dd995d6) if she/he needs non default behavior
> (i.e. user knows how to online manually and/or can write
> a daemon that would handle all of nuances of kernel in use).
> 
> For the rest when Fedora is used in cloud and user increases memory
> via management interface of whatever cloud she/he uses, it just works.
> 
> So it's choice of distribution to pick its own default that makes
> majority of user-base happy and this patch removes it without taking
> that in consideration.

You still can have a udev rule to achive the same thing for
non-ballooning based hotplug.

> How to online memory is different issue not related to this patch,
> current default onlining as ZONE_NORMAL works well for scaling
> up VMs.
> 
> Memory unplug is rather new and it doesn't work reliably so far,
> moving onlining to user-space won't really help. Further work
> is need to be done so that it would work reliably.

The main problem I have with this is that this is a limited usecase
driven configuration knob which doesn't work properly for other usecases
(namely movable online once your distribution choses to set the config
option to auto online). There is a userspace solution for this so this
shouldn't have been merged in the first place! It sneaked a proper review
process (linux-api wasn't CC to get a broader attenttion) which is
really sad.

So unless this causes a major regression which would be hard to fix I
will submit the patch for inclusion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
