Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 442F96B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 03:37:00 -0400 (EDT)
Received: by wgzl5 with SMTP id l5so22840758wgz.3
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 00:36:59 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id bo1si15976694wjb.27.2015.06.14.00.36.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 00:36:58 -0700 (PDT)
Received: by wiga1 with SMTP id a1so48911369wig.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 00:36:57 -0700 (PDT)
Date: Sun, 14 Jun 2015 09:36:52 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 02/12] x86/mm/hotplug: Remove pgd_list use from the
 memory hotplug code
Message-ID: <20150614073652.GA5923@gmail.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
 <1434188955-31397-3-git-send-email-mingo@kernel.org>
 <20150613192454.GA1735@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150613192454.GA1735@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>, "Paul E. McKenney" <paulmck@us.ibm.com>


* Oleg Nesterov <oleg@redhat.com> wrote:

> On 06/13, Ingo Molnar wrote:
> >
> > @@ -169,29 +169,40 @@ void sync_global_pgds(unsigned long start, unsigned long end, int removed)
> >
> >  	for (address = start; address <= end; address += PGDIR_SIZE) {
> >  		const pgd_t *pgd_ref = pgd_offset_k(address);
> > -		struct page *page;
> > +		struct task_struct *g, *p;
> >
> >  		/*
> > -		 * When it is called after memory hot remove, pgd_none()
> > -		 * returns true. In this case (removed == 1), we must clear
> > -		 * the PGD entries in the local PGD level page.
> > +		 * When this function is called after memory hot remove,
> > +		 * pgd_none() already returns true, but only the reference
> > +		 * kernel PGD has been cleared, not the process PGDs.
> > +		 *
> > +		 * So clear the affected entries in every process PGD as well:
> >  		 */
> >  		if (pgd_none(*pgd_ref) && !removed)
> >  			continue;
> >
> > -		spin_lock(&pgd_lock);
> > -		list_for_each_entry(page, &pgd_list, lru) {
> > +		spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
>                                          ^^^^^^^^^^^^^^^^^^^^^^^
> 
> Hmm, but it doesn't if PREEMPT_RCU? No, no, I do not pretend I understand how it 
> actually works ;) But, say, rcu_check_callbacks() can be called from irq and 
> since spin_lock() doesn't increment current->rcu_read_lock_nesting this can lead 
> to rcu_preempt_qs()?

No, RCU grace periods are still defined by 'heavy' context boundaries such as 
context switches, entering idle or user-space mode.

PREEMPT_RCU is like traditional RCU, except that blocking is allowed within the 
RCU read critical section - that is why it uses a separate nesting counter 
(current->rcu_read_lock_nesting), not the preempt count.

But if a piece of kernel code is non-preemptible, such as a spinlocked region or 
an irqs-off region, then those are still natural RCU read lock regions, regardless 
of the RCU model, and need no additional RCU locking.

rcu_check_callbacks() can be called from irq context, but only to observe whether 
the current CPU is in quiescent state. If it interrupts a spinlocked region it 
won't register a quiesent state.

> > +		for_each_process_thread(g, p) {
> > +			struct mm_struct *mm;
> >  			pgd_t *pgd;
> >  			spinlock_t *pgt_lock;
> >
> > -			pgd = (pgd_t *)page_address(page) + pgd_index(address);
> > -			/* the pgt_lock only for Xen */
> > -			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
> > +			task_lock(p);
> > +			mm = p->mm;
> > +			if (!mm) {
> > +				task_unlock(p);
> > +				continue;
> > +			}
> 
> Again, you can simplify this code and avoid for_each_process_thread() if you use 
> for_each_process() + find_lock_task_mm().

True!

So I looked at this when you first mentioned it but mis-read find_lock_task_mm(), 
which as you insist is exactly what this iteration needs to become faster and 
simpler. Thanks for the reminder - I have fixed it, will be part of -v3.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
