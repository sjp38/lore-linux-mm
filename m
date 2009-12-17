Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 158A06B009A
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 10:03:01 -0500 (EST)
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091217144551.GA6819@linux.vnet.ibm.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091216101107.GA15031@basil.fritz.box>
	 <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091216102806.GC15031@basil.fritz.box>
	 <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com>
	 <1261004224.21028.500.camel@laptop> <20091217084046.GA9804@basil.fritz.box>
	 <1261039534.27920.67.camel@laptop> <20091217085430.GG9804@basil.fritz.box>
	 <20091217144551.GA6819@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Dec 2009 16:02:12 +0100
Message-ID: <1261062132.27920.469.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-12-17 at 06:45 -0800, Paul E. McKenney wrote:
> On Thu, Dec 17, 2009 at 09:54:30AM +0100, Andi Kleen wrote:
> > On Thu, Dec 17, 2009 at 09:45:34AM +0100, Peter Zijlstra wrote:
> > > On Thu, 2009-12-17 at 09:40 +0100, Andi Kleen wrote:
> > > > On Wed, Dec 16, 2009 at 11:57:04PM +0100, Peter Zijlstra wrote:
> > > > > On Wed, 2009-12-16 at 19:31 +0900, KAMEZAWA Hiroyuki wrote:
> > > > > 
> > > > > > The problem of range locking is more than mmap_sem, anyway. I don't think
> > > > > > it's possible easily.
> > > > > 
> > > > > We already have a natural range lock in the form of the split pte lock.
> > > > > 
> > > > > If we make the vma lookup speculative using RCU, we can use the pte lock
> > > > 
> > > > One problem is here that mmap_sem currently contains sleeps
> > > > and RCU doesn't work for blocking operations until a custom
> > > > quiescent period is defined.
> > > 
> > > Right, so one thing we could do is always have preemptible rcu present
> > > in another RCU flavour, like
> > > 
> > > rcu_read_lock_sleep()
> > > rcu_read_unlock_sleep()
> > > call_rcu_sleep()
> > > 
> > > or whatever name that would be, and have PREEMPT_RCU=y only flip the
> > > regular rcu implementation between the sched/sleep one.
> > 
> > That could work yes.
> 
> OK, I have to ask...
> 
> Why not just use the already-existing SRCU in this case?

Because somehow the preemptible RCU implementation seems superior to
SRCU, but sure, when developing all this one can start by simply
mandating PREEMPT_RCU=y, then maybe use SRCU or try to drop the rcu lock
when sleeping.

That mmap_sem lockbreak on wait_page() seems like a sensible idea
anyway, regardless of what we do with the rest of the locking.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
