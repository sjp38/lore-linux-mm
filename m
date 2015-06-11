Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 51EA16B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 07:40:50 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so3648021wgb.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 04:40:49 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id d3si720012wjr.121.2015.06.11.04.40.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 04:40:48 -0700 (PDT)
Date: Thu, 11 Jun 2015 13:40:42 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [RFC][PATCH] mm: ifdef out VM_BUG_ON check on PREEMPT_RT_FULL
Message-ID: <20150611114042.GC16115@linutronix.de>
References: <20150529104815.2d2e880c@sluggy>
 <20150529142614.37792b9ff867626dcf5e0f08@linux-foundation.org>
 <20150601131452.3e04f10a@sluggy>
 <20150601190047.GA5879@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150601190047.GA5879@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Clark Williams <williams@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@glx-um.de>, linux-mm@kvack.org, RT <linux-rt-users@vger.kernel.org>, Fernando Lopez-Lezcano <nando@ccrma.Stanford.EDU>, Steven Rostedt <rostedt@goodmis.org>

* Johannes Weiner | 2015-06-01 15:00:47 [-0400]:

>Andrew's suggestion makes sense, we can probably just delete the check
>as long as we keep the comment.

that comment didn't get out attention - the BUG_ON() did because the
latter helped to spot a bug in -RT. Also if the comment says that the
preemption is expected to be disabled then I still miss the important
piece of information: WHY. You explained it in an earlier email that
this has something to do with the per CPU variables which are modified.
This piece of information is important. In future updates of the code I
would appreciate BUG_ON() statements like this to catch things I didn't
see originally.

>That being said, I think it's a little weird that this doesn't work:
>
>spin_lock_irq()
>BUG_ON(!irqs_disabled())
>spin_unlock_irq()

This depends on the point of view. You expect interrupts to be disabled
while taking a lock. This is not how the function is defined.
The function ensures that the lock can be taken from process context while
it may also be taken by another caller from interrupt context. The fact
that it disables interrupts on vanilla to achieve its goal is an
implementation detail. Same goes for spin_lock_bh() btw. Based on this
semantic it works on vanilla and -RT. It does not disable interrupts on
-RT because there is no need for it: the interrupt handler runs in thread
context. The function delivers what it is expected to deliver from API
point of view: "take the lock from process context which can also be
taken in interrupt context".

>I'd expect that if you change the meaning of spin_lock_irq() from
>"mask hardware interrupts" to "disable preemption by tophalf", you
>would update the irqs_disabled() macro to match.  Most people using
>this check probably don't care about the hardware state, only that
>they don't get preempted by an interfering interrupt handler, no?

Most people that use irqs_disabled() or preempt_disabled() implement
some kind locking which is not documented. It is either related to CPU
features (which are per-CPU) or protect per-CPU variables (sometimes
even global ones). It often ends with something that they rely on how
the vanilla API works.
For instance: preempt_disable() is used to for locking in all callers
but one and this is because that one caller takes a spin_lock() (a
totally unrelated lock) but since spin_lock() also performs
preempt_disable() the author optimizes the "needed" preempt_disable()
invocation away.

Either way, those functions do perform some kind of locking, don't
document what they are actually protecting and you can't test if the
locks are held properly all the time since lockdep can't see them. This
is bad. It is awful. This should not be done.

So. Back to the actual problem. In short: The per-CPU variables were
protected by local_irq_disable() in all places but one because it
inherited the needed local_irq_disable() from spin_lock_irq().
I did not make the preempt_disable() + spin_lock() case up, it happened
unfortunately more than once - ask tglx.

The function in question was introduced in v4.0-rc1. The other functions
that were calling mem_cgroup_charge_statistics() + memcg_check_events()
were converted to use local_lock_irq() for instance in
mem_cgroup_move_account(). That happened in v3.18 I think. I didn't spot
this new users while doing v4.0 -RT. So the next -RT release will get:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5822,6 +5822,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 {
 	struct mem_cgroup *memcg;
 	unsigned short oldid;
+	unsigned long flags;
 
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 	VM_BUG_ON_PAGE(page_count(page), page);
@@ -5844,11 +5845,10 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!mem_cgroup_is_root(memcg))
 		page_counter_uncharge(&memcg->memory, 1);
 
-	/* XXX: caller holds IRQ-safe mapping->tree_lock */
-	VM_BUG_ON(!irqs_disabled());
-
+	local_lock_irqsave(event_lock, flags);
 	mem_cgroup_charge_statistics(memcg, page, -1);
 	memcg_check_events(memcg, page);
+	local_unlock_irqrestore(event_lock, flags);
 }
 
 /**

The only downside for the non-RT version is that local_lock_irqsave()
expands to local_irq_save() (on non-RT) which disables IRQs which are
already disabled - a minor issue if at all.

Johannes, would you mind using local_lock_irqsave() if it would be
available in vanilla? As you see it documents what is locked :)

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
