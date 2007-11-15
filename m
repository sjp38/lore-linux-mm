Date: Thu, 15 Nov 2007 10:40:05 +0000
Subject: Re: [RFC] Page allocator: Get rid of the list of cold pages
Message-ID: <20071115104004.GC5128@skynet.ie>
References: <Pine.LNX.4.64.0711122041320.30747@schroedinger.engr.sgi.com> <20071114184111.GE773@skynet.ie> <Pine.LNX.4.64.0711141045090.12606@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711141045090.12606@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On (14/11/07 10:51), Christoph Lameter didst pronounce:
> On Wed, 14 Nov 2007, Mel Gorman wrote:
> 
> > What was this based against? It didn't apply cleanly to 2.6.24-rc2 but it
> > was fairly trivial to fix up the rejects. I tested on a few machines just
> > to see what happened. The performance results for kernbench, dbench, tbench
> > and aim9[1] and were generally good.
> 
> It was against git current (hmm.... Maybe one or the other patchset was in 
> there too). Thanks for the evaluation.
> 

Ok, makes sense.

> > I'm still waiting on results to come in from a PPC64 machine but initially
> > indicators are this is not a bad idea because you are not abandoning the
> > idea of giving hot pages when requested, just altering a little how they
> > are found. I suspect your main motivation is reducing the size of a per-cpu
> > structure?
> 
> Yes. I can put more pagesets into a single cacheline if the cpu_alloc 
> patchset is also applied. The major benefit will only be reached together 
> with another patchset.
> 

Sounds promising.

> > However, the opposite is also true. Currently, if someone is doing a lot of
> > file-readahead, they regularly will go to the main allocator as the cold
> > per-cpu lists get emptied. Now they will be able to take hot pages for a
> > cold user instead which may be noticable in some cases.
> 
> This means that they will be able to use large batchsizes. This may 
> actually improve that situation.
> 

It would improve readahead but if there are active processes looking
for hot pages, they could be impacted because readahead has used up hot
pages. Basically, it could go either way but justifying that splitting the
lists is the right thing to do in all situations is difficult to justify
too. I think you could justify either approach with about the same amount
of hand-waving and not be able to prove anything conclusively.

> > However, in the event we cannot prove whether separate hot/cold lists are
> > worth it or not, we might as well collapse them for smaller per-cpu structures.
> 
> If we cannot prove that they are worth it then we should take them out.
> 
> > >  	local_irq_save(flags);
> > > -	pcp = &THIS_CPU(zone->pageset)->pcp[cold];
> > > +	pcp = &THIS_CPU(zone->pageset)->pcp;
> > >  	__count_vm_event(PGFREE);
> > > -	list_add(&page->lru, &pcp->list);
> > > +	if (cold)
> > > +		list_add_tail(&page->lru, &pcp->list);
> > > +	else
> > > +		list_add(&page->lru, &pcp->list);
> > 
> > There is scope here for a list function that adds to the head or tail depending
> > on the value of a parameter. I know Andy has the prototype of such a function
> > lying around so you may be able to share.
> 
> I use a similar thing in SLUB. So if Andy has something then we may be 
> able to use it in both places.
> 
> > > +	pcp = &p->pcp;
> > >  	pcp->count = 0;
> > >  	pcp->high = 6 * batch;
> > >  	pcp->batch = max(1UL, 1 * batch);
> > >  	INIT_LIST_HEAD(&pcp->list);
> > > -
> > > -	pcp = &p->pcp[1];		/* cold*/
> > > -	pcp->count = 0;
> > > -	pcp->high = 2 * batch;
> > > -	pcp->batch = max(1UL, batch/2);
> > > -	INIT_LIST_HEAD(&pcp->list);
> > 
> > Before - per-cpu high count was 8 * batch. After, it is 6 * batch. This
> > may be noticable in some corner case involving page readahead requesting
> > cold pages.
> 
> Actually it is the other way around. Readahead used the 2 * batch size for 
> readahead. Now it uses 6 * batch. So the queue size is improved 3 fold. 
> Should be better.
> 

I was referring to the size of the two lists combined rather than each
list individually, but point taken.

> > All in all, pretty straight-forward. I think it's worth wider testing at
> > least. I think it'll be hard to show for sure whether this is having a
> > negative performance impact or not but initial results look ok.
> 
> Thanks for the thorough evaluation.
> 

You're welcome. The PPC64 results came through as well. The difference
between the two kernels is negligible. There are very slight
improvements with your patch but it's in the noise.

What I have seen so far is that things are no worse with your patch than
without which is the important thing.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
