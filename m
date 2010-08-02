Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 378C8600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:29:52 -0400 (EDT)
Received: by iwn2 with SMTP id 2so5215975iwn.14
        for <linux-mm@kvack.org>; Mon, 02 Aug 2010 16:32:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100802081253.GA27492@localhost>
References: <20100802003616.5b31ed8b@digital-domain.net>
	<20100802081253.GA27492@localhost>
Date: Tue, 3 Aug 2010 08:32:36 +0900
Message-ID: <AANLkTi=5074JuygMXPwTy1qSro+WfU2E9jJCd79S8vD6@mail.gmail.com>
Subject: Re: Bug 12309 - Large I/O operations result in poor interactive
	performance and high iowait times
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Clayton <andrew@digital-domain.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, pvz@pvz.pp.se, bgamari@gmail.com, larppaxyz@gmail.com, seanj@xyke.com, kernel-bugs.dev1world@spamgourmet.com, akatopaz@gmail.com, frankrq2009@gmx.com, thomas.pi@arcor.de, spawels13@gmail.com, vshader@gmail.com, rockorequin@hotmail.com, ylalym@gmail.com, theholyettlz@googlemail.com, hassium@yandex.ru
List-ID: <linux-mm.kvack.org>

Hi Wu,

On Mon, Aug 2, 2010 at 5:12 PM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
>> I've pointed to your two patches in the bug report, so hopefully someone
>> who is seeing the issues can try them out.
>
> Thanks.
>
>> I noticed your comment about the no swap situation
>>
>> "#26: Per von Zweigbergk
>> Disabling swap makes the terminal launch much faster while copying;
>> However Firefox and vim hang much more aggressively and frequently
>> during copying.
>>
>> It's interesting to see processes behave differently. Is this
>> reproducible at all?"
>>
>> Recently there have been some other people who have noticed this.
>>
>> Comment #460 From =A0S=F8ren Holm =A0 2010-07-22 20:33:00 =A0 (-) [reply=
] -------
>>
>> I've tried stress also.
>> I have 2 Gb og memory and 1.5 Gb swap
>>
>> With swap activated stress -d 1 hangs my machine
>>
>> Same does stress -d while swapiness set to 0
>>
>> Widh swap deactivated things runs pretty fine. Of couse apps utilizing
>> syncronous disk-io fight stress for priority.
>>
>> Comment #461 From =A0Nels Nielson =A0 2010-07-23 16:23:06 =A0 (-) [reply=
] -------
>>
>> I can also confirm this. Disabling swap with swapoff -a solves the probl=
em.
>> I have 8gb of ram and 8gb of swap with a fake raid mirror.
>>
>> Before this I couldn't do backups without the whole system grinding to a=
 halt.
>> Right now I am doing a backup from the drives, watching a movie from the=
 same
>> drives and more. No more iowait times and programs freezing as they are =
starved
>> from being able to access the drives.
>
> So swapping is another major cause of responsiveness lags.
>
> I just tested the heavy swapping case with the patches to remove
> the congestion_wait() and wait_on_page_writeback() stalls on high
> order allocations. The patches work as expected. No single stall shows
> up with the debug patch posted in http://lkml.org/lkml/2010/8/1/10.
>
> However there are still stalls on get_request_wait():
> - kswapd trying to pageout anonymous pages
> - _any_ process in direct reclaim doing pageout()
>
> Since 90% pages are dirty anonymous pages, the chances to stall is high.
> kswapd can hardly make smooth progress. The applications end up doing
> direct reclaim by themselves, which also ends up stuck in pageout().
> They are not explicitly stalled in vmscan code, but implicitly in
> get_request_wait() when trying to swapping out the dirty pages.
>
> It sure hurts responsiveness with so many applications stalled on
> get_request_wait(). But question is, what can we do otherwise? The
> system is running short of memory and cannot keep up freeing enough
> memory anyway. So page allocations have to be throttled somewhere..
>
> But wait.. What if there are only 50% anonymous pages? In this case
> applications don't necessarily need to sleep in get_request_wait().
> The memory pressure is not really high. The poor man's solution is to
> disable swapping totally, as the bug reporters find to be helpful..

What you mentioned problem is following as.

1. VM pageout many anon page to swap device.
2. Swap device starts to congest
3. When some application swap-in its page, it would be stalled by 2.

Or

1. So many application start to swap-in
2. Swap device starts to congest
3. When VM page out some anon page to swap device, it can be stalled by 2.

Is right?

> One easy fix is to skip swap-out when bdi is congested and priority is
> close to DEF_PRIORITY. However it would be unfair to selectively
> (largely in random) keep some pages and reclaim the others that
> actually have the same age.
>
> A more complete fix may be to introduce some swap_out LRU list(s).
> Pages in it will be swap out as fast as possible by a dedicated
> kernel thread. And pageout() can freely add pages to it until it
> grows larger than some threshold, eg. 30% reclaimable memory, at which
> point pageout() will stall on the list. The basic idea is to switch
> the random get_request_wait() stalls to some more global wise stalls.
>
> Does this sound feasible?
Tend to agree prevent random sleep.
But swap_out LRU list is meaningful?
If VM decides to swap out the page, it is a cold page.
If we want to batch I/O of swap pages, IMHO it would be better to put
together swap pages not LRU order but physical block order.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
