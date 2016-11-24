Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6556B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 02:26:42 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w13so12274661wmw.0
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 23:26:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sd16si35378780wjb.290.2016.11.23.23.26.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Nov 2016 23:26:40 -0800 (PST)
Subject: Re: [RFC PATCH] mm: page_alloc: High-order per-cpu page allocator
References: <20161121155540.5327-1-mgorman@techsingularity.net>
 <4a9cdec4-b514-e414-de86-fc99681889d8@suse.cz>
 <20161123163351.6s76ijwnqoakgcud@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a1f8d311-1f69-b672-1dad-9867c212147f@suse.cz>
Date: Thu, 24 Nov 2016 08:26:39 +0100
MIME-Version: 1.0
In-Reply-To: <20161123163351.6s76ijwnqoakgcud@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On 11/23/2016 05:33 PM, Mel Gorman wrote:
>>> +
>>> +static inline unsigned int pindex_to_order(unsigned int pindex)
>>> +{
>>> +	return pindex < MIGRATE_PCPTYPES ? 0 : pindex - MIGRATE_PCPTYPES + 1;
>>> +}
>>> +
>>> +static inline unsigned int order_to_pindex(int migratetype, unsigned int order)
>>> +{
>>> +	return (order == 0) ? migratetype : MIGRATE_PCPTYPES - 1 + order;
>>
>> Here I think that "MIGRATE_PCPTYPES + order - 1" would be easier to
>> understand as the array is for all migratetypes, but the order is shifted?
>>
>
> As in migratetypes * costly_order ? That would be excessively large.

No, I just meant that instead of "MIGRATE_PCPTYPES - 1 + order" it could 
be "MIGRATE_PCPTYPES + order - 1" as we are subtracting from order, not 
migratetypes. Just made me confused a bit when seeing the code for the 
first time.

>>> @@ -1083,10 +1083,12 @@ static bool bulkfree_pcp_prepare(struct page *page)
>>>   * pinned" detection logic.
>>>   */
>>>  static void free_pcppages_bulk(struct zone *zone, int count,
>>> -					struct per_cpu_pages *pcp)
>>> +					struct per_cpu_pages *pcp,
>>> +					int migratetype)
>>>  {
>>> -	int migratetype = 0;
>>> -	int batch_free = 0;
>>> +	unsigned int pindex = 0;
>>
>> Should pindex be initialized to migratetype to match the list below?
>>
>
> Functionally it doesn't matter. It affects which list is tried first if
> the preferred list is empty. Arguably it would make more sense to init
> it to NR_PCP_LISTS - 1 so all order-0 lists are always drained before the
> high-order pages but there is not much justification for that.

OK

> I'll take your suggestion until there is data supporting that high-order
> caches should be preserved.
>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
