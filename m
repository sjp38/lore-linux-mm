Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CA9AA900114
	for <linux-mm@kvack.org>; Fri, 20 May 2011 21:26:31 -0400 (EDT)
Date: Fri, 20 May 2011 18:26:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 8/8] memcg asyncrhouns reclaim workqueue
Message-Id: <20110520182640.7e71af33.akpm@linux-foundation.org>
In-Reply-To: <BANLkTinwmtgh+p=aeZux3NuC2ftbR5OMgQ@mail.gmail.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124837.72978344.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520145115.d52f3693.akpm@linux-foundation.org>
	<BANLkTinwmtgh+p=aeZux3NuC2ftbR5OMgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>

On Sat, 21 May 2011 09:41:50 +0900 Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com> wrote:

> 2011/5/21 Andrew Morton <akpm@linux-foundation.org>:
> > On Fri, 20 May 2011 12:48:37 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> >> workqueue for memory cgroup asynchronous memory shrinker.
> >>
> >> This patch implements the workqueue of async shrinker routine. each
> >> memcg has a work and only one work can be scheduled at the same time.
> >>
> >> If shrinking memory doesn't goes well, delay will be added to the work.
> >>
> >
> > When this code explodes (as it surely will), users will see large
> > amounts of CPU consumption in the work queue thread. __We want to make
> > this as easy to debug as possible, so we should try to make the
> > workqueue's names mappable back onto their memcg's. __And anything else
> > we can think of to help?
> >
> 
> I had a patch for showing per-memcg reclaim latency stats. It will be help.
> I'll add it again to this set. I just dropped it because there are many patches
> onto memory.stat in flight..

Will that patch help us when users report the memcg equivalent of
"kswapd uses 99% of CPU"?

> >
> >> + __ __ limit = res_counter_read_u64(&mem->res, RES_LIMIT);
> >> + __ __ shrink_to = limit - MEMCG_ASYNC_MARGIN - PAGE_SIZE;
> >> + __ __ usage = res_counter_read_u64(&mem->res, RES_USAGE);
> >> + __ __ if (shrink_to <= usage) {
> >> + __ __ __ __ __ __ required = usage - shrink_to;
> >> + __ __ __ __ __ __ required = (required >> PAGE_SHIFT) + 1;
> >> + __ __ __ __ __ __ /*
> >> + __ __ __ __ __ __ __* This scans some number of pages and returns that memory
> >> + __ __ __ __ __ __ __* reclaim was slow or now. If slow, we add a delay as
> >> + __ __ __ __ __ __ __* congestion_wait() in vmscan.c
> >> + __ __ __ __ __ __ __*/
> >> + __ __ __ __ __ __ congested = mem_cgroup_shrink_static_scan(mem, (long)required);
> >> + __ __ }
> >> + __ __ if (test_bit(ASYNC_NORESCHED, &mem->async_flags)
> >> + __ __ __ __ || mem_cgroup_async_should_stop(mem))
> >> + __ __ __ __ __ __ goto finish_scan;
> >> + __ __ /* If memory reclaim couldn't go well, add delay */
> >> + __ __ if (congested)
> >> + __ __ __ __ __ __ delay = HZ/10;
> >
> > Another magic number.
> >
> > If Moore's law holds, we need to reduce this number by 1.4 each year.
> > Is this good?
> >
> 
> not good.  I just used the same magic number now used with wait_iff_congested.
> Other than timer, I can use pagein/pageout event counter. If we have
> dirty_ratio,
> I may able to link this to dirty_ratio and wait until dirty_ratio is enough low.
> Or, wake up again hit limit.
> 
> Do you have suggestion ?
> 

mm..  It would be pretty easy to generate an estimate of "pages scanned
per second" from the contents of (and changes in) the scan_control. 
Konwing that datum and knowing the number of pages in the memcg, we
should be able to come up with a delay period which scales
appropriately with CPU speed and with memory size?

Such a thing could be used to rationalise magic delays in other places,
hopefully.

> 
> >> + __ __ queue_delayed_work(memcg_async_shrinker, &mem->async_work, delay);
> >> + __ __ return;
> >> +finish_scan:
> >> + __ __ cgroup_release_and_wakeup_rmdir(&mem->css);
> >> + __ __ clear_bit(ASYNC_RUNNING, &mem->async_flags);
> >> + __ __ return;
> >> +}
> >> +
> >> +static void run_mem_cgroup_async_shrinker(struct mem_cgroup *mem)
> >> +{
> >> + __ __ if (test_bit(ASYNC_NORESCHED, &mem->async_flags))
> >> + __ __ __ __ __ __ return;
> >
> > I can't work out what ASYNC_NORESCHED does. __Is its name well-chosen?
> >
> how about BLOCK/STOP_ASYNC_RECLAIM ?

I can't say - I don't know what it does!  Or maybe I did, and immediately
forgot ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
