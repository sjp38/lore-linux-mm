Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7396B0039
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 11:15:42 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so7251947pbc.4
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 08:15:41 -0700 (PDT)
Date: Tue, 1 Oct 2013 17:00:30 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131001150030.GA1801@redhat.com>
References: <20130925184015.GC3657@laptop.programming.kicks-ass.net> <20130925212200.GA7959@linux.vnet.ibm.com> <20130926111042.GS3081@twins.programming.kicks-ass.net> <20130926165840.GA863@redhat.com> <20130926175016.GI3657@laptop.programming.kicks-ass.net> <20130927181532.GA8401@redhat.com> <20130927204116.GJ15690@laptop.programming.kicks-ass.net> <20131001035604.GW19582@linux.vnet.ibm.com> <20131001141429.GA32423@redhat.com> <20131001144537.GC5790@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131001144537.GC5790@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On 10/01, Paul E. McKenney wrote:
>
> On Tue, Oct 01, 2013 at 04:14:29PM +0200, Oleg Nesterov wrote:
> >
> > But please note another email, it seems to me we can simply kill
> > cpuhp_seq and all the barriers in cpuhp_readers_active_check().
>
> If you don't have cpuhp_seq, you need some other way to avoid
> counter overflow.

I don't think so. Overflows (espicially "unsigned") should be fine and
in fact we can't avoid them.

Say, a task does get() on CPU_0 and put() on CPU_1, after that we have

	CTR[0] == 1, CTR[1] = (unsigned)-1

iow, the counter was already overflowed (underflowed). But this is fine,
all we care about is  CTR[0] + CTR[1] == 0, and this is only true because
of another overflow.

But probably you meant another thing,

> Which might be provided by limited number of
> tasks, or, on 64-bit systems, 64-bit counters.

perhaps you meant that max_threads * max_depth can overflow the counter?
I don't think so... but OK, perhaps this counter should be u_long.

But how cpuhp_seq can help?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
