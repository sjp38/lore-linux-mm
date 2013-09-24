Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3F16B0037
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 12:43:47 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so5209550pab.13
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:43:47 -0700 (PDT)
Date: Tue, 24 Sep 2013 12:43:41 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130924124341.64d57912@gandalf.local.home>
In-Reply-To: <20130924160359.GA2739@redhat.com>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
	<1378805550-29949-38-git-send-email-mgorman@suse.de>
	<20130917143003.GA29354@twins.programming.kicks-ass.net>
	<20130917162050.GK22421@suse.de>
	<20130917164505.GG12926@twins.programming.kicks-ass.net>
	<20130918154939.GZ26785@twins.programming.kicks-ass.net>
	<20130919143241.GB26785@twins.programming.kicks-ass.net>
	<20130923175052.GA20991@redhat.com>
	<20130924123821.GT12926@twins.programming.kicks-ass.net>
	<20130924160359.GA2739@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, 24 Sep 2013 18:03:59 +0200
Oleg Nesterov <oleg@redhat.com> wrote:

> On 09/24, Peter Zijlstra wrote:
> >
> > +static inline void get_online_cpus(void)
> > +{
> > +	might_sleep();
> > +
> > +	if (current->cpuhp_ref++) {
> > +		barrier();
> > +		return;
> 
> I don't undestand this barrier()... we are going to return if we already
> hold the lock, do we really need it?

I'm confused too. Unless gcc moves this after the release, but the
release uses preempt_disable() which is its own barrier.

If anything, it requires a comment.

-- Steve

> 
> The same for put_online_cpus().
> 
> > +void __get_online_cpus(void)
> >  {
> > -	if (cpu_hotplug.active_writer == current)
> > +	if (cpuhp_writer_task == current)
> >  		return;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
