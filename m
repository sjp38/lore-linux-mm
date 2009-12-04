Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 479EF6007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 02:49:21 -0500 (EST)
Date: Fri, 4 Dec 2009 16:43:55 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 5/7] memcg: avoid oom during moving charge
Message-Id: <20091204164355.517f0cc3.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091204161439.2e584630.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
	<20091204145154.4d184f1d.nishimura@mxp.nes.nec.co.jp>
	<20091204161439.2e584630.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009 16:14:39 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 4 Dec 2009 14:51:54 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This move-charge-at-task-migration feature has extra charges on "to"(pre-charges)
> > and "from"(leftover charges) during moving charge. This means unnecessary oom
> > can happen.
> > 
> > This patch tries to avoid such oom.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > Changelog: 2009/12/04
> > - take account of "from" too, because we uncharge from "from" at once in
> >   mem_cgroup_clear_mc(), so leftover charges exist during moving charge.
> > - check use_hierarchy of "mem_over_limit", instead of "to" or "from"(bugfix).
> > ---
> >  mm/memcontrol.c |   38 ++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 38 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 769b85a..f50ad15 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -253,6 +253,7 @@ struct move_charge_struct {
> >  	struct mem_cgroup *to;
> >  	unsigned long precharge;
> >  	unsigned long moved_charge;
> > +	struct task_struct *moving_task;	/* a task moving charges */
> >  };
> >  static struct move_charge_struct mc;
> >  
> > @@ -1504,6 +1505,40 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  		if (mem_cgroup_check_under_limit(mem_over_limit))
> >  			continue;
> >  
> > +		/* try to avoid oom while someone is moving charge */
> > +		if (mc.moving_task && current != mc.moving_task) {
> > +			struct mem_cgroup *from, *to;
> > +			bool do_continue = false;
> > +			/*
> > +			 * There is a small race that "from" or "to" can be
> > +			 * freed by rmdir, so we use css_tryget().
> > +			 */
> > +			rcu_read_lock();
> > +			from = mc.from;
> > +			to = mc.to;
> > +			if (from && css_tryget(&from->css)) {
> > +				if (mem_over_limit->use_hierarchy)
> > +					do_continue = css_is_ancestor(
> > +							&from->css,
> > +							&mem_over_limit->css);
> > +				else
> > +					do_continue = (from == mem_over_limit);
> > +				css_put(&from->css);
> > +			}
> > +			if (!do_continue && to && css_tryget(&to->css)) {
> > +				if (mem_over_limit->use_hierarchy)
> > +					do_continue = css_is_ancestor(
> > +							&to->css,
> > +							&mem_over_limit->css);
> > +				else
> > +					do_continue = (to == mem_over_limit);
> > +				css_put(&to->css);
> > +			}
> > +			rcu_read_unlock();
> > +			if (do_continue)
> > +				continue;
> 
> Hmm. do countine without any relaxing ? can't this occupy cpu ?
> Can't we add schedule() or some and put into sleep ?
> 
> Maybe the best way is enqueue this thread to mc.wait_queue and wait for
> the end of task moving.
> 
Good idea. I'll try it.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
