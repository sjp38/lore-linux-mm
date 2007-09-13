Date: Thu, 13 Sep 2007 16:03:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: add verbose_oom sysctl to dump tasklist
In-Reply-To: <20070913152359.85949e0e.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.0.9999.0709131556470.11367@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709070115130.19525@chino.kir.corp.google.com> <20070913152359.85949e0e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007, Andrew Morton wrote:

> > Adds 'verbose_oom' sysctl to dump the tasklist and pertinent memory usage
> > information on an OOM killing.  Information included is pid, uid, tgid,
> > VM size, RSS, last cpu, oom_adj score, and name.
> 
> Would be useful to have some description of why this is needed, how we will
> use it to fix stuff, etc.  IOW: what value does it bring??
> 

I don't think we would use it to fix anything, I think the end user would 
use it to figure out why his or her system was OOM.

Obviously this is also possible to do from userspace, but with more 
trouble in collecting all the information presented here.

> And if it _is_ valuable, how come it's tunable offable?  I guess the
> tasklist dump will be pretty huge..
> 

As a courtesy to SGI and friends who already have enough trouble scanning 
the tasklist because of their super huge machines.

> We should be dumping more stuff at oom-time.  I thought we were dumping the
> sysrq-m-style output but that patch which did that got lost years ago.
> 

I've wondered about a notifier hook to userspace so if the user had 
specified an OOM handling script to be executed before the actual killer 
was invoked, you could collect this information on your own or anything 
else you found pertinent.

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -27,6 +27,7 @@
> >  #include <linux/notifier.h>
> >  
> >  int sysctl_panic_on_oom;
> > +int sysctl_verbose_oom;
> >  /* #define DEBUG */
> >  
> >  unsigned long VM_is_OOM;
> > @@ -146,6 +147,29 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
> >  	return points;
> >  }
> >  
> > +static inline void dump_tasks(void)
> > +{
> > +	struct task_struct *g, *p;
> > +
> > +	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj name\n");
> > +	do_each_thread(g, p) {
> > +		/*
> > +		 * total_vm and rss sizes do not exist for tasks with a
> > +		 * detached mm so there's no need to report them.  They are
> > +		 * not eligible for OOM killing anyway.
> > +		 */
> > +		if (!p->mm)
> > +			continue;
> > +
> > +		task_lock(p);
> > +		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
> > +		       p->pid, p->uid, p->tgid, p->mm->total_vm,
> > +		       get_mm_rss(p->mm), (int)task_cpu(p), p->oomkilladj,
> > +		       p->comm);
> > +		task_unlock(p);
> > +	} while_each_thread(g, p);
> > +}
> 
> There's no need to inline this.
> 

Ah, gotcha.

> Also, it appears to be 100% generic and useful, so perhaps it should be put
> into kernel/something.c and made available to other code.  Probably there's
> already code out there which should be converted to a call to this
> function?
> 

I'll look into it, thanks for the review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
