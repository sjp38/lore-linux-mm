Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id E3B7D6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 16:21:12 -0400 (EDT)
Message-ID: <51ED9433.60707@redhat.com>
Date: Mon, 22 Jul 2013 16:21:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: page_alloc: fair zone allocator policy
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org> <1374267325-22865-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1374267325-22865-4-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/19/2013 04:55 PM, Johannes Weiner wrote:

> @@ -1984,7 +1992,8 @@ this_zone_full:
>   		goto zonelist_scan;
>   	}
>
> -	if (page)
> +	if (page) {
> +		atomic_sub(1U << order, &zone->alloc_batch);
>   		/*
>   		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
>   		 * necessary to allocate the page. The expectation is

Could this be moved into the slow path in buffered_rmqueue and
rmqueue_bulk, or would the effect of ignoring the pcp buffers be
too detrimental to keeping the balance between zones?

It would be kind of nice to not have this atomic operation on every
page allocation...

As a side benefit, higher-order buffered_rmqueue and rmqueue_bulk
both happen under the zone->lock, so moving this accounting down
to that layer might allow you to get rid of the atomics alltogether.

I like the overall approach though. This is something Linux has needed
for a long time, and could be extremely useful to automatic NUMA
balancing as well...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
