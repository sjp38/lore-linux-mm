Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 385506B0280
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 05:44:52 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e12so9492327oib.5
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 02:44:52 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id o18si1192195ita.0.2016.10.27.02.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 02:44:50 -0700 (PDT)
Date: Thu, 27 Oct 2016 11:44:49 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161027094449.GL3102@twins.programming.kicks-ass.net>
References: <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <20161026203158.GD2699@techsingularity.net>
 <CA+55aFy21NqcYTeLVVz4x4kfQ7A+o4HEv7srone6ppKAjCwn7g@mail.gmail.com>
 <20161026220339.GE2699@techsingularity.net>
 <CA+55aFwgZ6rUL2-KD7A38xEkALJcvk8foT2TBjLrvy8caj7k9w@mail.gmail.com>
 <20161026230726.GF2699@techsingularity.net>
 <20161027080852.GC3568@worktop.programming.kicks-ass.net>
 <20161027090742.GG2699@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161027090742.GG2699@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, Oct 27, 2016 at 10:07:42AM +0100, Mel Gorman wrote:
> > Something like so could work I suppose, but then there's a slight
> > regression in the page_unlock() path, where we now do an unconditional
> > spinlock; iow. we loose the unlocked waitqueue_active() test.
> > 
> 
> I can't convince myself it's worthwhile. At least, I can't see a penalty
> of potentially moving one of the two bits to the high word. It's the
> same cache line and the same op when it matters.

I'm having trouble connecting these here two paragraphs. Or were you
replying to something else?

So the current unlock code does:

  wake_up_page()
    if (waitqueue_active())
      __wake_up() /* takes waitqueue spinlocks here */

While the new one does:

  spin_lock(&q->lock);
  if (waitqueue_active()) {
    __wake_up_common()
  }
  spin_unlock(&q->lock);

Which is an unconditional atomic op (which go for about ~20 cycles each,
when uncontended).


> > +++ b/include/linux/page-flags.h
> > @@ -73,6 +73,14 @@
> >   */
> >  enum pageflags {
> >  	PG_locked,		/* Page is locked. Don't touch. */
> > +#ifdef CONFIG_NUMA
> > +	/*
> > +	 * This bit must end up in the same word as PG_locked (or any other bit
> > +	 * we're waiting on), as per all architectures their bitop
> > +	 * implementations.
> > +	 */
> > +	PG_waiters,		/* The hashed waitqueue has waiters */
> > +#endif
> >  	PG_error,
> >  	PG_referenced,
> >  	PG_uptodate,
> 
> I don't see why it should be NUMA-specific even though with Linus'
> patch, NUMA is a concern. Even then, you still need a 64BIT check
> because 32BIT && NUMA is allowed on a number of architectures.

Oh, I thought we killed 32bit NUMA and didn't check. I can make it
CONFIG_64BIT and be done with it. s/CONFIG_NUMA/CONFIG_64BIT/ on the
patch should do :-)

> Otherwise, nothing jumped out at me but glancing through it looked very
> similar to the previous patch.

Right, all the difference was in the bit being conditional and having a
different name.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
