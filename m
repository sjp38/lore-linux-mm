Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id D37686B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 02:51:15 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id xb12so375721pbc.26
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 23:51:15 -0700 (PDT)
Message-ID: <51F0CACE.7040609@gmail.com>
Date: Thu, 25 Jul 2013 14:50:54 +0800
From: Paul Bolle <paul.bollee@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: page_alloc: fair zone allocator policy
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org> <1374267325-22865-4-git-send-email-hannes@cmpxchg.org> <51ED9433.60707@redhat.com>
In-Reply-To: <51ED9433.60707@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/23/2013 04:21 AM, Rik van Riel wrote:
> On 07/19/2013 04:55 PM, Johannes Weiner wrote:
>
>> @@ -1984,7 +1992,8 @@ this_zone_full:
>>           goto zonelist_scan;
>>       }
>>
>> -    if (page)
>> +    if (page) {
>> +        atomic_sub(1U << order, &zone->alloc_batch);
>>           /*
>>            * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
>>            * necessary to allocate the page. The expectation is
>
> Could this be moved into the slow path in buffered_rmqueue and
> rmqueue_bulk, or would the effect of ignoring the pcp buffers be
> too detrimental to keeping the balance between zones?
>
> It would be kind of nice to not have this atomic operation on every
> page allocation...

atomic operation will lock cache line or memory bus? And cmpxchg will 
lock cache line or memory bus? ;-)

>
> As a side benefit, higher-order buffered_rmqueue and rmqueue_bulk
> both happen under the zone->lock, so moving this accounting down
> to that layer might allow you to get rid of the atomics alltogether.
>
> I like the overall approach though. This is something Linux has needed
> for a long time, and could be extremely useful to automatic NUMA
> balancing as well...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
