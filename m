Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 12D7A6B0092
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 11:34:23 -0500 (EST)
Date: Fri, 5 Mar 2010 03:34:18 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 4/4] cpuset,mm: use rwlock to protect task->mempolicy
 and mems_allowed
Message-ID: <20100304163417.GS8653@laptop>
References: <4B8E3F77.6070201@cn.fujitsu.com>
 <20100304033017.GN8653@laptop>
 <1267714704.25158.199.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1267714704.25158.199.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, tglx <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 04, 2010 at 03:58:24PM +0100, Peter Zijlstra wrote:
> On Thu, 2010-03-04 at 14:30 +1100, Nick Piggin wrote:
> > 
> > Thanks for working on this. However, rwlocks are pretty nasty to use
> > when you have short critical sections and hot read-side (they're twice
> > as heavy as even spinlocks in that case). 
> 
> Should we add a checkpatch.pl warning for them? 

Yes I think it could be useful.

Most people agree rwlock is *almost* always the wrong thing to do. Or at
least, they can easily be used wrongly because they seem like a great
idea for read-mostly data.

> 
> There really rarely is a good case for using rwlock_t, for as you say
> they're a pain and often more expensive than a spinlock_t, and if
> possible RCU has the best performance.

Yep. Not to mention they starve writers (and don't FIFO like spinlocks).

Between normal spinlocks, RCU, percpu, and seqlocks, there's not much
room for rwlocks. Even tasklist lock should be RCUable if the effort is
put into it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
