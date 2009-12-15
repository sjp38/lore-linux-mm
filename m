Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5851F6B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 13:17:30 -0500 (EST)
Subject: Re: [PATCH 4/8] Use prepare_to_wait_exclusive() instead
 prepare_to_wait()
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <4B27A417.3040206@redhat.com>
References: <20091214212936.BBBA.A69D9226@jp.fujitsu.com>
	 <4B264CCA.5010609@redhat.com> <20091215085631.CDAD.A69D9226@jp.fujitsu.com>
	 <1260855146.6126.30.camel@marge.simson.net>  <4B27A417.3040206@redhat.com>
Content-Type: text/plain
Date: Tue, 15 Dec 2009 19:17:22 +0100
Message-Id: <1260901042.5913.12.camel@marge.simson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-12-15 at 09:58 -0500, Rik van Riel wrote:
> On 12/15/2009 12:32 AM, Mike Galbraith wrote:
> > On Tue, 2009-12-15 at 09:45 +0900, KOSAKI Motohiro wrote:
> >>> On 12/14/2009 07:30 AM, KOSAKI Motohiro wrote:
> >>>> if we don't use exclusive queue, wake_up() function wake _all_ waited
> >>>> task. This is simply cpu wasting.
> >>>>
> >>>> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> >>>
> >>>>    		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
> >>>>    					0, 0)) {
> >>>> -			wake_up(wq);
> >>>> +			wake_up_all(wq);
> >>>>    			finish_wait(wq,&wait);
> >>>>    			sc->nr_reclaimed += sc->nr_to_reclaim;
> >>>>    			return -ERESTARTSYS;
> >>>
> >>> I believe we want to wake the processes up one at a time
> >>> here.
> 
> >> Actually, wake_up() and wake_up_all() aren't different so much.
> >> Although we use wake_up(), the task wake up next task before
> >> try to alloate memory. then, it's similar to wake_up_all().
> 
> That is a good point.  Maybe processes need to wait a little
> in this if() condition, before the wake_up().  That would give
> the previous process a chance to allocate memory and we can
> avoid waking up too many processes.
> 
> > What happens to waiters should running tasks not allocate for a while?
> 
> When a waiter is woken up, it will either:
> 1) see that there is enough free memory and wake up the next guy, or
> 2) run shrink_zone and wake up the next guy
> 
> Either way, the processes that just got woken up will ensure that
> the sleepers behind them in the queue will get woken up.

OK, that more or less covers my worry.  From the scheduler standpoint
though, you're better off turning them all loose and letting them race,
_with_ the caveat than thundering herds do indeed make thunder (reason
for patch).  Turning them loose piecemeal spreads things out over time,
which prolongs surge operations, possibly much longer than necessary.
We had the same long ago with everyone waiting for kswapd to do all the
work.  Sticky problem, this roll-down to inevitable wait.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
