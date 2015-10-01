Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 32AC482F7A
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 13:01:01 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so23232363igc.1
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 10:01:01 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id qo8si3095380igb.16.2015.10.01.10.01.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Oct 2015 10:01:00 -0700 (PDT)
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 1 Oct 2015 11:00:59 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 7EFF71FF004C
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 10:49:08 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t91Gxfi18061370
	for <linux-mm@kvack.org>; Thu, 1 Oct 2015 09:59:41 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t91H0tSa031608
	for <linux-mm@kvack.org>; Thu, 1 Oct 2015 11:00:56 -0600
Date: Thu, 1 Oct 2015 10:00:53 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC v2 00/18] kthread: Use kthread worker API more widely
Message-ID: <20151001170053.GH4043@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <20150930050833.GA4412@linux.vnet.ibm.com>
 <20151001155943.GE9603@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151001155943.GE9603@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 01, 2015 at 05:59:43PM +0200, Petr Mladek wrote:
> On Tue 2015-09-29 22:08:33, Paul E. McKenney wrote:
> > On Mon, Sep 21, 2015 at 03:03:41PM +0200, Petr Mladek wrote:
> > > My intention is to make it easier to manipulate kthreads. This RFC tries
> > > to use the kthread worker API. It is based on comments from the
> > > first attempt. See https://lkml.org/lkml/2015/7/28/648 and
> > > the list of changes below.
> > > 
> > > 1st..8th patches: improve the existing kthread worker API
> > > 
> > > 9th, 12th, 17th patches: convert three kthreads into the new API,
> > >      namely: khugepaged, ring buffer benchmark, RCU gp kthreads[*]
> > > 
> > > 10th, 11th patches: fix potential problems in the ring buffer
> > >       benchmark; also sent separately
> > > 
> > > 13th patch: small fix for RCU kthread; also sent separately;
> > >      being tested by Paul
> > > 
> > > 14th..16th patches: preparation steps for the RCU threads
> > >      conversion; they are needed _only_ if we split GP start
> > >      and QS handling into separate works[*]
> > > 
> > > 18th patch: does a possible improvement of the kthread worker API;
> > >      it adds an extra parameter to the create*() functions, so I
> > >      rather put it into this draft
> > >      
> > > 
> > > [*] IMPORTANT: I tried to split RCU GP start and GS state handling
> > >     into separate works this time. But there is a problem with
> > >     a race in rcu_gp_kthread_worker_poke(). It might queue
> > >     the wrong work. It can be detected and fixed by the work
> > >     itself but it is a bit ugly. Alternative solution is to
> > >     do both operations in one work. But then we sleep too much
> > >     in the work which is ugly as well. Any idea is appreciated.
> > 
> > I think that the kernel is trying really hard to tell you that splitting
> > up the RCU grace-period kthreads in this manner is not such a good idea.
> 
> Yup, I guess that it would be better to stay with the approach taken
> in the previous RFC. I mean to start the grace period and handle
> the quiescent state in a single work. See
> https://lkml.org/lkml/2015/7/28/650  It basically keeps the
> functionality. The only difference is that we regularly leave
> the RCU-specific function, so it will be possible to patch it.
> 
> The RCU kthreads are very special because they basically ignore
> freezer and they never stop. They do not show well the advantage
> of any new API. I tried to convert them primary because they were
> so sensitive. I thought that it was good for testing limits
> of the API.

OK, I am all for stress-testing new APIs.  But I don't yet see a reason
to push this RCU kthread stress-test of your new API upstream.  ;-)

And yes, trying to freeze the RCU grace-period kthreads mid-way through
a grace period does not appear to me to be a strategy to win.  I suggest
trying that at the end of a grace period.  Even then, halting grace
periods at pretty much any time risks hanging the system.

> > So what are we really trying to accomplish here?  I am guessing something
> > like the following:
> > 
> > 1.	Get each grace-period kthread to a known safe state within a
> > 	short time of having requested a safe state.  If I recall
> > 	correctly, the point of this is to allow no-downtime kernel
> > 	patches to the functions executed by the grace-period kthreads.
> > 
> > 2.	At the same time, if someone suddenly needs a grace period
> > 	at some point in this process, the grace period kthreads are
> > 	going to have to wake back up and handle the grace period.
> > 	Or do you have some tricky way to guarantee that no one is
> > 	going to need a grace period beyond the time you freeze
> > 	the grace-period kthreads?
> > 
> > 3.	The boost kthreads should not be a big problem because failing
> > 	to boost simply lets the grace period run longer.
> > 
> > 4.	The callback-offload kthreads are likely to be a big problem,
> > 	because in systems configured with them, they need to be running
> > 	to invoke the callbacks, and if the callbacks are not invoked,
> > 	the grace period might just as well have failed to end.
> > 
> > 5.	The per-CPU kthreads are in the same boat as the callback-offload
> > 	kthreads.  One approach is to offline all the CPUs but one, and
> > 	that will park all but the last per-CPU kthread.  But handling
> > 	that last per-CPU kthread would likely be "good clean fun"...
> > 
> > 6.	Other requirements?
> > 
> > One approach would be to simply say that the top-level rcu_gp_kthread()
> > function cannot be patched, and arrange for the grace-period kthreads
> > to park at some point within this function.  Or is there some requirement
> > that I am missing?
> 
> I am a bit confused by the above paragraphs because they mix patching,
> stopping, and parking. Note that we do not need to stop any process
> when live patching.
> 
> I hope that it is more clear after my response in the other mail about
> freezing. Or maybe, I am missing something.
> 
> Anyway, thanks a lot for looking at the patches and feedback.

If the point of these patches was simply to test your API, and if you are
not looking to get them upstream, we are OK.  If you want them upstream,
you need to explain to me why the patches help something.  And also how
the patches avoid breaking things.  I am currently coming up empty-handed
on both counts:  I don't understand how these patches help, and I don't
see how they can possibly be safe.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
