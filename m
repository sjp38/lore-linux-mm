Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 303596B015E
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 12:31:57 -0400 (EDT)
Date: Thu, 13 Sep 2012 17:31:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/2 v2]compaction: abort compaction loop if lock is
 contended or run too long
Message-ID: <20120913163151.GC11266@suse.de>
References: <20120910011830.GC3715@kernel.org>
 <20120911163455.bb249a3c.akpm@linux-foundation.org>
 <20120912004840.GI27078@redhat.com>
 <20120912142019.0e06bf52.akpm@linux-foundation.org>
 <20120912234808.GC3404@redhat.com>
 <20120913004722.GA5085@bbox>
 <20120913093826.GT11266@suse.de>
 <20120913160432.GG3388@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120913160432.GG3388@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@kernel.org>, linux-mm@kvack.org

On Thu, Sep 13, 2012 at 06:04:32PM +0200, Andrea Arcangeli wrote:
> On Thu, Sep 13, 2012 at 10:38:26AM +0100, Mel Gorman wrote:
> > I agree with Minchan. Andrea's patch ignores the fact that free page
> > isolation might have aborted due to lock contention. It's not necessarily
> > going to be isolating the pages it needs for migration.
> 
> Actually I thought of calling putback_lru_pages first, but then I
> thought it was better to just complete the current slice.
> 

Unfortunately that will end up calling compaction_alloc() ->
isolate_freepages and probably end up contending again. 

> Note that putback_lru_pages can take the lru_lock immediately too when

True, but in that case there is no choice in the matter. We can't just
leak the pages.

> the pagevec gets full which won't work any better than if the
> cc->contended was set by the freepages isolation and we do
> migrate_pages.
> 
> There's no way to abort lockless from that point, so I think it's
> better to take the last locks to finish the current slice of work and
> then abort if it's still contended (which confirms we're really
> trashing).
> 

To me, that will just contend more than we have to. We're aborting compaction
and finishing off the current slice will not make any meaningful difference
to whether tha allocation succeeds or not.

> Skipping isolated pages without rewinding low_pfn would also reduce
> compaction reliability so that should be evaluated as well. And
> rewinding with the putback_lru_pages would risk livelocks.
> 
> I agree Minchan's patch would fix the problem too, and this should be
> a fairly uncommon path so either ways shouldn't make a noticeable
> difference.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
