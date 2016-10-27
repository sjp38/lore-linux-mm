Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8CDAA6B028B
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 06:00:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i128so7085909wme.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:00:06 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id q1si7473817wjd.199.2016.10.27.03.00.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 03:00:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 661E298C2A
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 09:59:57 +0000 (UTC)
Date: Thu, 27 Oct 2016 10:59:50 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161027095950.GH2699@techsingularity.net>
References: <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <20161026203158.GD2699@techsingularity.net>
 <CA+55aFy21NqcYTeLVVz4x4kfQ7A+o4HEv7srone6ppKAjCwn7g@mail.gmail.com>
 <20161026220339.GE2699@techsingularity.net>
 <CA+55aFwgZ6rUL2-KD7A38xEkALJcvk8foT2TBjLrvy8caj7k9w@mail.gmail.com>
 <20161026230726.GF2699@techsingularity.net>
 <20161027080852.GC3568@worktop.programming.kicks-ass.net>
 <20161027090742.GG2699@techsingularity.net>
 <20161027094449.GL3102@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161027094449.GL3102@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, Oct 27, 2016 at 11:44:49AM +0200, Peter Zijlstra wrote:
> On Thu, Oct 27, 2016 at 10:07:42AM +0100, Mel Gorman wrote:
> > > Something like so could work I suppose, but then there's a slight
> > > regression in the page_unlock() path, where we now do an unconditional
> > > spinlock; iow. we loose the unlocked waitqueue_active() test.
> > > 
> > 
> > I can't convince myself it's worthwhile. At least, I can't see a penalty
> > of potentially moving one of the two bits to the high word. It's the
> > same cache line and the same op when it matters.
> 
> I'm having trouble connecting these here two paragraphs. Or were you
> replying to something else?
> 
> So the current unlock code does:
> 
>   wake_up_page()
>     if (waitqueue_active())
>       __wake_up() /* takes waitqueue spinlocks here */
> 
> While the new one does:
> 
>   spin_lock(&q->lock);
>   if (waitqueue_active()) {
>     __wake_up_common()
>   }
>   spin_unlock(&q->lock);
> 
> Which is an unconditional atomic op (which go for about ~20 cycles each,
> when uncontended).
> 

Ok, we were thinking about different things but I'm not sure I get your
concern. With your patch, in the uncontended case we check the waiters
bit and if there is no contention, we carry on. In the contended case,
the lock is taken. Given that contention is likely to be due to IO being
completed, I don't think the atomic op on top is going to make that much
of a difference.

About the only hazard I can think of is when unrelated pages hash to the
same queue and so there is an extra op for the "fake contended" case. I
don't think it's worth worrying about given that a false contention and
atomic op might hurt some workload but the common case is avoiding a
lookup.

> > I don't see why it should be NUMA-specific even though with Linus'
> > patch, NUMA is a concern. Even then, you still need a 64BIT check
> > because 32BIT && NUMA is allowed on a number of architectures.
> 
> Oh, I thought we killed 32bit NUMA and didn't check. I can make it
> CONFIG_64BIT and be done with it. s/CONFIG_NUMA/CONFIG_64BIT/ on the
> patch should do :-)
> 

Sounds good.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
