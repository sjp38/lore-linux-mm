Date: Tue, 10 Jun 2008 17:26:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Message-Id: <20080610172637.39ffff5c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080610163550.65c97f6a.nishimura@mxp.nes.nec.co.jp>
References: <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	<20080610163550.65c97f6a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008 16:35:50 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi, Kamezawa-san.
> 
> Sorry for late reply.
> 
> On Fri, 6 Jun 2008 10:52:35 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Move Usage at Task Move (just an experimantal for discussion)
> > I tested this but don't think bug-free.
> > 
> > In current memcg, when task moves to a new cg, the usage remains in the old cg.
> > This is considered to be not good.
> > 
> I agree.
> 
> > This is a trial to move "usage" from old cg to new cg at task move.
> > Finally, you'll see the problems we have to handle are failure and rollback.
> > 
> > This one's Basic algorithm is
> > 
> >      0. can_attach() is called.
> >      1. count movable pages by scanning page table. isolate all pages from LRU.
> >      2. try to create enough room in new memory cgroup
> >      3. start moving page accouing
> >      4. putback pages to LRU.
> >      5. can_attach() for other cgroups are called.
> > 
> You isolate pages and move charges of them by can_attach(),
> but it means that pages that are allocated between page isolation
> and moving tsk->cgroups remains charged to old group, right?
yes.

> 
> I think it would be better if possible to move charges by attach()
> as cpuset migrates pages by cpuset_attach().
> But one of the problem of it is that attch() does not return
> any value, so there is no way to notify failure...
> 
yes, here again. it makes roll-back more difficult.

> > A case study.
> > 
> >   group_A -> limit=1G, task_X's usage= 800M.
> >   group_B -> limit=1G, usage=500M.
> > 
> > For moving task_X from group_A to group_B.
> >   - group_B  should be reclaimed or have enough room.
> > 
> > While moving task_X from group_A to group_B.
> >   - group_B's memory usage can be changed
> >   - group_A's memory usage can be changed
> > 
> >   We accounts the resouce based on pages. Then, we can't move all resource
> >   usage at once.
> > 
> >   If group_B has no more room when we've moved 700M of task_X to group_B,
> >   we have to move 700M of task_X back to group_A. So I implemented roll-back.
> >   But other process may use up group_A's available resource at that point.
> >   
> >   For avoiding that, preserve 800M in group_B before moving task_X means that
> >   task_X can occupy 1600M of resource at moving. (So I don't do in this patch.)
> > 
> >   This patch uses Best-Effort rollback. Failure in rollback is ignored and
> >   the usage is just leaked.
> > 
> If implement rollback in kernel, I think it must not fail to prevent
> leak of usage.
> How about using "charge_force" for rollbak?
> 
means allowing to exceed limit ?

> Or, instead of implementing rollback in kernel,
> how about making user(or middle ware?) re-echo pid to rollbak
> on failure?
> 

"If the users does well, the system works in better way" is O.K.
"If the users doesn't well, the system works in broken way" is very bad.

This is an issue that the kernel should handle by itself.
So this is annoying me.
But we can choice our policy of this task_move. The problem depends
on the policy we establish. So, there will be a good way.
What is "broken" depends on the definition. But usage > limit case
is tend to be considered to be broken.


> > Roll-back can happen when
> >     (a) in phase 3. cannot move a page to new cgroup because of limit.
> >     (b) in phase 5. other cgourp subsys returns error in can_attach().
> > 
> Isn't rollbak needed on failure between can_attach and attach(e.g. failure
> on find_css_set, ...)?
> 
Yes, my mistake.

But...maybe failure after can_attach() is not good...(for me.)
Paul, how do you think ? 
ss->attach() should return a value and fail ? 



> > +int mem_cgroup_recharge_task(struct mem_cgroup *newcg,
> > +				struct task_struct *task)
> > +{
> (snip)
> > +	/* create enough room before move */
> > +	necessary = info.count * PAGE_SIZE;
> > +
> > +	do {
> > +		spin_lock(&newcg->res.lock);
> > +		if (newcg->res.limit > necessary)
> > +			rc = -ENOMEM;
> I think it should be (newcg->res.limit < necessary).
> 
Ah, you're right. should be fixed.

Anyway I'll rewrite the whole considering opions from others.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
