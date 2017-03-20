Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F04A6B0038
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 02:33:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d66so14445648wmi.2
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 23:33:04 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id w40si21574379wrc.185.2017.03.19.23.33.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 23:33:03 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id n11so55215802wma.1
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 23:33:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170316190125.GT27056@redhat.com>
References: <20170315091347.GA32626@dhcp22.suse.cz> <87shmedddm.fsf@vitty.brq.redhat.com>
 <20170315122914.GG32620@dhcp22.suse.cz> <87k27qd7m2.fsf@vitty.brq.redhat.com>
 <20170315131139.GK32620@dhcp22.suse.cz> <20170315163729.GR27056@redhat.com>
 <20170316053122.GA14701@js1304-P5Q-DELUXE> <20170316190125.GT27056@redhat.com>
From: Joonsoo Kim <js1304@gmail.com>
Date: Mon, 20 Mar 2017 15:33:01 +0900
Message-ID: <CAAmzW4OR7GREYv3LVE5LVOdEDGEfyGLaZNMg2ZBhO7niAakLAw@mail.gmail.com>
Subject: Re: ZONE_NORMAL vs. ZONE_MOVABLE
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Vitaly Kuznetsov <vkuznets@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Xishi Qiu <qiuxishi@huawei.com>, Toshi Kani <toshi.kani@hpe.com>, xieyisheng1@huawei.com, slaoub@gmail.com, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Andi Kleen <ak@linux.intel.com>

2017-03-17 4:01 GMT+09:00 Andrea Arcangeli <aarcange@redhat.com>:
> Hello Joonsoo,

Hello, Andrea.

> On Thu, Mar 16, 2017 at 02:31:22PM +0900, Joonsoo Kim wrote:
>> I don't follow up previous discussion so please let me know if I miss
>> something. I'd just like to mention about sticky pageblocks.
>
> The interesting part of the previous discussion relevant for the
> sticky movable pageblock is this part from Vitaly:
>
> === quote ===
> Now we have
>
> [Normal][Normal][Normal][Movable][Movable][Movable]
>
> we could have
>
> [Normal][Normal][Movable][Normal][Movable][Normal]
> === quote ===
>
> Suppose you're an admin you can try to do starting from an
> all-offlined hotplug memory:
>
> kvm ~ # cat /sys/devices/system/memory/memory3[6-9]/online
> 0
> 0
> 0
> 0
> kvm ~ # python ~andrea/zoneinfo.py
> Zone: DMA       Present: 15M    Managed: 15M    Start: 0M       End: 16M
> Zone: DMA32     Present: 2031M  Managed: 1892M  Start: 16M      End: 2047M
>
> All hotplug memory is offline, no Movable zone.
>
> Then you online interleaved:
>
> kvm ~ # echo online_movable > /sys/devices/system/memory/memory39/online
> kvm ~ # python ~andrea/zoneinfo.py
> Zone: DMA       Present: 15M    Managed: 15M    Start: 0M       End: 16M
> Zone: DMA32     Present: 2031M  Managed: 1892M  Start: 16M      End: 2047M
> Zone: Movable   Present: 128M   Managed: 128M   Start: 4.9G     End: 5.0G
> kvm ~ # echo online > /sys/devices/system/memory/memory38/online
> kvm ~ # python ~andrea/zoneinfo.py
> Zone: DMA       Present: 15M    Managed: 15M    Start: 0M       End: 16M
> Zone: DMA32     Present: 2031M  Managed: 1892M  Start: 16M      End: 2047M
> Zone: Normal    Present: 128M   Managed: 128M   Start: 4.0G     End: 4.9G
> Zone: Movable   Present: 128M   Managed: 128M   Start: 4.9G     End: 5.0G
>
> So far so good.
>
> kvm ~ # echo online_movable > /sys/devices/system/memory/memory37/online
> kvm ~ # python ~andrea/zoneinfo.py
> Zone: DMA       Present: 15M    Managed: 15M    Start: 0M       End: 16M
> Zone: DMA32     Present: 2031M  Managed: 1892M  Start: 16M      End: 2047M
> Zone: Normal    Present: 256M   Managed: 256M   Start: 4.0G     End: 4.9G
> Zone: Movable   Present: 128M   Managed: 128M   Start: 4.9G     End: 5.0G
>
> Oops you thought you onlined movable memory37 but instead it silently
> went in the normal zone (without even erroring out) and it's
> definitely not going to be unpluggable and it's definitely non
> movable.... all falls apart here. Admin won't run my zoneinfo.py
> script that I had write specifically to understand what a mess what
> was happening with online_movable interleaved.
>
> The admin is much better off not touching
> /sys/devices/system/memory/memory37 ever, and just use the in-kernel
> onlining, at the very least until udev and sys interface are fixed for
> both movable and non-movable hotplug onlining.

Thanks for explanation. Now, I understand the issue correctly.

>> Before that, I'd like to say that a lot of code already deals with zone
>> overlap. Zone overlap exists for a long time although I don't know exact
>> history. IIRC, Mel fixed such a case before and compaction code has a
>> check for it. And, I added the overlap check to some pfn iterators which
>> doesn't have such a check for preparation of introducing a new zone,
>> ZONE_CMA, which has zone range overlap property. See following commits.
>>
>> 'ba6b097', '9d43f5a', 'a91c43c'.
>>
>
> So you suggest to create a full overlap like:
>
>      --------------- Movable --------------
>      --------------- Normal  --------------
>
> Then search for pages in the Movable zone buddy which will only
> contain those that are onlined with echo online_movable?

Yes. Full overlap would be the worst case but it's possible and it
would work well(?) even in current kernel.

>> Come to my main topic, I disagree that sticky pageblock would be
>> superior to the current separate zone approach. There is some reasons
>> about the objection to sticky movable pageblock in following link.
>>
>> Sticky movable pageblock is conceptually same with MIGRATE_CMA and it
>> will cause many subtle issues like as MIGRATE_CMA did for CMA users.
>> MIGRATE_CMA introduces many hooks in various code path, and, to fix the
>> remaining issues, it needs more hooks. I don't think it is
>
> I'm not saying the sticky movable pageblocks are the way to go, to the
> contrary we're saying the Movable zone constraints can better be
> satisfied by the in-kernel onlining mechanism and it's overall much
> simpler for the user to use the in-kernel onlining, than in trying to
> fix udev to be synchronous and implementing sticky movable pageblocks
> to make the /sys interface usable without unexpected side effects. And
> I would suggest to look into dropping the MOVABLE_NODE config option
> first (and turn it in a kernel parameter if something).

Okay.

> I agree sticky movable pageblocks may slowdown things and increase
> complexity so it'd be better not having to implement those.
>
>> maintainable approach. If you see following link which implements ZONE
>> approach, you can see that many hooks are removed in the end.
>>
>> lkml.kernel.org/r/1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com
>>
>> I don't know exact requirement on memory hotplug so it would be
>> possible that ZONE approach is not suitable for it. But, anyway, sticky
>> pageblock seems not to be a good solution to me.
>
> The fact sticky movable pageblocks aren't ideal for CMA doesn't mean
> they're not ideal for memory hotunplug though.
>
> With CMA there's no point in having the sticky movable pageblocks
> scattered around and it's purely a misfeature to use sticky movable
> pageblocks because you need the whole CMA area contiguous hence a
> ZONE_CMA is ideal.

No. CMA ranges could be registered many times for each devices and they
could be scattered due to device's H/W limitation. So, current implementation
in kernel, MIGRATE_CMA pageblocks, are scattered sometimes.

> As opposed with memory hotplug the sticky movable pageblocks would
> allow the kernel to satisfy the current /sys API and they would
> provide no downside unlike in the CMA case where the size of the
> allocation is unknown.

No, same downside also exists in this case. Downside is not related to the case
that device uses that range. It is related to VM management to this range and
problems are the same. For example, with sticky movable pageblock, we need to
subtract number of freepages in sticky movable pageblock when watermark is
checked for non-movable allocation and it causes some problems.

> If we can make zone overlap work with a 100% overlap across the whole
> node that would be a fine alternative, the zoneinfo.py output will
> look weird, but if that's the only downside it's no big deal. With
> sticky movable pageblocks it'll all be ZONE_NORMAL, with overlap it'll
> all be both ZONE_NORMAL and ZONE_MOVABLE at the same time.

Okay.

> Again with the in-kernel onlining none of the above is necessary as
> nobody should then need to echo online/online_movable >memory*/enabled
> ever again and it can all be obsoleted. So before dropping the only
> option we have that works flawlessly, we should fix all the above in
> udev, /sys and provide full zone overlap or sticky movable pageblocks.

Okay.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
