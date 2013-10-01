Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 056E66B0039
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 15:08:04 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so7673374pdj.2
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 12:08:04 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 2 Oct 2013 00:37:59 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 636813940058
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 00:37:40 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r91J7s6a48103456
	for <linux-mm@kvack.org>; Wed, 2 Oct 2013 00:37:55 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r91J7t2l031030
	for <linux-mm@kvack.org>; Wed, 2 Oct 2013 00:37:55 +0530
Message-ID: <524B1C94.4020104@linux.vnet.ibm.com>
Date: Wed, 02 Oct 2013 00:33:48 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
References: <20130925175055.GA25914@redhat.com> <20130928144720.GL15690@laptop.programming.kicks-ass.net> <20130928163104.GA23352@redhat.com> <7632387.20FXkuCITr@vostro.rjw.lan> <524B0233.8070203@linux.vnet.ibm.com> <20131001173615.GW3657@laptop.programming.kicks-ass.net> <20131001174508.GA17411@redhat.com> <20131001175640.GQ15690@laptop.programming.kicks-ass.net>
In-Reply-To: <20131001175640.GQ15690@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Viresh Kumar <viresh.kumar@linaro.org>

On 10/01/2013 11:26 PM, Peter Zijlstra wrote:
> On Tue, Oct 01, 2013 at 07:45:08PM +0200, Oleg Nesterov wrote:
>> On 10/01, Peter Zijlstra wrote:
>>>
>>> On Tue, Oct 01, 2013 at 10:41:15PM +0530, Srivatsa S. Bhat wrote:
>>>> However, as Oleg said, its definitely worth considering whether this proposed
>>>> change in semantics is going to hurt us in the future. CPU_POST_DEAD has certainly
>>>> proved to be very useful in certain challenging situations (commit 1aee40ac9c
>>>> explains one such example), so IMHO we should be very careful not to undermine
>>>> its utility.
>>>
>>> Urgh.. crazy things. I've always understood POST_DEAD to mean 'will be
>>> called at some time after the unplug' with no further guarantees. And my
>>> patch preserves that.
>>
>> I tend to agree with Srivatsa... Without a strong reason it would be better
>> to preserve the current logic: "some time after" should not be after the
>> next CPU_DOWN/UP*. But I won't argue too much.
> 
> Nah, I think breaking it is the right thing :-)
> 
>> But note that you do not strictly need this change. Just kill cpuhp_waitcount,
>> then we can change cpu_hotplug_begin/end to use xxx_enter/exit we discuss in
>> another thread, this should likely "join" all synchronize_sched's.
> 
> That would still be 4k * sync_sched() == terribly long.
> 
>> Or split cpu_hotplug_begin() into 2 helpers which handle FAST -> SLOW and
>> SLOW -> BLOCK transitions, then move the first "FAST -> SLOW" handler outside
>> of for_each_online_cpu().
> 
> Right, that's more messy but would work if we cannot teach cpufreq (and
> possibly others) to not rely on state you shouldn't rely on anyway.
> 
> I tihnk the only guarnatee POST_DEAD should have is that it should be
> called before UP_PREPARE of the same cpu ;-) Nothing more, nothing less.
> 

Conceptually, that hints at a totally per-cpu implementation of CPU hotplug,
in which what happens to one CPU doesn't affect the others in the hotplug
path.. and yeah, that sounds very tempting! ;-) but I guess that will
need to be preceded by a massive rework of many of the existing hotplug
callbacks ;-)

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
