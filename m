Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6876B0038
	for <linux-mm@kvack.org>; Thu, 15 May 2014 11:35:21 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so790675eek.34
        for <linux-mm@kvack.org>; Thu, 15 May 2014 08:35:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 44si4431262eef.310.2014.05.15.08.35.18
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 08:35:19 -0700 (PDT)
Date: Thu, 15 May 2014 17:34:24 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
	lookups in unlock_page fastpath v4
Message-ID: <20140515153424.GB30668@redhat.com>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de> <1399974350-11089-20-git-send-email-mgorman@suse.de> <20140513125313.GR23991@suse.de> <20140513141748.GD2485@laptop.programming.kicks-ass.net> <20140514161152.GA2615@redhat.com> <20140514192945.GA10830@redhat.com> <20140515104808.GF23991@suse.de> <20140515132058.GL30445@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140515132058.GL30445@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On 05/15, Peter Zijlstra wrote:
>
> So I suppose I'm failing to see the problem with something like:

Yeeees, I was thinking about something like this too ;)

> static inline void lock_page(struct page *page)
> {
> 	if (!trylock_page(page))
> 		__lock_page(page);
> }
>
> static inline void unlock_page(struct page *page)
> {
> 	clear_bit_unlock(&page->flags, PG_locked);
> 	if (PageWaiters(page))
> 		__unlock_page();
> }

but in this case we need mb() before PageWaiters(), I guess.

> void __lock_page(struct page *page)
> {
> 	struct wait_queue_head_t *wqh = page_waitqueue(page);
> 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
>
> 	spin_lock_irq(&wqh->lock);
> 	if (!PageWaiters(page))
> 		SetPageWaiters(page);
>
> 	wait.flags |= WQ_FLAG_EXCLUSIVE;
> 	preempt_disable();

why?

> 	do {
> 		if (list_empty(&wait->task_list))
> 			__add_wait_queue_tail(wqh, &wait);
>
> 		set_current_state(TASK_UNINTERRUPTIBLE);
>
> 		if (test_bit(wait.key.bit_nr, wait.key.flags)) {
> 			spin_unlock_irq(&wqh->lock);
> 			schedule_preempt_disabled();
> 			spin_lock_irq(&wqh->lock);

OK, probably to avoid the preemption before schedule(). Still can't
undestand why this makes sense, but in this case it would be better
to do disable/enable under "if (test_bit())" ?

Of course, this needs more work for lock_page_killable(), but this
should be simple.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
