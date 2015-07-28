Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 330176B0038
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 13:23:33 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so101492407ykd.2
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:23:33 -0700 (PDT)
Received: from mail-yk0-x244.google.com (mail-yk0-x244.google.com. [2607:f8b0:4002:c07::244])
        by mx.google.com with ESMTPS id o187si15994756yka.19.2015.07.28.10.23.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 10:23:32 -0700 (PDT)
Received: by ykfw194 with SMTP id w194so6272463ykf.2
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:23:32 -0700 (PDT)
Date: Tue, 28 Jul 2015 13:23:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 05/14] kthread: Add
 wakeup_and_destroy_kthread_worker()
Message-ID: <20150728172329.GB5322@mtj.duckdns.org>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-6-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438094371-8326-6-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Tue, Jul 28, 2015 at 04:39:22PM +0200, Petr Mladek wrote:
...
> +void wakeup_and_destroy_kthread_worker(struct kthread_worker *worker)
> +{
> +	struct task_struct *task = worker->task;
> +
> +	if (WARN_ON(!task))
> +		return;
> +
> +	spin_lock_irq(&worker->lock);
> +	if (worker->current_work)
> +		wake_up_process(worker->task);
> +	spin_unlock_irq(&worker->lock);
> +
> +	destroy_kthread_worker(worker);
> +}

I don't know.  Wouldn't it make far more sense to convert those wake
up events with queueings?  It seems backwards to be converting things
to work item based interface and then insert work items which wait for
external events.  More on this later.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
