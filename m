Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E47AF6B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 01:25:01 -0500 (EST)
Received: by pvh11 with SMTP id 11so295905pvh.14
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 22:25:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1003021610530.14687@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003010213480.26824@chino.kir.corp.google.com>
	 <28c262361003010802o7de2a32ci913b3833074af9eb@mail.gmail.com>
	 <28c262361003012029j1d17a0dch8987c0d6d939959e@mail.gmail.com>
	 <alpine.DEB.2.00.1003021610530.14687@chino.kir.corp.google.com>
Date: Wed, 3 Mar 2010 15:25:00 +0900
Message-ID: <28c262361003022225k420a5e23y2eeee2c4dfdbccc3@mail.gmail.com>
Subject: Re: [patch] mm: adjust kswapd nice level for high priority page
	allocators
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Con Kolivas <kernel@kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 3, 2010 at 9:14 AM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 2 Mar 2010, Minchan Kim wrote:
>
>> > Why do you reset nice value which set by set_kswapd_nice?
>>
>> My point is that you reset nice value(which is boosted at wakeup_kswapd) to 0
>> before calling balance_pgdat. It means kswapd could be rescheduled by nice 0
>> before really reclaim happens by balance_pgdat.
>
> wakeup_kswapd() wakes up kswapd at the finish_wait() point so that it has
> the nice value set by set_kswapd_nice() when it calls balance_pgdat(),
> loops, and then sets it back to the default nice level of 0.

I can't understand your point.

Now kswapd is working following as.

for (; ;) {
  prepare_to_wait();
  if ( ... ) {
    ...
    ...
    schedule() < --- wakeup point
    ...
    set_user_nice(tsk, 0); <-- You reset nice value to zero.
    order = pgdata->kswapd_max_order;
  }
  finish_wait();
  balance_pgdat(); << before entering balance_pgdat, the nice vaule
will be invalidated.
}

As above code, wakeup_kswapd() wakes up kswapd at not finish_wait but
next line of schedule(). So I think nice vaule promoted by
wakeup_kswapd would be invalidated.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
