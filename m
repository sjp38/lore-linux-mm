Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB7FD6B0003
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 21:38:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x20-v6so21332048eda.21
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 18:38:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x18-v6sor8260432ejw.47.2018.10.19.18.38.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Oct 2018 18:38:13 -0700 (PDT)
Date: Sat, 20 Oct 2018 01:38:11 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC] put page to pcp->lists[] tail if it is not on the same node
Message-ID: <20181020013811.tzhxz6sjv3g2g5c5@master>
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

Your guess is right. :-)

I took a look in the code

    zone->pageset = alloc_percpu(struct per_cpu_pageset);

each zone has its pageset.

This means just a portion of the pageset is used on a multi-node
system, since a node just belongs to one node. Could we allocate just
this part or initialize just this part? Maybe it is too small to polish.

Well, I am lost on when we will allocate a page from remote node. Let me
try to understand :-)

>> +	/*
>> +	 * If the page has the same node_id as this cpu, put the page at head.
>> +	 * Otherwise, put at the end.
>> +	 */
>> +	if (page_node == pcp->node)
>
>So this should in fact be always true due to what I explained above.
>
>Otherwise I second the recommendation from Mel.
>

Sure, I have to say you are right.

BTW, is there other channel not as formal as mail list to raise some
question or discussion? Reading the code alone is not that exciting and
sometimes when I get some idea or confusion, I really willing to chat
with someone or to understand why it is so.

Mail list seems not the proper channel, maybe the irc is a proper way?

>Cheers,
>Vlastimil

-- 
Wei Yang
Help you, Help me
