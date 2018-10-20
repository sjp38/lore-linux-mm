Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA5A6B0003
	for <linux-mm@kvack.org>; Sat, 20 Oct 2018 12:10:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x10-v6so22245947edx.9
        for <linux-mm@kvack.org>; Sat, 20 Oct 2018 09:10:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d26-v6sor9370557ejc.0.2018.10.20.09.10.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Oct 2018 09:10:11 -0700 (PDT)
Date: Sat, 20 Oct 2018 16:10:08 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC] put page to pcp->lists[] tail if it is not on the same node
Message-ID: <20181020161008.zwi3uft3377fd6dv@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181019043303.s5axhjfb2v2lzsr3@master>
 <36be02a3-cdb9-15d0-a491-eba34675db3b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <36be02a3-cdb9-15d0-a491-eba34675db3b@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Wei Yang <richard.weiyang@gmail.com>, willy@infradead.org, mhocko@suse.com, mgorman@techsingularity.net, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri, Oct 19, 2018 at 03:43:29PM +0200, Vlastimil Babka wrote:
>On 10/19/18 6:33 AM, Wei Yang wrote:
>> @@ -2763,7 +2764,14 @@ static void free_unref_page_commit(struct page *page, unsigned long pfn)
>>  	}
>>  
>>  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
>> -	list_add(&page->lru, &pcp->lists[migratetype]);
>
>My impression is that you think there's only one pcp per cpu. But the
>"pcp" here is already specific to the zone (and thus node) of the page
>being freed. So it doesn't matter if we put the page to the list or
>tail. For allocation we already typically prefer local nodes, thus local
>zones, thus pcp's containing only local pages.
>
>> +	/*
>> +	 * If the page has the same node_id as this cpu, put the page at head.
>> +	 * Otherwise, put at the end.
>> +	 */
>> +	if (page_node == pcp->node)
>
>So this should in fact be always true due to what I explained above.

Vlastimil,

After looking at the code, I got some new understanding of the pcp
pages, which maybe a little different from yours.

Every zone has a per_cpu_pageset for each cpu, and the pages allocated
to per_cpu_pageset is either of the same node with this *cpu* or
different node.

So this comparison (page_node == pcp->node) would always be true or
false for a particular per_cpu_pageset.

Well, one thing for sure is putting a page to tail will not improve the
locality.

>
>Otherwise I second the recommendation from Mel.
>
>Cheers,
>Vlastimil

-- 
Wei Yang
Help you, Help me
