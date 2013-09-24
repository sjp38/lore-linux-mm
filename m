Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EEEE16B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 17:02:38 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so5094117pdj.21
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 14:02:38 -0700 (PDT)
Date: Tue, 24 Sep 2013 23:02:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130924210221.GF26785@twins.programming.kicks-ass.net>
References: <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130921163404.GA8545@redhat.com>
 <20130923092955.GV9326@twins.programming.kicks-ass.net>
 <20130923173203.GA20392@redhat.com>
 <20130924202423.GW12926@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130924202423.GW12926@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Tue, Sep 24, 2013 at 10:24:23PM +0200, Peter Zijlstra wrote:
> +void __get_online_cpus(void)
> +{
> +	if (__cpuhp_writer == 1) {
take_ref:
> +		/* See __srcu_read_lock() */
> +		__this_cpu_inc(__cpuhp_refcount);
> +		smp_mb();
> +		__this_cpu_inc(cpuhp_seq);
> +		return;
> +	}
> +
> +	atomic_inc(&cpuhp_waitcount);
> +
>  	/*
> +	 * We either call schedule() in the wait, or we'll fall through
> +	 * and reschedule on the preempt_enable() in get_online_cpus().
>  	 */
> +	preempt_enable_no_resched();
> +	wait_event(cpuhp_readers, !__cpuhp_writer);
> +	preempt_disable();
>  
> +	/*
> +	 * XXX list_empty_careful(&cpuhp_readers.task_list) ?
> +	 */
> +	if (atomic_dec_and_test(&cpuhp_waitcount))
> +		wake_up_all(&cpuhp_writer);
	goto take_ref;
> +}
> +EXPORT_SYMBOL_GPL(__get_online_cpus);

It would probably be a good idea to increment __cpuhp_refcount after the
wait_event.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
