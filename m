Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E2D9B6B007E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 05:51:56 -0400 (EDT)
Date: Thu, 14 Jul 2011 11:51:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-ID: <20110714095152.GG19408@tiehlicka.suse.cz>
References: <cover.1310561078.git.mhocko@suse.cz>
 <50d526ee242916bbfb44b9df4474df728c4892c6.1310561078.git.mhocko@suse.cz>
 <20110714100259.cedbf6af.kamezawa.hiroyu@jp.fujitsu.com>
 <20110714115913.cf8d1b9d.kamezawa.hiroyu@jp.fujitsu.com>
 <20110714090017.GD19408@tiehlicka.suse.cz>
 <20110714183014.8b15e9b9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110714183014.8b15e9b9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu 14-07-11 18:30:14, KAMEZAWA Hiroyuki wrote:
> On Thu, 14 Jul 2011 11:00:17 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Thu 14-07-11 11:59:13, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 14 Jul 2011 10:02:59 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > On Wed, 13 Jul 2011 13:05:49 +0200
> > > > Michal Hocko <mhocko@suse.cz> wrote:
> > [...]
> > > > > This patch replaces the counter by a simple {un}lock semantic. We are
> > > > > using only 0 and 1 to distinguish those two states.
> > > > > As mem_cgroup_oom_{un}lock works on the hierarchy we have to make sure
> > > > > that we cannot race with somebody else which is already guaranteed
> > > > > because we call both functions with the mutex held. All other consumers
> > > > > just read the value atomically for a single group which is sufficient
> > > > > because we set the value atomically.
> > > > > The other thing is that only that process which locked the oom will
> > > > > unlock it once the OOM is handled.
> > > > > 
> > > > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > > > > ---
> > > > >  mm/memcontrol.c |   24 +++++++++++++++++-------
> > > > >  1 files changed, 17 insertions(+), 7 deletions(-)
> > > > > 
> > > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > > index e013b8e..f6c9ead 100644
> > > > > --- a/mm/memcontrol.c
> > > > > +++ b/mm/memcontrol.c
> > > > > @@ -1803,22 +1803,31 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > > > >  /*
> > > > >   * Check OOM-Killer is already running under our hierarchy.
> > > > >   * If someone is running, return false.
> > > > > + * Has to be called with memcg_oom_mutex
> > > > >   */
> > > > >  static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
> > > > >  {
> > > > > -	int x, lock_count = 0;
> > > > > +	int x, lock_count = -1;
> > > > >  	struct mem_cgroup *iter;
> > > > >  
> > > > >  	for_each_mem_cgroup_tree(iter, mem) {
> > > > > -		x = atomic_inc_return(&iter->oom_lock);
> > > > > -		lock_count = max(x, lock_count);
> > > > > +		x = !!atomic_add_unless(&iter->oom_lock, 1, 1);
> > > > > +		if (lock_count == -1)
> > > > > +			lock_count = x;
> > > > > +
> > > > 
> > > > 
> > > > Hmm...Assume following hierarchy.
> > > > 
> > > > 	  A
> > > >        B     C
> > > >       D E 
> > 
> > IIUC, A, B, D, E are one hierarchy, right?
> > 
> yes.
> 
> 
> > > > 
> > > > The orignal code hanldes the situation
> > > > 
> > > >  1. B-D-E is under OOM
> > > >  2. A enters OOM after 1.
> > > > 
> > > > In original code, A will not invoke OOM (because B-D-E oom will kill a process.)
> > > > The new code invokes A will invoke new OOM....right ?
> > 
> > Sorry, I do not understand what you mean by that. 
> 
> This is your code.
> ==
>  	for_each_mem_cgroup_tree(iter, mem) {
> -		x = atomic_inc_return(&iter->oom_lock);
> -		lock_count = max(x, lock_count);
> +		x = !!atomic_add_unless(&iter->oom_lock, 1, 1);
> +		if (lock_count == -1)
> +			lock_count = x;
> +
> +		/* New child can be created but we shouldn't race with
> +		 * somebody else trying to oom because we are under
> +		 * memcg_oom_mutex
> +		 */
> +		BUG_ON(lock_count != x);
>  	}
> ==
> 
> When, B,D,E is under OOM,  
> 
>    A oom_lock = 0
>    B oom_lock = 1
>    C oom_lock = 0
>    D oom_lock = 1
>    E oom_lock = 1
> 
> Here, assume A enters OOM.
> 
>    A oom_lock = 1 -- (*)
>    B oom_lock = 1
>    C oom_lock = 1
>    D oom_lock = 1
>    E oom_lock = 1
> 
> because of (*), mem_cgroup_oom_lock() will return lock_count=1, true.
> 
> Then, a new oom-killer will another oom-kiiler running in B-D-E.

OK, does this mean that for_each_mem_cgroup_tree doesn't lock the whole
hierarchy at once? 
I have to confess that the behavior of mem_cgroup_start_loop is little
bit obscure to me. The comment says it searches for the cgroup with the
minimum ID - I assume this is the root of the hierarchy. Is this
correct?

If yes then if we have oom in what-ever cgroup in the hierarchy then
the above code should lock the whole hierarchy and the above never
happens. Right?

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
