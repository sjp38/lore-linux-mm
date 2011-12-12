Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 215746B00B7
	for <linux-mm@kvack.org>; Sun, 11 Dec 2011 23:37:07 -0500 (EST)
Date: Mon, 12 Dec 2011 15:36:57 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: XFS causing stack overflow
Message-ID: <20111212043657.GO14273@dastard>
References: <CAAnfqPAm559m-Bv8LkHARm7iBW5Kfs7NmjTFidmg-idhcOq4sQ@mail.gmail.com>
 <20111209115513.GA19994@infradead.org>
 <20111209221956.GE14273__25752.826271537$1323469420$gmane$org@dastard>
 <m262hop5kc.fsf@firstfloor.org>
 <20111210221345.GG14273@dastard>
 <20111211000036.GH24062@one.firstfloor.org>
 <20111211230511.GH14273@dastard>
 <20111212023130.GI24062@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111212023130.GI24062@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, xfs@oss.sgi.com, "Ryan C. England" <ryan.england@corvidtec.com>

On Mon, Dec 12, 2011 at 03:31:30AM +0100, Andi Kleen wrote:
> > But that happens before do_IRQ is called, so what is the do_IRQ call
> > chain doing on this stack given that we've already supposed to have
> > switched to the interrupt stack before do_IRQ is called?
> 
> Not sure I understand the question.
> 
> The pt_regs are on the original stack (but they are quite small), all the rest 

It's ~180 bytes, so it's not really that small.

> is on the new stack. ISTs are not used for interrupts, only for 
> some special exceptions.

IST = ???

> do_IRQ doesn't switch any stacks on 64bit.

No, but it appears that it's caller does:

/* 0(%rsp): ~(interrupt number) */
        .macro interrupt func
        /* reserve pt_regs for scratch regs and rbp */
        subq $ORIG_RAX-RBP, %rsp
        CFI_ADJUST_CFA_OFFSET ORIG_RAX-RBP
        SAVE_ARGS_IRQ
        call \func
        .endm

and the SAVE_ARGS_IRQ macro switches to the per cpu interrupt stack.
The only caller does this:

common_interrupt:
        XCPT_FRAME
        addq $-0x80,(%rsp)              /* Adjust vector to [-256,-1] range */
        interrupt do_IRQ

So, why do we get this:

Dec  6 20:27:55 localhost kernel: <IRQ>  [<ffffffff81067097>] ?  warn_slowpath_common+0x87/0xc0
Dec  6 20:27:55 localhost kernel: [<ffffffff8106f6da>] ?  __do_softirq+0x11a/0x1d0
Dec  6 20:27:55 localhost kernel: [<ffffffff81067186>] ?  warn_slowpath_fmt+0x46/0x50
Dec  6 20:27:55 localhost kernel: [<ffffffff8100c2cc>] ?  call_softirq+0x1c/0x30
Dec  6 20:27:55 localhost kernel: [<ffffffff8100dfcf>] ?  handle_irq+0x8f/0xa0
Dec  6 20:27:55 localhost kernel: [<ffffffff814e310c>] ? do_IRQ+0x6c/0xf0
Dec  6 20:27:55 localhost kernel: [<ffffffff8100bad3>] ?  ret_from_intr+0x0/0x11
Dec  6 20:27:55 localhost kernel: <EOI>  [<ffffffff8115b80f>] ?  kmem_cache_free+0xbf/0x2b0

at the top of the stack frame? Is the stack unwinder walking back
across the interrupt stack to the previous task stack?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
