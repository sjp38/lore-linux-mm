Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0302B6B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 01:03:33 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so2684455pbc.40
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:03:33 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id to10si8211414pbc.228.2014.06.19.22.03.31
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 22:03:33 -0700 (PDT)
Date: Fri, 20 Jun 2014 14:04:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Write down design and intentions in English for
 proportial scan
Message-ID: <20140620050410.GB14884@bbox>
References: <20140620030002.GA14884@bbox>
 <20140619205357.e171e174.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140619205357.e171e174.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chen Yucong <slaoub@gmail.com>, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 19, 2014 at 08:53:57PM -0700, Andrew Morton wrote:
> On Fri, 20 Jun 2014 12:00:02 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > By suggestion from Andrew, first of all, I try to add only comment
> > but I believe we could make it more clear by some change like this.
> > https://lkml.org/lkml/2014/6/16/750
> > 
> > Anyway, push this patch firstly.
> 
> Thanks.
> 
> > ================= &< =================
> > 
> > >From b1fd007097064db34a211ffeacfe4da9fb22d49e Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Fri, 20 Jun 2014 11:37:52 +0900
> > Subject: [PATCH] mm: Write down design and intentions in English for
> >  proportial scan
> > 
> > Quote from Andrew
> > "
> > That code is absolutely awful :( It's terribly difficult to work out
> > what the design is - what the code is actually setting out to achieve.
> > One is reduced to trying to reverse-engineer the intent from the
> > implementation and that becomes near impossible when the
> > implementation has bugs!
> > 
> > <snip>
> > 
> > The only way we're going to fix all this up is to stop looking at the
> > code altogether.  Write down the design and the intentions in English.
> > Review that.  Then implement that design in C
> > "
> > 
> > One thing I know it might not be English Andrew expected but other
> > thing I know is there are lots of native people in here so one of them
> > will spend his time to make this horrible English smooth.
> > 
> > I alreday spent my time to try to fix this situation so it's your
> > turn. It's good time balance between non-native and native people
> > so open source community is fair for all of us.
> > 
> 
> I can do that ;)  But not yet.
> 
> > ---
> >  mm/vmscan.c | 37 +++++++++++++++++++++++++++++++------
> >  1 file changed, 31 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 521f7eab1798..3a9862895a64 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2071,6 +2071,22 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
> >  
> >  	get_scan_count(lruvec, sc, nr);
> >  
> > +	/*
> > +	 * Basically, VM scans file/anon LRU list proportionally
> 
> OK
> 
> > depending
> > +	 * on the value of vm.swappiness
> 
> "depending" in what fashion?  Higher swappiness leads to lengthier
> scans.  But there's this:

Higher swappiness leads to scan for *anon* pages more while it leads to
file pages less. But thing we should keep in mind is it's not a absolute
value but relative value based on each LRU size.


> 
> 	/*
> 	 * With swappiness at 100, anonymous and file have the same priority.

The default is 60 so it turns out Linux prefers file to anon for scanning
(ie, chace of reclaiming) but if we set it to 100, it means VM can give a
same ratio to them(file and anon LRU list) so we could call it
"it's same prioirty".


> 	 * This scanning priority is essentially the inverse of IO cost.
> 	 */
> 	anon_prio = sc->swappiness;
> 	file_prio = 200 - anon_prio;
> 
> 
> > but doesn't want to reclaim
> > +	 * excessive pages. So, it might be better to stop scan as soon as
> > +	 * we meet nr_to_reclaim
> 
> "scanning" does not equal "reclaiming", as not all scanned pages are
> reclaimed.  I guess we mean "stop scanning when nr_reclaimed pages have
> been reclaimed".

No objection but use nr_to_reclaim instead of nr_reclaimed.

> 
> > but it breaks aging balance between LRU lists
> 
> Why does it do this?

Let's assume that anon LRU size is 100 and file is 1000 and our mission
(ie, nr_to_reclaim) is 20.

get_scan_count decides scanning 20:80 ratio for anon:file.
In this case, target[anon] is 20 and target[file] is 800.

If we scan 10 pages(actually, it's 32 but I'd like to make it simple) as batch
unit for each LRU, only one loop would be enough to meet nr_to_reclaim(ie, 20)
if we assume our reclaim efficiency is 100%.
IOW, we reclaimed 10 pages from anon LRU and another 10 pages from file LRU,
which meet our target 20 pages.
But what happens if we stop in here?

For anon LRU list, 10 pages scanning is 10%(ie, 10/100) with considering
anon LRU size but 10 pages scanning for file LRU list is 0.0125%(ie, 10/800).
It's really unfair so this logic want to make 0.0125 to 10%.

> 
> > +	 * To keep the balance, what we do is as follows.
> > +	 *
> > +	 * If we reclaim pages requested, we stop scanning first and
> > +	 * investigate which LRU should be scanned more depending on
> > +	 * remained lru size(ie, nr[xxx]). We will scan bigger one more
> > +	 * so, final goal is
> > +	 *
> > +	 * scanned[xxx] = targets[xxx] - nr[xxx]
> > +	 * targets[anon] : targets[file] = scanned[anon] : scanned[file]
> > +	 */
> 
> hm, what's going on here.  Something like this?
> 
> "after having scanned sufficient pages to reclaim nr_to_reclaim pages,
> the LRUs will now be out of balance if many more pages were reclaimed
> from one LRU than from the others.  We now bring the LRUs back into
> balance by ...".  
> 
> I'm not sure this really makes sense from a *design* aspect.  Is the
> amount of scanning which we do here sufficiently large to have a
> significant impact on the LRU sizes?  I suppose yes, in rare cases.

Maybe, Mel could say.
mm: vmscan: obey proportional scanning requirements for kswapd

> 
> How do we define "balance" anyway?  Can we make some statement explaining
> how the LRUs will appear when they are in a "balanced" state?

I guess above my example is enough.

> 
> >  	/* Record the original scan target for proportional adjustments later */
> >  	memcpy(targets, nr, sizeof(nr));
> >  
> > @@ -2091,8 +2107,14 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
> >  	blk_start_plug(&plug);
> >  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> >  					nr[LRU_INACTIVE_FILE]) {
> > -		unsigned long nr_anon, nr_file, percentage;
> > +		unsigned long nr_anon, nr_file;
> >  		unsigned long nr_scanned;
> > +		/*
> > +		 * How many pages we should scan to meet target
> > +		 * calculated by get_scan_count. It means that
> > +		 * (100 - percentage) = already scanned ratio
> > +		 */
> > +		unsigned percentage;
> 
> Well, "percentage" is a ratio.  So maybe "what proportion of the LRUs
> we should scan to..."?

Yeb, better.

"what proportion of the LRU we should scan to meet terget ratio
calculated by get_scan_count"
> 
> 
> >  		for_each_evictable_lru(lru) {
> >  			if (nr[lru]) {
> > @@ -2108,11 +2130,10 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
> >  			continue;
> >  
> >  		/*
> > -		 * For kswapd and memcg, reclaim at least the number of pages
> > -		 * requested. Ensure that the anon and file LRUs are scanned
> > -		 * proportionally what was requested by get_scan_count(). We
> > -		 * stop reclaiming one LRU and reduce the amount scanning
> > -		 * proportional to the original scan target.
> > +		 * Here, we reclaimed at least the number of pages requested.
> > +		 * Then, what we should do is the ensure that the anon and
> > +		 * file LRUs are scanned proportionally what was requested
> > +		 * by get_scan_count().
> >  		 */
> 
> OK.
> 
> >  		nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
> >  		nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];
> > @@ -2126,6 +2147,10 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
> >  		if (!nr_file || !nr_anon)
> >  			break;
> >  
> > +		/*
> > +		 * Scan the bigger of the LRU more while stop scanning
> > +		 * the smaller of the LRU to keep aging balance between LRUs
> > +		 */
> 
> OK.
> 
> >  		if (nr_file > nr_anon) {
> >  			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
> >  						targets[LRU_ACTIVE_ANON] + 1;
> 
> I think I can work with all that.  Please have a think about the few
> issues above and I'll try to sit down tomorrow and correlate this with
> the implementation.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
