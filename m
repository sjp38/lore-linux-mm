Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 3B3E76B00D3
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 04:00:37 -0500 (EST)
Date: Mon, 12 Dec 2011 20:00:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: XFS causing stack overflow
Message-ID: <20111212090033.GQ14273@dastard>
References: <CAAnfqPAm559m-Bv8LkHARm7iBW5Kfs7NmjTFidmg-idhcOq4sQ@mail.gmail.com>
 <20111209115513.GA19994@infradead.org>
 <20111209221956.GE14273__25752.826271537$1323469420$gmane$org@dastard>
 <m262hop5kc.fsf@firstfloor.org>
 <20111210221345.GG14273@dastard>
 <20111211000036.GH24062@one.firstfloor.org>
 <20111211230511.GH14273@dastard>
 <20111212023130.GI24062@one.firstfloor.org>
 <20111212043657.GO14273@dastard>
 <20111212051311.GJ24062@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111212051311.GJ24062@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, xfs@oss.sgi.com, "Ryan C. England" <ryan.england@corvidtec.com>

On Mon, Dec 12, 2011 at 06:13:11AM +0100, Andi Kleen wrote:
> > It's ~180 bytes, so it's not really that small.
> 
> Quite small compared to what real code uses. And also fixed
> size.
> 
> > 
> > > is on the new stack. ISTs are not used for interrupts, only for 
> > > some special exceptions.
> > 
> > IST = ???
> 
> That's a hardware mechanism on x86-64 to switch stacks
> (Interrupt Stack Table or somesuch) 
> 
> With ISTs it would have been possible to move the the pt_regs too,
> but the software mechanism is somewhat simpler.
> 
> > at the top of the stack frame? Is the stack unwinder walking back
> > across the interrupt stack to the previous task stack?
> 
> Yes, the unwinder knows about all the extra stacks (interrupt
> and exception stacks) and crosses them as needed.
> 
> BTW I suppose it wouldn't be all that hard to add more stacks and
> switch to them too, similar to what the 32bit do_IRQ does. 
> Perhaps XFS could just allocate its own stack per thread
> (or maybe only if it detects some specific configuration that
> is known to need much stack) 

That's possible, but rather complex, I think.
> It would need to be per thread if you could sleep inside them.

Yes, we'd need to sleep, do IO, possibly operate within a
transaction context, etc, and a workqueue handles all these cases
without having to do anything special. Splitting the stack at a
logical point is probably better, such as this patch:

http://oss.sgi.com/archives/xfs/2011-07/msg00443.html

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
