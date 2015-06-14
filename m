Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 71F066B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 15:25:33 -0400 (EDT)
Received: by qgfg8 with SMTP id g8so3133286qgf.2
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 12:25:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a39si10585093qgf.24.2015.06.14.12.25.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 12:25:31 -0700 (PDT)
Date: Sun, 14 Jun 2015 21:24:22 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 02/12] x86/mm/hotplug: Remove pgd_list use from the
	memory hotplug code
Message-ID: <20150614192422.GA18477@redhat.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org> <1434188955-31397-3-git-send-email-mingo@kernel.org> <20150613192454.GA1735@redhat.com> <20150614073652.GA5923@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150614073652.GA5923@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>, "Paul E. McKenney" <paulmck@us.ibm.com>

On 06/14, Ingo Molnar wrote:
>
> * Oleg Nesterov <oleg@redhat.com> wrote:
>
> > > +		spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
> >                                          ^^^^^^^^^^^^^^^^^^^^^^^
> >
> > Hmm, but it doesn't if PREEMPT_RCU? No, no, I do not pretend I understand how it
> > actually works ;) But, say, rcu_check_callbacks() can be called from irq and
> > since spin_lock() doesn't increment current->rcu_read_lock_nesting this can lead
> > to rcu_preempt_qs()?
>
> No, RCU grace periods are still defined by 'heavy' context boundaries such as
> context switches, entering idle or user-space mode.
>
> PREEMPT_RCU is like traditional RCU, except that blocking is allowed within the
> RCU read critical section - that is why it uses a separate nesting counter
> (current->rcu_read_lock_nesting), not the preempt count.

Yes.

> But if a piece of kernel code is non-preemptible, such as a spinlocked region or
> an irqs-off region, then those are still natural RCU read lock regions, regardless
> of the RCU model, and need no additional RCU locking.

I do not think so. Yes I understand that rcu_preempt_qs() itself doesn't
finish the gp, but if there are no other rcu-read-lock holders then it
seems synchronize_rcu() on another CPU can return _before_ spin_unlock(),
this CPU no longer needs rcu_preempt_note_context_switch().

OK, I can be easily wrong, I do not really understand the implementation
of PREEMPT_RCU. Perhaps preempt_disable() can actually act as rcu_read_lock()
with the _current_ implementation. Still this doesn't look right even if
happens to work, and Documentation/RCU/checklist.txt says:

11.	Note that synchronize_rcu() -only- guarantees to wait until
	all currently executing rcu_read_lock()-protected RCU read-side
	critical sections complete.  It does -not- necessarily guarantee
	that all currently running interrupts, NMIs, preempt_disable()
	code, or idle loops will complete.  Therefore, if your
	read-side critical sections are protected by something other
	than rcu_read_lock(), do -not- use synchronize_rcu().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
