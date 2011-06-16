Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4545C6B0083
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 03:04:16 -0400 (EDT)
Date: Thu, 16 Jun 2011 09:03:35 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] Re: REGRESSION: Performance regressions from
 switching anon_vma->lock to mutex
Message-ID: <20110616070335.GA7661@elte.hu>
References: <1308097798.17300.142.camel@schen9-DESK>
 <1308134200.15315.32.camel@twins>
 <1308135495.15315.38.camel@twins>
 <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
 <20110615201216.GA4762@elte.hu>
 <35c0ff16-bd58-4b9c-9d9f-d1a4df2ae7b9@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35c0ff16-bd58-4b9c-9d9f-d1a4df2ae7b9@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> Ingo Molnar <mingo@elte.hu> wrote:
> >
> > I have this fix queued up currently:
> >
> >  09223371deac: rcu: Use softirq to address performance regression
> 
> I really don't think that is even close to enough.

Yeah.

> It still does all the callbacks in the threads, and according to 
> Peter, about half the rcu time in the threads remained..

You are right - things that are a few percent on a 24 core machine 
will definitely go exponentially worse on larger boxen. We'll get rid 
of the kthreads entirely.

The funny thing about this workload is that context-switches are 
really a fastpath here and we are using anonymous IRQ-triggered 
softirqs embedded in random task contexts as a workaround for that.

[ I think we'll have to revisit this issue and do it properly:
  quiescent state is mostly defined by context-switches here, so we
  could do the RCU callbacks from the task that turns a CPU
  quiescent, right in the scheduler context-switch path - perhaps
  with an option for SCHED_FIFO tasks to *not* do GC.

  That could possibly be more cache-efficient than softirq execution,
  as we'll process a still-hot pool of callbacks instead of doing
  them only once per timer tick. It will also make the RCU GC
  behavior HZ independent. ]

In any case the proxy kthread model clearly sucked, no argument about 
that.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
