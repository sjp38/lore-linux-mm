Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id BD40C6B0033
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 17:04:30 -0400 (EDT)
Date: Mon, 22 Jul 2013 17:04:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130722210423.GG715@cmpxchg.org>
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org>
 <1374267325-22865-4-git-send-email-hannes@cmpxchg.org>
 <51ED9433.60707@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51ED9433.60707@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 22, 2013 at 04:21:07PM -0400, Rik van Riel wrote:
> On 07/19/2013 04:55 PM, Johannes Weiner wrote:
> 
> >@@ -1984,7 +1992,8 @@ this_zone_full:
> >  		goto zonelist_scan;
> >  	}
> >
> >-	if (page)
> >+	if (page) {
> >+		atomic_sub(1U << order, &zone->alloc_batch);
> >  		/*
> >  		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
> >  		 * necessary to allocate the page. The expectation is
> 
> Could this be moved into the slow path in buffered_rmqueue and
> rmqueue_bulk, or would the effect of ignoring the pcp buffers be
> too detrimental to keeping the balance between zones?

What I'm worried about is not the inaccury that comes from the buffer
size but the fact that there are no guaranteed buffer empty+refill
cycles.  The reclaimer could end up feeding the pcp list that the
allocator is using indefinitely, which brings us back to the original
problem.  If you have >= NR_CPU jobs running, the kswapds are bound to
share CPUs with the allocating tasks, so the scenario is not unlikely.

> It would be kind of nice to not have this atomic operation on every
> page allocation...

No argument there ;)

> I like the overall approach though. This is something Linux has needed
> for a long time, and could be extremely useful to automatic NUMA
> balancing as well...
> 
> -- 
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
