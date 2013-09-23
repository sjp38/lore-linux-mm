Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 79FDF6B0037
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 10:50:26 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so2393102pab.10
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 07:50:26 -0700 (PDT)
Date: Mon, 23 Sep 2013 10:50:17 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130923105017.030e0aef@gandalf.local.home>
In-Reply-To: <20130919143241.GB26785@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
	<1378805550-29949-38-git-send-email-mgorman@suse.de>
	<20130917143003.GA29354@twins.programming.kicks-ass.net>
	<20130917162050.GK22421@suse.de>
	<20130917164505.GG12926@twins.programming.kicks-ass.net>
	<20130918154939.GZ26785@twins.programming.kicks-ass.net>
	<20130919143241.GB26785@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu, 19 Sep 2013 16:32:41 +0200
Peter Zijlstra <peterz@infradead.org> wrote:


> +extern void __get_online_cpus(void);
> +
> +static inline void get_online_cpus(void)
> +{
> +	might_sleep();
> +
> +	preempt_disable();
> +	if (likely(!__cpuhp_writer || __cpuhp_writer == current))
> +		this_cpu_inc(__cpuhp_refcount);
> +	else
> +		__get_online_cpus();
> +	preempt_enable();
> +}


This isn't much different than srcu_read_lock(). What about doing
something like this:

static inline void get_online_cpus(void)
{
	might_sleep();

	srcu_read_lock(&cpuhp_srcu);
	if (unlikely(__cpuhp_writer || __cpuhp_writer != current)) {
		srcu_read_unlock(&cpuhp_srcu);
		__get_online_cpus();
		current->online_cpus_held++;
	}
}

static inline void put_online_cpus(void)
{
	if (unlikely(current->online_cpus_held)) {
		current->online_cpus_held--;
		__put_online_cpus();
		return;
	}

	srcu_read_unlock(&cpuhp_srcu);
}

Then have the writer simply do:

	__cpuhp_write = current;
	synchronize_srcu(&cpuhp_srcu);

	<grab the mutex here>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
