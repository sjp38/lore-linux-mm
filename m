Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6C160044A
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 03:39:56 -0500 (EST)
Subject: Re: [RFC PATCH] asynchronous page fault.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091228005746.GE3601@balbir.in.ibm.com>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
	 <1261912796.15854.25.camel@laptop>
	 <20091228005746.GE3601@balbir.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Dec 2009 09:32:53 +0100
Message-ID: <1261989173.7135.5.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-12-28 at 06:27 +0530, Balbir Singh wrote:
> * Peter Zijlstra <peterz@infradead.org> [2009-12-27 12:19:56]:
> 
> > Your changelog states as much.
> > 
> > "Even if RB-tree rotation occurs while we walk tree for look-up, we just
> > miss vma without oops."
> > 
> > However, since this is the case, do we still need the
> > rcu_assign_pointer() conversion your patch does? All I can see it do is
> > slow down all RB-tree users, without any gain.
> 
> Don't we need the rcu_assign_pointer() on the read side primarily to
> make sure the pointer is still valid and assignments (writes) are not
> re-ordered? Are you suggesting that the pointer assignment paths be
> completely atomic?

rcu_assign_pointer() is the write side, but if you need a barrier, you
can make do with a single smp_wmb() after doing the rb-tree op. There is
no need to add multiple in the tree-ops themselves.

You cannot make the assignment paths atomic (without locks) that's the
whole problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
