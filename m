Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4CC6B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 21:50:05 -0400 (EDT)
Date: Fri, 25 Sep 2009 10:44:09 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 6/8] memcg: avoid oom during charge migration
Message-Id: <20090925104409.b85b1f27.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090924163440.758ead95.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
	<20090924144902.f4e5854c.nishimura@mxp.nes.nec.co.jp>
	<20090924163440.758ead95.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Sep 2009 16:34:40 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 24 Sep 2009 14:49:02 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This charge migration feature has double charges on both "from" and "to"
> > mem_cgroup during charge migration.
> > This means unnecessary oom can happen because of charge migration.
> > 
> > This patch tries to avoid such oom.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |   19 +++++++++++++++++++
> >  1 files changed, 19 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index fbcc195..25de11c 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -287,6 +287,8 @@ struct migrate_charge {
> >  	unsigned long precharge;
> >  };
> >  static struct migrate_charge *mc;
> > +static struct task_struct *mc_task;
> > +static DECLARE_WAIT_QUEUE_HEAD(mc_waitq);
> >  
> >  static void mem_cgroup_get(struct mem_cgroup *mem);
> >  static void mem_cgroup_put(struct mem_cgroup *mem);
> > @@ -1317,6 +1319,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  	while (1) {
> >  		int ret = 0;
> >  		unsigned long flags = 0;
> > +		DEFINE_WAIT(wait);
> >  
> >  		if (mem_cgroup_is_root(mem))
> >  			goto done;
> > @@ -1358,6 +1361,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  		if (mem_cgroup_check_under_limit(mem_over_limit))
> >  			continue;
> >  
> > +		/* try to avoid oom while someone is migrating charge */
> > +		if (mc_task && current != mc_task) {
> 
> Hmm, I like
> 
> ==
> 	if (mc && mc->to == mem)
> or
> 	if (mc) {
> 		if (mem is ancestor of mc->to)
> 			wait for a while
> ==
> 
> ?
> 
I think we cannot access safely to mc->to w/o cgroup_lock,
and we cannot hold cgroup_lock in __mem_cgroup_try_charge.

And I think we need to check "current != mc_task" anyway to prevent
the process itself which is moving a task from being stopped.
(Thas's why I defined mc_task.)

> 
> > +			prepare_to_wait(&mc_waitq, &wait, TASK_INTERRUPTIBLE);
> > +			if (mc) {
> > +				schedule();
> > +				finish_wait(&mc_waitq, &wait);
> > +				continue;
> > +			}
> > +			finish_wait(&mc_waitq, &wait);
> > +		}
> > +
> >  		if (!nr_retries--) {
> >  			if (oom) {
> >  				mutex_lock(&memcg_tasklist);
> > @@ -3345,6 +3359,8 @@ static void mem_cgroup_clear_migrate_charge(void)
> >  		__mem_cgroup_cancel_charge(mc->to);
> >  	kfree(mc);
> >  	mc = NULL;
> > +	mc_task = NULL;
> > +	wake_up_all(&mc_waitq);
> >  }
> 
> Hmm. I think this wake_up is too late.
> How about waking up when we release page_table_lock() or
> once per vma ?
> 
> Or, just skip nr_retries-- like
> 
> if (mc && mc->to_is_not_ancestor(mem) && nr_retries--) {
> }
> 
> ?
> 
I used waitq to prevent busy retries, but O.K. I'll try some.
Anyway, as I said above, we need to check "current != mc_task" and do something
to access mc->to safely.


Thanks,
Daisuke Nishimura.

> I think page-reclaim war itself is not bad.
> (Anyway, we'll have to fix cgroup_lock if the move cost is a problem.)
> 
> 
> Thanks,
> -Kame
> 
> >  
> >  static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
> > @@ -3354,6 +3370,7 @@ static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
> >  	struct mem_cgroup *from = mem_cgroup_from_task(p);
> >  
> >  	VM_BUG_ON(mc);
> > +	VM_BUG_ON(mc_task);
> >  
> >  	if (from == mem)
> >  		return 0;
> > @@ -3367,6 +3384,8 @@ static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
> >  	mc->to = mem;
> >  	mc->precharge = 0;
> >  
> > +	mc_task = current;
> > +
> >  	ret = migrate_charge_prepare();
> >  
> >  	if (ret)
> > -- 
> > 1.5.6.1
> > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
