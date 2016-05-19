Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B98A56B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 08:13:46 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m64so42606072lfd.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 05:13:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m189si17984264wme.113.2016.05.19.05.13.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 May 2016 05:13:45 -0700 (PDT)
Subject: Re: [PATCH] mm: compact: fix zoneindex in compact
References: <1463659121-84124-1-git-send-email-puck.chen@hisilicon.com>
 <573DAD84.7020403@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573DADF7.4000109@suse.cz>
Date: Thu, 19 May 2016 14:13:43 +0200
MIME-Version: 1.0
In-Reply-To: <573DAD84.7020403@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>, mhocko@suse.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: suzhuangluan@hisilicon.com, dan.zhao@hisilicon.com, qijiwen@hisilicon.com, xuyiping@hisilicon.com, oliver.fu@hisilicon.com, puck.chen@foxmail.com

On 05/19/2016 02:11 PM, Vlastimil Babka wrote:
> On 05/19/2016 01:58 PM, Chen Feng wrote:
>> While testing the kcompactd in my platform 3G MEM only DMA ZONE.
>> I found the kcompactd never wakeup. It seems the zoneindex
>> has already minus 1 before. So the traverse here should be <=.
> 
> Ouch, thanks!
> 
>> Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
> 
> Fixes: 0f87baf4f7fb ("mm: wake kcompactd before kswapd's short sleep")

Bah, not that one.

Fixes: accf62422b3a ("mm, kswapd: replace kswapd compaction with waking
up kcompactd")

> Cc: stable@vger.kernel.org
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
>> ---
>>  mm/compaction.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 8fa2540..e5122d9 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -1742,7 +1742,7 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
>>  	struct zone *zone;
>>  	enum zone_type classzone_idx = pgdat->kcompactd_classzone_idx;
>>  
>> -	for (zoneid = 0; zoneid < classzone_idx; zoneid++) {
>> +	for (zoneid = 0; zoneid <= classzone_idx; zoneid++) {
>>  		zone = &pgdat->node_zones[zoneid];
>>  
>>  		if (!populated_zone(zone))
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
