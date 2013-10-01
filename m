Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED526B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 13:15:39 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so7535401pdj.22
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 10:15:38 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 2 Oct 2013 03:15:34 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id E60172CE8055
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 03:15:28 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r91HFFEY2294130
	for <linux-mm@kvack.org>; Wed, 2 Oct 2013 03:15:17 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r91HFPJ6001087
	for <linux-mm@kvack.org>; Wed, 2 Oct 2013 03:15:26 +1000
Message-ID: <524B0233.8070203@linux.vnet.ibm.com>
Date: Tue, 01 Oct 2013 22:41:15 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
References: <20130925175055.GA25914@redhat.com> <20130928144720.GL15690@laptop.programming.kicks-ass.net> <20130928163104.GA23352@redhat.com> <7632387.20FXkuCITr@vostro.rjw.lan>
In-Reply-To: <7632387.20FXkuCITr@vostro.rjw.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Viresh Kumar <viresh.kumar@linaro.org>

On 10/01/2013 01:41 AM, Rafael J. Wysocki wrote:
> On Saturday, September 28, 2013 06:31:04 PM Oleg Nesterov wrote:
>> On 09/28, Peter Zijlstra wrote:
>>>
>>> On Sat, Sep 28, 2013 at 02:48:59PM +0200, Oleg Nesterov wrote:
>>>
>>>> Please note that this wait_event() adds a problem... it doesn't allow
>>>> to "offload" the final synchronize_sched(). Suppose a 4k cpu machine
>>>> does disable_nonboot_cpus(), we do not want 2 * 4k * synchronize_sched's
>>>> in this case. We can solve this, but this wait_event() complicates
>>>> the problem.
>>>
>>> That seems like a particularly easy fix; something like so?
>>
>> Yes, but...
>>
>>> @@ -586,6 +603,11 @@ int disable_nonboot_cpus(void)
>>>
>>> +	cpu_hotplug_done();
>>> +
>>> +	for_each_cpu(cpu, frozen_cpus)
>>> +		cpu_notify_nofail(CPU_POST_DEAD_FROZEN, (void*)(long)cpu);
>>
>> This changes the protocol, I simply do not know if it is fine in general
>> to do __cpu_down(another_cpu) without CPU_POST_DEAD(previous_cpu). Say,
>> currently it is possible that CPU_DOWN_PREPARE takes some global lock
>> released by CPU_DOWN_FAILED or CPU_POST_DEAD.
>>
>> Hmm. Now that workqueues do not use CPU_POST_DEAD, it has only 2 users,
>> mce_cpu_callback() and cpufreq_cpu_callback() and the 1st one even ignores
>> this notification if FROZEN. So yes, probably this is fine, but needs an
>> ack from cpufreq maintainers (cc'ed), for example to ensure that it is
>> fine to call __cpufreq_remove_dev_prepare() twice without _finish().
> 
> To my eyes it will return -EBUSY when it tries to stop an already stopped
> governor, which will cause the entire chain to fail I guess.
>
> Srivatsa has touched that code most recently, so he should know better, though.
> 

Yes it will return -EBUSY, but unfortunately it gets scarier from that
point onwards. When it gets an -EBUSY, __cpufreq_remove_dev_prepare() aborts
its work mid-way and returns, but doesn't bubble up the error to the CPU-hotplug
core. So the CPU hotplug code will continue to take that CPU down, with
further notifications such as CPU_DEAD, and chaos will ensue.

And we can't exactly "fix" this by simply returning the error code to CPU-hotplug
(since that would mean that suspend/resume would _always_ fail). Perhaps we can
teach cpufreq to ignore the error in this particular case (since the governor has
already been stopped and that's precisely what this function wanted to do as well),
but the problems don't seem to end there.

The other issue is that the CPUs in the policy->cpus mask are removed in the
_dev_finish() stage. So if that stage is post-poned like this, then _dev_prepare()
will get thoroughly confused since it also depends on seeing an updated
policy->cpus mask to decide when to nominate a new policy->cpu etc. (And the
cpu nomination code itself might start ping-ponging between CPUs, since none of
the CPUs would have been removed from the policy->cpus mask).

So, to summarize, this change to CPU hotplug code will break cpufreq (and
suspend/resume) as things stand today, but I don't think these problems are
insurmountable though.. 
 
However, as Oleg said, its definitely worth considering whether this proposed
change in semantics is going to hurt us in the future. CPU_POST_DEAD has certainly
proved to be very useful in certain challenging situations (commit 1aee40ac9c
explains one such example), so IMHO we should be very careful not to undermine
its utility.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
