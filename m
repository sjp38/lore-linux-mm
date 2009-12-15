Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 092A46B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 19:35:46 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF0ZidM008784
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 15 Dec 2009 09:35:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F37AF45DE57
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:35:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C818D45DE4F
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:35:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4194E1DB8038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:35:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D70FCE1800F
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 09:35:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/8] Stop reclaim quickly when the task reclaimed enough lots pages
In-Reply-To: <20091215091107.219644fe.minchan.kim@barrios-desktop>
References: <20091214213103.BBC0.A69D9226@jp.fujitsu.com> <20091215091107.219644fe.minchan.kim@barrios-desktop>
Message-Id: <20091215092654.CDB3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 15 Dec 2009 09:35:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Mon, 14 Dec 2009 21:31:36 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > 
> > From latency view, There isn't any reason shrink_zones() continue to
> > reclaim another zone's page if the task reclaimed enough lots pages.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/vmscan.c |   16 ++++++++++++----
> >  1 files changed, 12 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 0880668..bf229d3 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1654,7 +1654,7 @@ static void shrink_zone_end(struct zone *zone, struct scan_control *sc)
> >  /*
> >   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
> >   */
> > -static void shrink_zone(int priority, struct zone *zone,
> > +static int shrink_zone(int priority, struct zone *zone,
> >  			struct scan_control *sc)
> >  {
> >  	unsigned long nr[NR_LRU_LISTS];
> > @@ -1669,7 +1669,7 @@ static void shrink_zone(int priority, struct zone *zone,
> >  
> >  	ret = shrink_zone_begin(zone, sc);
> >  	if (ret)
> > -		return;
> > +		return ret;
> >  
> >  	/* If we have no swap space, do not bother scanning anon pages. */
> >  	if (!sc->may_swap || (nr_swap_pages <= 0)) {
> > @@ -1692,6 +1692,7 @@ static void shrink_zone(int priority, struct zone *zone,
> >  					  &reclaim_stat->nr_saved_scan[l]);
> >  	}
> >  
> > +	ret = 0;
> >  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> >  					nr[LRU_INACTIVE_FILE]) {
> >  		for_each_evictable_lru(l) {
> > @@ -1712,8 +1713,10 @@ static void shrink_zone(int priority, struct zone *zone,
> >  		 * with multiple processes reclaiming pages, the total
> >  		 * freeing target can get unreasonably large.
> >  		 */
> > -		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
> > +		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY) {
> > +			ret = -ERESTARTSYS;
> 
> Just nitpick. 
> 
> shrink_zone's return value is matter?
> shrink_zones never handle that. 

shrink_zones() stop vmscan quickly if ret isn't !0.
if we already scanned rather than nr_to_reclaim, we can stop vmscan.


> As a matter of fact, I am worried about this patch. 
> 
> My opinion is we put aside this patch until we can solve Larry's problem.
> We could apply this patch in future.
> 
> I don't want to see the side effect while we focus Larry's problem.
> But If you mind my suggestion, I also will not bother you by this nitpick.
> 
> Thanks for great cleanup and improving VM, Kosaki. :)

I agree with Larry's issue is highest priority.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
