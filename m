Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ACAB46B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:53:18 -0500 (EST)
Date: Fri, 11 Dec 2009 14:52:48 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 4/9] oom: Add missing rcu protection of __task_cred() in
 dump_tasks
In-Reply-To: <13284.1260539371@redhat.com>
Message-ID: <alpine.LFD.2.00.0912111452360.3089@localhost.localdomain>
References: <20091210004703.148689096@linutronix.de> <20091210001308.247025548@linutronix.de> <13284.1260539371@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@tv-sign.ru>, Al Viro <viro@zeniv.linux.org.uk>, James Morris <jmorris@namei.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Dec 2009, David Howells wrote:

> Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> > +		/* Protect __task_cred() access */
> > +		rcu_read_lock();
> >  		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
> >  		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
> >  		       get_mm_rss(mm), (int)task_cpu(p), p->signal->oom_adj,
> >  		       p->comm);
> > +		rcu_read_unlock();
> 
> No.  If there's only one access to __task_cred() like this, use
> task_cred_xxx() or one of its wrappers instead:
> 
> -		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
> +		       p->pid, task_uid(p), p->tgid, mm->total_vm,
> 
> that limits the size of the critical section.

Fair enough.

     tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
