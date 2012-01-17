Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 57A1C6B004D
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 18:08:15 -0500 (EST)
Received: by vbbfa15 with SMTP id fa15so2728455vbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 15:08:14 -0800 (PST)
Date: Wed, 18 Jan 2012 08:08:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/3] vmscan hook
Message-ID: <20120117230801.GA903@barrios-desktop.redhat.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
 <1326788038-29141-3-git-send-email-minchan@kernel.org>
 <20120117173932.1c058ba4.kamezawa.hiroyu@jp.fujitsu.com>
 <20120117091356.GA29736@barrios-desktop.redhat.com>
 <20120117190512.047d3a03.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120117190512.047d3a03.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, penberg@kernel.org, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>

On Tue, Jan 17, 2012 at 07:05:12PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 17 Jan 2012 18:13:56 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > On Tue, Jan 17, 2012 at 05:39:32PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 17 Jan 2012 17:13:57 +0900
> > > Minchan Kim <minchan@kernel.org> wrote:
> > > 
> > > 
> > > > +	/*
> > > > +	 * We want to avoid dropping page cache excessively
> > > > +	 * in no swap system
> > > > +	 */
> > > > +	if (nr_swap_pages <= 0) {
> > > > +		free = zone_page_state(mz->zone, NR_FREE_PAGES);
> > > > +		file = zone_page_state(mz->zone, NR_ACTIVE_FILE) +
> > > > +			zone_page_state(mz->zone, NR_INACTIVE_FILE);
> > > > +		/*
> > > > +		 * If we have very few page cache pages,
> > > > +		 * notify to user
> > > > +		 */
> > > > +		if (file < free)
> > > > +			low_mem = true;
> > > > +	}
> > > 
> > > I can't understand why you think you can check lowmem condition by "file < free".
> > 
> > The reason I thought so is I want to maintain some page cache to some degree.
> > But I admit It's very naive heuristic and should be improved.
> > 
> > > And I don't think using per-zone data is good.
> > > (I'm not sure how many zones embeded guys using..)
> > 
> > Agree. In case of swapless system, we need another heuristic.
> > 
> > > 
> > > Another idea:
> > > 1. can't we use some technique like cleancache to detect the condition ?
> > 
> > I totally forgot cleancache approach. Could you remind that?
> > 
> 
> Similar to 'victim cache'. Then, cache some clean pages somewhere when
> vmscan pageout it.
> 
>    page -> vmscan's pageout -> cleancache  -> may be discarded.
> 
> If a filesystem look up a page which is in a cleancache, cache-hit and
> bring it back to radix-tree. If not, read from disk again.
> And cleancache for swap(frontswap) was posted, too.

I am not sure this can prevent swapout.
I think it ends up evicting pages into swap devices.

> 
> 
> > > 2. can't we measure page-in/page-out distance by recording something ?
> > 
> > I can't understand your point. What's relation does it with swapout prevent?
> > 
> 
> If distance between pageout -> pagein is short, it means thrashing.
> For example, recoding the timestamp when the page(mapping, index) was
> paged-out, and check it at page-in.

Our goal is prevent swapout. When we found thrashing, it's too late.

> 
> 
> > > 3. NR_ANON + NR_FILE_MAPPED can't mean the amount of core memory if we can
> > >    ignore the data file cache ?
> > 
> > It's good but how do we define some amount?
> > It's very vague but I guess we can get a good idea from that.
> > Perhaps, you already has it.
> > 
> 
> Hm, a rough idea is...
> 
>   - we now have rss counter per mm.
>     - mapped anon
>     - mapped file
>     - swapents
>  
> Ok, here, add one more counter.
> 
>     - paged-out file. (I think this can be recorded in pte.)
>       +1 when try_to_unmap_file() unmaps it.
>       -1 when a page is back or unmapped.
> 
> Then, scanning all tasks. Then,
> 
>                                  mapped_anon + mapped_file
> active_map_ratio =   ----------------------------------------------------- * 100
>                      mapped_anon + mapped_file + swapents + paged_out_file
> 
> Ok, how to use this value...
> 
> Like memcg's threshold notify interface, you can change the mem_notify interface
> to use eventfd() as
> 
>    <event_fd, fd of /dev/mem_notify, threshold of active_map_ratio>
> 
> This will inform you an event when active_map_ratio crosses passed threshold.
> 
> complicated ? 

Yes. :)
I want to make simple if possible.

> 
> 
> > > 4. how about checking kswapd's busy status ?
> > 
> > Could you elaborate on your idea?
> > 
> 
> I just thought kswapd may not stop when the situation is very bad.

As I said eariler, the goal is prevent swap.
When we found kswapd is busy, it might many pages are already swapped-out so it's too late.

> 
> Thanks,
> -Kame
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
