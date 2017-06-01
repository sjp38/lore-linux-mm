Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D41FA6B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 08:32:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b84so9642083wmh.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 05:32:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 80si34629357wmt.84.2017.06.01.05.32.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 05:32:45 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm, memory_hotplug: fix MMOP_ONLINE_KEEP behavior
References: <20170601083746.4924-1-mhocko@kernel.org>
 <20170601083746.4924-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ad200307-63d1-fe6f-cbc6-09c8cb431b8a@suse.cz>
Date: Thu, 1 Jun 2017 14:32:42 +0200
MIME-Version: 1.0
In-Reply-To: <20170601083746.4924-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/01/2017 10:37 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Heiko Carstens has noticed that the MMOP_ONLINE_KEEP is broken currently
> $ grep . memory3?/valid_zones
> memory34/valid_zones:Normal Movable
> memory35/valid_zones:Normal Movable
> memory36/valid_zones:Normal Movable
> memory37/valid_zones:Normal Movable
> 
> $ echo online_movable > memory34/state
> $ grep . memory3?/valid_zones
> memory34/valid_zones:Movable
> memory35/valid_zones:Movable
> memory36/valid_zones:Movable
> memory37/valid_zones:Movable
> 
> $ echo online > memory36/state
> $ grep . memory3?/valid_zones
> memory34/valid_zones:Movable
> memory36/valid_zones:Normal
> memory37/valid_zones:Movable
> 
> so we have effectivelly punched a hole into the movable zone. The
> problem is that move_pfn_range() check for MMOP_ONLINE_KEEP is wrong.
> It only checks whether the given range is already part of the movable
> zone which is not the case here as only memory34 is in the zone. Fix
> this by using allow_online_pfn_range(..., MMOP_ONLINE_KERNEL) if that
> is false then we can be sure that movable onlining is the right thing to
> do.
> 
> Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Tested-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Fixes: "mm, memory_hotplug: do not associate hotadded memory to zones until online"

Just fold it there before sending to Linus, right?

> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/memory_hotplug.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 0a895df2397e..b3895fd609f4 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -950,11 +950,12 @@ static struct zone * __meminit move_pfn_range(int online_type, int nid,
>  	if (online_type == MMOP_ONLINE_KEEP) {
>  		struct zone *movable_zone = &pgdat->node_zones[ZONE_MOVABLE];
>  		/*
> -		 * MMOP_ONLINE_KEEP inherits the current zone which is
> -		 * ZONE_NORMAL by default but we might be within ZONE_MOVABLE
> -		 * already.
> +		 * MMOP_ONLINE_KEEP defaults to MMOP_ONLINE_KERNEL but use
> +		 * movable zone if that is not possible (e.g. we are within
> +		 * or past the existing movable zone)
>  		 */
> -		if (zone_intersects(movable_zone, start_pfn, nr_pages))
> +		if (!allow_online_pfn_range(nid, start_pfn, nr_pages,
> +					MMOP_ONLINE_KERNEL))
>  			zone = movable_zone;
>  	} else if (online_type == MMOP_ONLINE_MOVABLE) {
>  		zone = &pgdat->node_zones[ZONE_MOVABLE];
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
