Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6D06B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 16:10:07 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id v77so46586981ywg.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 13:10:07 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id h13si12443071ywa.7.2016.06.20.13.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 13:10:06 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id v77so4352215ywg.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 13:10:06 -0700 (PDT)
Date: Mon, 20 Jun 2016 16:10:02 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 08/12] kthread: Detect when a kthread work is used by
 more workers
Message-ID: <20160620201002.GZ3262@mtj.duckdns.org>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-9-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466075851-24013-9-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Thu, Jun 16, 2016 at 01:17:27PM +0200, Petr Mladek wrote:
> diff --git a/kernel/kthread.c b/kernel/kthread.c
> index 567ec49b4872..8e9548649c86 100644
> --- a/kernel/kthread.c
> +++ b/kernel/kthread.c
> @@ -574,6 +574,9 @@ EXPORT_SYMBOL_GPL(__kthread_init_worker);
>   * The works are not allowed to keep any locks, disable preemption or interrupts
>   * when they finish. There is defined a safe point for freezing when one work
>   * finishes and before a new one is started.
> + *
> + * Also the works must not be handled by more workers at the same time, see also
                                                ^
						than one
> + * kthread_queue_work().
>   */
>  int kthread_worker_fn(void *worker_ptr)
>  {
> @@ -710,12 +713,21 @@ kthread_create_worker_on_cpu(int cpu, const char namefmt[], ...)
>  }
>  EXPORT_SYMBOL(kthread_create_worker_on_cpu);
>  
> +static void kthread_insert_work_sanity_check(struct kthread_worker *worker,
> +					     struct kthread_work *work)
> +{
> +	lockdep_assert_held(&worker->lock);
> +	WARN_ON_ONCE(!list_empty(&work->node));
> +	/* Do not use a work with more workers, see kthread_queue_work() */
                                  ^
				  ditto, maybe just say ">1 workers"?

Looks good otherwise.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
