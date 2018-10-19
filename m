Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 582356B0003
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 09:43:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g36-v6so20740480edb.3
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 06:43:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x39-v6si1974597edx.261.2018.10.19.06.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 06:43:31 -0700 (PDT)
Subject: Re: [RFC] put page to pcp->lists[] tail if it is not on the same node
References: <20181019043303.s5axhjfb2v2lzsr3@master>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <36be02a3-cdb9-15d0-a491-eba34675db3b@suse.cz>
Date: Fri, 19 Oct 2018 15:43:29 +0200
MIME-Version: 1.0
In-Reply-To: <20181019043303.s5axhjfb2v2lzsr3@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, willy@infradead.org, mhocko@suse.com, mgorman@techsingularity.net
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On 10/19/18 6:33 AM, Wei Yang wrote:
> @@ -2763,7 +2764,14 @@ static void free_unref_page_commit(struct page *page, unsigned long pfn)
>  	}
>  
>  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
> -	list_add(&page->lru, &pcp->lists[migratetype]);

My impression is that you think there's only one pcp per cpu. But the
"pcp" here is already specific to the zone (and thus node) of the page
being freed. So it doesn't matter if we put the page to the list or
tail. For allocation we already typically prefer local nodes, thus local
zones, thus pcp's containing only local pages.

> +	/*
> +	 * If the page has the same node_id as this cpu, put the page at head.
> +	 * Otherwise, put at the end.
> +	 */
> +	if (page_node == pcp->node)

So this should in fact be always true due to what I explained above.

Otherwise I second the recommendation from Mel.

Cheers,
Vlastimil
