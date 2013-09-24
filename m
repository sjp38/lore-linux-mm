Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 20AB06B0037
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 12:54:49 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so4833266pbb.0
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 09:54:48 -0700 (PDT)
Date: Tue, 24 Sep 2013 18:54:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130924165437.GR9326@twins.programming.kicks-ass.net>
References: <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130923175052.GA20991@redhat.com>
 <20130924123821.GT12926@twins.programming.kicks-ass.net>
 <20130924160359.GA2739@redhat.com>
 <20130924164900.GG9093@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130924164900.GG9093@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Tue, Sep 24, 2013 at 09:49:00AM -0700, Paul E. McKenney wrote:
> > >  void cpu_hotplug_done(void)
> > >  {
> > > +	/* Signal the writer is done */
> > > +	cpuhp_writer = 0;
> > > +	wake_up_all(&cpuhp_wq);
> > > +
> > > +	/* Wait for any pending readers to be running */
> > > +	cpuhp_writer_wait(!atomic_read(&cpuhp_waitcount));
> > > +	cpuhp_writer_task = NULL;
> > 
> > We also need to ensure that the next reader should see all changes
> > done by the writer, iow this lacks "realease" semantics.
> 
> Good point -- I was expecting wake_up_all() to provide the release
> semantics, but code could be reordered into __wake_up()'s critical
> section, especially in the case where there was nothing to wake
> up, but where there were new readers starting concurrently with
> cpu_hotplug_done().

Doh, indeed. I missed this in Oleg's email, but yes I made that same
assumption about wake_up_all().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
