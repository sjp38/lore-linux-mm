Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0ED6B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 21:16:29 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 76so106901897pgh.11
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 18:16:29 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id h11si5176865plk.114.2017.06.29.18.16.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 18:16:28 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id f127so13609822pgc.2
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 18:16:28 -0700 (PDT)
Date: Fri, 30 Jun 2017 10:16:20 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
Message-ID: <20170630011618.GB13062@js1304-desktop>
References: <20170629073509.623-1-mhocko@kernel.org>
 <20170629073509.623-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170629073509.623-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Jun 29, 2017 at 09:35:09AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Historically we have enforced that any kernel zone (e.g ZONE_NORMAL) has
> to precede the Movable zone in the physical memory range. The purpose of
> the movable zone is, however, not bound to any physical memory restriction.
> It merely defines a class of migrateable and reclaimable memory.
> 
> There are users (e.g. CMA) who might want to reserve specific physical
> memory ranges for their own purpose. Moreover our pfn walkers have to be
> prepared for zones overlapping in the physical range already because we
> do support interleaving NUMA nodes and therefore zones can interleave as
> well. This means we can allow each memory block to be associated with a
> different zone.
> 
> Loosen the current onlining semantic and allow explicit onlining type on
> any memblock. That means that online_{kernel,movable} will be allowed
> regardless of the physical address of the memblock as long as it is
> offline of course. This might result in moveble zone overlapping with
> other kernel zones. Default onlining then becomes a bit tricky but still
> sensible. echo online > memoryXY/state will online the given block to
> 	1) the default zone if the given range is outside of any zone
> 	2) the enclosing zone if such a zone doesn't interleave with
> 	   any other zone
>         3) the default zone if more zones interleave for this range
> where default zone is movable zone only if movable_node is enabled
> otherwise it is a kernel zone.
> 
> Here is an example of the semantic with (movable_node is not present but
> it work in an analogous way). We start with following memblocks, all of
> them offline
> memory34/valid_zones:Normal Movable
> memory35/valid_zones:Normal Movable
> memory36/valid_zones:Normal Movable
> memory37/valid_zones:Normal Movable
> memory38/valid_zones:Normal Movable
> memory39/valid_zones:Normal Movable
> memory40/valid_zones:Normal Movable
> memory41/valid_zones:Normal Movable
> 
> Now, we online block 34 in default mode and block 37 as movable
> root@test1:/sys/devices/system/node/node1# echo online > memory34/state
> root@test1:/sys/devices/system/node/node1# echo online_movable > memory37/state
> memory34/valid_zones:Normal
> memory35/valid_zones:Normal Movable
> memory36/valid_zones:Normal Movable
> memory37/valid_zones:Movable
> memory38/valid_zones:Normal Movable
> memory39/valid_zones:Normal Movable
> memory40/valid_zones:Normal Movable
> memory41/valid_zones:Normal Movable
> 
> As we can see all other blocks can still be onlined both into Normal and
> Movable zones and the Normal is default because the Movable zone spans
> only block37 now.
> root@test1:/sys/devices/system/node/node1# echo online_movable > memory41/state
> memory34/valid_zones:Normal
> memory35/valid_zones:Normal Movable
> memory36/valid_zones:Normal Movable
> memory37/valid_zones:Movable
> memory38/valid_zones:Movable Normal
> memory39/valid_zones:Movable Normal
> memory40/valid_zones:Movable Normal
> memory41/valid_zones:Movable
> 
> Now the default zone for blocks 37-41 has changed because movable zone
> spans that range.
> root@test1:/sys/devices/system/node/node1# echo online_kernel > memory39/state
> memory34/valid_zones:Normal
> memory35/valid_zones:Normal Movable
> memory36/valid_zones:Normal Movable
> memory37/valid_zones:Movable
> memory38/valid_zones:Normal Movable
> memory39/valid_zones:Normal
> memory40/valid_zones:Movable Normal
> memory41/valid_zones:Movable
> 
> Note that the block 39 now belongs to the zone Normal and so block38
> falls into Normal by default as well.
> 
> For completness
> root@test1:/sys/devices/system/node/node1# for i in memory[34]?
> do
> 	echo online > $i/state 2>/dev/null
> done
> 
> memory34/valid_zones:Normal
> memory35/valid_zones:Normal
> memory36/valid_zones:Normal
> memory37/valid_zones:Movable
> memory38/valid_zones:Normal
> memory39/valid_zones:Normal
> memory40/valid_zones:Movable
> memory41/valid_zones:Movable
> 
> Implementation wise the change is quite straightforward. We can get rid
> of allow_online_pfn_range altogether. online_pages allows only offline
> nodes already. The original default_zone_for_pfn will become
> default_kernel_zone_for_pfn. New default_zone_for_pfn implements the
> above semantic. zone_for_pfn_range is slightly reorganized to implement
> kernel and movable online type explicitly and MMOP_ONLINE_KEEP becomes
> a catch all default behavior.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

I appreaciate your help!

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
