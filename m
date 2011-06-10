Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFF26B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 04:46:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AD4403EE0BD
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:46:52 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 826E445DED6
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:46:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5116545DECE
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:46:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A9DF1DB8043
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:46:52 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E13221DB8037
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:46:51 +0900 (JST)
Date: Fri, 10 Jun 2011 17:39:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH v3] memcg: fix behavior of per cpu charge cache
 draining.
Message-Id: <20110610173958.d9ab901c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110610081218.GC4832@tiehlicka.suse.cz>
References: <20110609093045.1f969d30.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610081218.GC4832@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>

On Fri, 10 Jun 2011 10:12:19 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 09-06-11 09:30:45, KAMEZAWA Hiroyuki wrote:
> > From 0ebd8a90a91d50c512e7c63e5529a22e44e84c42 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Wed, 8 Jun 2011 13:51:11 +0900
> > Subject: [PATCH] Fix behavior of per-cpu charge cache draining in memcg.
> > 
> > For performance, memory cgroup caches some "charge" from res_counter
> > into per cpu cache. This works well but because it's cache,
> > it needs to be flushed in some cases. Typical cases are
> > 	1. when someone hit limit.
> > 	2. when rmdir() is called and need to charges to be 0.
> > 
> > But "1" has problem.
> > 
> > Recently, with large SMP machines, we many kworker runs because
> > of flushing memcg's cache. Bad things in implementation are
> > 
> > a) it's called before calling try_to_free_mem_cgroup_pages()
> >    so, it's called immidiately when a task hit limit.
> >    (I though it was better to avoid to run into memory reclaim.
> >     But it was wrong decision.)
> > 
> > b) Even if a cpu contains a cache for memcg not related to
> >    a memcg which hits limit, drain code is called.
> > 
> > This patch fixes a) and b) by
> > 
> > A) delay calling of flushing until one run of try_to_free...
> >    Then, the number of calling is decreased.
> > B) check percpu cache contains a useful data or not.
> > plus
> > C) check asynchronous percpu draining doesn't run.
> > 
> > BTW, why this patch relpaces atomic_t counter with mutex is
> > to guarantee a memcg which is pointed by stock->cacne is
> > not destroyed while we check css_id.
> > 
> > Reported-by: Ying Han <yinghan@google.com>
> > Reviewed-by: Michal Hocko <mhocko@suse.cz>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Changelog:
> >  - fixed typo.
> >  - fixed rcu_read_lock() and add strict mutal execution between
> >    asynchronous and synchronous flushing. It's requred for validness
> >    of cached pointer.
> >  - add root_mem->use_hierarchy check.
> > ---
> >  mm/memcontrol.c |   54 +++++++++++++++++++++++++++++++++++-------------------
> >  1 files changed, 35 insertions(+), 19 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index bd9052a..3baddcb 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> [...]
> >  static struct mem_cgroup_per_zone *
> >  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> > @@ -1670,8 +1670,6 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  		victim = mem_cgroup_select_victim(root_mem);
> >  		if (victim == root_mem) {
> >  			loop++;
> > -			if (loop >= 1)
> > -				drain_all_stock_async();
> >  			if (loop >= 2) {
> >  				/*
> >  				 * If we have not been able to reclaim
> > @@ -1723,6 +1721,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  				return total;
> >  		} else if (mem_cgroup_margin(root_mem))
> >  			return total;
> > +		drain_all_stock_async(root_mem);
> >  	}
> >  	return total;
> >  }
> 
> I still think that we pointlessly reclaim even though we could have a
> lot of pages pre-charged in the cache (the more CPUs we have the more
> significant this might be).

The more CPUs, the more scan cost for each per-cpu memory, which makes
cache-miss.

I know placement of drain_all_stock_async() is not big problem on my host,
which has 2socket/8core cpus. But, assuming 1000+ cpu host, 
"when you hit limit, you'll see 1000*128bytes cache miss and need to call test_and_set for 1000+ cpus in bad case." doesn't seem much win.

If we implement "call-drain-only-nearby-cpus", I think we can call it before
calling try_to_free_mem_cgroup_pages(). I'll add it to my TO-DO-LIST.

How do you think ?

Thanks,
-Kame












--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
