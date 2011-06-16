Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 097D86B00E9
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 17:01:36 -0400 (EDT)
Received: by vxg38 with SMTP id 38so721808vxg.14
        for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:01:32 -0700 (PDT)
Date: Thu, 16 Jun 2011 23:01:22 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [GIT PULL] Re: REGRESSION: Performance regressions from
 switching anon_vma->lock to mutex
Message-ID: <20110616210119.GD23624@somewhere.redhat.com>
References: <1308097798.17300.142.camel@schen9-DESK>
 <1308134200.15315.32.camel@twins>
 <1308135495.15315.38.camel@twins>
 <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
 <20110615201216.GA4762@elte.hu>
 <35c0ff16-bd58-4b9c-9d9f-d1a4df2ae7b9@email.android.com>
 <20110616070335.GA7661@elte.hu>
 <20110616171644.GK2582@linux.vnet.ibm.com>
 <20110616202550.GA16214@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110616202550.GA16214@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>

On Thu, Jun 16, 2011 at 10:25:50PM +0200, Ingo Molnar wrote:
> 
> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > > The funny thing about this workload is that context-switches are 
> > > really a fastpath here and we are using anonymous IRQ-triggered 
> > > softirqs embedded in random task contexts as a workaround for 
> > > that.
> > 
> > The other thing that the IRQ-triggered softirqs do is to get the 
> > callbacks invoked in cases where a CPU-bound user thread is never 
> > context switching.
> 
> Yeah - but this workload didnt have that.
> 
> > Of course, one alternative might be to set_need_resched() to force 
> > entry into the scheduler as needed.
> 
> No need for that: we can just do the callback not in softirq but in 
> regular syscall context in that case, in the return-to-userspace 
> notifier. (see TIF_USER_RETURN_NOTIFY and the USER_RETURN_NOTIFIER 
> facility)
> 
> Abusing a facility like setting need_resched artificially will 
> generally cause trouble.

If the task enqueued callbacks in the kernel, thus started a new grace period,
it might return to userspace before every CPUs have completed that grace period,
and you need that full completion to happen before invoking the callbacks.

I think you need to keep the tick in such case because you can't count on
the other CPUs to handle that completion as they may be all idle.

So when you resume to userspace and you started a GP, either you find another
CPU to handle the GP completion and callbacks executions, or you keep the tick
until you are done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
