Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF926B00E8
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 06:06:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 925AA3EE0BC
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 19:06:52 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A8A345DECE
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 19:06:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 562A345DED0
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 19:06:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 49EC71DB803E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 19:06:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F0D7F1DB803B
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 19:06:51 +0900 (JST)
Date: Fri, 10 Jun 2011 18:59:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH v3] memcg: fix behavior of per cpu charge cache
 draining.
Message-Id: <20110610185952.a07b968f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110610090802.GB4110@tiehlicka.suse.cz>
References: <20110609093045.1f969d30.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610081218.GC4832@tiehlicka.suse.cz>
	<20110610173958.d9ab901c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610090802.GB4110@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>

On Fri, 10 Jun 2011 11:08:02 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Fri 10-06-11 17:39:58, KAMEZAWA Hiroyuki wrote:
> > On Fri, 10 Jun 2011 10:12:19 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Thu 09-06-11 09:30:45, KAMEZAWA Hiroyuki wrote:
> [...]
> > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > index bd9052a..3baddcb 100644
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > [...]
> > > >  static struct mem_cgroup_per_zone *
> > > >  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> > > > @@ -1670,8 +1670,6 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > > >  		victim = mem_cgroup_select_victim(root_mem);
> > > >  		if (victim == root_mem) {
> > > >  			loop++;
> > > > -			if (loop >= 1)
> > > > -				drain_all_stock_async();
> > > >  			if (loop >= 2) {
> > > >  				/*
> > > >  				 * If we have not been able to reclaim
> > > > @@ -1723,6 +1721,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > > >  				return total;
> > > >  		} else if (mem_cgroup_margin(root_mem))
> > > >  			return total;
> > > > +		drain_all_stock_async(root_mem);
> > > >  	}
> > > >  	return total;
> > > >  }
> > > 
> > > I still think that we pointlessly reclaim even though we could have a
> > > lot of pages pre-charged in the cache (the more CPUs we have the more
> > > significant this might be).
> > 
> > The more CPUs, the more scan cost for each per-cpu memory, which makes
> > cache-miss.
> > 
> > I know placement of drain_all_stock_async() is not big problem on my host,
> > which has 2socket/8core cpus. But, assuming 1000+ cpu host, 
> 
> Hmm, it really depends what you want to optimize for. Reclaim path is
> already slow path and cache misses, while not good, are not the most
> significant issue, I guess.
> What I would see as a much bigger problem is that there might be a lot
> of memory pre-charged at those per-cpu caches. Falling into a reclaim
> costs us much more IMO and we can evict something that could be useful
> for no good reason.
> 

It's waste of time to talk this kind of things without the numbers.

ok, I don't change the caller's logic. Discuss this when someone gets
number of LARGE smp box. Updated one is attached. Tested on my host
without problem and it seems kworker run is much reduced on my test
with "cat"

When I run "cat 1Gfile > /dev/null" under 300M limit memcg,

[Before]
13767 kamezawa  20   0 98.6m  424  416 D 10.0  0.0   0:00.61 cat
   58 root      20   0     0    0    0 S  0.6  0.0   0:00.09 kworker/2:1
   60 root      20   0     0    0    0 S  0.6  0.0   0:00.08 kworker/4:1
    4 root      20   0     0    0    0 S  0.3  0.0   0:00.02 kworker/0:0
   57 root      20   0     0    0    0 S  0.3  0.0   0:00.05 kworker/1:1
   61 root      20   0     0    0    0 S  0.3  0.0   0:00.05 kworker/5:1
   62 root      20   0     0    0    0 S  0.3  0.0   0:00.05 kworker/6:1
   63 root      20   0     0    0    0 S  0.3  0.0   0:00.05 kworker/7:1

[After]
 2676 root      20   0 98.6m  416  416 D  9.3  0.0   0:00.87 cat
 2626 kamezawa  20   0 15192 1312  920 R  0.3  0.0   0:00.28 top
    1 root      20   0 19384 1496 1204 S  0.0  0.0   0:00.66 init
    2 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kthreadd
    3 root      20   0     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd/0
    4 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kworker/0:0



> > "when you hit limit, you'll see 1000*128bytes cache miss and need to
> > call test_and_set for 1000+ cpus in bad case." doesn't seem much win.
> > 
> > If we implement "call-drain-only-nearby-cpus", I think we can call it before
> > calling try_to_free_mem_cgroup_pages(). I'll add it to my TO-DO-LIST.
> 
> It would just consider cpus at the same node?
> 
just on the same socket. anyway, keep-margin-in-background will be final
help for large SMP.


please test/ack if ok.
==
