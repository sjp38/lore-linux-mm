Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 819876B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 20:40:38 -0400 (EDT)
Received: by qkhq76 with SMTP id q76so46235733qkh.2
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 17:40:38 -0700 (PDT)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id f1si8394604qcs.18.2015.06.14.17.40.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Sun, 14 Jun 2015 17:40:37 -0700 (PDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 14 Jun 2015 18:40:36 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 352C719D8041
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 18:31:36 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5F0dvgK58654802
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 17:39:57 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5F0eYB4009609
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 18:40:35 -0600
Date: Sun, 14 Jun 2015 17:40:30 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 02/12] x86/mm/hotplug: Remove pgd_list use from the
	memory hotplug code
Message-ID: <20150615004030.GK3913@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
 <1434188955-31397-3-git-send-email-mingo@kernel.org>
 <20150613192454.GA1735@redhat.com>
 <20150614073652.GA5923@gmail.com>
 <20150614192422.GA18477@redhat.com>
 <20150614193825.GA19582@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150614193825.GA19582@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

On Sun, Jun 14, 2015 at 09:38:25PM +0200, Oleg Nesterov wrote:
> On 06/14, Oleg Nesterov wrote:
> >
> > On 06/14, Ingo Molnar wrote:
> > >
> > > * Oleg Nesterov <oleg@redhat.com> wrote:
> > >
> > > > > +		spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
> > > >                                          ^^^^^^^^^^^^^^^^^^^^^^^
> > > >
> > > > Hmm, but it doesn't if PREEMPT_RCU? No, no, I do not pretend I understand how it
> > > > actually works ;) But, say, rcu_check_callbacks() can be called from irq and
> > > > since spin_lock() doesn't increment current->rcu_read_lock_nesting this can lead
> > > > to rcu_preempt_qs()?
> > >
> > > No, RCU grace periods are still defined by 'heavy' context boundaries such as
> > > context switches, entering idle or user-space mode.
> > >
> > > PREEMPT_RCU is like traditional RCU, except that blocking is allowed within the
> > > RCU read critical section - that is why it uses a separate nesting counter
> > > (current->rcu_read_lock_nesting), not the preempt count.
> >
> > Yes.
> >
> > > But if a piece of kernel code is non-preemptible, such as a spinlocked region or
> > > an irqs-off region, then those are still natural RCU read lock regions, regardless
> > > of the RCU model, and need no additional RCU locking.
> >
> > I do not think so. Yes I understand that rcu_preempt_qs() itself doesn't
> > finish the gp, but if there are no other rcu-read-lock holders then it
> > seems synchronize_rcu() on another CPU can return _before_ spin_unlock(),
> > this CPU no longer needs rcu_preempt_note_context_switch().
> >
> > OK, I can be easily wrong, I do not really understand the implementation
> > of PREEMPT_RCU. Perhaps preempt_disable() can actually act as rcu_read_lock()
> > with the _current_ implementation. Still this doesn't look right even if
> > happens to work, and Documentation/RCU/checklist.txt says:
> >
> > 11.	Note that synchronize_rcu() -only- guarantees to wait until
> > 	all currently executing rcu_read_lock()-protected RCU read-side
> > 	critical sections complete.  It does -not- necessarily guarantee
> > 	that all currently running interrupts, NMIs, preempt_disable()
> > 	code, or idle loops will complete.  Therefore, if your
> > 	read-side critical sections are protected by something other
> > 	than rcu_read_lock(), do -not- use synchronize_rcu().
> 
> 
> I've even checked this ;) I applied the stupid patch below and then
> 
> 	$ taskset 2 perl -e 'syscall 157, 666, 5000' &
> 	[1] 565
> 
> 	$ taskset 1 perl -e 'syscall 157, 777'
> 
> 	$
> 	[1]+  Done                    taskset 2 perl -e 'syscall 157, 666, 5000'
> 
> 	$ dmesg -c
> 	SPIN start
> 	SYNC start
> 	SYNC done!
> 	SPIN done!

Please accept my apologies for my late entry to this thread.
Youngest kid graduated from university this weekend, so my
attention has been elsewhere.

If you were to disable interrupts instead of preemption, I would expect
that the preemptible-RCU grace period would be blocked -- though I am
not particularly comfortable with people relying on disabled interrupts
blocking a preemptible-RCU grace period.

Here is what can happen if you try to block a preemptible-RCU grace
period by disabling preemption, assuming that there are at least two
online CPUs in the system:

1.	CPU 0 does spin_lock(), which disables preemption.

2.	CPU 1 starts a grace period.

3.	CPU 0 takes a scheduling-clock interrupt.  It raises softirq,
	and the RCU_SOFTIRQ handler notes that there is a new grace
	period and sets state so that a subsequent quiescent state on
	this CPU will be noted.

4.	CPU 0 takes another scheduling-clock interrupt, which checks
	current->rcu_read_lock_nesting, and notes that there is no
	preemptible-RCU read-side critical section in progress.  It
	again raises softirq, and the RCU_SOFTIRQ handler reports
	the quiescent state to core RCU.

5.	Once each of the other CPUs report a quiescent state, the
	grace period can end, despite CPU 0 having preemption
	disabled the whole time.

So Oleg's test is correct, disabling preemption is not sufficient
to block a preemptible-RCU grace period.

The usual suggestion would be to add rcu_read_lock() just after the
lock is acquired and rcu_read_unlock() just before each release of that
same lock.  Putting the entire RCU read-side critical section under
the lock prevents RCU from having to invoke rcu_read_unlock_special()
due to preemption.  (It might still invoke it if the RCU read-side
critical section was overly long, but that is much cheaper than the
preemption-handling case.)

							Thanx, Paul

> Oleg.
> 
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -2049,6 +2049,9 @@ static int prctl_get_tid_address(struct task_struct *me, int __user **tid_addr)
>  }
>  #endif
> 
> +#include <linux/delay.h>
> +
> +
>  SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
>  		unsigned long, arg4, unsigned long, arg5)
>  {
> @@ -2062,6 +2065,19 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
> 
>  	error = 0;
>  	switch (option) {
> +	case 666:
> +		preempt_disable();
> +		pr_crit("SPIN start\n");
> +		while (arg2--)
> +			mdelay(1);
> +		pr_crit("SPIN done!\n");
> +		preempt_enable();
> +		break;
> +	case 777:
> +		pr_crit("SYNC start\n");
> +		synchronize_rcu();
> +		pr_crit("SYNC done!\n");
> +		break;
>  	case PR_SET_PDEATHSIG:
>  		if (!valid_signal(arg2)) {
>  			error = -EINVAL;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
