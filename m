Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B224440844
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 07:17:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so23447477wrb.6
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 04:17:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x4si6179041wmg.27.2017.07.10.04.17.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 04:17:52 -0700 (PDT)
Date: Mon, 10 Jul 2017 13:17:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
Message-ID: <20170710111750.GG19185@dhcp22.suse.cz>
References: <20170629073509.623-1-mhocko@kernel.org>
 <20170629073509.623-3-mhocko@kernel.org>
 <64e889ae-24ab-b845-5751-978a76dd0dd9@suse.cz>
 <20170710064540.GA19185@dhcp22.suse.cz>
 <24c3606d-837a-266d-a294-7e100d1430f0@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24c3606d-837a-266d-a294-7e100d1430f0@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon 10-07-17 13:11:29, Vlastimil Babka wrote:
> On 07/10/2017 08:45 AM, Michal Hocko wrote:
> > On Fri 07-07-17 17:02:59, Vlastimil Babka wrote:
> >> [+CC linux-api]
> >>
> >> On 06/29/2017 09:35 AM, Michal Hocko wrote:
> >>> From: Michal Hocko <mhocko@suse.com>
> >>>
> >>> Historically we have enforced that any kernel zone (e.g ZONE_NORMAL) has
> >>> to precede the Movable zone in the physical memory range. The purpose of
> >>> the movable zone is, however, not bound to any physical memory restriction.
> >>> It merely defines a class of migrateable and reclaimable memory.
> >>>
> >>> There are users (e.g. CMA) who might want to reserve specific physical
> >>> memory ranges for their own purpose. Moreover our pfn walkers have to be
> >>> prepared for zones overlapping in the physical range already because we
> >>> do support interleaving NUMA nodes and therefore zones can interleave as
> >>> well. This means we can allow each memory block to be associated with a
> >>> different zone.
> >>>
> >>> Loosen the current onlining semantic and allow explicit onlining type on
> >>> any memblock. That means that online_{kernel,movable} will be allowed
> >>> regardless of the physical address of the memblock as long as it is
> >>> offline of course. This might result in moveble zone overlapping with
> >>> other kernel zones. Default onlining then becomes a bit tricky but still
> >>> sensible. echo online > memoryXY/state will online the given block to
> >>> 	1) the default zone if the given range is outside of any zone
> >>> 	2) the enclosing zone if such a zone doesn't interleave with
> >>> 	   any other zone
> >>>         3) the default zone if more zones interleave for this range
> >>> where default zone is movable zone only if movable_node is enabled
> >>> otherwise it is a kernel zone.
> >>>
> >>> Here is an example of the semantic with (movable_node is not present but
> >>> it work in an analogous way). We start with following memblocks, all of
> >>> them offline
> >>> memory34/valid_zones:Normal Movable
> >>> memory35/valid_zones:Normal Movable
> >>> memory36/valid_zones:Normal Movable
> >>> memory37/valid_zones:Normal Movable
> >>> memory38/valid_zones:Normal Movable
> >>> memory39/valid_zones:Normal Movable
> >>> memory40/valid_zones:Normal Movable
> >>> memory41/valid_zones:Normal Movable
> >>>
> >>> Now, we online block 34 in default mode and block 37 as movable
> >>> root@test1:/sys/devices/system/node/node1# echo online > memory34/state
> >>> root@test1:/sys/devices/system/node/node1# echo online_movable > memory37/state
> >>> memory34/valid_zones:Normal
> >>> memory35/valid_zones:Normal Movable
> >>> memory36/valid_zones:Normal Movable
> >>> memory37/valid_zones:Movable
> >>> memory38/valid_zones:Normal Movable
> >>> memory39/valid_zones:Normal Movable
> >>> memory40/valid_zones:Normal Movable
> >>> memory41/valid_zones:Normal Movable
> >>
> >> Hm so previously, blocks 37-41 would only allow Movable at this point, right?
> > 
> > yes
> > 
> >> Shouldn't we still default to Movable for them? We might be breaking some
> >> existing userspace here.
> > 
> > I do not think so. Prior to this merge window f1dd2cd13c4b ("mm,
> > memory_hotplug: do not associate hotadded memory to zones until online")
> > we allowed only the last offline or the adjacent to existing movable
> > memory block to be onlined movable. So the above wasn't possible.
> 
> Not exactly the above, but let's say 1-34 is onlined as Normal, 35-37 is
> Movable. Then the only possible action before would be online 38 as
> Movable? Now it defaults to Normal?

Yes. And let me repeat you couldn't onlne 35-37 as movable before. So no
userspace could depend on that before the rework. Or do I still miss
your point?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
