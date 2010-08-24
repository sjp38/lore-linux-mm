Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 40A4460080B
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 20:27:54 -0400 (EDT)
Date: Tue, 24 Aug 2010 08:27:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100824002753.GB6568@localhost>
References: <20100818154130.GC9431@localhost>
 <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
 <20100819160006.GG6805@barrios-desktop>
 <AA3F2D89535A431DB91FE3032EDCB9EA@rainbow>
 <20100820053447.GA13406@localhost>
 <20100820093558.GG19797@csn.ul.ie>
 <AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com>
 <20100822153121.GA29389@barrios-desktop>
 <20100822232316.GA339@localhost>
 <20100823171416.GA2216@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100823171416.GA2216@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Iram Shahzad <iram.shahzad@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 01:14:16AM +0800, Minchan Kim wrote:
> On Mon, Aug 23, 2010 at 07:23:16AM +0800, Wu Fengguang wrote:
> > > From: Minchan Kim <minchan.kim@gmail.com>
> > > Date: Mon, 23 Aug 2010 00:20:44 +0900
> > > Subject: [PATCH] compaction: handle active and inactive fairly in too_many_isolated
> > > 
> > > Iram reported compaction's too_many_isolated loops forever.
> > > (http://www.spinics.net/lists/linux-mm/msg08123.html)
> > > 
> > > The meminfo of situation happened was inactive anon is zero.
> > > That's because the system has no memory pressure until then.
> > > While all anon pages was in active lru, compaction could select
> > > active lru as well as inactive lru. That's different things
> > > with vmscan's isolated. So we has been two too_many_isolated.
> > > 
> > > While compaction can isolated pages in both active and inactive,
> > > current implementation of too_many_isolated only considers inactive.
> > > It made Iram's problem.
> > > 
> > > This patch handles active and inactie with fair.
> > > That's because we can't expect where from and how many compaction would
> > > isolated pages.
> > > 
> > > This patch changes (nr_isolated > nr_inactive) with
> > > nr_isolated > (nr_active + nr_inactive) / 2.
> > 
> > The change looks good, thanks. However I'm not sure if it's enough.
> > 
> > I wonder where the >40MB isolated pages come about.  inactive_anon
> > remains 0 and free remains high over a long time, so it seems there
> > are no concurrent direct reclaims at all. Are the pages isolated by
> > the compaction process itself?
> 
> I think it can't happen without kswapd or direct reclaim.
> But I think direct reclaim doesn't happen becuase Iram has no activity on system 
> at that time. So just geussing following scenario.
> 
> 1. trigger compaction by proc
> 2. isolate some pages and then migrate_pages
> 3. migrate_pages calls cond_resched
> 4. someone need big page(I am not sure this part)
> 4. kswapd: shrink anon active list due to inactive_anon_is_low
> 5. kswapd: isolate_lru_pages for order > 0 (ex, 0.5M page) so 0.5 M * 32 = 16M are isolated
> 6. kswapd: shrink_zone : shrink anon active list due to inactive_anon_is_low 
> 7. kswapd: isolate_lru_pages for order > 0 (ex, 0.5M page) so 0.5 M * 32  are isolated again.
> 
> Does it make sense?

One question is, why kswapd won't proceed after isolating all the pages?
If it has done with the isolated pages, we'll see growing inactive_anon
numbers.

/proc/vmstat should give more clues on any possible page reclaim
activities. Iram, would you help post it?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
