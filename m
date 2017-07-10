Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4E7440844
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 07:12:20 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g46so23431606wrd.3
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 04:12:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e84si1953117wme.194.2017.07.10.04.12.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 04:12:18 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
References: <20170629073509.623-1-mhocko@kernel.org>
 <20170629073509.623-3-mhocko@kernel.org>
 <64e889ae-24ab-b845-5751-978a76dd0dd9@suse.cz>
 <20170710064540.GA19185@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <24c3606d-837a-266d-a294-7e100d1430f0@suse.cz>
Date: Mon, 10 Jul 2017 13:11:29 +0200
MIME-Version: 1.0
In-Reply-To: <20170710064540.GA19185@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 07/10/2017 08:45 AM, Michal Hocko wrote:
> On Fri 07-07-17 17:02:59, Vlastimil Babka wrote:
>> [+CC linux-api]
>>
>> On 06/29/2017 09:35 AM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> Historically we have enforced that any kernel zone (e.g ZONE_NORMAL) has
>>> to precede the Movable zone in the physical memory range. The purpose of
>>> the movable zone is, however, not bound to any physical memory restriction.
>>> It merely defines a class of migrateable and reclaimable memory.
>>>
>>> There are users (e.g. CMA) who might want to reserve specific physical
>>> memory ranges for their own purpose. Moreover our pfn walkers have to be
>>> prepared for zones overlapping in the physical range already because we
>>> do support interleaving NUMA nodes and therefore zones can interleave as
>>> well. This means we can allow each memory block to be associated with a
>>> different zone.
>>>
>>> Loosen the current onlining semantic and allow explicit onlining type on
>>> any memblock. That means that online_{kernel,movable} will be allowed
>>> regardless of the physical address of the memblock as long as it is
>>> offline of course. This might result in moveble zone overlapping with
>>> other kernel zones. Default onlining then becomes a bit tricky but still
>>> sensible. echo online > memoryXY/state will online the given block to
>>> 	1) the default zone if the given range is outside of any zone
>>> 	2) the enclosing zone if such a zone doesn't interleave with
>>> 	   any other zone
>>>         3) the default zone if more zones interleave for this range
>>> where default zone is movable zone only if movable_node is enabled
>>> otherwise it is a kernel zone.
>>>
>>> Here is an example of the semantic with (movable_node is not present but
>>> it work in an analogous way). We start with following memblocks, all of
>>> them offline
>>> memory34/valid_zones:Normal Movable
>>> memory35/valid_zones:Normal Movable
>>> memory36/valid_zones:Normal Movable
>>> memory37/valid_zones:Normal Movable
>>> memory38/valid_zones:Normal Movable
>>> memory39/valid_zones:Normal Movable
>>> memory40/valid_zones:Normal Movable
>>> memory41/valid_zones:Normal Movable
>>>
>>> Now, we online block 34 in default mode and block 37 as movable
>>> root@test1:/sys/devices/system/node/node1# echo online > memory34/state
>>> root@test1:/sys/devices/system/node/node1# echo online_movable > memory37/state
>>> memory34/valid_zones:Normal
>>> memory35/valid_zones:Normal Movable
>>> memory36/valid_zones:Normal Movable
>>> memory37/valid_zones:Movable
>>> memory38/valid_zones:Normal Movable
>>> memory39/valid_zones:Normal Movable
>>> memory40/valid_zones:Normal Movable
>>> memory41/valid_zones:Normal Movable
>>
>> Hm so previously, blocks 37-41 would only allow Movable at this point, right?
> 
> yes
> 
>> Shouldn't we still default to Movable for them? We might be breaking some
>> existing userspace here.
> 
> I do not think so. Prior to this merge window f1dd2cd13c4b ("mm,
> memory_hotplug: do not associate hotadded memory to zones until online")
> we allowed only the last offline or the adjacent to existing movable
> memory block to be onlined movable. So the above wasn't possible.

Not exactly the above, but let's say 1-34 is onlined as Normal, 35-37 is
Movable. Then the only possible action before would be online 38 as
Movable? Now it defaults to Normal?

> I
> doubt we have grown a new user since the rework has been merged but if
> you think we should make sure nothing like that happens then we should
> probably merge this patch in this release cycle.

If I'm right and this is a change compared to pre-rework, then it
doesn't matter.

>> IMHO onlining new memory past existing blocks is more common use case than
>> onlining memory between two blocks that are already online?
> 
> I am not really sure. It is quite common to online and offline within an
> existing zones for the memory ballooning. I do not know what kind of
> online operation they use but using the default online operation has
> historically preserved the zone so I would be really reluctant to change
> that.

Hmm all right, ballooning...

>> I also agree with Wei Yang that it's rather fuzzy that a zone that has been
>> completely offlined will affect the defaults for the next onlining just because
>> it has some spanned range, which is however empty of actual populated memory.
> 
> I am sorry but I still do not see why. The zone is not empty. It has a
> range spanned. It just doesn't have any pages online. I really fail to
> see how that is different from zones with large offline holes.
> 
>> Maybe it would simplest for everyone to just default to Normal, except
>> movable_node? That's if we decide that the potential breakage I
>> described above is a non-issue.
> 
> This would break the usecase where the memory is onlined a certain type
> initially and the offline/online it later on demand for ballooning.
> 
> I wish this could be more clear but the default onlining has been fuzzy
> since the movable online has been introduced and it is hard to buil
> something really clear since then. The proposed semantic is the most
> clean I could come up with but I am open to any suggestions that
> wouldn't break existing usage.

OK I can live with the semantics, if we clear question of breaking
existing users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
