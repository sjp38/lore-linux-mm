Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C21576B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 13:01:40 -0500 (EST)
Date: Wed, 24 Nov 2010 18:01:22 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC 1/2] deactive invalidated pages
Message-ID: <20101124180122.GC19571@csn.ul.ie>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com> <20101122141449.9de58a2c.akpm@linux-foundation.org> <AANLkTimk4JL7hDvLWuHjiXGNYxz8GJ_TypWFC=74Xt1Q@mail.gmail.com> <20101122210132.be9962c7.akpm@linux-foundation.org> <20101123093859.GE19571@csn.ul.ie> <87k4k49jii.fsf@gmail.com> <20101123145856.GQ19571@csn.ul.ie> <20101123123535.438e9750.akpm@linux-foundation.org> <20101123221049.GR19571@csn.ul.ie> <AANLkTikvsEpQM4=fGj5sH7rS74-KfPL5nq0v18v59MOb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikvsEpQM4=fGj5sH7rS74-KfPL5nq0v18v59MOb@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ben Gamari <bgamari@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2010 at 08:45:20AM +0900, Minchan Kim wrote:
> >
> >> I just don't see any argument for moving the page to the head of the
> >> inactive LRU as a matter of policy.  We can park it there because we
> >> can't think of anythnig else to do with it, but it's the wrong place
> >> for it.
> >>
> >
> > Is there a better alternative? One thing that springs to mind is that we are
> > not exactly tracking very well what effect these policy changes have. The
> > analysis scripts I have do a reasonable job on tracking reclaim activity
> > (although only as part of the mmtests tarball, I should split them out as
> > a standalone tool) but not the impact - namely minor and major faults. I
> > should sort that out so we can put better reclaim analysis in place.
> 
> It can help very much. :)
> 
> Also, I need time since I am so busy.
> 

No worries, I had a framework in place that made it easy enough to
collect. The necessary information is available in /proc/vmstat in this
case so a tester just needs to record vmstat before and after the target
workload runs. For the reclaim/compaction series, a partial run of the
series and the subsequent report looks like;

proc vmstat: Faults
                                       traceonly reclaimcompact obeysync
Major Faults                                 84102      6724      7298
Minor Faults                             139704394 138778777 138777304
Page ins                                   4966564   3621280   3569508
Page outs                                 11283328   7980576   7959352
Swap ins                                     85800      5647      7062
Swap outs                                   828488      8799     10565

Series acted as expected - major faults were reduced. Minor faults on on the
high side which I didn't analyse further. Main thing that it's possible to
collect the information on what reclaim is doing and how it affects processes.
I don't have anything in place to evaluate this series unfortunately as
I haven't automated a workload that depends on the behaviour of fadvise.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
