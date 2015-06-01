Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 51F646B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 15:01:07 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so84525713wic.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 12:01:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x6si26275417wjy.114.2015.06.01.12.01.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 12:01:06 -0700 (PDT)
Date: Mon, 1 Jun 2015 15:00:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH] mm: ifdef out VM_BUG_ON check on PREEMPT_RT_FULL
Message-ID: <20150601190047.GA5879@cmpxchg.org>
References: <20150529104815.2d2e880c@sluggy>
 <20150529142614.37792b9ff867626dcf5e0f08@linux-foundation.org>
 <20150601131452.3e04f10a@sluggy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150601131452.3e04f10a@sluggy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Clark Williams <williams@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@glx-um.de>, linux-mm@kvack.org, RT <linux-rt-users@vger.kernel.org>, Fernando Lopez-Lezcano <nando@ccrma.Stanford.EDU>, Steven Rostedt <rostedt@goodmis.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

On Mon, Jun 01, 2015 at 01:14:52PM -0500, Clark Williams wrote:
> On Fri, 29 May 2015 14:26:14 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Fri, 29 May 2015 10:48:15 -0500 Clark Williams <williams@redhat.com> wrote:
> > 
> > > The irqs_disabled() check in mem_cgroup_swapout() fails on the latest
> > > RT kernel because RT mutexes do not disable interrupts when held. Change
> > > the test for the lock being held to use spin_is_locked.
> > >
> > > ...
> > >
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -5845,7 +5845,7 @@ void mem_cgroup_swapout(struct page *page,
> > > swp_entry_t entry) page_counter_uncharge(&memcg->memory, 1);
> > >  
> > >  	/* XXX: caller holds IRQ-safe mapping->tree_lock */
> > > -	VM_BUG_ON(!irqs_disabled());
> > > +	VM_BUG_ON(!spin_is_locked(&page_mapping(page)->tree_lock));
> > >  
> > >  	mem_cgroup_charge_statistics(memcg, page, -1);
> > >  	memcg_check_events(memcg, page);
> > 
> > spin_is_locked() returns zero on uniprocessor builds.  The results will
> > be unhappy.  
> > 
> > I suggest just deleting the check.
> 
> Guess this is Johannes call. We can just #ifdef it out and that would
> remain the same when we finally merge PREEMPT_RT in mainline. 
> 
> If Johannes wants to keep the check on non-RT, here's a patch:

Andrew's suggestion makes sense, we can probably just delete the check
as long as we keep the comment.

That being said, I think it's a little weird that this doesn't work:

spin_lock_irq()
BUG_ON(!irqs_disabled())
spin_unlock_irq()

I'd expect that if you change the meaning of spin_lock_irq() from
"mask hardware interrupts" to "disable preemption by tophalf", you
would update the irqs_disabled() macro to match.  Most people using
this check probably don't care about the hardware state, only that
they don't get preempted by an interfering interrupt handler, no?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Mon, 1 Jun 2015 14:30:49 -0400
Subject: [PATCH] mm: memcontrol: fix false-positive VM_BUG_ON() on -rt

On -rt, the VM_BUG_ON(!irqs_disabled()) triggers inside the memcg
swapout path because the spin_lock_irq(&mapping->tree_lock) in the
caller doesn't actually disable the hardware interrupts - which is
fine, because on -rt the tophalves run in process context and so we
are still safe from preemption while updating the statistics.

Remove the VM_BUG_ON() but keep the comment of what we rely on.

Reported-by: Clark Williams <williams@redhat.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14c2f20..977f7cd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5833,9 +5833,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!mem_cgroup_is_root(memcg))
 		page_counter_uncharge(&memcg->memory, 1);
 
-	/* XXX: caller holds IRQ-safe mapping->tree_lock */
-	VM_BUG_ON(!irqs_disabled());
-
+	/* Caller disabled preemption with mapping->tree_lock */
 	mem_cgroup_charge_statistics(memcg, page, -1);
 	memcg_check_events(memcg, page);
 }
-- 
2.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
