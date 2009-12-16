Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 112776B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 19:48:55 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG0mr1n029900
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 16 Dec 2009 09:48:53 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B5F1745DE6E
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 09:48:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EA6D45DE60
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 09:48:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 01E871DB803B
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 09:48:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AEF981DB8037
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 09:48:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/8] Use prepare_to_wait_exclusive() instead prepare_to_wait()
In-Reply-To: <4B27A417.3040206@redhat.com>
References: <1260855146.6126.30.camel@marge.simson.net> <4B27A417.3040206@redhat.com>
Message-Id: <20091216093533.CDF1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 16 Dec 2009 09:48:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mike Galbraith <efault@gmx.de>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

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

if we really need wait a bit, Mike's wake_up_batch is best, I think.
It mean
 - if another CPU is idle, wake up one process soon. iow, it don't
   make meaningless idle.
 - if another CPU is busy, woken process don't start to run awhile.
   then, zone_watermark_ok() can calculate correct value.


> > What happens to waiters should running tasks not allocate for a while?
> 
> When a waiter is woken up, it will either:
> 1) see that there is enough free memory and wake up the next guy, or
> 2) run shrink_zone and wake up the next guy
> 
> Either way, the processes that just got woken up will ensure that
> the sleepers behind them in the queue will get woken up.
> 
> -- 
> All rights reversed.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
