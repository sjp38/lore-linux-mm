Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 41B078D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 07:23:25 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LB3u83010539
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 07:03:56 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LBNGA11130548
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 07:23:16 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LBNFE1014189
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 08:23:16 -0300
Date: Thu, 21 Apr 2011 16:39:11 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 18/26] 18: uprobes: commonly used
 filters.
Message-ID: <20110421110911.GE10698@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
 <20110401143602.15455.82211.sendpatchset@localhost6.localdomain6>
 <1303221477.8345.6.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1303221477.8345.6.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-04-19 15:57:57]:

> On Fri, 2011-04-01 at 20:06 +0530, Srikar Dronamraju wrote:
> > Provides most commonly used filters that most users of uprobes can
> > reuse.  However this would be useful once we can dynamically associate a
> > filter with a uprobe-event tracer.
> > 
> > Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> > ---
> >  include/linux/uprobes.h |    5 +++++
> >  kernel/uprobes.c        |   50 +++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 55 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
> > index 26c4d78..34b989f 100644
> > --- a/include/linux/uprobes.h
> > +++ b/include/linux/uprobes.h
> > @@ -65,6 +65,11 @@ struct uprobe_consumer {
> >  	struct uprobe_consumer *next;
> >  };
> >  
> > +struct uprobe_simple_consumer {
> > +	struct uprobe_consumer consumer;
> > +	pid_t fvalue;
> > +};
> > +
> >  struct uprobe {
> >  	struct rb_node		rb_node;	/* node in the rb tree */
> >  	atomic_t		ref;
> > diff --git a/kernel/uprobes.c b/kernel/uprobes.c
> > index cdd52d0..c950f13 100644
> > --- a/kernel/uprobes.c
> > +++ b/kernel/uprobes.c
> > @@ -1389,6 +1389,56 @@ int uprobe_post_notifier(struct pt_regs *regs)
> >  	return 0;
> >  }
> >  
> > +bool uprobes_pid_filter(struct uprobe_consumer *self, struct task_struct *t)
> > +{
> > +	struct uprobe_simple_consumer *usc;
> > +
> > +	usc = container_of(self, struct uprobe_simple_consumer, consumer);
> > +	if (t->tgid == usc->fvalue)
> > +		return true;
> > +	return false;
> > +}
> > +
> > +bool uprobes_tid_filter(struct uprobe_consumer *self, struct task_struct *t)
> > +{
> > +	struct uprobe_simple_consumer *usc;
> > +
> > +	usc = container_of(self, struct uprobe_simple_consumer, consumer);
> > +	if (t->pid == usc->fvalue)
> > +		return true;
> > +	return false;
> > +}
> 
> Pretty much everything using t->pid/t->tgid is doing it wrong.
> 
> > +bool uprobes_ppid_filter(struct uprobe_consumer *self, struct task_struct *t)
> > +{
> > +	pid_t pid;
> > +	struct uprobe_simple_consumer *usc;
> > +
> > +	usc = container_of(self, struct uprobe_simple_consumer, consumer);
> > +	rcu_read_lock();
> > +	pid = task_tgid_vnr(t->real_parent);
> > +	rcu_read_unlock();
> > +
> > +	if (pid == usc->fvalue)
> > +		return true;
> > +	return false;
> > +}
> > +
> > +bool uprobes_sid_filter(struct uprobe_consumer *self, struct task_struct *t)
> > +{
> > +	pid_t pid;
> > +	struct uprobe_simple_consumer *usc;
> > +
> > +	usc = container_of(self, struct uprobe_simple_consumer, consumer);
> > +	rcu_read_lock();
> > +	pid = pid_vnr(task_session(t));
> > +	rcu_read_unlock();
> > +
> > +	if (pid == usc->fvalue)
> > +		return true;
> > +	return false;
> > +}
> 
> And there things go haywire too.
> 
> What you want is to save the pid-namespace of the task creating the
> filter in your uprobe_simple_consumer and use that to obtain the task's
> pid for matching with the provided number.
> 

Okay, will do by adding the pid-namespace of the task creating the
filter in the uprobe_simple_consumer.


-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
