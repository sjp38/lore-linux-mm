Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D91496B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 20:45:43 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5H0Hlfw024043
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 20:17:47 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5H0jeYG169770
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 20:45:40 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5H0jcxO017146
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 20:45:40 -0400
Date: Thu, 16 Jun 2011 17:45:37 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [GIT PULL] Re: REGRESSION: Performance regressions from
 switching anon_vma->lock to mutex
Message-ID: <20110617004536.GP2582@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
 <20110615201216.GA4762@elte.hu>
 <35c0ff16-bd58-4b9c-9d9f-d1a4df2ae7b9@email.android.com>
 <20110616070335.GA7661@elte.hu>
 <20110616171644.GK2582@linux.vnet.ibm.com>
 <20110616202550.GA16214@elte.hu>
 <1308262883.2516.71.camel@pasglop>
 <20110616223837.GA18431@elte.hu>
 <4DFA8802.6010300@linux.intel.com>
 <20110616225803.GA28557@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110616225803.GA28557@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <ak@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, Jun 17, 2011 at 12:58:03AM +0200, Ingo Molnar wrote:
> 
> * Andi Kleen <ak@linux.intel.com> wrote:
> 
> > > There's a crazy solution for that: the idle thread could process 
> > > RCU callbacks carefully, as if it was running user-space code.
> > 
> > In Ben's kernel NFS server case the system may not be idle.
> 
> An always-100%-busy NFS server is very unlikely, but even in the 
> hypothetical case a kernel NFS server is really performing system 
> calls from a kernel thread in essence. If it doesn't do it explicitly 
> then its main loop can easily include a "check RCU callbacks" call.

As long as they make sure to call it in a clean environment: no locks
held and so on.  But I am a bit worried about the possibility of someone
forgetting to put one of these where it is needed -- it would work just
fine for most workloads, but could fail only for rare workloads.

That said, invoking RCU core/callback processing from the scheduler
context certainly sounds like an interesting way to speed up grace
periods.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
