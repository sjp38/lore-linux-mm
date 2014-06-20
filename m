Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 72C366B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 23:56:21 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so2624678pad.38
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 20:56:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id rp15si8131466pab.235.2014.06.19.20.56.20
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 20:56:20 -0700 (PDT)
Date: Thu, 19 Jun 2014 20:53:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Write down design and intentions in English for
 proportial scan
Message-Id: <20140619205357.e171e174.akpm@linux-foundation.org>
In-Reply-To: <20140620030002.GA14884@bbox>
References: <20140620030002.GA14884@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Chen Yucong <slaoub@gmail.com>, mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 20 Jun 2014 12:00:02 +0900 Minchan Kim <minchan@kernel.org> wrote:

> By suggestion from Andrew, first of all, I try to add only comment
> but I believe we could make it more clear by some change like this.
> https://lkml.org/lkml/2014/6/16/750
> 
> Anyway, push this patch firstly.

Thanks.

> ================= &< =================
> 
> >From b1fd007097064db34a211ffeacfe4da9fb22d49e Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Fri, 20 Jun 2014 11:37:52 +0900
> Subject: [PATCH] mm: Write down design and intentions in English for
>  proportial scan
> 
> Quote from Andrew
> "
> That code is absolutely awful :( It's terribly difficult to work out
> what the design is - what the code is actually setting out to achieve.
> One is reduced to trying to reverse-engineer the intent from the
> implementation and that becomes near impossible when the
> implementation has bugs!
> 
> <snip>
> 
> The only way we're going to fix all this up is to stop looking at the
> code altogether.  Write down the design and the intentions in English.
> Review that.  Then implement that design in C
> "
> 
> One thing I know it might not be English Andrew expected but other
> thing I know is there are lots of native people in here so one of them
> will spend his time to make this horrible English smooth.
> 
> I alreday spent my time to try to fix this situation so it's your
> turn. It's good time balance between non-native and native people
> so open source community is fair for all of us.
> 

I can do that ;)  But not yet.

> ---
>  mm/vmscan.c | 37 +++++++++++++++++++++++++++++++------
>  1 file changed, 31 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 521f7eab1798..3a9862895a64 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2071,6 +2071,22 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  
>  	get_scan_count(lruvec, sc, nr);
>  
> +	/*
> +	 * Basically, VM scans file/anon LRU list proportionally

OK

> depending
> +	 * on the value of vm.swappiness

"depending" in what fashion?  Higher swappiness leads to lengthier
scans.  But there's this:

	/*
	 * With swappiness at 100, anonymous and file have the same priority.
	 * This scanning priority is essentially the inverse of IO cost.
	 */
	anon_prio = sc->swappiness;
	file_prio = 200 - anon_prio;


> but doesn't want to reclaim
> +	 * excessive pages. So, it might be better to stop scan as soon as
> +	 * we meet nr_to_reclaim

"scanning" does not equal "reclaiming", as not all scanned pages are
reclaimed.  I guess we mean "stop scanning when nr_reclaimed pages have
been reclaimed".

> but it breaks aging balance between LRU lists

Why does it do this?

> +	 * To keep the balance, what we do is as follows.
> +	 *
> +	 * If we reclaim pages requested, we stop scanning first and
> +	 * investigate which LRU should be scanned more depending on
> +	 * remained lru size(ie, nr[xxx]). We will scan bigger one more
> +	 * so, final goal is
> +	 *
> +	 * scanned[xxx] = targets[xxx] - nr[xxx]
> +	 * targets[anon] : targets[file] = scanned[anon] : scanned[file]
> +	 */

hm, what's going on here.  Something like this?

"after having scanned sufficient pages to reclaim nr_to_reclaim pages,
the LRUs will now be out of balance if many more pages were reclaimed
from one LRU than from the others.  We now bring the LRUs back into
balance by ...".  

I'm not sure this really makes sense from a *design* aspect.  Is the
amount of scanning which we do here sufficiently large to have a
significant impact on the LRU sizes?  I suppose yes, in rare cases.

How do we define "balance" anyway?  Can we make some statement explaining
how the LRUs will appear when they are in a "balanced" state?

>  	/* Record the original scan target for proportional adjustments later */
>  	memcpy(targets, nr, sizeof(nr));
>  
> @@ -2091,8 +2107,14 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  	blk_start_plug(&plug);
>  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
>  					nr[LRU_INACTIVE_FILE]) {
> -		unsigned long nr_anon, nr_file, percentage;
> +		unsigned long nr_anon, nr_file;
>  		unsigned long nr_scanned;
> +		/*
> +		 * How many pages we should scan to meet target
> +		 * calculated by get_scan_count. It means that
> +		 * (100 - percentage) = already scanned ratio
> +		 */
> +		unsigned percentage;

Well, "percentage" is a ratio.  So maybe "what proportion of the LRUs
we should scan to..."?


>  		for_each_evictable_lru(lru) {
>  			if (nr[lru]) {
> @@ -2108,11 +2130,10 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  			continue;
>  
>  		/*
> -		 * For kswapd and memcg, reclaim at least the number of pages
> -		 * requested. Ensure that the anon and file LRUs are scanned
> -		 * proportionally what was requested by get_scan_count(). We
> -		 * stop reclaiming one LRU and reduce the amount scanning
> -		 * proportional to the original scan target.
> +		 * Here, we reclaimed at least the number of pages requested.
> +		 * Then, what we should do is the ensure that the anon and
> +		 * file LRUs are scanned proportionally what was requested
> +		 * by get_scan_count().
>  		 */

OK.

>  		nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
>  		nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];
> @@ -2126,6 +2147,10 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  		if (!nr_file || !nr_anon)
>  			break;
>  
> +		/*
> +		 * Scan the bigger of the LRU more while stop scanning
> +		 * the smaller of the LRU to keep aging balance between LRUs
> +		 */

OK.

>  		if (nr_file > nr_anon) {
>  			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
>  						targets[LRU_ACTIVE_ANON] + 1;

I think I can work with all that.  Please have a think about the few
issues above and I'll try to sit down tomorrow and correlate this with
the implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
