Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 48C266B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 13:57:51 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id x13so7204169ief.1
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 10:57:50 -0700 (PDT)
Date: Mon, 23 Sep 2013 19:50:52 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130923175052.GA20991@redhat.com>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de> <1378805550-29949-38-git-send-email-mgorman@suse.de> <20130917143003.GA29354@twins.programming.kicks-ass.net> <20130917162050.GK22421@suse.de> <20130917164505.GG12926@twins.programming.kicks-ass.net> <20130918154939.GZ26785@twins.programming.kicks-ass.net> <20130919143241.GB26785@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130919143241.GB26785@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

And somehow I didn't notice that cpuhp_set_state() doesn't look right,

On 09/19, Peter Zijlstra wrote:
>  void cpu_hotplug_begin(void)
>  {
> -	cpu_hotplug.active_writer = current;
> +	lockdep_assert_held(&cpu_add_remove_lock);
>  
> -	for (;;) {
> -		mutex_lock(&cpu_hotplug.lock);
> -		if (likely(!cpu_hotplug.refcount))
> -			break;
> -		__set_current_state(TASK_UNINTERRUPTIBLE);
> -		mutex_unlock(&cpu_hotplug.lock);
> -		schedule();
> -	}
> +	__cpuhp_writer = current;
> +
> +	/* After this everybody will observe _writer and take the slow path. */
> +	synchronize_sched();
> +
> +	/* Wait for no readers -- reader preference */
> +	cpuhp_wait_refcount();
> +
> +	/* Stop new readers. */
> +	cpuhp_set_state(1);

But this stops all readers, not only new. Even if cpuhp_wait_refcount()
was correct, a new reader can come right before cpuhp_set_state(1) and
then it can call another recursive get_online_cpus() right after.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
