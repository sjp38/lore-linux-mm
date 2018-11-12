Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA7ED6B0287
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 09:26:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y23-v6so4678732eds.12
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 06:26:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6sor7155117edx.21.2018.11.12.06.26.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 06:26:44 -0800 (PST)
Date: Mon, 12 Nov 2018 14:26:41 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: skip zone who has no managed_pages in
 calculate_totalreserve_pages()
Message-ID: <20181112142641.6oxn4fv4pocm7fmt@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181112071404.13620-1-richard.weiyang@gmail.com>
 <20181112080926.GA14987@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181112080926.GA14987@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Mon, Nov 12, 2018 at 09:09:26AM +0100, Michal Hocko wrote:
>On Mon 12-11-18 15:14:04, Wei Yang wrote:
>> Zone with no managed_pages doesn't contribute totalreserv_pages. And the
>> more nodes we have, the more empty zones there are.
>> 
>> This patch skip the zones to save some cycles.
>
>What is the motivation for the patch? Does it really cause any
>measurable difference in performance?
>

The motivation here is to reduce some unnecessary work.

Based on my understanding, almost every node has empty zones, since
zones within a node are ordered in monotonic increasing memory address.

The worst case is all zones has managed_pages. For example, there is
only one node, or configured to have only ZONE_NORMAL and
ZONE_MOVABLE. Otherwise, the more node/zone we have, the more empty
zones there are.

I didn't have detail tests on this patch, since I don't have machine
with large numa nodes. While compared with the following ten lines of
code, this check to skip them is worthwhile to me.


>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  mm/page_alloc.c | 3 +++
>>  1 file changed, 3 insertions(+)
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index a919ba5cb3c8..567de15e1106 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -7246,6 +7246,9 @@ static void calculate_totalreserve_pages(void)
>>  			struct zone *zone = pgdat->node_zones + i;
>>  			long max = 0;
>>  
>> +			if (!managed_zone(zone))
>> +				continue;
>> +
>>  			/* Find valid and maximum lowmem_reserve in the zone */
>>  			for (j = i; j < MAX_NR_ZONES; j++) {
>>  				if (zone->lowmem_reserve[j] > max)
>> -- 
>> 2.15.1
>> 
>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
