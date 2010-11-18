Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C50EA6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 12:28:18 -0500 (EST)
Date: Thu, 18 Nov 2010 17:27:39 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v3] factor out kswapd sleeping logic from kswapd()
Message-ID: <20101118172738.GN8135@csn.ul.ie>
References: <20101114180505.BEE2.A69D9226@jp.fujitsu.com> <20101115094239.GH27362@csn.ul.ie> <20101116144709.BF26.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101116144709.BF26.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 16, 2010 at 03:07:22PM +0900, KOSAKI Motohiro wrote:
> > > +void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
> > > +{
> > 
> > As pointed out elsewhere, this should be static.
> 
> Fixed.
> 
> 
> > > +	long remaining = 0;
> > > +	DEFINE_WAIT(wait);
> > > +
> > > +	if (freezing(current) || kthread_should_stop())
> > > +		return;
> > > +
> > > +	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > > +
> > > +	/* Try to sleep for a short interval */
> > > +	if (!sleeping_prematurely(pgdat, order, remaining)) {
> > > +		remaining = schedule_timeout(HZ/10);
> > > +		finish_wait(&pgdat->kswapd_wait, &wait);
> > > +		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > > +	}
> > > +
> > > +	/*
> > > +	 * After a short sleep, check if it was a
> > > +	 * premature sleep. If not, then go fully
> > > +	 * to sleep until explicitly woken up
> > > +	 */
> > 
> > Very minor but that comment should now fit on fewer lines.
> 
> Thanks, fixed.
> 
> 
> > > +	if (!sleeping_prematurely(pgdat, order, remaining)) {
> > > +		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> > > +		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
> > > +		schedule();
> > > +		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
> > 
> > I posted a patch adding a comment on why set_pgdat_percpu_threshold() is
> > called. I do not believe it has been picked up by Andrew but it if is,
> > the patches will conflict. The resolution will be obvious but you may
> > need to respin this patch if the comment patch gets picked up in mmotm.
> > 
> > Otherwise, I see no problems.
> 
> OK, I've rebased the patch on top your comment patch. 
> 
> 
> 
> From 1bd232713d55f033676f80cc7451ff83d4483884 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Mon, 6 Dec 2010 20:44:27 +0900
> Subject: [PATCH] factor out kswapd sleeping logic from kswapd()
> 
> Currently, kswapd() function has deeper nest and it slightly harder to
> read. cleanup it.
> 
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

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
