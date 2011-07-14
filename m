Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C48976B004A
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 23:06:28 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 633D13EE0B6
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 12:06:25 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4084C45DE5E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 12:06:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DD63C45DE5B
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 12:06:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CCFEB1DB8059
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 12:06:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E47C1DB8054
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 12:06:24 +0900 (JST)
Date: Thu, 14 Jul 2011 11:59:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-Id: <20110714115913.cf8d1b9d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110714100259.cedbf6af.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1310561078.git.mhocko@suse.cz>
	<50d526ee242916bbfb44b9df4474df728c4892c6.1310561078.git.mhocko@suse.cz>
	<20110714100259.cedbf6af.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu, 14 Jul 2011 10:02:59 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 13 Jul 2011 13:05:49 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > 867578cb "memcg: fix oom kill behavior" introduced oom_lock counter
> > which is incremented by mem_cgroup_oom_lock when we are about to handle
> > memcg OOM situation. mem_cgroup_handle_oom falls back to a sleep if
> > oom_lock > 1 to prevent from multiple oom kills at the same time.
> > The counter is then decremented by mem_cgroup_oom_unlock called from the
> > same function.
> > 
> > This works correctly but it can lead to serious starvations when we
> > have many processes triggering OOM.
> > 
> > Consider a process (call it A) which gets the oom_lock (the first one
> > that got to mem_cgroup_handle_oom and grabbed memcg_oom_mutex). All
> > other processes are blocked on the mutex.
> > While A releases the mutex and calls mem_cgroup_out_of_memory others
> > will wake up (one after another) and increase the counter and fall into
> > sleep (memcg_oom_waitq). Once A finishes mem_cgroup_out_of_memory it
> > takes the mutex again and decreases oom_lock and wakes other tasks (if
> > releasing memory of the killed task hasn't done it yet).
> > The main problem here is that everybody still race for the mutex and
> > there is no guarantee that we will get counter back to 0 for those
> > that got back to mem_cgroup_handle_oom. In the end the whole convoy
> > in/decreases the counter but we do not get to 1 that would enable
> > killing so nothing useful is going on.
> > The time is basically unbounded because it highly depends on scheduling
> > and ordering on mutex.
> > 
> 
> Hmm, ok, I see the problem.
> 
> 
> > This patch replaces the counter by a simple {un}lock semantic. We are
> > using only 0 and 1 to distinguish those two states.
> > As mem_cgroup_oom_{un}lock works on the hierarchy we have to make sure
> > that we cannot race with somebody else which is already guaranteed
> > because we call both functions with the mutex held. All other consumers
> > just read the value atomically for a single group which is sufficient
> > because we set the value atomically.
> > The other thing is that only that process which locked the oom will
> > unlock it once the OOM is handled.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/memcontrol.c |   24 +++++++++++++++++-------
> >  1 files changed, 17 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index e013b8e..f6c9ead 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1803,22 +1803,31 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> >  /*
> >   * Check OOM-Killer is already running under our hierarchy.
> >   * If someone is running, return false.
> > + * Has to be called with memcg_oom_mutex
> >   */
> >  static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
> >  {
> > -	int x, lock_count = 0;
> > +	int x, lock_count = -1;
> >  	struct mem_cgroup *iter;
> >  
> >  	for_each_mem_cgroup_tree(iter, mem) {
> > -		x = atomic_inc_return(&iter->oom_lock);
> > -		lock_count = max(x, lock_count);
> > +		x = !!atomic_add_unless(&iter->oom_lock, 1, 1);
> > +		if (lock_count == -1)
> > +			lock_count = x;
> > +
> 
> 
> Hmm...Assume following hierarchy.
> 
> 	  A
>        B     C
>       D E 
> 
> The orignal code hanldes the situation
> 
>  1. B-D-E is under OOM
>  2. A enters OOM after 1.
> 
> In original code, A will not invoke OOM (because B-D-E oom will kill a process.)
> The new code invokes A will invoke new OOM....right ?
> 
> I wonder this kind of code
> ==
> 	bool success = true;
> 	...
> 	for_each_mem_cgroup_tree(iter, mem) {
> 		success &= !!atomic_add_unless(&iter->oom_lock, 1, 1);
> 		/* "break" loop is not allowed because of css refcount....*/
> 	}
> 	return success.
> ==
> Then, one hierarchy can invoke one OOM kill within it.
> But this will not work because we can't do proper unlock.
> 
> 
> Hm. how about this ? This has only one lock point and we'll not see the BUG.
> Not tested yet..
> 
Here, tested patch + test program. this seems to work well.
==
