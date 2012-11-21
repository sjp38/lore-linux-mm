Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 230F06B005D
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 16:30:19 -0500 (EST)
Date: Wed, 21 Nov 2012 13:30:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscan: Check for fatal signals iff the process was
 throttled
Message-Id: <20121121133017.f98149f2.akpm@linux-foundation.org>
In-Reply-To: <20121121210520.GP8218@suse.de>
References: <20121105144614.GJ8218@suse.de>
	<20121106002550.GA3530@barrios>
	<20121106085822.GN8218@suse.de>
	<20121106101719.GA2005@barrios>
	<20121109095024.GI8218@suse.de>
	<20121112133218.GA3156@barrios>
	<20121112140631.GV8218@suse.de>
	<20121113133109.GA5204@barrios>
	<20121121153824.GG8218@suse.de>
	<20121121121559.a1aa0593.akpm@linux-foundation.org>
	<20121121210520.GP8218@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>, Minchan Kim <minchan@kernel.org>

On Wed, 21 Nov 2012 21:05:20 +0000
Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Nov 21, 2012 at 12:15:59PM -0800, Andrew Morton wrote:
>
> ...
>
> > > -static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
> > > +static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
> > >  					nodemask_t *nodemask)
> > >  {
> > >  	struct zone *zone;
> > > @@ -2224,13 +2227,20 @@ static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
> > >  	 * processes to block on log_wait_commit().
> > >  	 */
> > >  	if (current->flags & PF_KTHREAD)
> > > -		return;
> > > +		goto out;
> > 
> > hm, well, back in the old days some kernel threads were killable via
> > signals.  They had to opt-in to it by diddling their signal masks and a
> > few other things.  Too lazy to check if there are still any such sites.
> > 
> 
> That check is against throttling rather than signal handling though. It
> could have been just left as "return".

My point is that there might still exist kernel threads which are killable
via signals.  Those threads match your criteria here: don't throttle -
just let them run to exit().

If there are indeed missed opportunities here then they will be small
ones.  And those threads probably only have signal_pending(), not
fatal_signal_pending().  Don't worry about it ;)

> > 
> > > +	/*
> > > +	 * If a fatal signal is pending, this process should not throttle.
> > > +	 * It should return quickly so it can exit and free its memory
> > > +	 */
> > > +	if (fatal_signal_pending(current))
> > > +		goto out;
> > 
> > theresabug.  It should return "true" here.
> > 
> 
> The intention here is that a process would
> 
> 1. allocate, fail, enter direct reclaim
> 2. no signal pending, gets throttled because of low pfmemalloc reserves
> 3. a user kills -9 the throttled process. returns true and goes back
>    to the page allocator
> 4. If that allocation fails again, it re-enters direct reclaim and tries
>    to throttle. This time the fatal signal is pending but we know
>    we must have already failed to make the allocation so this time false
>    is rurned by throttle_direct_reclaim and it tries direct reclaim.

My spinning head fell on the floor and is now drilling its way to China.

> 5. direct reclaim frees something -- probably clean file-backed pages
>    if the last allocation attempt had failed.
> 
> so the fatal signal check should only prevent entering direct reclaim
> once. Maybe the comment sucks

Well it did say "Returns true if a fatal signal was received during
throttling.".  That "during" was subtle.

> /*
>  * If a fatal signal is pending, this process should not throttle.
>  * It should return quickly so it can exit and free its memory. Note
>  * that returning false here allows a process to enter direct reclaim.
>  * Otherwise there is a risk that the process loops in the page
>  * allocator, checking signals and never making forward progress
>  */
> 
> ?

It's still unclear why throttle_direct_reclaim() returns false if
fatal_signal_pending() *before* throttling, but true *after* throttling. 
Why not always return true and just scram?

>
> ...
>
> Same comment about the potential looping. Otherwise I think it's ok.

Send me something sometime ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
