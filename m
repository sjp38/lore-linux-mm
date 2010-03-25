Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3219D6B01AC
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 05:40:56 -0400 (EDT)
Date: Thu, 25 Mar 2010 09:40:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/11] Do not compact within a preferred zone after a
	compaction failure
Message-ID: <20100325094035.GL2024@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-12-git-send-email-mel@csn.ul.ie> <20100324135347.7a9eb37b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100324135347.7a9eb37b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 01:53:47PM -0700, Andrew Morton wrote:
> On Tue, 23 Mar 2010 12:25:46 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > The fragmentation index may indicate that a failure it due to external
> > fragmentation, a compaction run complete and an allocation failure still
> > fail. There are two obvious reasons as to why
> > 
> >   o Page migration cannot move all pages so fragmentation remains
> >   o A suitable page may exist but watermarks are not met
> > 
> > In the event of compaction and allocation failure, this patch prevents
> > compaction happening for a short interval. It's only recorded on the
> > preferred zone but that should be enough coverage. This could have been
> > implemented similar to the zonelist_cache but the increased size of the
> > zonelist did not appear to be justified.
> > 
> >
> > ...
> >
> > +/* defer_compaction - Do not compact within a zone until a given time */
> > +static inline void defer_compaction(struct zone *zone, unsigned long resume)
> > +{
> > +	/*
> > +	 * This function is called when compaction fails to result in a page
> > +	 * allocation success. This is somewhat unsatisfactory as the failure
> > +	 * to compact has nothing to do with time and everything to do with
> > +	 * the requested order, the number of free pages and watermarks. How
> > +	 * to wait on that is more unclear, but the answer would apply to
> > +	 * other areas where the VM waits based on time.
> 
> um.  "Two wrongs don't make a right".  We should fix the other sites,
> not use them as excuses ;)
> 

Heh, one of those sites is currently in dispute. Specifically, the patch
that replaces congestion_wait() with a waitqueue that is woken when
watermarks are reached. I wrote that comment around about the same time
that patch was being developed which is why I found the situation
particularly unsatisfactory.

> What _is_ a good measure of "time" in this code?  "number of pages
> scanned" is a pretty good one in reclaim. 

In this case, a strong possibility is number of pages freed since deferral.
It's not perfect though because heavy memory pressure would mean those
pages are getting allocated again and the compaction is still not going
to succeed. I could use NR_FREE_PAGES to make a guess at how much has
changed since and whether it's worth trying to compact again but even
that is not perfect.

Lets say for example that compaction failed because the zone was mostly slab
pages. If all those were freed and replaced with migratable pages then the
counters would look similar but compaction will now succeed.  I could make
some sort of guess based on number of free, anon and file pages in the zone but
ultimately it would be hard to tell if the heuristic was any better than time.

I think this is only worth worrying about if a workload is found where
compact_fail is rising rapidly.

> We want something which will
> adapt itself to amount-of-memory, number-of-cpus, speed-of-cpus,
> nature-of-workload, etc, etc.
> 
> Is it possible to come up with some simple metric which approximately
> reflects how busy this code is, then pace ourselves via that?
> 

I think a simple metric would be based on free anon and file pages but
I think we would need a workload that was hitting compact_fail to devise
it properly.

> > +	 */
> > +	zone->compact_resume = resume;
> > +}
> > +
> > +static inline int compaction_deferred(struct zone *zone)
> > +{
> > +	/* init once if necessary */
> > +	if (unlikely(!zone->compact_resume)) {
> > +		zone->compact_resume = jiffies;
> > +		return 0;
> > +	}
> > +
> > +	return time_before(jiffies, zone->compact_resume);
> > +}
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
