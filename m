Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 495456B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 17:27:08 -0500 (EST)
Received: by ykdv3 with SMTP id v3so255115231ykd.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 14:27:08 -0800 (PST)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id e68si8597435ywf.237.2015.11.23.14.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 14:27:07 -0800 (PST)
Received: by ykdv3 with SMTP id v3so255114913ykd.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 14:27:07 -0800 (PST)
Date: Mon, 23 Nov 2015 17:27:03 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 07/22] kthread: Detect when a kthread work is used by
 more workers
Message-ID: <20151123222703.GH19072@mtj.duckdns.org>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
 <1447853127-3461-8-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447853127-3461-8-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Nov 18, 2015 at 02:25:12PM +0100, Petr Mladek wrote:
> @@ -610,6 +625,12 @@ repeat:
>  	if (work) {
>  		__set_current_state(TASK_RUNNING);
>  		work->func(work);
> +
> +		spin_lock_irq(&worker->lock);
> +		/* Allow to queue the work into another worker */
> +		if (!kthread_work_pending(work))
> +			work->worker = NULL;
> +		spin_unlock_irq(&worker->lock);

Doesn't this mean that the work item can't be freed from its callback?
That pattern tends to happen regularly.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
