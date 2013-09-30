Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A9A146B0036
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 12:45:13 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so5950657pde.10
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 09:45:13 -0700 (PDT)
Date: Mon, 30 Sep 2013 18:38:10 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC] introduce synchronize_sched_{enter,exit}()
Message-ID: <20130930163810.GA25642@redhat.com>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de> <1378805550-29949-38-git-send-email-mgorman@suse.de> <20130917143003.GA29354@twins.programming.kicks-ass.net> <20130929183634.GA15563@redhat.com> <20130930125942.GB12926@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130930125942.GB12926@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 09/30, Peter Zijlstra wrote:
>
> On Sun, Sep 29, 2013 at 08:36:34PM +0200, Oleg Nesterov wrote:
> > Why? Say, percpu_rw_semaphore, or upcoming changes in get_online_cpus(),
> > (Peter, I think they should be unified anyway, but lets ignore this for
> > now).
>
> If you think the percpu_rwsem users can benefit sure.. So far its good I
> didn't go the percpu_rwsem route for it looks like we got something
> better at the end of it ;-)

I think you could simply improve percpu_rwsem instead. Once we add
task_struct->cpuhp_ctr percpu_rwsem and get_online_cpus/hotplug_begin
becomes absolutely congruent.

OTOH, it would be simpler to change hotplug first, then copy-and-paste
the improvents into percpu_rwsem, then see if we can simply convert
cpu_hotplug_begin/end into percpu_down/up_write.

> Well, if we make percpu_rwsem the defacto container of the pattern and
> use that throughout, we'd have only a single implementation

Not sure. I think it can have other users. But even if not, please look
at "struct sb_writers". Yes, I believe it makes sense to use percpu_rwsem
here, but note that it is actually array of semaphores. I do not think
each element needs its own xxx_struct.

> and don't
> need the abstraction.

And even if struct percpu_rw_semaphore will be the only container of
xxx_struct, I think the code looks better and more understandable this
way, exactly because it adds the new abstraction layer. Performance-wise
this should be free.

> > static void cb_rcu_func(struct rcu_head *rcu)
> > {
> > 	struct xxx_struct *xxx = container_of(rcu, struct xxx_struct, cb_head);
> > 	long flags;
> >
> > 	BUG_ON(xxx->gp_state != GP_PASSED);
> > 	BUG_ON(xxx->cb_state == CB_IDLE);
> >
> > 	spin_lock_irqsave(&xxx->xxx_lock, flags);
> > 	if (xxx->gp_count) {
> > 		xxx->cb_state = CB_IDLE;
>
> This seems to be when a new xxx_begin() has happened after our last
> xxx_end() and the sync_sched() from xxx_begin() merges with the
> xxx_end() one and we're done.

Yes,

> > 	} else if (xxx->cb_state == CB_REPLAY) {
> > 		xxx->cb_state = CB_PENDING;
> > 		call_rcu_sched(&xxx->cb_head, cb_rcu_func);
>
> A later xxx_exit() has happened, and we need to requeue to catch a later
> GP.

Exactly.

> So I don't immediately see the point of the concurrent write side;
> percpu_rwsem wouldn't allow this and afaict neither would
> freeze_super().

Oh I disagree. Even ignoring the fact I believe xxx_struct itself
can have more users (I can be wrong of course), I do think that
percpu_down_write_nonexclusive() makes sense (except "exclusive"
should be the argument of percpu_init_rwsem). And in fact the
initial implementation I sent didn't even has the "exclusive" mode.

Please look at uprobes (currently the only user). We do not really
need the global write-lock, we can do the per-uprobe locking. However,
every caller needs to block the percpu_down_read() callers (dup_mmap).

> Other than that; yes this makes sense if you care about write side
> performance and I think its solid.

Great ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
