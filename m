Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A4F1E440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 06:10:40 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g7so53056134pgp.1
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 03:10:40 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r9si4135658plj.563.2017.07.13.03.10.39
        for <linux-mm@kvack.org>;
        Thu, 13 Jul 2017 03:10:39 -0700 (PDT)
Date: Thu, 13 Jul 2017 19:09:53 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170713100953.GI20323@X58A-UD3R>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
 <20170711161232.GB28975@worktop>
 <20170712020053.GB20323@X58A-UD3R>
 <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
 <20170713020745.GG20323@X58A-UD3R>
 <20170713081442.GA439@worktop>
 <20170713085746.GH20323@X58A-UD3R>
 <20170713095052.dssev34f7c43vlok@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170713095052.dssev34f7c43vlok@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Jul 13, 2017 at 11:50:52AM +0200, Peter Zijlstra wrote:
> 	wait_for_completion(&C);
> 	  atomic_inc_return();
> 
> 					mutex_lock(A1);
> 					mutex_unlock(A1);
> 
> 
> 					<IRQ>
> 					  spin_lock(B1);
> 					  spin_unlock(B1);
> 
> 					  ...
> 
> 					  spin_lock(B64);
> 					  spin_unlock(B64);
> 					</IRQ>
> 
> 
> 					mutex_lock(A2);
> 					mutex_unlock(A2);
> 
> 					complete(&C);
> 
> 
> That gives:
> 
> 	xhist[ 0] = A1

We have to rollback here later on irq_exit.

The followings are ones for irq context.

> 	xhist[ 1] = B1
> 	...
> 	xhist[63] = B63
> 
> then we wrap and have:
> 
> 	xhist[0] = B64
> 
> then we rewind to 1 and invalidate to arrive at:
> 

Now, whether xhist[0] has been overwritten or not is important. If yes,
xhist[0] should be NULL, _not_ xhist[1], which is one for irq context so
not interest at all.

> 	xhist[ 0] = B64
> 	xhist[ 1] = NULL   <-- idx

Therefore, it should be,

 	xhist[ 0] = NULL <- invalidate, cannot use it any more
	--- <- on returning back from irq context, start from here
 	xhist[ 1] = B1 <-- obsolete history of irq

> 	xhist[ 2] = B2
> 	...
> 	xhist[63] = B63
> 
> 
> Then we do A2 and get
> 
> 	xhist[ 0] = B64
> 	xhist[ 1] = A2   <-- idx
> 	xhist[ 2] = B2
> 	...
> 	xhist[63] = B63

So invalidating only one is enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
