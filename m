Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8F96760021B
	for <linux-mm@kvack.org>; Tue, 29 Dec 2009 04:54:54 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id nBT9sl70017171
	for <linux-mm@kvack.org>; Tue, 29 Dec 2009 20:54:47 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBT9oa1H1761338
	for <linux-mm@kvack.org>; Tue, 29 Dec 2009 20:50:37 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBT9skk3032241
	for <linux-mm@kvack.org>; Tue, 29 Dec 2009 20:54:47 +1100
Date: Tue, 29 Dec 2009 15:24:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] asynchronous page fault.
Message-ID: <20091229095441.GP3601@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
 <1261912796.15854.25.camel@laptop>
 <20091228005746.GE3601@balbir.in.ibm.com>
 <1261989173.7135.5.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1261989173.7135.5.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2009-12-28 09:32:53]:

> On Mon, 2009-12-28 at 06:27 +0530, Balbir Singh wrote:
> > * Peter Zijlstra <peterz@infradead.org> [2009-12-27 12:19:56]:
> > 
> > > Your changelog states as much.
> > > 
> > > "Even if RB-tree rotation occurs while we walk tree for look-up, we just
> > > miss vma without oops."
> > > 
> > > However, since this is the case, do we still need the
> > > rcu_assign_pointer() conversion your patch does? All I can see it do is
> > > slow down all RB-tree users, without any gain.
> > 
> > Don't we need the rcu_assign_pointer() on the read side primarily to
> > make sure the pointer is still valid and assignments (writes) are not
> > re-ordered? Are you suggesting that the pointer assignment paths be
> > completely atomic?
> 
> rcu_assign_pointer() is the write side, but if you need a barrier, you
> can make do with a single smp_wmb() after doing the rb-tree op. There is
> no need to add multiple in the tree-ops themselves.
>

Yes, that makes sense.
 
> You cannot make the assignment paths atomic (without locks) that's the
> whole problem.
>

True, but pre-emption can be nasty in some cases. But I am no expert
in the atomicity of operations like assignments across architectures.
I assume all word, long assignments are.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
