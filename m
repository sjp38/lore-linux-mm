Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 359276B01F2
	for <linux-mm@kvack.org>; Wed, 12 May 2010 13:48:59 -0400 (EDT)
Date: Wed, 12 May 2010 10:48:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] cpuset,mm: fix no node to alloc memory when
 changing cpuset's mems - fix2
Message-Id: <20100512104817.beeee3b5.akpm@linux-foundation.org>
In-Reply-To: <4BEA6E3D.10503@cn.fujitsu.com>
References: <4BEA56D3.6040705@cn.fujitsu.com>
	<20100512003246.9f0ee03c.akpm@linux-foundation.org>
	<4BEA6E3D.10503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 May 2010 17:00:45 +0800
Miao Xie <miaox@cn.fujitsu.com> wrote:

> on 2010-5-12 12:32, Andrew Morton wrote:
> > On Wed, 12 May 2010 15:20:51 +0800 Miao Xie <miaox@cn.fujitsu.com> wrote:
> > 
> >> @@ -985,6 +984,7 @@ repeat:
> >>  	 * for the read-side.
> >>  	 */
> >>  	while (ACCESS_ONCE(tsk->mems_allowed_change_disable)) {
> >> +		task_unlock(tsk);
> >>  		if (!task_curr(tsk))
> >>  			yield();
> >>  		goto repeat;
> > 
> > Oh, I meant to mention that.  No yield()s, please.  Their duration is
> > highly unpredictable.  Can we do something more deterministic here?
> 
> Maybe we can use wait_for_completion().

That would work.

> > 
> > Did you consider doing all this with locking?  get_mems_allowed() does
> > mutex_lock(current->lock)?
> 
> do you means using a real lock(such as: mutex) to protect mempolicy and mem_allowed?

yes.

> It may cause the performance regression, so I do my best to abstain from using a real
> lock.

Well, the code as-is is pretty exotic with lots of open-coded tricky
barriers - it's best to avoid inventing new primitives if possible. 
For example, there's no lockdep support for this new "lock".

mutex_lock() is pretty quick - basically a simgle atomic op.  How
frequently do these operations occur?

The code you have at present is fairly similar to sequence locks.  I
wonder if there's some way of (ab)using sequence locks for this. 
seqlocks don't have lockdep support either...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
