Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A95756B01B4
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 20:41:50 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o520flFm022156
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 2 Jun 2010 09:41:47 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 02D5045DE6E
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:41:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CBB3545DE4D
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:41:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B3F821DB803B
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:41:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A70C1DB8037
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:41:46 +0900 (JST)
Date: Wed, 2 Jun 2010 09:37:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][2/3] memcg safe operaton for checking a cgroup is under
 move accounts
Message-Id: <20100602093732.1026eaf3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100601112529.GE2804@balbir.in.ibm.com>
References: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
	<20100601182720.f1562de6.kamezawa.hiroyu@jp.fujitsu.com>
	<20100601112529.GE2804@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010 16:55:29 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-01 18:27:20]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, for checking a memcg is under task-account-moving, we do css_tryget()
> > against mc.to and mc.from. But this ust complicates things. This patch
> > makes the check easier. (And I doubt the current code has some races..)
> > 
> > This patch adds a spinlock to move_charge_struct and guard modification
> > of mc.to and mc.from. By this, we don't have to think about complicated
> > races around this not-critical path.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   48 ++++++++++++++++++++++++++++--------------------
> >  1 file changed, 28 insertions(+), 20 deletions(-)
> > 
> > Index: mmotm-2.6.34-May21/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.34-May21.orig/mm/memcontrol.c
> > +++ mmotm-2.6.34-May21/mm/memcontrol.c
> > @@ -268,6 +268,7 @@ enum move_type {
> > 
> >  /* "mc" and its members are protected by cgroup_mutex */
> >  static struct move_charge_struct {
> > +	spinlock_t	  lock; /* for from, to, moving_task */
> >  	struct mem_cgroup *from;
> >  	struct mem_cgroup *to;
> >  	unsigned long precharge;
> > @@ -276,6 +277,7 @@ static struct move_charge_struct {
> >  	struct task_struct *moving_task;	/* a task moving charges */
> >  	wait_queue_head_t waitq;		/* a waitq for other context */
> >  } mc = {
> > +	.lock = __SPIN_LOCK_UNLOCKED(mc.lock),
> >  	.waitq = __WAIT_QUEUE_HEAD_INITIALIZER(mc.waitq),
> >  };
> > 
> > @@ -1076,26 +1078,25 @@ static unsigned int get_swappiness(struc
> > 
> >  static bool mem_cgroup_under_move(struct mem_cgroup *mem)
> >  {
> > -	struct mem_cgroup *from = mc.from;
> > -	struct mem_cgroup *to = mc.to;
> > +	struct mem_cgroup *from;
> > +	struct mem_cgroup *to;
> >  	bool ret = false;
> > -
> > -	if (from == mem || to == mem)
> > -		return true;
> > -
> > -	if (!from || !to || !mem->use_hierarchy)
> > -		return false;
> > -
> > -	rcu_read_lock();
> > -	if (css_tryget(&from->css)) {
> > -		ret = css_is_ancestor(&from->css, &mem->css);
> > -		css_put(&from->css);
> > -	}
> > -	if (!ret && css_tryget(&to->css)) {
> > -		ret = css_is_ancestor(&to->css,	&mem->css);
> > +	/*
> > +	 * Unlike task_move routines, we access mc.to, mc.from not under
> > +	 * mutual execution by cgroup_mutex. Here, we take spinlock instead.
>                  ^^^^^
>         Typo should be exclusion
Sure.

> 
> > +	 */
> > +	spin_lock_irq(&mc.lock);
> 
> Why do we use the _irq variant here?
> 

Hmm. I'd like to add preemption_disable() or disable irq here. This spinlock
is held as

	cgroup_mutex();
	  -> mc.lock
Then, I don't want to have a risk for preemption. But yes, logically, disabling irq
isn't necessary. I'll remove _irq() in the next.

Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
