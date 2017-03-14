Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6BCB6B0393
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 15:35:26 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 9so275832698qkk.6
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:35:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x89si3762263qtd.231.2017.03.14.12.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 12:35:25 -0700 (PDT)
Date: Tue, 14 Mar 2017 20:35:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: WTH is going on with memory hotplug sysf interface (was: Re:
 [RFC PATCH] mm, hotplug: get rid of auto_online_blocks)
Message-ID: <20170314193521.GP27056@redhat.com>
References: <20170302180315.78975d4b@nial.brq.redhat.com>
 <20170303082723.GB31499@dhcp22.suse.cz>
 <20170303183422.6358ee8f@nial.brq.redhat.com>
 <20170306145417.GG27953@dhcp22.suse.cz>
 <20170307134004.58343e14@nial.brq.redhat.com>
 <20170309125400.GI11592@dhcp22.suse.cz>
 <20170310135807.GI3753@dhcp22.suse.cz>
 <20170310155333.GN3753@dhcp22.suse.cz>
 <20170310190037.fifahjd47joim6zy@arbab-laptop>
 <20170313092145.GG31518@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313092145.GG31518@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>, Igor Mammedov <imammedo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, Zhang Zhen <zhenzhang.zhang@huawei.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello,

On Mon, Mar 13, 2017 at 10:21:45AM +0100, Michal Hocko wrote:
> On Fri 10-03-17 13:00:37, Reza Arbab wrote:
> > On Fri, Mar 10, 2017 at 04:53:33PM +0100, Michal Hocko wrote:
> > >OK, so while I was playing with this setup some more I probably got why
> > >this is done this way. All new memblocks are added to the zone Normal
> > >where they are accounted as spanned but not present.
> > 
> > It's not always zone Normal. See zone_for_memory(). This leads to a
> > workaround for having to do online_movable in descending block order.
> > Instead of this:
> > 
> > 1. probe block 34, probe block 33, probe block 32, ...
> > 2. online_movable 34, online_movable 33, online_movable 32, ...
> > 
> > you can online_movable the first block before adding the rest:
> 
> I do I enforce that behavior when the probe happens automagically?

What I provided as guide to online as movable in current and older
kernels is:

1) Remove udev rule
2) After adding memory with qemu/libvirt API run in the guest

------- workaround start ----
#!/bin/bash
for i in `ls -d1 /sys/devices/system/memory/memory* | sort -nr -t y -k 5`; do if [ "`cat $i/state`" == "offline" ]; then echo online_movable > $i/state ; fi; done
------- workaround end ----

That's how bad is onlining as movable for memory hotunplug.

> > 1. probe block 32, online_movable 32
> > 2. probe block 33, probe block 34, ...
> > 	- zone_for_memory() will cause these to start Movable
> > 3. online 33, online 34, ...
> > 	- they're already in Movable, so online_movable is equivalentr
> > 
> > I agree with your general sentiment that this stuff is very nonintuitive.
> 
> My criterion for nonintuitive is probably different because I would call
> this _completely_unusable_. Sorry for being so loud about this but the
> more I look into this area the more WTF code I see. This has seen close
> to zero review and seems to be building up more single usecase code on
> top of previous. We need to change this, seriously!

It's not a bug, but when I found it I called it a "constraint" and
when I debugged it (IIRC) it originated here:

	} else if (online_type == MMOP_ONLINE_MOVABLE) {
		if (!zone_can_shift(pfn, nr_pages, ZONE_MOVABLE, &zone_shift))
			return -EINVAL;
	}

Fixing it so you could online as movable even if it wasn't the last
block was in my todo list but then we had other plans.

Unfortunately unless pfn+nr_pages of the newly created Movable zone
matches the end of the normal zone (or whatever was there that has to
be converted to Movable), it will fail onlining as movable.

To fix it is enough to check that everything from pfn to the end of
whatever zone existed there (or the end of the node perhaps safer) can
be converted as movable and just convert the whole thing as movable
instead of stopping at pfn+nr_pages.

Also note, onlining highmem physical ranges as movable requires yet
another config option to be set for the below check to pass
(CONFIG_MOVABLE_NODE=y), which I'm not exactly sure why anybody would
want to set =n, and perhaps would be candidate for dropping well
before considering to drop _DEFAULT_ONLINE and at best it should be
replaced with a kernel parameter to turn off the CONFIG_MOVABLE_NODE=y
behavior.

	if ((zone_idx(zone) > ZONE_NORMAL ||
	    online_type == MMOP_ONLINE_MOVABLE) &&
	    !can_online_high_movable(zone))
		return -EINVAL;

I would suggest to drop the constraints in online_pages and perhaps
also the CONFIG_MOVABLE_NODE option before going to drop the automatic
onlining in kernel.

Because of the above constraint the udev rule is unusable anyway for
onlining memory as movable so that it can be hotunplugged reliably
(well not so reliably, page_migrate does a loop and tries many times
but it occurred to me it failed once to offline and at next try it
worked, temporary page pins with O_DIRECT screw with page_migration,
rightfully so and no easy fix).

After the above constraint is fixed I suggest to look into fixing the
async onlining by making the udev rule run synchronously. Adding 4T to
a 8G guest is perfectly reasonable and normal operation, no excuse for
it to fail as long as you don't pretend such 4T to be unpluggable too
later (which we won't).

As I understand it, the whole point of _DEFFAULT_ONLINE=y is precisely
that it's easier to fix it in kernel than fixing the udev
rule. Furthermore the above constraint for the zone shifting which
breaks online_movable in udev is not an issue for _DEFFAULT_ONLINE=y
because kernel onlining is synchronous by design (no special
synchronous udev rule fix is required) so it can cope fine with the
existing above constraint by onlining as movable from the end of the
last zone in each node so that such constraint never gets in the way.

Extending _DEFFAULT_ONLINE=y so that it can also online as movable has
been worked on.

On a side note, kernelcore=xxx passed to a kernel with
_DEFFAULT_ONLINE=y should already allow to create lots of
hotunpluggable memory onlined automatically as movable (never tested
but I would expect it to work).

After the udev rule can handle adding 4T to a 8G guest and it can
handle onlining memory as movable reliably by just doing
s/online/online_movable/, I think then we can restart the discussion
about the removal of _DEFFAULT_ONLINE=y. As far as I can tell, there
are higher priority and more interesting things to fix in this area
before _DEFFAULT_ONLINE=y can be removed. Either udev gets fixed and
it's reasonably simpler to fix (it will remain slower) or we should
eventually obsolete the udev rule instead, which is why the focus
hasn't been in fixing the udev rule and to replace it instead.

To be clear, I'm not necessarily against eventually removing
_DEFFAULT_ONLINE, but an equally reliable and comparably fast
alternative should be provided first and there's no such alternative
right now.

If s390 has special issues requiring admin or a software hotplug
manager app to enable blocks of memory by hand, the _DEFFAULT_ONLINE
could be then an option selected or not selected by
arch/*/Kconfig. The udev rule is still an automatic action so it's 1:1
with the in-kernel feature. If the in-kernel automatic onlining is not
workable on s390 I would assume the udev rule is also not workable.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
