Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 755738D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 03:21:12 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6C3353EE0C0
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 16:21:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 510ED45DE4E
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 16:21:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D51145DE61
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 16:21:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BE1F1DB802C
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 16:21:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DBC271DB8038
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 16:21:07 +0900 (JST)
Date: Thu, 21 Apr 2011 16:14:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] memcg kswapd thread pool (Was Re: [PATCH V6 00/10]
 memcg: per cgroup background reclaim
Message-Id: <20110421161427.21b3ed80.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTin+Hghwx6L-jy_3n7ySPunECEiA3g@mail.gmail.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124357.c94a03a5.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin+Hghwx6L-jy_3n7ySPunECEiA3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 00:09:13 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Apr 20, 2011 at 8:43 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Ying, please take this just a hint, you don't need to implement this as is.
> >
> 
> Thank you for the patch.
> 
> 
> > ==
> > Now, memcg-kswapd is created per a cgroup. Considering there are users
> > who creates hundreds on cgroup on a system, it consumes too much
> > resources, memory, cputime.
> >
> > This patch creates a thread pool for memcg-kswapd. All memcg which
> > needs background recalim are linked to a list and memcg-kswapd
> > picks up a memcg from the list and run reclaim. This reclaimes
> > SWAP_CLUSTER_MAX of pages and putback the memcg to the lail of
> > list. memcg-kswapd will visit memcgs in round-robin manner and
> > reduce usages.
> >
> > This patch does
> >
> >  - adds memcg-kswapd thread pool, the number of threads is now
> >   sqrt(num_of_cpus) + 1.
> >  - use unified kswapd_waitq for all memcgs.
> >
> 
> So I looked through the patch, it implements an alternative threading model
> using thread-pool. Also it includes some changes on calculating how much
> pages to reclaim per memcg. Other than that, all the existing implementation
> of per-memcg-kswapd seems not being impacted.
> 
> I tried to apply the patch but get some conflicts on vmscan.c/ I will try
> some manual work tomorrow. Meantime, after applying the patch, I will try to
> test it w/ the same test suite i used on original patch. AFAIK, the only
> difference of the two threading model is the amount of resources we consume
> on the kswapd kernel thread, which shouldn't have run-time performance
> differences.
> 

I hope so. 
To be honest, I don't like one-thread-per-one-job model because it's wastes
resouce and cache foot print and what we can do is just hoping schedulre
schedules tasks well. I like one-thread-per-mulutiple job and switching in
finer grain with knowledge of memory cgroup.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
