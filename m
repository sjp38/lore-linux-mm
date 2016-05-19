Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 773B56B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 13:45:33 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id rs7so22825367lbb.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 10:45:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id so17si19382315wjb.226.2016.05.19.10.45.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 May 2016 10:45:31 -0700 (PDT)
Subject: Re: [PATCH] mm: compact: fix zoneindex in compact
References: <1463659121-84124-1-git-send-email-puck.chen@hisilicon.com>
 <573DAD84.7020403@suse.cz> <573DADF7.4000109@suse.cz>
 <alpine.LSU.2.11.1605191020470.12425@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9741ef6d-b93b-a99b-e42f-9f510295dd3f@suse.cz>
Date: Thu, 19 May 2016 19:45:34 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1605191020470.12425@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Chen Feng <puck.chen@hisilicon.com>, mhocko@suse.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, suzhuangluan@hisilicon.com, dan.zhao@hisilicon.com, qijiwen@hisilicon.com, xuyiping@hisilicon.com, oliver.fu@hisilicon.com, puck.chen@foxmail.com

On 19.5.2016 19:23, Hugh Dickins wrote:
> On Thu, 19 May 2016, Vlastimil Babka wrote:
>> On 05/19/2016 02:11 PM, Vlastimil Babka wrote:
>>> On 05/19/2016 01:58 PM, Chen Feng wrote:
>>>> While testing the kcompactd in my platform 3G MEM only DMA ZONE.
>>>> I found the kcompactd never wakeup. It seems the zoneindex
>>>> has already minus 1 before. So the traverse here should be <=.
>>>
>>> Ouch, thanks!
>>>
>>>> Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
>>>
>>> Fixes: 0f87baf4f7fb ("mm: wake kcompactd before kswapd's short sleep")
>>
>> Bah, not that one.
>>
>> Fixes: accf62422b3a ("mm, kswapd: replace kswapd compaction with waking
>> up kcompactd")
>>
>>> Cc: stable@vger.kernel.org
>>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>>>
>>>> ---
>>>>  mm/compaction.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>>> index 8fa2540..e5122d9 100644
>>>> --- a/mm/compaction.c
>>>> +++ b/mm/compaction.c
>>>> @@ -1742,7 +1742,7 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
>>>>  	struct zone *zone;
>>>>  	enum zone_type classzone_idx = pgdat->kcompactd_classzone_idx;
>>>>  
>>>> -	for (zoneid = 0; zoneid < classzone_idx; zoneid++) {
>>>> +	for (zoneid = 0; zoneid <= classzone_idx; zoneid++) {
>>>>  		zone = &pgdat->node_zones[zoneid];
>>>>  
>>>>  		if (!populated_zone(zone))
> 
> Ignorant question: kcompactd_do_work() just below has a similar loop:

You spelled "Important" wrong.

> should that one be saying "zoneid <= cc.classzone_idx" too?

Yes. Chen, can you send updated patch (also with the ack/cc/fixes tags I added?)

Thanks!

> Hugh
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
