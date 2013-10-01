Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6017A6B0036
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 14:19:19 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so7609988pdj.32
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 11:19:19 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 1 Oct 2013 23:49:06 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 219B3394004D
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 23:48:47 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r91ILVPF34472144
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 23:51:31 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r91IJ1oE029340
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 23:49:02 +0530
Message-ID: <524B111F.9060003@linux.vnet.ibm.com>
Date: Tue, 01 Oct 2013 23:44:55 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
References: <20130925175055.GA25914@redhat.com> <20130928144720.GL15690@laptop.programming.kicks-ass.net> <20130928163104.GA23352@redhat.com> <7632387.20FXkuCITr@vostro.rjw.lan> <524B0233.8070203@linux.vnet.ibm.com> <20131001173615.GW3657@laptop.programming.kicks-ass.net>
In-Reply-To: <20131001173615.GW3657@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Viresh Kumar <viresh.kumar@linaro.org>

On 10/01/2013 11:06 PM, Peter Zijlstra wrote:
> On Tue, Oct 01, 2013 at 10:41:15PM +0530, Srivatsa S. Bhat wrote:
>> However, as Oleg said, its definitely worth considering whether this proposed
>> change in semantics is going to hurt us in the future. CPU_POST_DEAD has certainly
>> proved to be very useful in certain challenging situations (commit 1aee40ac9c
>> explains one such example), so IMHO we should be very careful not to undermine
>> its utility.
> 
> Urgh.. crazy things. I've always understood POST_DEAD to mean 'will be
> called at some time after the unplug' with no further guarantees. And my
> patch preserves that.
> 
> Its not at all clear to me why cpufreq needs more; 1aee40ac9c certainly
> doesn't explain it.
>

Sorry if I was unclear - I didn't mean to say that cpufreq needs more guarantees
than that. I was just saying that the cpufreq code would need certain additional
changes/restructuring to accommodate the change in the semantics brought about
by this patch. IOW, it won't work as it is, but it can certainly be fixed.

My other point (unrelated to cpufreq) was this: POST_DEAD of course means
that it will be called after unplug, with hotplug lock dropped. But it also
provides the guarantee (in the existing code), that a *new* hotplug operation
won't start until the POST_DEAD stage is also completed. This patch doesn't seem
to honor that part. The concern I have is in cases like those mentioned by
Oleg - say you take a lock at DOWN_PREPARE and want to drop it at POST_DEAD;
or some other requirement that makes it important to finish a full hotplug cycle
before moving on to the next one. I don't really have such a requirement in mind
at present, but I was just trying to think what we would be losing with this
change...

But to reiterate, I believe cpufreq can be reworked so that it doesn't depend
on things such as the above. But I wonder if dropping that latter guarantee
is going to be OK, going forward.

Regards,
Srivatsa S. Bhat
 
> What's wrong with leaving a cleanup handle in percpu storage and
> effectively doing:
> 
> struct cpu_destroy {
> 	void (*destroy)(void *);
> 	void *args;
> };
> 
> DEFINE_PER_CPU(struct cpu_destroy, cpu_destroy);
> 
> 	POST_DEAD:
> 	{
> 		struct cpu_destroy x = per_cpu(cpu_destroy, cpu);
> 		if (x.destroy)
> 			x.destroy(x.arg);
> 	}
> 
> POST_DEAD cannot fail; so CPU_DEAD/CPU_DOWN_PREPARE can simply assume it
> will succeed; it has to.
> 
> The cpufreq situation simply doesn't make any kind of sense to me.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
