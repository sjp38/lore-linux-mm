Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id A2D0F6B0034
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:23:57 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so6154768pdj.8
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 08:23:57 -0700 (PDT)
Date: Wed, 25 Sep 2013 17:16:42 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130925151642.GA13244@redhat.com>
References: <20130918154939.GZ26785@twins.programming.kicks-ass.net> <20130919143241.GB26785@twins.programming.kicks-ass.net> <20130923175052.GA20991@redhat.com> <20130924123821.GT12926@twins.programming.kicks-ass.net> <20130924160359.GA2739@redhat.com> <20130924124341.64d57912@gandalf.local.home> <20130924170631.GB5059@redhat.com> <20130924174717.GH9093@linux.vnet.ibm.com> <20130924180005.GA7148@redhat.com> <20130924203512.GS9326@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130924203512.GS9326@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Steven Rostedt <rostedt@goodmis.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On 09/24, Peter Zijlstra wrote:
>
> On Tue, Sep 24, 2013 at 08:00:05PM +0200, Oleg Nesterov wrote:
> >
> > Yes, we need to ensure gcc doesn't reorder this code so that
> > do_something() comes before get_online_cpus(). But it can't? At least
> > it should check current->cpuhp_ref != 0 first? And if it is non-zero
> > we do not really care, we are already in the critical section and
> > this ->cpuhp_ref has only meaning in put_online_cpus().
> >
> > Confused...
>
>
> So the reason I put it in was because of the inline; it could possibly
> make it do:

[...snip...]

> In which case the recursive fast path doesn't have a barrier() between
> taking the ref and starting do_something().

Yes, but my point was, this can only happen in recursive fast path.
And in this case (I think) we do not care, we are already in the critical
section.

current->cpuhp_ref doesn't matter at all until we call put_online_cpus().

Suppose that gcc knows for sure that current->cpuhp_ref != 0. Then I
think, for example,

	get_online_cpus();
	do_something();
	put_online_cpus();

converted to

	do_something();
	current->cpuhp_ref++;
	current->cpuhp_ref--;

is fine. do_something() should not depend on ->cpuhp_ref.

OK, please forget. I guess I will never understand this ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
