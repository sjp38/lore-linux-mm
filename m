Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A3FAC6B0388
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 03:57:58 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c143so3569355wmd.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 00:57:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u74si1554530wrc.274.2017.03.15.00.57.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 00:57:57 -0700 (PDT)
Date: Wed, 15 Mar 2017 08:57:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WTH is going on with memory hotplug sysf interface (was: Re:
 [RFC PATCH] mm, hotplug: get rid of auto_online_blocks)
Message-ID: <20170315075755.GC32620@dhcp22.suse.cz>
References: <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
 <20170307134004.58343e14@nial.brq.redhat.com>
 <20170309125400.GI11592@dhcp22.suse.cz>
 <20170310135807.GI3753@dhcp22.suse.cz>
 <20170310155333.GN3753@dhcp22.suse.cz>
 <20170310190037.fifahjd47joim6zy@arbab-laptop>
 <20170313092145.GG31518@dhcp22.suse.cz>
 <20170314193521.GP27056@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170314193521.GP27056@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>, Igor Mammedov <imammedo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Zhang Zhen <zhenzhang.zhang@huawei.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Tue 14-03-17 20:35:21, Andrea Arcangeli wrote:
> Hello,
> 
> On Mon, Mar 13, 2017 at 10:21:45AM +0100, Michal Hocko wrote:
> > On Fri 10-03-17 13:00:37, Reza Arbab wrote:
> > > On Fri, Mar 10, 2017 at 04:53:33PM +0100, Michal Hocko wrote:
> > > >OK, so while I was playing with this setup some more I probably got why
> > > >this is done this way. All new memblocks are added to the zone Normal
> > > >where they are accounted as spanned but not present.
> > > 
> > > It's not always zone Normal. See zone_for_memory(). This leads to a
> > > workaround for having to do online_movable in descending block order.
> > > Instead of this:
> > > 
> > > 1. probe block 34, probe block 33, probe block 32, ...
> > > 2. online_movable 34, online_movable 33, online_movable 32, ...
> > > 
> > > you can online_movable the first block before adding the rest:
> > 
> > I do I enforce that behavior when the probe happens automagically?
> 
> What I provided as guide to online as movable in current and older
> kernels is:
> 
> 1) Remove udev rule
> 2) After adding memory with qemu/libvirt API run in the guest
> 
> ------- workaround start ----
> #!/bin/bash
> for i in `ls -d1 /sys/devices/system/memory/memory* | sort -nr -t y -k 5`; do if [ "`cat $i/state`" == "offline" ]; then echo online_movable > $i/state ; fi; done
> ------- workaround end ----
> 
> That's how bad is onlining as movable for memory hotunplug.

Yeah, this is really yucky. Fortunately, I already have a working prototype
which removes this restriction altogether.

> > > 1. probe block 32, online_movable 32
> > > 2. probe block 33, probe block 34, ...
> > > 	- zone_for_memory() will cause these to start Movable
> > > 3. online 33, online 34, ...
> > > 	- they're already in Movable, so online_movable is equivalentr
> > > 
> > > I agree with your general sentiment that this stuff is very nonintuitive.
> > 
> > My criterion for nonintuitive is probably different because I would call
> > this _completely_unusable_. Sorry for being so loud about this but the
> > more I look into this area the more WTF code I see. This has seen close
> > to zero review and seems to be building up more single usecase code on
> > top of previous. We need to change this, seriously!
> 
> It's not a bug, but when I found it I called it a "constraint" and
> when I debugged it (IIRC) it originated here:
> 
> 	} else if (online_type == MMOP_ONLINE_MOVABLE) {
> 		if (!zone_can_shift(pfn, nr_pages, ZONE_MOVABLE, &zone_shift))
> 			return -EINVAL;
> 	}
> 
> Fixing it so you could online as movable even if it wasn't the last
> block was in my todo list but then we had other plans.
> 
> Unfortunately unless pfn+nr_pages of the newly created Movable zone
> matches the end of the normal zone (or whatever was there that has to
> be converted to Movable), it will fail onlining as movable.

Well, I think the main problem is that we associate pages added in the
first phase (probe) to the Normal zone. The everything else is just a
fallout and fiddling to make it work somehow.
 
[...]

> To be clear, I'm not necessarily against eventually removing
> _DEFFAULT_ONLINE, but an equally reliable and comparably fast
> alternative should be provided first and there's no such alternative
> right now.

As pointed in other reply that is not an intention here. I primarily
wanted to understand the scope of the problem. I believe this config
option was rushed into the kernel without considering other alternatives
which would make the hotplug more usable by others as well.
 
> If s390 has special issues requiring admin or a software hotplug
> manager app to enable blocks of memory by hand, the _DEFFAULT_ONLINE
> could be then an option selected or not selected by
> arch/*/Kconfig. The udev rule is still an automatic action so it's 1:1
> with the in-kernel feature. If the in-kernel automatic onlining is not
> workable on s390 I would assume the udev rule is also not workable.

But this is not about s390. It is about different usecases which require
different onlining policy and that is the main problem of the hardcoded
one in the kernel. See the other reply.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
