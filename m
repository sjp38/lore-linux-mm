Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0901D6B0039
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 13:36:30 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so7389441pbc.25
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 10:36:30 -0700 (PDT)
Date: Tue, 1 Oct 2013 19:36:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131001173615.GW3657@laptop.programming.kicks-ass.net>
References: <20130925175055.GA25914@redhat.com>
 <20130928144720.GL15690@laptop.programming.kicks-ass.net>
 <20130928163104.GA23352@redhat.com>
 <7632387.20FXkuCITr@vostro.rjw.lan>
 <524B0233.8070203@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524B0233.8070203@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Viresh Kumar <viresh.kumar@linaro.org>

On Tue, Oct 01, 2013 at 10:41:15PM +0530, Srivatsa S. Bhat wrote:
> However, as Oleg said, its definitely worth considering whether this proposed
> change in semantics is going to hurt us in the future. CPU_POST_DEAD has certainly
> proved to be very useful in certain challenging situations (commit 1aee40ac9c
> explains one such example), so IMHO we should be very careful not to undermine
> its utility.

Urgh.. crazy things. I've always understood POST_DEAD to mean 'will be
called at some time after the unplug' with no further guarantees. And my
patch preserves that.

Its not at all clear to me why cpufreq needs more; 1aee40ac9c certainly
doesn't explain it.

What's wrong with leaving a cleanup handle in percpu storage and
effectively doing:

struct cpu_destroy {
	void (*destroy)(void *);
	void *args;
};

DEFINE_PER_CPU(struct cpu_destroy, cpu_destroy);

	POST_DEAD:
	{
		struct cpu_destroy x = per_cpu(cpu_destroy, cpu);
		if (x.destroy)
			x.destroy(x.arg);
	}

POST_DEAD cannot fail; so CPU_DEAD/CPU_DOWN_PREPARE can simply assume it
will succeed; it has to.

The cpufreq situation simply doesn't make any kind of sense to me.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
