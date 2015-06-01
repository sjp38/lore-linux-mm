Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id B8A1A6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 15:28:26 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so69720535igb.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 12:28:26 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0230.hostedemail.com. [216.40.44.230])
        by mx.google.com with ESMTP id v85si11928880ioi.40.2015.06.01.12.28.26
        for <linux-mm@kvack.org>;
        Mon, 01 Jun 2015 12:28:26 -0700 (PDT)
Date: Mon, 1 Jun 2015 15:28:23 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC][PATCH] mm: ifdef out VM_BUG_ON check on PREEMPT_RT_FULL
Message-ID: <20150601152823.405157c3@gandalf.local.home>
In-Reply-To: <20150601190047.GA5879@cmpxchg.org>
References: <20150529104815.2d2e880c@sluggy>
	<20150529142614.37792b9ff867626dcf5e0f08@linux-foundation.org>
	<20150601131452.3e04f10a@sluggy>
	<20150601190047.GA5879@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Clark Williams <williams@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@glx-um.de>, linux-mm@kvack.org, RT <linux-rt-users@vger.kernel.org>, Fernando Lopez-Lezcano <nando@ccrma.Stanford.EDU>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

On Mon, 1 Jun 2015 15:00:47 -0400
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Andrew's suggestion makes sense, we can probably just delete the check
> as long as we keep the comment.
> 
> That being said, I think it's a little weird that this doesn't work:
> 
> spin_lock_irq()
> BUG_ON(!irqs_disabled())
> spin_unlock_irq()
> 
> I'd expect that if you change the meaning of spin_lock_irq() from
> "mask hardware interrupts" to "disable preemption by tophalf", you
> would update the irqs_disabled() macro to match.  Most people using
> this check probably don't care about the hardware state, only that
> they don't get preempted by an interfering interrupt handler, no?

The thing is, in -rt, there's no state to check if a spin_lock_irq()
was done. Adding that would add overhead to the rt_mutexes without much
gain.

The fast path of spin_lock_irq() in -rt looks like this:

	migrate_disable();
	rt_mutex_cmpxchg(lock, NULL, current);

Now, the migrate_disable() is more like preempt disable.

Although, maybe we could have -rt change irq_disabled() just check
that, and add a raw_irq_disabled() for when we need to make sure
interrupts are really off.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
