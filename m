Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id D01886B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 15:39:34 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so43908384qkh.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 12:39:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 33si10626157qkq.22.2015.06.14.12.39.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 12:39:34 -0700 (PDT)
Date: Sun, 14 Jun 2015 21:38:25 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 02/12] x86/mm/hotplug: Remove pgd_list use from the
	memory hotplug code
Message-ID: <20150614193825.GA19582@redhat.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org> <1434188955-31397-3-git-send-email-mingo@kernel.org> <20150613192454.GA1735@redhat.com> <20150614073652.GA5923@gmail.com> <20150614192422.GA18477@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150614192422.GA18477@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>, "Paul E. McKenney" <paulmck@us.ibm.com>

On 06/14, Oleg Nesterov wrote:
>
> On 06/14, Ingo Molnar wrote:
> >
> > * Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > > > +		spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
> > >                                          ^^^^^^^^^^^^^^^^^^^^^^^
> > >
> > > Hmm, but it doesn't if PREEMPT_RCU? No, no, I do not pretend I understand how it
> > > actually works ;) But, say, rcu_check_callbacks() can be called from irq and
> > > since spin_lock() doesn't increment current->rcu_read_lock_nesting this can lead
> > > to rcu_preempt_qs()?
> >
> > No, RCU grace periods are still defined by 'heavy' context boundaries such as
> > context switches, entering idle or user-space mode.
> >
> > PREEMPT_RCU is like traditional RCU, except that blocking is allowed within the
> > RCU read critical section - that is why it uses a separate nesting counter
> > (current->rcu_read_lock_nesting), not the preempt count.
>
> Yes.
>
> > But if a piece of kernel code is non-preemptible, such as a spinlocked region or
> > an irqs-off region, then those are still natural RCU read lock regions, regardless
> > of the RCU model, and need no additional RCU locking.
>
> I do not think so. Yes I understand that rcu_preempt_qs() itself doesn't
> finish the gp, but if there are no other rcu-read-lock holders then it
> seems synchronize_rcu() on another CPU can return _before_ spin_unlock(),
> this CPU no longer needs rcu_preempt_note_context_switch().
>
> OK, I can be easily wrong, I do not really understand the implementation
> of PREEMPT_RCU. Perhaps preempt_disable() can actually act as rcu_read_lock()
> with the _current_ implementation. Still this doesn't look right even if
> happens to work, and Documentation/RCU/checklist.txt says:
>
> 11.	Note that synchronize_rcu() -only- guarantees to wait until
> 	all currently executing rcu_read_lock()-protected RCU read-side
> 	critical sections complete.  It does -not- necessarily guarantee
> 	that all currently running interrupts, NMIs, preempt_disable()
> 	code, or idle loops will complete.  Therefore, if your
> 	read-side critical sections are protected by something other
> 	than rcu_read_lock(), do -not- use synchronize_rcu().


I've even checked this ;) I applied the stupid patch below and then

	$ taskset 2 perl -e 'syscall 157, 666, 5000' &
	[1] 565

	$ taskset 1 perl -e 'syscall 157, 777'

	$
	[1]+  Done                    taskset 2 perl -e 'syscall 157, 666, 5000'

	$ dmesg -c
	SPIN start
	SYNC start
	SYNC done!
	SPIN done!

Oleg.

--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2049,6 +2049,9 @@ static int prctl_get_tid_address(struct task_struct *me, int __user **tid_addr)
 }
 #endif
 
+#include <linux/delay.h>
+
+
 SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		unsigned long, arg4, unsigned long, arg5)
 {
@@ -2062,6 +2065,19 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 
 	error = 0;
 	switch (option) {
+	case 666:
+		preempt_disable();
+		pr_crit("SPIN start\n");
+		while (arg2--)
+			mdelay(1);
+		pr_crit("SPIN done!\n");
+		preempt_enable();
+		break;
+	case 777:
+		pr_crit("SYNC start\n");
+		synchronize_rcu();
+		pr_crit("SYNC done!\n");
+		break;
 	case PR_SET_PDEATHSIG:
 		if (!valid_signal(arg2)) {
 			error = -EINVAL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
