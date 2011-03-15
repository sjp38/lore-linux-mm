Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DD9C38D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:58:53 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id p2FIwk2S016472
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 00:28:46 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2FIwkHo4264094
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 00:28:46 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2FIwj7S000668
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 05:58:46 +1100
Date: Wed, 16 Mar 2011 00:28:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 7/20]  7: uprobes: store/restore
 original instruction.
Message-ID: <20110315185841.GH3410@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133522.27435.45121.sendpatchset@localhost6.localdomain6>
 <20110314180914.GA18855@fibrous.localdomain>
 <20110315092247.GW24254@linux.vnet.ibm.com>
 <1300211862.2203.302.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1300211862.2203.302.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Peter Zijlstra <peterz@infradead.org> [2011-03-15 18:57:42]:

> On Tue, 2011-03-15 at 14:52 +0530, Srikar Dronamraju wrote:
> > * Stephen Wilson <wilsons@start.ca> [2011-03-14 14:09:14]:
> > 
> > > On Mon, Mar 14, 2011 at 07:05:22PM +0530, Srikar Dronamraju wrote:
> > > >  static int install_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
> > > >  {
> > > > -	int ret = 0;
> > > > +	struct task_struct *tsk;
> > > > +	int ret = -EINVAL;
> > > >  
> > > > -	/*TODO: install breakpoint */
> > > > -	if (!ret)
> > > > +	get_task_struct(mm->owner);
> > > > +	tsk = mm->owner;
> > > > +	if (!tsk)
> > > > +		return ret;
> > > 
> > > I think you need to check that tsk != NULL before calling
> > > get_task_struct()...
> > > 
> > 
> > Guess checking for tsk != NULL would only help if and only if we are doing
> > within rcu.  i.e we have to change to something like this
> > 
> > 	rcu_read_lock()
> > 	if (mm->owner) {
> > 		get_task_struct(mm->owner)
> > 		tsk = mm->owner;
> > 	}
> > 	rcu_read_unlock()
> > 	if (!tsk)
> > 		return ret;
> 
> so the whole mm->owner semantics seem vague, memcontrol.c doesn't seem
> consistent in itself, one site uses rcu_dereference() the other site
> doesn't.
> 

mm->owner should be under rcu_read_lock, unless the task is exiting
and mm_count is 1. mm->owner is updated under task_lock().

> Also, the assignments in kernel/fork.c and kernel/exit.c don't use
> rcu_assign_pointer() and therefore lack the needed write barrier.
>

Those are paths when the only context using the mm->owner is single
 
> Git blames Balbir for this.

I accept the blame and am willing to fix anything incorrect found in
the code.


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
