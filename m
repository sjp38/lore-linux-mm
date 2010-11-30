Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1CA266B0085
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 19:09:14 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU09Amc019135
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Nov 2010 09:09:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 40AF545DE57
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:09:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D15745DE60
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:09:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F38EB1DB8037
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:09:09 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B50B3E08004
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:09:09 +0900 (JST)
Date: Tue, 30 Nov 2010 09:03:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Question about cgroup hierarchy and reducing memory limit
Message-Id: <20101130090333.0c8c1728.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101129140233.GA4199@balbir.in.ibm.com>
References: <AANLkTingzd3Pqrip1izfkLm+HCE9jRQL777nu9s3RnLv@mail.gmail.com>
	<20101124094736.3c4ba760.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimSRJ6GC3=bddNMfnVE3LmMx-9xSY2GX_XNvzCA@mail.gmail.com>
	<20101125100428.24920cd3.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinQ_sqpEc=-vcCQvpp98ny5HSDVvqD_R6_YE3-C@mail.gmail.com>
	<20101129155858.6af29381.kamezawa.hiroyu@jp.fujitsu.com>
	<20101129140233.GA4199@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Evgeniy Ivanov <lolkaantimat@gmail.com>, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 29 Nov 2010 19:32:33 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-11-29 15:58:58]:
> 
> > On Thu, 25 Nov 2010 13:51:06 +0300
> > Evgeniy Ivanov <lolkaantimat@gmail.com> wrote:
> > 
> > > That would be great, thanks!
> > > For now we decided either to use decreasing limits in script with
> > > timeout or controlling the limit just by root group.
> > > 
> > 
> > I wrote a patch as below but I also found that "success" of shrkinking limit 
> > means easy OOM Kill because we don't have wait-for-writeback logic.
> > 
> > Now, -EBUSY seems to be a safe guard logic against OOM KILL.
> > I'd like to wait for the merge of dirty_ratio logic and test this again.
> > I hope it helps.
> > 
> > Thanks,
> > -Kame
> > ==
> > At changing limit of memory cgroup, we see many -EBUSY when
> >  1. Cgroup is small.
> >  2. Some tasks are accessing pages very frequently.
> > 
> > It's not very covenient. This patch makes memcg to be in "shrinking" mode
> > when the limit is shrinking. This patch does,
> > 
> >  a) block new allocation.
> >  b) ignore page reference bit at shrinking.
> > 
> > The admin should know what he does...
> > 
> > Need:
> >  - dirty_ratio for avoid OOM.
> >  - Documentation update.
> > 
> > Note:
> >  - Sudden shrinking of memory limit tends to cause OOM.
> >    We need dirty_ratio patch before merging this.
> > 
> > Reported-by: Evgeniy Ivanov <lolkaantimat@gmail.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h |    6 +++++
> >  mm/memcontrol.c            |   48 +++++++++++++++++++++++++++++++++++++++++++++
> >  mm/vmscan.c                |    2 +
> >  3 files changed, 56 insertions(+)
> > 
> > Index: mmotm-1117/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-1117.orig/mm/memcontrol.c
> > +++ mmotm-1117/mm/memcontrol.c
> > @@ -239,6 +239,7 @@ struct mem_cgroup {
> >  	unsigned int	swappiness;
> >  	/* OOM-Killer disable */
> >  	int		oom_kill_disable;
> > +	atomic_t	shrinking;
> > 
> >  	/* set when res.limit == memsw.limit */
> >  	bool		memsw_is_minimum;
> > @@ -1814,6 +1815,25 @@ static int __cpuinit memcg_cpu_hotplug_c
> >  	return NOTIFY_OK;
> >  }
> > 
> > +static DECLARE_WAIT_QUEUE_HEAD(memcg_shrink_waitq);
> > +
> > +bool mem_cgroup_shrinking(struct mem_cgroup *mem)
> 
> I prefer is_mem_cgroup_shrinking
> 
Hmm, ok.

> > +{
> > +	return atomic_read(&mem->shrinking) > 0;
> > +}
> > +
> > +void mem_cgroup_shrink_wait(struct mem_cgroup *mem)
> > +{
> > +	wait_queue_t wait;
> > +
> > +	init_wait(&wait);
> > +	prepare_to_wait(&memcg_shrink_waitq, &wait, TASK_INTERRUPTIBLE);
> > +	smp_rmb();
> 
> Why the rmb?
> 
my fault.


> > +	if (mem_cgroup_shrinking(mem))
> > +		schedule();
> 
> We need to check for signals if we sleep with TASK_INTERRUPTIBLE, but
> that complicates the entire path as well. May be the question to ask
> is - why is this TASK_INTERRUPTIBLE, what is the expected delay. Could
> this be a fairness issue as well?
> 
Signal check is done in do_charge() automaticaly.


> > +	finish_wait(&memcg_shrink_waitq, &wait);
> > +}
> > +
> > 
> >  /* See __mem_cgroup_try_charge() for details */
> >  enum {
> > @@ -1832,6 +1852,17 @@ static int __mem_cgroup_do_charge(struct
> >  	unsigned long flags = 0;
> >  	int ret;
> > 
> > +	/*
> > + 	 * If shrinking() == true, admin is now reducing limit of memcg and
> > + 	 * reclaiming memory eagerly. This _new_ charge will increase usage and
> > + 	 * prevents the system from setting new limit. We add delay here and
> > + 	 * make reducing size easier.
> > + 	 */
> > +	if (unlikely(mem_cgroup_shrinking(mem)) && (gfp_mask & __GFP_WAIT)) {
> > +		mem_cgroup_shrink_wait(mem);
> > +		return CHARGE_RETRY;
> > +	}
> > +
> 
> Oh! oh! I'd hate to do this in the fault path
> 
Why ? We have per-cpu stock now and infulence of this is minimum.
We never hit this.
If problem, I'll use per-cpu value but it seems to be overkill.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
