Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA7460021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 21:58:56 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id nBS2wggJ030040
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 13:58:42 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBS2saI91163354
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 13:54:36 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBS2wibI001777
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 13:58:44 +1100
Date: Mon, 28 Dec 2009 08:28:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] asynchronous page fault.
Message-ID: <20091228025839.GF3601@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
 <1261912796.15854.25.camel@laptop>
 <20091228005746.GE3601@balbir.in.ibm.com>
 <20091228100514.ec6f9949.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091228100514.ec6f9949.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-12-28 10:05:14]:

> On Mon, 28 Dec 2009 06:27:46 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
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
> > 
> >From following reasons.
>   - What we have to avoid is not to touch unkonwn memory via broken pointer.
>     This is speculative look up and can miss vmas. So, even if tree is broken,
>     there is no problem. Broken pointer which points to places other than rb-tree
>     is problem.

Exactly!

>   - rb-tree's rb_left and rb_right don't points to memory other than
>     rb-tree. (or NULL)  And vmas are not freed/reused while rcu_read_lock().
>     Then, we don't dive into unknown memory.
>   - Then, we can skip rcu_assign_pointer().
>

We can, but the data being on read-side is going to be out-of-date
more than without the use of rcu_assign_pointer(). Do we need variants
like to rcu_rb_next() to avoid overheads for everyone?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
