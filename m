Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D55706B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 20:18:04 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1B0053EE0C2
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:18:01 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F35C945DE96
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:18:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DA32C45DE92
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:18:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB1321DB803F
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:18:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8839C1DB802F
	for <linux-mm@kvack.org>; Tue, 24 May 2011 09:18:00 +0900 (JST)
Date: Tue, 24 May 2011 09:11:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/8] memcg asynchronous memory reclaim interface
Message-Id: <20110524091114.02fb183d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTinEcbQoV6n0+S9W4s4+AFJKKCiwsA@mail.gmail.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124636.45c26cfa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520144935.3bfdb2e2.akpm@linux-foundation.org>
	<BANLkTi=Ap=NdZ+05UjjEsC5f5wdjo9yvew@mail.gmail.com>
	<BANLkTinEcbQoV6n0+S9W4s4+AFJKKCiwsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>

On Mon, 23 May 2011 16:36:20 -0700
Ying Han <yinghan@google.com> wrote:

> On Fri, May 20, 2011 at 4:56 PM, Hiroyuki Kamezawa
> <kamezawa.hiroyuki@gmail.com> wrote:
> > 2011/5/21 Andrew Morton <akpm@linux-foundation.org>:
> >> On Fri, 20 May 2011 12:46:36 +0900
> >> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >>
> >>> This patch adds a logic to keep usage margin to the limit in asynchronous way.
> >>> When the usage over some threshould (determined automatically), asynchronous
> >>> memory reclaim runs and shrink memory to limit - MEMCG_ASYNC_STOP_MARGIN.
> >>>
> >>> By this, there will be no difference in total amount of usage of cpu to
> >>> scan the LRU
> >>
> >> This is not true if "don't writepage at all (revisit this when
> >> dirty_ratio comes.)" is true. A Skipping over dirty pages can cause
> >> larger amounts of CPU consumption.
> >>
> >>> but we'll have a chance to make use of wait time of applications
> >>> for freeing memory. For example, when an application read a file or socket,
> >>> to fill the newly alloated memory, it needs wait. Async reclaim can make use
> >>> of that time and give a chance to reduce latency by background works.
> >>>
> >>> This patch only includes required hooks to trigger async reclaim and user interfaces.
> >>> Core logics will be in the following patches.
> >>>
> >>>
> >>> ...
> >>>
> >>> A /*
> >>> + * For example, with transparent hugepages, memory reclaim scan at hitting
> >>> + * limit can very long as to reclaim HPAGE_SIZE of memory. This increases
> >>> + * latency of page fault and may cause fallback. At usual page allocation,
> >>> + * we'll see some (shorter) latency, too. To reduce latency, it's appreciated
> >>> + * to free memory in background to make margin to the limit. This consumes
> >>> + * cpu but we'll have a chance to make use of wait time of applications
> >>> + * (read disk etc..) by asynchronous reclaim.
> >>> + *
> >>> + * This async reclaim tries to reclaim HPAGE_SIZE * 2 of pages when margin
> >>> + * to the limit is smaller than HPAGE_SIZE * 2. This will be enabled
> >>> + * automatically when the limit is set and it's greater than the threshold.
> >>> + */
> >>> +#if HPAGE_SIZE != PAGE_SIZE
> >>> +#define MEMCG_ASYNC_LIMIT_THRESH A  A  A (HPAGE_SIZE * 64)
> >>> +#define MEMCG_ASYNC_MARGIN A  A  A  A  (HPAGE_SIZE * 4)
> >>> +#else /* make the margin as 4M bytes */
> >>> +#define MEMCG_ASYNC_LIMIT_THRESH A  A  A (128 * 1024 * 1024)
> >>> +#define MEMCG_ASYNC_MARGIN A  A  A  A  A  A (8 * 1024 * 1024)
> >>> +#endif
> >>
> >> Document them, please. A How are they used, what are their units.
> >>
> >
> > will do.
> >
> >
> >>> +static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);
> >>> +
> >>> +/*
> >>> A  * The memory controller data structure. The memory controller controls both
> >>> A  * page cache and RSS per cgroup. We would eventually like to provide
> >>> A  * statistics based on the statistics developed by Rik Van Riel for clock-pro,
> >>> @@ -278,6 +303,12 @@ struct mem_cgroup {
> >>> A  A  A  A */
> >>> A  A  A  unsigned long A  move_charge_at_immigrate;
> >>> A  A  A  /*
> >>> + A  A  A * Checks for async reclaim.
> >>> + A  A  A */
> >>> + A  A  unsigned long A  async_flags;
> >>> +#define AUTO_ASYNC_ENABLED A  (0)
> >>> +#define USE_AUTO_ASYNC A  A  A  A  A  A  A  (1)
> >>
> >> These are really confusing. A I looked at the implementation and at the
> >> documentation file and I'm still scratching my head. A I can't work out
> >> why they exist. A With the amount of effort I put into it ;)
> >>
> >> Also, AUTO_ASYNC_ENABLED and USE_AUTO_ASYNC have practically the same
> >> meaning, which doesn't help things.
> >>
> > Ah, yes it's confusing.
> 
> Sorry I was confused by the memory.async_control interface. I assume
> that is the knob to turn on/off the bg reclaim on per-memcg basis. But
> when I tried to turn it off, it seems not working well:
> 
> $ cat /proc/7248/cgroup
> 3:memory:/A
> 
> $ cat /dev/cgroup/memory/A/memory.async_control
> 0
> 

If enabled and kworker runs, this shows "3", for now.
I'll make this simpler in the next post.

> Then i can see the kworkers start running when the memcg A under
> memory pressure. There was no other memcgs configured under root.


What kworkers ? For example, many kworkers runs on ext4? on my host.
If kworker/u:x works, it may be for memcg (for my host)

Ok, I'll add statistics in v3.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
