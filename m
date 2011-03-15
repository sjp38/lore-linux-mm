Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E47B78D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 05:29:01 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2F9FsF6007140
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 03:15:54 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p2F9SlTR109922
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 03:28:49 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2F9SjgT027888
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 03:28:47 -0600
Date: Tue, 15 Mar 2011 14:52:47 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 7/20]  7: uprobes: store/restore
 original instruction.
Message-ID: <20110315092247.GW24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133522.27435.45121.sendpatchset@localhost6.localdomain6>
 <20110314180914.GA18855@fibrous.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110314180914.GA18855@fibrous.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Stephen Wilson <wilsons@start.ca> [2011-03-14 14:09:14]:

> On Mon, Mar 14, 2011 at 07:05:22PM +0530, Srikar Dronamraju wrote:
> >  static int install_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
> >  {
> > -	int ret = 0;
> > +	struct task_struct *tsk;
> > +	int ret = -EINVAL;
> >  
> > -	/*TODO: install breakpoint */
> > -	if (!ret)
> > +	get_task_struct(mm->owner);
> > +	tsk = mm->owner;
> > +	if (!tsk)
> > +		return ret;
> 
> I think you need to check that tsk != NULL before calling
> get_task_struct()...
> 

Guess checking for tsk != NULL would only help if and only if we are doing
within rcu.  i.e we have to change to something like this

	rcu_read_lock()
	if (mm->owner) {
		get_task_struct(mm->owner)
		tsk = mm->owner;
	}
	rcu_read_unlock()
	if (!tsk)
		return ret;

Agree?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
