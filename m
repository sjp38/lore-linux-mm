Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC816B00FB
	for <linux-mm@kvack.org>; Sun, 26 Jun 2011 21:56:46 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4E59A3EE0B6
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 10:56:43 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 299B845DE7E
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 10:56:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 013D345DE9C
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 10:56:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB8111DB8041
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 10:56:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9761D1DB8038
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 10:56:42 +0900 (JST)
Date: Mon, 27 Jun 2011 10:49:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/7] memcg: add memory.scan_stat
Message-Id: <20110627104941.3b4cbb22.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTimBPo6PyMKB4_ASL2nP2xiajExFK7ZWwvCUkdaqssnHiQ@mail.gmail.com>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125314.4f78b1e0.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim-r6ejJK601rWq7smY37FC9um7mg@mail.gmail.com>
	<20110622092031.e4be1846.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimBPo6PyMKB4_ASL2nP2xiajExFK7ZWwvCUkdaqssnHiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Fri, 24 Jun 2011 14:40:42 -0700
Ying Han <yinghan@google.com> wrote:

> On Tue, Jun 21, 2011 at 5:20 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 20 Jun 2011 23:49:54 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> >> On Wed, Jun 15, 2011 at 8:53 PM, KAMEZAWA Hiroyuki <
> >> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >>
> >> > From e08990dd9ada13cf236bec1ef44b207436434b8e Mon Sep 17 00:00:00 2001
> >> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> > Date: Wed, 15 Jun 2011 14:11:01 +0900
> >> > Subject: [PATCH 3/7] memcg: add memory.scan_stat

> >> > +
> >> > +struct scanstat {
> >> > + A  A  A  spinlock_t A  A  A lock;
> >> > + A  A  A  unsigned long A  stats[NR_SCANSTATS]; A  A /* local statistics */
> >> > + A  A  A  unsigned long A  totalstats[NR_SCANSTATS]; A  /* hierarchical */
> >> > +};
> 
> I wonder why not extending the mem_cgroup_stat_cpu struct, and then we
> can use the per-cpu counters like others.
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b7d2d79..5b8bbe9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -138,6 +138,7 @@ struct mem_cgroup_stat_cpu {
>         long count[MEM_CGROUP_STAT_NSTATS];
>         unsigned long events[MEM_CGROUP_EVENTS_NSTATS];
>         unsigned long targets[MEM_CGROUP_NTARGETS];
> +       unsigned long reclaim_stats[MEMCG_RECLAIM_NSTATS];
>  };
> 

Hmm, do we have enough benefit to consume 72 bytes per cpu and make
read-side slow for this rarely updated counter ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
