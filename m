Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 96F188D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 01:07:09 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C2D703EE0C2
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:07:05 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 969E045DE5E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:07:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 750BF45DE55
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:07:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 62DB01DB8042
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:07:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D6681DB803F
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:07:05 +0900 (JST)
Date: Fri, 22 Apr 2011 14:00:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V7 4/9] Add memcg kswapd thread pool
Message-Id: <20110422140023.949e5737.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTinkJC2-HiGtxgTTo8RvRjZqYuq2pA@mail.gmail.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-5-git-send-email-yinghan@google.com>
	<20110422133643.6a36d838.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinkJC2-HiGtxgTTo8RvRjZqYuq2pA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 21:49:04 -0700
Ying Han <yinghan@google.com> wrote:

> On Thu, Apr 21, 2011 at 9:36 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 21 Apr 2011 21:24:15 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> > > This patch creates a thread pool for memcg-kswapd. All memcg which needs
> > > background recalim are linked to a list and memcg-kswapd picks up a memcg
> > > from the list and run reclaim.
> > >
> > > The concern of using per-memcg-kswapd thread is the system overhead
> > including
> > > memory and cputime.
> > >
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Signed-off-by: Ying Han <yinghan@google.com>
> >
> > Thank you for merging. This seems ok to me.
> >
> > Further development may make this better or change thread pools (to some
> > other),
> > but I think this is enough good.
> >
> 
> Thank you for reviewing and Acking. At the same time, I do have wondering on
> the thread-pool modeling which I posted on the cover-letter :)
> 
> The per-memcg-per-kswapd model
> Pros:
> 1. memory overhead per thread, and The memory consumption would be 8k*1000 =
> 8M
> with 1k cgroup.
> 2. we see lots of threads at 'ps -elf'
> 
> Cons:
> 1. the implementation is simply and straigh-forward.
> 2. we can easily isolate the background reclaim overhead between cgroups.
> 3. better latency from memory pressure to actual start reclaiming
> 
> The thread-pool model
> Pros:
> 1. there is no isolation between memcg background reclaim, since the memcg
> threads
> are shared.
> 2. it is hard for visibility and debugability. I have been experienced a lot
> when
> some kswapds running creazy and we need a stright-forward way to identify
> which
> cgroup causing the reclaim.
> 3. potential starvation for some memcgs, if one workitem stucks and the rest
> of work
> won't proceed.
> 
> Cons:
> 1. save some memory resource.
> 
> In general, the per-memcg-per-kswapd implmentation looks sane to me at this
> point, esepcially the sharing memcg thread model will make debugging issue
> very hard later.
> 
> Comments?
> 
Pros <-> Cons ?

My idea is adding trace point for memcg-kswapd and seeing what it's now doing.
(We don't have too small trace point in memcg...)

I don't think its sane to create kthread per memcg because we know there is a user
who makes hundreds/thousands of memcg.

And, I think that creating threads, which does the same job, more than the number
of cpus will cause much more difficult starvation, priority inversion issue.
Keeping scheduling knob/chances of jobs in memcg is important. I don't want to
give a hint to scheduler because of memcg internal issue.

And, even if memcg-kswapd doesn't exist, memcg works (well?). 
memcg-kswapd just helps making things better but not do any critical jobs.
So, it's okay to have this as best-effort service.
Of course, better scheduling idea for picking up memcg is welcomed. It's now
round-robin.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
