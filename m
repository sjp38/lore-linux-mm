Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA12934
	for <linux-mm@kvack.org>; Wed, 29 Jan 2003 15:02:02 -0800 (PST)
Date: Wed, 29 Jan 2003 15:12:06 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Linus rollup
Message-Id: <20030129151206.269290ff.akpm@digeo.com>
In-Reply-To: <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
References: <20030128220729.1f61edfe.akpm@digeo.com>
	<20030129095949.A24161@flint.arm.linux.org.uk>
	<20030129.015134.19663914.davem@redhat.com>
	<20030129022617.62800a6e.akpm@digeo.com>
	<1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Hemminger <shemminger@osdl.org>
Cc: davem@redhat.com, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Stephen Hemminger <shemminger@osdl.org> wrote:
>
> On Wed, 2003-01-29 at 02:26, Andrew Morton wrote:
> > "David S. Miller" <davem@redhat.com> wrote:
> > >
> > >    From: Russell King <rmk@arm.linux.org.uk>
> > >    Date: Wed, 29 Jan 2003 09:59:49 +0000
> > >    
> > >    	/* This function must be called with interrupts disabled
> > >    
> > >    which hasn't been true for some time, and is even less true now that
> > >    local IRQs don't get disabled.  Does this matter... for UP?
> > > 
> > > I disable local IRQs during gettimeofday() on sparc.
> > > 
> > > These locks definitely need to be taken with IRQs disabled.
> > > Why isn't x86 doing that?
> > 
> > Darned if I know.  Looks like Andrea's kernel will deadlock if
> > arch/i386/kernel/time.c:timer_interrupt() takes i8253_lock
> > while that cpu is holding the same lock in do_slow_gettimeoffset().
> 
> Rather than disabling interrupts in the i386 do_gettimeofday
> why not just change spin_lock(&i8253_lock) to spin_lock_irqsave
> in timer_pit.c

That's probably a legitimate fix, subject to audit of the other
implementations of ->get_offset().

But that would be a separate patch.  _all_ we are doing here is fixing and
optimising the xtime_lock problems.  We should seek to do that with
"equivalent transformations".

Fine-tuning the ia32 timer implementation is all well and good, but should
not be kerfuddled with kernel-wide xtime_lock rework.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
