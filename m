Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 89BD26B0253
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 11:44:39 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so16291477wgx.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 08:44:39 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id pk5si4575564wjb.201.2015.07.08.08.44.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 08:44:38 -0700 (PDT)
Date: Wed, 8 Jul 2015 17:44:32 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [RFC][PATCH] mm: ifdef out VM_BUG_ON check on PREEMPT_RT_FULL
Message-ID: <20150708154432.GA31345@linutronix.de>
References: <20150529104815.2d2e880c@sluggy>
 <20150529142614.37792b9ff867626dcf5e0f08@linux-foundation.org>
 <20150601131452.3e04f10a@sluggy>
 <20150601190047.GA5879@cmpxchg.org>
 <20150611114042.GC16115@linutronix.de>
 <20150619180002.GB11492@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150619180002.GB11492@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Clark Williams <williams@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@glx-um.de>, linux-mm@kvack.org, RT <linux-rt-users@vger.kernel.org>, Fernando Lopez-Lezcano <nando@ccrma.Stanford.EDU>, Steven Rostedt <rostedt@goodmis.org>

* Johannes Weiner | 2015-06-19 14:00:02 [-0400]:

>> This depends on the point of view. You expect interrupts to be disabled
>> while taking a lock. This is not how the function is defined.
>> The function ensures that the lock can be taken from process context while
>> it may also be taken by another caller from interrupt context. The fact
>> that it disables interrupts on vanilla to achieve its goal is an
>> implementation detail. Same goes for spin_lock_bh() btw. Based on this
>> semantic it works on vanilla and -RT. It does not disable interrupts on
>> -RT because there is no need for it: the interrupt handler runs in thread
>> context. The function delivers what it is expected to deliver from API
>> point of view: "take the lock from process context which can also be
>> taken in interrupt context".
>
>Uhm, that's really distorting reality to fit your requirements.  This
>helper has been defined to mean local_irq_disable() + spin_lock() for
>ages, it's been documented in books on Linux programming.  And people
>expect it to prevent interrupt handlers from executing, which it does.

After all it documents the current implementation and the semantic
requirement.

>But more importantly, people expect irqs_disabled() to mean that as
>well.  Check the callsites.  Except for maybe in the IRQ code itself,
>every single caller using irqs_disabled() cares exclusively about the
>serialization against interrupt handlers.

I am aware of some people expect and we fix them in -RT. Using
irqs_disabled() as a form locking for per-CPU variables is another way
of creating a BKL.

>> Most people that use irqs_disabled() or preempt_disabled() implement
>> some kind locking which is not documented. It is either related to CPU
>> features (which are per-CPU) or protect per-CPU variables (sometimes
>> even global ones). It often ends with something that they rely on how
>> the vanilla API works.
>> For instance: preempt_disable() is used to for locking in all callers
>> but one and this is because that one caller takes a spin_lock() (a
>> totally unrelated lock) but since spin_lock() also performs
>> preempt_disable() the author optimizes the "needed" preempt_disable()
>> invocation away.
>
>That's different, and spin_lock() doesn't imply preemption-disabling
>on -rt.  But spin_lock_irq() prevents interrupt handlers from running,
>even on -rt.  And people expect irqs_disabled() to test this fact.

What is the point of
    spin_lock_irq(&a);
    BUG_ON(!irqs_disabled())

It should not trigger. It triggers on -RT. But there is no BUG as long
as it safe to use it from IRQ handler and process context and this is
what it has been built for in the first place.

Lets have another example: Lets assume I come up with a way to lazy
disable interrupts. That means spin_lock_irq() does not disable
interrupts it simply simple sets a per-CPU bit that the interrupts
should remain off. Should an interrupt arrive (because the CPU flag
still enabled them) it will see the bit set and postpones the interrupt
and return.
Now: we don't deadlock with spin_lock_irq() against an interrupt even if
we don't disable interrupts. There is a precaution for this. And my
question: What should irqs_disabled() return within the spin_lock_irq()
section? The real state or what people documented in books ages ago?

>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -5822,6 +5822,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>>  {
>>  	struct mem_cgroup *memcg;
>>  	unsigned short oldid;
>> +	unsigned long flags;
>>  
>>  	VM_BUG_ON_PAGE(PageLRU(page), page);
>>  	VM_BUG_ON_PAGE(page_count(page), page);
>> @@ -5844,11 +5845,10 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>>  	if (!mem_cgroup_is_root(memcg))
>>  		page_counter_uncharge(&memcg->memory, 1);
>>  
>> -	/* XXX: caller holds IRQ-safe mapping->tree_lock */
>> -	VM_BUG_ON(!irqs_disabled());
>> -
>> +	local_lock_irqsave(event_lock, flags);
>>  	mem_cgroup_charge_statistics(memcg, page, -1);
>>  	memcg_check_events(memcg, page);
>> +	local_unlock_irqrestore(event_lock, flags);
>>  }
>>  
>>  /**
>> 
>> The only downside for the non-RT version is that local_lock_irqsave()
>> expands to local_irq_save() (on non-RT) which disables IRQs which are
>> already disabled - a minor issue if at all.
>> 
>> Johannes, would you mind using local_lock_irqsave() if it would be
>> available in vanilla? As you see it documents what is locked :)
>
>WTF is event_lock?  This is even more obscure than anything else we
>had before.  Seriously, just fix irqs_disabled() to mean "interrupt
>handlers can't run", which is the expectation in pretty much all
>callsites that currently use it, except for maybe irq code itself.

How is it more obscure than anything else? After all it disables
interrupts and documents based on the lock named `event_lock' what is
protected. Which means each section that share the same (per-CPU)
ressources belong together and may not be accessed independently.

>Use raw_irqs_disabled() or something for the three callers that care
>about the actual hardware state.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
