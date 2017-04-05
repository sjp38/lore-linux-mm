Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC1836B03A1
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 14:15:07 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z36so2817138wrc.14
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 11:15:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l22si30113235wre.304.2017.04.05.11.15.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 11:15:06 -0700 (PDT)
Date: Wed, 5 Apr 2017 20:15:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170405181502.GU6035@dhcp22.suse.cz>
References: <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
 <20170404164452.GQ15132@dhcp22.suse.cz>
 <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
 <20170404194122.GS15132@dhcp22.suse.cz>
 <20170404214339.6o4c4uhwudyhzbbo@arbab-laptop>
 <20170405064239.GB6035@dhcp22.suse.cz>
 <20170405092427.GG6035@dhcp22.suse.cz>
 <20170405145304.wxzfavqxnyqtrlru@arbab-laptop>
 <20170405154258.GR6035@dhcp22.suse.cz>
 <20170405173248.4vtdgk2kolbzztya@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405173248.4vtdgk2kolbzztya@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed 05-04-17 12:32:49, Reza Arbab wrote:
> On Wed, Apr 05, 2017 at 05:42:59PM +0200, Michal Hocko wrote:
> >But one thing that is really bugging me is how could you see low pfns in
> >the previous oops. Please drop the last patch and sprinkle printks down
> >the remove_memory path to see where this all go south. I believe that
> >there is something in the initialization code lurking in my code. Please
> >also scratch the pfn_valid check in online_pages diff. It will not help
> >here.
> 
> Got it.
> 
> shrink_pgdat_span: start_pfn=0x10000, end_pfn=0x10100, pgdat_start_pfn=0x0, pgdat_end_pfn=0x20000
> 
> The problem is that pgdat_start_pfn here should be 0x10000. As you
> suspected, it never got set. This fixes things for me.
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 623507f..37c1b63 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -884,7 +884,7 @@ static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsigned lon
> {
> 	unsigned long old_end_pfn = pgdat_end_pfn(pgdat);
> 
> -	if (start_pfn < pgdat->node_start_pfn)
> +	if (!pgdat->node_spanned_pages || start_pfn < pgdat->node_start_pfn)
> 		pgdat->node_start_pfn = start_pfn;

Dang! You are absolutely right. This explains the issue during the
remove_memory. I still fail to see how this makes any difference for the
sysfs file registration though. If anything the pgdat will be larger and
so try_offline_node would check also unrelated node0 but the code will
handle that and eventually offline the node1 anyway. /me still confused.
 
> 	pgdat->node_spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - pgdat->node_start_pfn;
> ---
> 
> Along these lines, maybe we should also do
> 
> -	if (start_pfn < zone->zone_start_pfn)
> +	if (zone_is_empty(zone) || start_pfn < zone->zone_start_pfn)

yes we should.

Thanks a lot!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
