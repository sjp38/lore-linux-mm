Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE3BA6B029B
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 07:06:14 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v77so8867201wmv.5
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 04:06:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v130si6234011wmd.161.2017.01.19.04.06.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 04:06:13 -0800 (PST)
Subject: Re: [RFC PATCH 1/5] mm/vmstat: retrieve suitable free pageblock
 information just once
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1484291673-2239-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20170119115113.GQ30786@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dd16892c-3af0-a30d-ea82-205d0ebf01d7@suse.cz>
Date: Thu, 19 Jan 2017 13:06:06 +0100
MIME-Version: 1.0
In-Reply-To: <20170119115113.GQ30786@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/19/2017 12:51 PM, Michal Hocko wrote:
> On Fri 13-01-17 16:14:29, Joonsoo Kim wrote:
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> It's inefficient to retrieve buddy information for fragmentation index
>> calculation on every order. By using some stack memory, we could retrieve
>> it once and reuse it to compute all the required values. MAX_ORDER is
>> usually small enough so there is no big risk about stack overflow.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> ---
>>  mm/vmstat.c | 25 ++++++++++++-------------
>>  1 file changed, 12 insertions(+), 13 deletions(-)
>>
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 7c28df3..e1ca5eb 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -821,7 +821,7 @@ unsigned long node_page_state(struct pglist_data *pgdat,
>>  struct contig_page_info {
>>  	unsigned long free_pages;
>>  	unsigned long free_blocks_total;
>> -	unsigned long free_blocks_suitable;
>> +	unsigned long free_blocks_order[MAX_ORDER];
>>  };
> 
> I haven't looked at the rest of the patch becaust this has already
> raised a red flag.  This will increase the size of the structure quite a
> bit and from a quick look at least compaction_suitable->fragmentation_index
> will call with this allocated on the stack and this can be pretty deep
> on the call chain already.

Yeah, but compaction_suitable() is usually called at a point where
you're deciding whether to do more reclaim or compaction in the same
context, and both of those most likely have much larger stacks than this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
