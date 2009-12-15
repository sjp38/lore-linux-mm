Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 02A676B0062
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 00:32:32 -0500 (EST)
Subject: Re: [PATCH 4/8] Use prepare_to_wait_exclusive() instead
 prepare_to_wait()
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <20091215085631.CDAD.A69D9226@jp.fujitsu.com>
References: <20091214212936.BBBA.A69D9226@jp.fujitsu.com>
	 <4B264CCA.5010609@redhat.com> <20091215085631.CDAD.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 15 Dec 2009 06:32:26 +0100
Message-Id: <1260855146.6126.30.camel@marge.simson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-12-15 at 09:45 +0900, KOSAKI Motohiro wrote:
> > On 12/14/2009 07:30 AM, KOSAKI Motohiro wrote:
> > > if we don't use exclusive queue, wake_up() function wake _all_ waited
> > > task. This is simply cpu wasting.
> > >
> > > Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> > 
> > >   		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
> > >   					0, 0)) {
> > > -			wake_up(wq);
> > > +			wake_up_all(wq);
> > >   			finish_wait(wq,&wait);
> > >   			sc->nr_reclaimed += sc->nr_to_reclaim;
> > >   			return -ERESTARTSYS;
> > 
> > I believe we want to wake the processes up one at a time
> > here.  If the queue of waiting processes is very large
> > and the amount of excess free memory is fairly low, the
> > first processes that wake up can take the amount of free
> > memory back down below the threshold.  The rest of the
> > waiters should stay asleep when this happens.
> 
> OK.
> 
> Actually, wake_up() and wake_up_all() aren't different so much.
> Although we use wake_up(), the task wake up next task before
> try to alloate memory. then, it's similar to wake_up_all().

What happens to waiters should running tasks not allocate for a while?

> However, there are few difference. recent scheduler latency improvement
> effort reduce default scheduler latency target. it mean, if we have
> lots tasks of running state, the task have very few time slice. too
> frequently context switch decrease VM efficiency.
> Thank you, Rik. I didn't notice wake_up() makes better performance than
> wake_up_all() on current kernel.

Perhaps this is a spot where an explicit wake_up_all_nopreempt() would
be handy.  Excessive wakeup preemption from wake_up_all() has long been
annoying when there are many waiters, but converting it to only have the
first wakeup be preemptive proved harmful to performance.  Recent tweaks
will have aggravated the problem somewhat, but it's not new.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
