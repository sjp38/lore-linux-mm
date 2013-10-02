Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id CC05F6B006E
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 11:17:54 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so1024301pbc.3
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 08:17:54 -0700 (PDT)
Date: Wed, 2 Oct 2013 17:17:34 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131002151734.GT3081@twins.programming.kicks-ass.net>
References: <7632387.20FXkuCITr@vostro.rjw.lan>
 <524B0233.8070203@linux.vnet.ibm.com>
 <20131001173615.GW3657@laptop.programming.kicks-ass.net>
 <20131001174508.GA17411@redhat.com>
 <20131001175640.GQ15690@laptop.programming.kicks-ass.net>
 <20131001180750.GA18261@redhat.com>
 <20131002090859.GE12926@twins.programming.kicks-ass.net>
 <20131002121356.GA21581@redhat.com>
 <20131002133137.GG28601@twins.programming.kicks-ass.net>
 <20131002140020.GA25256@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131002140020.GA25256@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Viresh Kumar <viresh.kumar@linaro.org>

On Wed, Oct 02, 2013 at 04:00:20PM +0200, Oleg Nesterov wrote:
> And again, even
> 
> 	for (;;) {
> 		percpu_down_write();
> 		percpu_up_write();
> 	}
> 
> should not completely block the readers.

Sure there's a tiny window, but don't forget that a reader will have to
wait for the gp_state cacheline to transfer to shared state and the
per-cpu refcount cachelines to be brought back into exclusive mode and
the above can be aggressive enough that by that time we'll observe
state == blocked again.

So I don't think that in practise a reader will get in.

Also, since the write side is exposed to userspace; you've got an
effective DoS.

So I'll stick to waitcount -- as you can see in the patches I've just
posted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
