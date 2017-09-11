Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 074766B0298
	for <linux-mm@kvack.org>; Sun, 10 Sep 2017 21:07:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y29so12541665pff.6
        for <linux-mm@kvack.org>; Sun, 10 Sep 2017 18:07:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l81sor2657647pfa.37.2017.09.10.18.07.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Sep 2017 18:07:27 -0700 (PDT)
Date: Sun, 10 Sep 2017 18:07:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, compaction: kcompactd should not ignore pageblock
 skip
In-Reply-To: <5d578461-0982-f719-3a04-b2f3552dc7cc@suse.cz>
Message-ID: <alpine.DEB.2.10.1709101801200.85650@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com> <5d578461-0982-f719-3a04-b2f3552dc7cc@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Aug 2017, Vlastimil Babka wrote:

> On 08/16/2017 01:39 AM, David Rientjes wrote:
> > Kcompactd is needlessly ignoring pageblock skip information.  It is doing
> > MIGRATE_SYNC_LIGHT compaction, which is no more powerful than
> > MIGRATE_SYNC compaction.
> > 
> > If compaction recently failed to isolate memory from a set of pageblocks,
> > there is nothing to indicate that kcompactd will be able to do so, or
> > that it is beneficial from attempting to isolate memory.
> > 
> > Use the pageblock skip hint to avoid rescanning pageblocks needlessly
> > until that information is reset.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> It would be much better if patches like this were accompanied by some
> numbers.
> 

The numbers were from https://marc.info/?l=linux-mm&m=150231232707999 
where very large amounts (>90% of system RAM) were hugetlb pages.  We can 
supplement this changelog with the following if it helps:

"""
Currently, kcompactd ignores pageblock skip information that can become 
useful if it is known that memory should not be considered by both the 
migration and freeing scanners.  Abundant hugetlb memory is a good example 
of memory that is needlessly (and expensively) scanned since the hugepage 
order normally matches the pageblock order.

For example, on a sysctl with very large amounts of memory reserved by the 
hugetlb subsystem:

compact_migrate_scanned 2931254031294 
compact_free_scanned    102707804816705 
compact_isolated        1309145254 

Kcompactd ends up successfully isolating ~0.0012% of memory that is 
scans (the above does not involve direct compaction).

A follow-up change will set the pageblock skip for this memory since it is 
never useful for either scanner.
"""

> Also there's now a danger that in cases where there's no direct
> compaction happening (just kcompactd), nothing will ever call
> __reset_isolation_suitable().
> 

I'm not sure that is helpful in a context where no high-order memory can 
call direct compaction that kcompactd needlessly scanning the same memory 
over and over is beneficial.

> > ---
> >  mm/compaction.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1927,9 +1927,8 @@ static void kcompactd_do_work(pg_data_t *pgdat)
> >  		.total_free_scanned = 0,
> >  		.classzone_idx = pgdat->kcompactd_classzone_idx,
> >  		.mode = MIGRATE_SYNC_LIGHT,
> > -		.ignore_skip_hint = true,
> > +		.ignore_skip_hint = false,
> >  		.gfp_mask = GFP_KERNEL,
> > -
> >  	};
> >  	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
> >  							cc.classzone_idx);
> > 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
