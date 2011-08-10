Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 89FE8900146
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 20:00:16 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 15CC43EE0B6
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:00:13 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ED6CE45DE5D
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:00:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C1E8E45DE54
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:00:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B65EC1DB8052
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:00:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 81D8E1DB804F
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 09:00:12 +0900 (JST)
Date: Thu, 11 Aug 2011 08:52:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 2/6]  memcg: stop vmscan when enough done.
Message-Id: <20110811085252.b29081f1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110810141425.GC15007@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809190933.d965888b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110810141425.GC15007@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Wed, 10 Aug 2011 16:14:25 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 09-08-11 19:09:33, KAMEZAWA Hiroyuki wrote:
> > memcg :avoid node fallback scan if possible.
> > 
> > Now, try_to_free_pages() scans all zonelist because the page allocator
> > should visit all zonelists...but that behavior is harmful for memcg.
> > Memcg just scans memory because it hits limit...no memory shortage
> > in pased zonelist.
> > 
> > For example, with following unbalanced nodes
> > 
> >      Node 0    Node 1
> > File 1G        0
> > Anon 200M      200M
> > 
> > memcg will cause swap-out from Node1 at every vmscan.
> > 
> > Another example, assume 1024 nodes system.
> > With 1024 node system, memcg will visit 1024 nodes
> > pages per vmscan... This is overkilling. 
> > 
> > This is why memcg's victim node selection logic doesn't work
> > as expected.
> > 
> > This patch is a help for stopping vmscan when we scanned enough.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> OK, I see the point. At first I was afraid that we would make a bigger
> pressure on the node which triggered the reclaim but as we are selecting
> t dynamically (mem_cgroup_select_victim_node) - round robin at the
> moment - it should be fair in the end. More targeted node selection
> should be even more efficient.
> 
> I still have a concern about resize_limit code path, though. It uses
> memcg direct reclaim to get under the new limit (assuming it is lower
> than the current one). 
> Currently we might reclaim nr_nodes * SWAP_CLUSTER_MAX while
> after your change we have it at SWAP_CLUSTER_MAX. This means that
> mem_cgroup_resize_mem_limit might fail sooner on large NUMA machines
> (currently it is doing 5 rounds of reclaim before it gives up). I do not
> consider this to be blocker but maybe we should enhance
> mem_cgroup_hierarchical_reclaim with a nr_pages argument to tell it how
> much we want to reclaim (min(SWAP_CLUSTER_MAX, nr_pages)).
> What do you think?
> 

Hmm,

> mem_cgroup_resize_mem_limit might fail sooner on large NUMA machines

mem_cgroup_resize_limit() just checks (curusage < prevusage), then, 
I agree reducing the number of scan/reclaim will cause that.

I agree to pass nr_pages to try_to_free_mem_cgroup_pages().


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
