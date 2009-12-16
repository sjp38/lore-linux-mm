Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 534EA6B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 00:43:49 -0500 (EST)
Subject: Re: [PATCH 4/8] Use prepare_to_wait_exclusive() instead
 prepare_to_wait()
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <20091216093533.CDF1.A69D9226@jp.fujitsu.com>
References: <1260855146.6126.30.camel@marge.simson.net>
	 <4B27A417.3040206@redhat.com> <20091216093533.CDF1.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 16 Dec 2009 06:43:44 +0100
Message-Id: <1260942224.5766.57.camel@marge.simson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 2009-12-16 at 09:48 +0900, KOSAKI Motohiro wrote:
> > On 12/15/2009 12:32 AM, Mike Galbraith wrote:
> > > On Tue, 2009-12-15 at 09:45 +0900, KOSAKI Motohiro wrote:
> > >>> On 12/14/2009 07:30 AM, KOSAKI Motohiro wrote:
> > >>>> if we don't use exclusive queue, wake_up() function wake _all_ waited
> > >>>> task. This is simply cpu wasting.
> > >>>>
> > >>>> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> > >>>
> > >>>>    		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
> > >>>>    					0, 0)) {
> > >>>> -			wake_up(wq);
> > >>>> +			wake_up_all(wq);
> > >>>>    			finish_wait(wq,&wait);
> > >>>>    			sc->nr_reclaimed += sc->nr_to_reclaim;
> > >>>>    			return -ERESTARTSYS;
> > >>>
> > >>> I believe we want to wake the processes up one at a time
> > >>> here.
> > 
> > >> Actually, wake_up() and wake_up_all() aren't different so much.
> > >> Although we use wake_up(), the task wake up next task before
> > >> try to alloate memory. then, it's similar to wake_up_all().
> > 
> > That is a good point.  Maybe processes need to wait a little
> > in this if() condition, before the wake_up().  That would give
> > the previous process a chance to allocate memory and we can
> > avoid waking up too many processes.
> 
> if we really need wait a bit, Mike's wake_up_batch is best, I think.
> It mean
>  - if another CPU is idle, wake up one process soon. iow, it don't
>    make meaningless idle.

Along those lines, there's also NEWIDLE balancing considerations.  That
idle may result in a task being pulled, which may or may not hurt a bit.

'course, if you're jamming up on memory allocation, that's the least of
your worries, but every idle avoided is potentially a pull avoided.

Just a thought.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
