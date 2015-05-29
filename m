Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id A01976B008A
	for <linux-mm@kvack.org>; Fri, 29 May 2015 15:21:16 -0400 (EDT)
Received: by iesa3 with SMTP id a3so70447814ies.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 12:21:16 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0213.hostedemail.com. [216.40.44.213])
        by mx.google.com with ESMTP id v103si1549778iov.51.2015.05.29.12.21.16
        for <linux-mm@kvack.org>;
        Fri, 29 May 2015 12:21:16 -0700 (PDT)
Date: Fri, 29 May 2015 15:21:12 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC] mm: change irqs_disabled() test to spin_is_locked() in
 mem_cgroup_swapout
Message-ID: <20150529152112.2e8cfdb3@gandalf.local.home>
In-Reply-To: <20150529191159.GA29078@cmpxchg.org>
References: <20150529104815.2d2e880c@sluggy>
	<20150529191159.GA29078@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Clark Williams <williams@redhat.com>, Thomas Gleixner <tglx@glx-um.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, RT <linux-rt-users@vger.kernel.org>, Fernando Lopez-Lezcano <nando@ccrma.Stanford.EDU>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

On Fri, 29 May 2015 15:11:59 -0400
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Hi Clark,
> 
> On Fri, May 29, 2015 at 10:48:15AM -0500, Clark Williams wrote:
> > @@ -5845,7 +5845,7 @@ void mem_cgroup_swapout(struct page *page,
> > swp_entry_t entry) page_counter_uncharge(&memcg->memory, 1);
> >  
> >  	/* XXX: caller holds IRQ-safe mapping->tree_lock */
> > -	VM_BUG_ON(!irqs_disabled());
> > +	VM_BUG_ON(!spin_is_locked(&page_mapping(page)->tree_lock));
> >  
> >  	mem_cgroup_charge_statistics(memcg, page, -1);
> 
> It's not about the lock, it's about preemption.  The charge statistics

OK, I just lost my bet with Clark. He said it was about preemption, and
I said it was about the lock ;-)

> use __this_cpu operations and they're updated from process context and
> interrupt context both.
> 
> This function really should do a local_irq_save().  I only added the
> VM_BUG_ON() to document that we know the caller is holding an IRQ-safe
> lock and so we don't need to bother with another level of IRQ saving.
> 
> So how does this translate to RT?  I don't know.  But if switching to
> explicit IRQ toggling would help you guys out we can do that.  It is
> in the swapout path after all, the optimization isn't that important.

You only need to prevent this from preempting with other users here,
right? RT provides a "local_lock_irqsave(var)" which on vanilla linux
will do a local_irq_save(), but more importantly, it provides
documentation of what that local_irq_save is about (the var).

On -rt, that turns into a migrate disable, plus grabbing of the
rt_mutex(var). Thus, the process wont migrate from that CPU, but may be
preempted. If another process (or interrupt thread, as in -rt
interrupts run as preemptable threads) tries to do a local_lock(var) on
the same var, it will block.

Basically, you get the same serialization in both, but you don't cause
latencies in -rt.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
