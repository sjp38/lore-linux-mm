Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4416A6B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 06:48:45 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a189so9187562qkc.4
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 03:48:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 10si1122945qts.304.2017.03.15.03.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 03:48:44 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] rework memory hotplug onlining
References: <20170315091347.GA32626@dhcp22.suse.cz>
Date: Wed, 15 Mar 2017 11:48:37 +0100
In-Reply-To: <20170315091347.GA32626@dhcp22.suse.cz> (Michal Hocko's message
	of "Wed, 15 Mar 2017 10:13:48 +0100")
Message-ID: <87shmedddm.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Andi Kleen <ak@linux.intel.com>

Michal Hocko <mhocko@kernel.org> writes:

> Hi,
> this is a follow up for [1]. In short the current semantic of the memory
> hotplug is awkward and hard/impossible to use from the udev to online
> memory as movable. The main problem is that only the last memblock or
> the adjacent to highest movable memblock can be onlined as movable:
> : Let's simulate memory hot online manually
> : # echo 0x100000000 > /sys/devices/system/memory/probe
> : # grep . /sys/devices/system/memory/memory32/valid_zones
> : Normal Movable
> : 
> : which looks reasonably right? Both Normal and Movable zones are allowed
> : 
> : # echo $((0x100000000+(128<<20))) > /sys/devices/system/memory/probe
> : # grep . /sys/devices/system/memory/memory3?/valid_zones
> : /sys/devices/system/memory/memory32/valid_zones:Normal
> : /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> : 
> : Huh, so our valid_zones have changed under our feet...
> : 
> : # echo $((0x100000000+2*(128<<20))) > /sys/devices/system/memory/probe
> : # grep . /sys/devices/system/memory/memory3?/valid_zones
> : /sys/devices/system/memory/memory32/valid_zones:Normal
> : /sys/devices/system/memory/memory33/valid_zones:Normal
> : /sys/devices/system/memory/memory34/valid_zones:Normal Movable
> : 
> : and again. So only the last memblock is considered movable. Let's try to
> : online them now.
> : 
> : # echo online_movable > /sys/devices/system/memory/memory34/state
> : # grep . /sys/devices/system/memory/memory3?/valid_zones
> : /sys/devices/system/memory/memory32/valid_zones:Normal
> : /sys/devices/system/memory/memory33/valid_zones:Normal Movable
> : /sys/devices/system/memory/memory34/valid_zones:Movable Normal
>
> Now consider that the userspace gets the notification when the memblock
> is added. If the udev context tries to online it it will a) race with
> new memblocks showing up which leads to undeterministic behavior and
> b) it will see memblocks ordered in growing physical addresses while
> the only reliable way to online blocks as movable is exactly from other
> directions. This is just plain wrong!
>
> It seems that all this is just started by the semantic introduced by
> 9d99aaa31f59 ("[PATCH] x86_64: Support memory hotadd without sparsemem")
> quite some time ago. When the movable onlinining has been introduced it
> just built on top of this. It seems that the requirement to have
> freshly probed memory associated with the zone normal is no longer
> necessary. HOTPLUG depends on CONFIG_SPARSEMEM these days.
>
> The following blob [2] simply removes all the zone specific operations
> from __add_pages (aka arch_add_memory) path.  Instead we do page->zone
> association from move_pfn_range which is called from online_pages. The
> criterion for movable/normal zone association is really simple now. We
> just have to guarantee that zone Normal is always lower than zone
> Movable. It would be actually sufficient to guarantee they do not
> overlap and that is indeed trivial to implement now. I didn't do that
> yet for simplicity of this change though.
>
> I have lightly tested the patch and nothing really jumped at me. I
> assume there will be some rough edges but it should be sufficient to
> start the discussion at least. Please note the diffstat. We have added
> a lot of code to tweak on top of the previous semantic which is just
> sad. Instead of developing a robust solution the memory hotplug is full
> of tweaks to satisfy particular usecase without longer term plans.
>
> Please note that this is just for x86 now but I will address other
> arches once there is an agreement this is the right approach.
>
> Thoughts, objections?
>

Speaking about long term approach,

(I'm not really familiar with the history of memory zones code so please
bear with me if my questions are stupid)

Currently when we online memory blocks we need to know where to put the
boundary between NORMAL and MOVABLE and this is a very hard decision to
make, no matter if we do this from kernel or from userspace. In theory,
we just want to avoid redundant limitations with future unplug but we
don't really know how much memory we'll need for kernel allocations in
future.

What actually stops us from having the following approach:
1) Everything is added to MOVABLE
2) When we're out of memory for kernel allocations in NORMAL we 'harvest'
the first MOVABLE block and 'convert' it to NORMAL. It may happen that
there is no free pages in this block but it was MOVABLE which means we
can move all allocations somewhere else.
3) Freeing the whole 128mb memblock takes time but we don't need to wait
till it finishes, we just need to satisfy the currently pending
allocation and we can continue moving everything else in the background.

An alternative approach would be to have lists of memblocks which
constitute ZONE_NORMAL and ZONE_MOVABLE instead of a simple 'NORMAL
before MOVABLE' rule we have now but I'm not sure this is a viable
approach with the current code base.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
