Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 79FEB6007DC
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 03:18:19 -0400 (EDT)
Date: Mon, 23 Aug 2010 08:18:04 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100823071804.GM19797@csn.ul.ie>
References: <4385155269B445AEAF27DC8639A953D7@rainbow> <20100818154130.GC9431@localhost> <565A4EE71DAC4B1A820B2748F56ABF73@rainbow> <20100819160006.GG6805@barrios-desktop> <AA3F2D89535A431DB91FE3032EDCB9EA@rainbow> <20100820053447.GA13406@localhost> <20100820093558.GG19797@csn.ul.ie> <AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com> <20100822153121.GA29389@barrios-desktop> <20100822232316.GA339@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100822232316.GA339@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Iram Shahzad <iram.shahzad@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 07:23:16AM +0800, Wu Fengguang wrote:
> > From: Minchan Kim <minchan.kim@gmail.com>
> > Date: Mon, 23 Aug 2010 00:20:44 +0900
> > Subject: [PATCH] compaction: handle active and inactive fairly in too_many_isolated
> > 
> > Iram reported compaction's too_many_isolated loops forever.
> > (http://www.spinics.net/lists/linux-mm/msg08123.html)
> > 
> > The meminfo of situation happened was inactive anon is zero.
> > That's because the system has no memory pressure until then.
> > While all anon pages was in active lru, compaction could select
> > active lru as well as inactive lru. That's different things
> > with vmscan's isolated. So we has been two too_many_isolated.
> > 
> > While compaction can isolated pages in both active and inactive,
> > current implementation of too_many_isolated only considers inactive.
> > It made Iram's problem.
> > 
> > This patch handles active and inactie with fair.
> > That's because we can't expect where from and how many compaction would
> > isolated pages.
> > 
> > This patch changes (nr_isolated > nr_inactive) with
> > nr_isolated > (nr_active + nr_inactive) / 2.
> 
> The change looks good, thanks. However I'm not sure if it's enough.
> 
> I wonder where the >40MB isolated pages come about.  inactive_anon
> remains 0 and free remains high over a long time, so it seems there
> are no concurrent direct reclaims at all.

When the proc trigger is used, it is not necessary for there to be any
memory pressure for compaction to be running. It's unlikely in this case
that there are many processes direct compacting but the check should
still not potentially loop.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
