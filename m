Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA369000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 03:37:20 -0400 (EDT)
Date: Wed, 27 Apr 2011 09:36:18 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
Message-ID: <20110427073618.GC6152@cmpxchg.org>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
 <20110421025107.GG2333@cmpxchg.org>
 <20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
 <20110421050851.GI2333@cmpxchg.org>
 <BANLkTimUQjW_XVdzoLJJwwFDuFvm=Qg_FA@mail.gmail.com>
 <20110423013534.GK2333@cmpxchg.org>
 <BANLkTi=UgLihmoRwdA4E4MXmGc4BmqkqTg@mail.gmail.com>
 <20110423023407.GN2333@cmpxchg.org>
 <BANLkTimwMcBwTvi8aNDPXkS_Vu+bxdciMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimwMcBwTvi8aNDPXkS_Vu+bxdciMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri, Apr 22, 2011 at 08:33:58PM -0700, Ying Han wrote:
> On Fri, Apr 22, 2011 at 7:34 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Fri, Apr 22, 2011 at 07:10:25PM -0700, Ying Han wrote: >
> > However, i still think there is a need from the admin to have some
> > controls > of which memcg to do background reclaim proactively
> > (before global memory > pressure) and that was the initial logic
> > behind the API.
> >
> > That sounds more interesting.  Do you have a specific use case
> > that requires this?
> 
> There might be more interesting use cases there, and here is one I
> can think of:
> 
> let's say we three jobs A, B and C, and one host with 32G of RAM. We
> configure each job's hard_limit as their peak memory usage.
> A: 16G
> B: 16G
> C: 10G
> 
> 1. we start running A with hard_limit 15G, and start running B with
> hard_limit 15G.
> 2. we set A and B's soft_limit based on their "hot" memory. Let's say
> setting A's soft_limit 10G and B's soft_limit 10G.
> (The soft_limit will be changing based on their runtime memory usage)
> 
> If no more jobs running on the system, A and B will easily fill up the whole
> system with pagecache pages. Since we are not over-committing the machine
> with their hard_limit, there will be no pressure to push their memory usage
> down to soft_limit.
> 
> Now we would like to launch another job C, since we know there are A(16G -
> 10G) + B(16G - 10G)  = 12G "cold" memory can be reclaimed (w/o impacting the
> A and B's performance). So what will happen
> 
> 1. start running C on the host, which triggers global memory pressure right
> away. If the reclaim is fast, C start growing with the free pages from A and
> B.
> 
> However, it might be possible that the reclaim can not catch-up with the
> job's page allocation. We end up with either OOM condition or performance
> spike on any of the running jobs.

If background reclaim can not catch up, C will go into direct reclaim,
which will have exactly the same effect, only that C will have to do
the work itself.

> One way to improve it is to set a wmark on either A/B to be proactively
> reclaiming pages before launching C. The global memory pressure won't help
> much here since we won't trigger that.

Ok, so you want to use the watermarks to push back and limit the usage
of A and B to make room for C.  Isn't this exactly what the hard limit
is for?

I don't understand the second sentence: global memory pressure won't
kick in with only A and B, but it will once C starts up.

> > min_free_kbytes more or less indirectly provides the same on a global
> > level, but I don't think anybody tunes it just for aggressiveness of
> > background reclaim.
> >
> 
> Hmm, we do scale that in google workload. With large machines under lots of
> memory pressure and heavily network traffic workload, we would like to
> reduce the likelyhood of page alloc failure. But this is kind of different
> from what we are talking about here.

My point indeed ;-)

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
