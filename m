Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1ED6B0254
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:35:19 -0400 (EDT)
Received: by ykft14 with SMTP id t14so20407046ykf.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:35:19 -0700 (PDT)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com. [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id d16si1974933ywb.11.2015.09.22.12.35.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 12:35:18 -0700 (PDT)
Received: by ykft14 with SMTP id t14so20406656ykf.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:35:18 -0700 (PDT)
Date: Tue, 22 Sep 2015 15:35:13 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 07/18] kthread: Allow to cancel kthread work
Message-ID: <20150922193513.GE17659@mtj.duckdns.org>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-8-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442840639-6963-8-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 21, 2015 at 03:03:48PM +0200, Petr Mladek wrote:
>  /**
> + * try_to_grab_pending_kthread_work - steal kthread work item from worklist,
> + *	and disable irq
> + * @work: work item to steal
> + * @is_dwork: @work is a delayed_work
> + * @flags: place to store irq state
> + *
> + * Try to grab PENDING bit of @work.  This function can handle @work in any
> + * stable state - idle, on timer or on worklist.
> + *
> + * Return:
> + *  1		if @work was pending and we successfully stole PENDING
> + *  0		if @work was idle and we claimed PENDING
> + *  -EAGAIN	if PENDING couldn't be grabbed at the moment, safe to busy-retry
> + *  -ENOENT	if someone else is canceling @work, this state may persist
> + *		for arbitrarily long
> + *
> + * Note:
> + * On >= 0 return, the caller owns @work's PENDING bit.  To avoid getting
> + * interrupted while holding PENDING and @work off queue, irq must be
> + * disabled on return.  This, combined with delayed_work->timer being
> + * irqsafe, ensures that we return -EAGAIN for finite short period of time.
> + *
> + * On successful return, >= 0, irq is disabled and the caller is
> + * responsible for releasing it using local_irq_restore(*@flags).
> + *
> + * This function is safe to call from any context including IRQ handler.
> + */

Ugh... I think this is way too much for kthread_worker.  Workqueue is
as complex as it is partly for historical reasons and partly because
it's used so widely and heavily.  kthread_worker is always guaranteed
to have a single worker and in most cases maybe several work items.
There's no reason to bring this level of complexity onto it.
Providing simliar semantics is fine but it should be possible to do
this in a lot simpler way if the requirements on space and concurrency
is this much lower.

e.g. always embed timer_list in a work item and use per-worker
spinlock to synchronize access to both the work item and timer and use
per-work-item mutex to synchronize multiple cancelers.  Let's please
keep it simple.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
