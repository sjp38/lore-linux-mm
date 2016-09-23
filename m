Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id ABB016B027F
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:56:03 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b130so7635889wmc.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 23:56:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jk1si6123209wjb.221.2016.09.22.23.56.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 23:56:02 -0700 (PDT)
Subject: Re: [PATCH 2/4] mm, compaction: more reliably increase direct
 compaction priority
References: <20160906135258.18335-1-vbabka@suse.cz>
 <20160906135258.18335-3-vbabka@suse.cz>
 <20160921171348.GF24210@dhcp22.suse.cz>
 <f1670976-b4da-5d2c-0a85-37f9a87d6868@suse.cz>
 <20160922140821.GG11875@dhcp22.suse.cz>
 <20160922145237.GH11875@dhcp22.suse.cz>
 <1f47ebe3-61bc-ba8a-defb-9fd8e78614d7@suse.cz>
 <005b01d2154f$8d38b830$a7aa2890$@alibaba-inc.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <98b0c783-28dc-62c4-5a94-74c9e27bebe0@suse.cz>
Date: Fri, 23 Sep 2016 08:55:33 +0200
MIME-Version: 1.0
In-Reply-To: <005b01d2154f$8d38b830$a7aa2890$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Michal Hocko' <mhocko@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Arkadiusz Miskiewicz' <a.miskiewicz@gmail.com>, 'Ralf-Peter Rohbeck' <Ralf-Peter.Rohbeck@quantum.com>, 'Olaf Hering' <olaf@aepfle.de>, linux-kernel@vger.kernel.org, 'Linus Torvalds' <torvalds@linux-foundation.org>, linux-mm@kvack.org, 'Mel Gorman' <mgorman@techsingularity.net>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'David Rientjes' <rientjes@google.com>, 'Rik van Riel' <riel@redhat.com>

On 09/23/2016 06:04 AM, Hillf Danton wrote:
>>
>> ----8<----
>> From a7921e57ba1189b9c08fc4879358a908c390e47c Mon Sep 17 00:00:00 2001
>> From: Vlastimil Babka <vbabka@suse.cz>
>> Date: Thu, 22 Sep 2016 17:02:37 +0200
>> Subject: [PATCH] mm, page_alloc: pull no_progress_loops update to
>>  should_reclaim_retry()
>>
>> The should_reclaim_retry() makes decisions based on no_progress_loops, so it
>> makes sense to also update the counter there. It will be also consistent with
>> should_compact_retry() and compaction_retries. No functional change.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>  mm/page_alloc.c | 28 ++++++++++++++--------------
>>  1 file changed, 14 insertions(+), 14 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 582820080601..a01359ab3ed6 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3401,16 +3401,26 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>>  static inline bool
>>  should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>>  		     struct alloc_context *ac, int alloc_flags,
>> -		     bool did_some_progress, int no_progress_loops)
>> +		     bool did_some_progress, int *no_progress_loops)
>>  {
>>  	struct zone *zone;
>>  	struct zoneref *z;
>>
>>  	/*
>> +	 * Costly allocations might have made a progress but this doesn't mean
>> +	 * their order will become available due to high fragmentation so
>> +	 * always increment the no progress counter for them
>> +	 */
>> +	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
>> +		no_progress_loops = 0;
> 
> s/no/*no/
>> +	else
>> +		no_progress_loops++;
> 
> s/no_progress_loops/(*no_progress_loops)/

Crap, thanks. I'm asking our gcc guy about possible warnings for this,
and some past mistake I've seen which would be *no_progress_loops++.
 
> With that feel free to add
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Thanks!

----8<----
