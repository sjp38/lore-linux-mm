Date: Mon, 24 Sep 2007 21:57:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 5/5] oom: add sysctl to dump tasks memory state
In-Reply-To: <46F8909E.40907@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.0.9999.0709242154010.667@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709212313140.13727@chino.kir.corp.google.com> <46F8909E.40907@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007, Balbir Singh wrote:

> > +static void dump_tasks(void)
> > +{
> > +	struct task_struct *g, *p;
> > +
> > +	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
> > +	       "name\n");
> > +	do_each_thread(g, p) {
> > +		/*
> > +		 * total_vm and rss sizes do not exist for tasks with a
> > +		 * detached mm so there's no need to report them.
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
> > +
> 
> 
> I like this, but can we make this cgroup aware?

To do that it would be necessary to pass the struct mem_cgroup pointer to 
oom_kill_process(), pass it to dump_tasks(), and filter any tasks where
mm->mem_cgroup != mem.

We can fold that into any changes that are made for OOM killer cgroup 
serialization when the time comes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
