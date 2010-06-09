Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 65A0B6B0071
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 16:16:01 -0400 (EDT)
Date: Wed, 9 Jun 2010 22:14:30 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 06/18] oom: avoid sending exiting tasks a SIGKILL
Message-ID: <20100609201430.GA8210@redhat.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com> <20100608202611.GA11284@redhat.com> <alpine.DEB.2.00.1006082330160.30606@chino.kir.corp.google.com> <20100609162523.GA30464@redhat.com> <alpine.DEB.2.00.1006091241330.26827@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006091241330.26827@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/09, David Rientjes wrote:
>
> On Wed, 9 Jun 2010, Oleg Nesterov wrote:
>
> > David, currently I do not know how the code looks with all patches
> > applied, could you please confirm there is no problem here? I am
> > looking at Linus's tree,
> >
> > 	mem_cgroup_out_of_memory:
> >
> > 		 p = select_bad_process();
> > 		 oom_kill_process(p);
> >
>
> mem_cgroup_out_of_memory() does this under tasklist_lock:
>
> retry:
> 	p = select_bad_process(&points, mem, CONSTRAINT_MEMCG, NULL);
> 	if (!p || PTR_ERR(p) == -1UL)
> 		goto out;
>
> 	if (oom_kill_process(p, gfp_mask, 0, points, mem,
> 				"Memory cgroup out of memory"))
> 		goto retry;
> out:
> 	...
>
> > Now, again, select_bad_process() can return the dead group-leader
> > of the memory-hog-thread-group.
> >
>
> select_bad_process() already has:
>
> 	if ((p->flags & PF_EXITING) && p->mm) {
> 		if (p != current)
> 			return ERR_PTR(-1UL);
>
> 		chosen = p;
> 		*ppoints = ULONG_MAX;
> 	}
>
> so we can disregard the check for p == current

Not sure I understand... We can just ignore this check, in this case
p->mm == NULL.

> in this case since it would
> not be allocating memory without p->mm.

This thread will not allocate the memory, yes. But its sub-threads can.
And select_bad_process() can constantly return the same (dead) thread P,
badness() inspects ->mm under find_lock_task_mm() which finds the thread
with the valid ->mm.

OK. Probably this doesn't matter. I don't know if task_in_mem_cgroup(task)
was fixed or not, but currently it also looks at task->mm and thus have
the same boring problem: it is trivial to make the memory-hog process
invisible to oom. Unless I missed something, of course.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
