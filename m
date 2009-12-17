Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1D54D6B0078
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 03:46:19 -0500 (EST)
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091217084046.GA9804@basil.fritz.box>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091216101107.GA15031@basil.fritz.box>
	 <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091216102806.GC15031@basil.fritz.box>
	 <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com>
	 <1261004224.21028.500.camel@laptop> <20091217084046.GA9804@basil.fritz.box>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Dec 2009 09:45:34 +0100
Message-ID: <1261039534.27920.67.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-12-17 at 09:40 +0100, Andi Kleen wrote:
> On Wed, Dec 16, 2009 at 11:57:04PM +0100, Peter Zijlstra wrote:
> > On Wed, 2009-12-16 at 19:31 +0900, KAMEZAWA Hiroyuki wrote:
> > 
> > > The problem of range locking is more than mmap_sem, anyway. I don't think
> > > it's possible easily.
> > 
> > We already have a natural range lock in the form of the split pte lock.
> > 
> > If we make the vma lookup speculative using RCU, we can use the pte lock
> 
> One problem is here that mmap_sem currently contains sleeps
> and RCU doesn't work for blocking operations until a custom
> quiescent period is defined.

Right, so one thing we could do is always have preemptible rcu present
in another RCU flavour, like

rcu_read_lock_sleep()
rcu_read_unlock_sleep()
call_rcu_sleep()

or whatever name that would be, and have PREEMPT_RCU=y only flip the
regular rcu implementation between the sched/sleep one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
