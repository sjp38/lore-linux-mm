Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8B06B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 08:08:15 -0500 (EST)
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
From: Andi Kleen <andi@firstfloor.org>
References: <20091210185626.26f9828a@cuia.bos.redhat.com>
Date: Mon, 14 Dec 2009 14:08:09 +0100
In-Reply-To: <20091210185626.26f9828a@cuia.bos.redhat.com> (Rik van Riel's message of "Thu, 10 Dec 2009 18:56:26 -0500")
Message-ID: <87pr6hya86.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@redhat.com> writes:

> +max_zone_concurrent_reclaim:
> +
> +The number of processes that are allowed to simultaneously reclaim
> +memory from a particular memory zone.
> +
> +With certain workloads, hundreds of processes end up in the page
> +reclaim code simultaneously.  This can cause large slowdowns due
> +to lock contention, freeing of way too much memory and occasionally
> +false OOM kills.
> +
> +To avoid these problems, only allow a smaller number of processes
> +to reclaim pages from each memory zone simultaneously.
> +
> +The default value is 8.

I don't like the hardcoded number. Is the same number good for a 128MB
embedded system as for as 1TB server?  Seems doubtful.

This should be perhaps scaled with memory size and number of CPUs?

> +/*
> + * Maximum number of processes concurrently running the page
> + * reclaim code in a memory zone.  Having too many processes
> + * just results in them burning CPU time waiting for locks,
> + * so we're better off limiting page reclaim to a sane number
> + * of processes at a time.  We do this per zone so local node
> + * reclaim on one NUMA node will not block other nodes from
> + * making progress.
> + */
> +int max_zone_concurrent_reclaimers = 8;

__read_mostly

> +
>  static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);
>  
> @@ -1600,6 +1612,29 @@ static void shrink_zone(int priority, struct zone *zone,
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  	int noswap = 0;
>  
> +	if (!current_is_kswapd() && atomic_read(&zone->concurrent_reclaimers) >
> +					max_zone_concurrent_reclaimers) {
> +		/*
> +		 * Do not add to the lock contention if this zone has
> +		 * enough processes doing page reclaim already, since
> +		 * we would just make things slower.
> +		 */
> +		sleep_on(&zone->reclaim_wait);

wait_event()? sleep_on is a really deprecated racy interface.

This would still badly thunder the herd if not enough memory is freed
, won't it? It would be better to only wake up a single process if memory got freed.

How about for each page freed do a wake up for one thread?


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
