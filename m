Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76EC46B0558
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 04:11:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k71so5084368wrc.15
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 01:11:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 195si2785338wmp.109.2017.08.02.01.11.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 01:11:39 -0700 (PDT)
Date: Wed, 2 Aug 2017 10:11:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] memdelay: memory health metric for systems and
 workloads
Message-ID: <20170802081136.GE2524@dhcp22.suse.cz>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
 <20170727134325.2c8cff2a6dc84e34ae6dc8ab@linux-foundation.org>
 <20170728194337.GA18981@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170728194337.GA18981@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri 28-07-17 15:43:37, Johannes Weiner wrote:
> Hi Andrew,
> 
> On Thu, Jul 27, 2017 at 01:43:25PM -0700, Andrew Morton wrote:
> > On Thu, 27 Jul 2017 11:30:07 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > This patch series implements a fine-grained metric for memory
> > > health.
> > 
> > I assume some Documentation/ is forthcoming.
> 
> Yep, I'll describe the interface and how to use this more extensively.
> 
> > Consuming another page flag hurts.  What's our current status there?
> 
> I would say we can make it 64-bit only, but I also need this refault
> distinction flag in the LRU balancing patches [1] to apply pressure on
> anon pages only when the page cache is actually thrashing, not when
> it's just transitioning to another workingset. So let's see...

I didn't get to look at the patchset yet but just for this part. I guess
you can go without a new page flag. PG_slab could be reused with some
care AFAICS.  Slab allocators do not seem to use other page flags so we
could make

bool PageSlab() 
{
	unsigned long flags = page->flags & ((1UL << NR_PAGEFLAGS) - 1);
	return (flags & (1UL << PG_slab)) == (1UL << PG_slab);
}

and then reuse the same bit for working set pages. Page cache will
almost always have LRU bit set and workingset_eviction assumes PG_locked
so we will have another bit set when needed. I know this is fuggly and
subtle but basically everything about struct page is inevitably like
that...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
