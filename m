Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id BDAFD6B0096
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 14:00:26 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so25947805wic.1
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 11:00:26 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d8si21138171wjx.17.2015.06.19.11.00.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jun 2015 11:00:24 -0700 (PDT)
Date: Fri, 19 Jun 2015 14:00:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH] mm: ifdef out VM_BUG_ON check on PREEMPT_RT_FULL
Message-ID: <20150619180002.GB11492@cmpxchg.org>
References: <20150529104815.2d2e880c@sluggy>
 <20150529142614.37792b9ff867626dcf5e0f08@linux-foundation.org>
 <20150601131452.3e04f10a@sluggy>
 <20150601190047.GA5879@cmpxchg.org>
 <20150611114042.GC16115@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150611114042.GC16115@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Clark Williams <williams@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@glx-um.de>, linux-mm@kvack.org, RT <linux-rt-users@vger.kernel.org>, Fernando Lopez-Lezcano <nando@ccrma.Stanford.EDU>, Steven Rostedt <rostedt@goodmis.org>

On Thu, Jun 11, 2015 at 01:40:42PM +0200, Sebastian Andrzej Siewior wrote:
> * Johannes Weiner | 2015-06-01 15:00:47 [-0400]:
> 
> >Andrew's suggestion makes sense, we can probably just delete the check
> >as long as we keep the comment.
> 
> that comment didn't get out attention - the BUG_ON() did because the
> latter helped to spot a bug in -RT. Also if the comment says that the
> preemption is expected to be disabled then I still miss the important
> piece of information: WHY. You explained it in an earlier email that
> this has something to do with the per CPU variables which are modified.
> This piece of information is important. In future updates of the code I
> would appreciate BUG_ON() statements like this to catch things I didn't
> see originally.
> 
> >That being said, I think it's a little weird that this doesn't work:
> >
> >spin_lock_irq()
> >BUG_ON(!irqs_disabled())
> >spin_unlock_irq()
> 
> This depends on the point of view. You expect interrupts to be disabled
> while taking a lock. This is not how the function is defined.
> The function ensures that the lock can be taken from process context while
> it may also be taken by another caller from interrupt context. The fact
> that it disables interrupts on vanilla to achieve its goal is an
> implementation detail. Same goes for spin_lock_bh() btw. Based on this
> semantic it works on vanilla and -RT. It does not disable interrupts on
> -RT because there is no need for it: the interrupt handler runs in thread
> context. The function delivers what it is expected to deliver from API
> point of view: "take the lock from process context which can also be
> taken in interrupt context".

Uhm, that's really distorting reality to fit your requirements.  This
helper has been defined to mean local_irq_disable() + spin_lock() for
ages, it's been documented in books on Linux programming.  And people
expect it to prevent interrupt handlers from executing, which it does.

But more importantly, people expect irqs_disabled() to mean that as
well.  Check the callsites.  Except for maybe in the IRQ code itself,
every single caller using irqs_disabled() cares exclusively about the
serialization against interrupt handlers.

> >I'd expect that if you change the meaning of spin_lock_irq() from
> >"mask hardware interrupts" to "disable preemption by tophalf", you
> >would update the irqs_disabled() macro to match.  Most people using
> >this check probably don't care about the hardware state, only that
> >they don't get preempted by an interfering interrupt handler, no?
> 
> Most people that use irqs_disabled() or preempt_disabled() implement
> some kind locking which is not documented. It is either related to CPU
> features (which are per-CPU) or protect per-CPU variables (sometimes
> even global ones). It often ends with something that they rely on how
> the vanilla API works.
> For instance: preempt_disable() is used to for locking in all callers
> but one and this is because that one caller takes a spin_lock() (a
> totally unrelated lock) but since spin_lock() also performs
> preempt_disable() the author optimizes the "needed" preempt_disable()
> invocation away.

That's different, and spin_lock() doesn't imply preemption-disabling
on -rt.  But spin_lock_irq() prevents interrupt handlers from running,
even on -rt.  And people expect irqs_disabled() to test this fact.

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5822,6 +5822,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  {
>  	struct mem_cgroup *memcg;
>  	unsigned short oldid;
> +	unsigned long flags;
>  
>  	VM_BUG_ON_PAGE(PageLRU(page), page);
>  	VM_BUG_ON_PAGE(page_count(page), page);
> @@ -5844,11 +5845,10 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  	if (!mem_cgroup_is_root(memcg))
>  		page_counter_uncharge(&memcg->memory, 1);
>  
> -	/* XXX: caller holds IRQ-safe mapping->tree_lock */
> -	VM_BUG_ON(!irqs_disabled());
> -
> +	local_lock_irqsave(event_lock, flags);
>  	mem_cgroup_charge_statistics(memcg, page, -1);
>  	memcg_check_events(memcg, page);
> +	local_unlock_irqrestore(event_lock, flags);
>  }
>  
>  /**
> 
> The only downside for the non-RT version is that local_lock_irqsave()
> expands to local_irq_save() (on non-RT) which disables IRQs which are
> already disabled - a minor issue if at all.
> 
> Johannes, would you mind using local_lock_irqsave() if it would be
> available in vanilla? As you see it documents what is locked :)

WTF is event_lock?  This is even more obscure than anything else we
had before.  Seriously, just fix irqs_disabled() to mean "interrupt
handlers can't run", which is the expectation in pretty much all
callsites that currently use it, except for maybe irq code itself.

Use raw_irqs_disabled() or something for the three callers that care
about the actual hardware state.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
