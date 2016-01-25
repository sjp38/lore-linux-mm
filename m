Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBBD6B0259
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 14:19:13 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id cy9so85243957pac.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:19:13 -0800 (PST)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id wc6si35401725pab.33.2016.01.25.11.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 11:19:12 -0800 (PST)
Received: by mail-pa0-x243.google.com with SMTP id pv5so6911259pac.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:19:12 -0800 (PST)
Date: Mon, 25 Jan 2016 14:19:09 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 10/22] kthread: Allow to modify delayed kthread work
Message-ID: <20160125191909.GF3628@mtj.duckdns.org>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
 <1453736711-6703-11-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453736711-6703-11-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jan 25, 2016 at 04:44:59PM +0100, Petr Mladek wrote:
> +bool mod_delayed_kthread_work(struct kthread_worker *worker,
> +			      struct delayed_kthread_work *dwork,
> +			      unsigned long delay)
> +{
> +	struct kthread_work *work = &dwork->work;
> +	unsigned long flags;
> +	int ret = 0;
> +
> +try_again:
> +	spin_lock_irqsave(&worker->lock, flags);
> +	WARN_ON_ONCE(work->worker && work->worker != worker);
> +
> +	if (work->canceling)
> +		goto out;
> +
> +	ret = try_to_cancel_kthread_work(work, &worker->lock, &flags);
> +	if (ret == -EAGAIN)
> +		goto try_again;
> +
> +	if (work->canceling)

Does this test need to be repeated?  How would ->canceling change
while worker->lock is held?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
