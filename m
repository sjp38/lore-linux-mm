Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA17424
	for <linux-mm@kvack.org>; Wed, 29 Jan 2003 02:16:36 -0800 (PST)
Date: Wed, 29 Jan 2003 02:16:57 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Linus rollup
Message-Id: <20030129021657.25713049.akpm@digeo.com>
In-Reply-To: <20030129095949.A24161@flint.arm.linux.org.uk>
References: <20030128220729.1f61edfe.akpm@digeo.com>
	<20030129095949.A24161@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: ak@muc.de, davem@redhat.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Russell King <rmk@arm.linux.org.uk> wrote:
>
> On Tue, Jan 28, 2003 at 10:07:29PM -0800, Andrew Morton wrote:
> > Possible breakage would be in the new frlock-for-xtime_lock code and the
> > get_order() cleanup.
> > 
> > The frlock code is showing nice speedups, but I think the main reason we want
> > this is to fix the problem wherein an application spinning on gettimeofday()
> > can make time stop.
> 
> I'm slightly concerned about this.  With this patch, we generally seem
> to do:
> 
>        do {
>                seq = fr_read_begin(&xtime_lock);
>                *tv = xtime;
>                tv->tv_usec += do_fast_gettimeoffset();
>                tv->tv_usec += lost_ticks;
>        } while (seq != fr_read_end(&xtime_lock));
> 
> This is fine when considering xtime.  However, considering the
> implementation of do_fast_gettimeoffset().  Notice that
> linux/arch/i386/kernel/timers/timer_pit.c:do_offset_pit specifically
> makes the comment:
> 
> 	/* This function must be called with interrupts disabled
> 
> which hasn't been true for some time, and is even less true now that
> local IRQs don't get disabled.  Does this matter... for UP?
> 
> The same is true for other architectures; their gettimeoffset
> implementations need to be audited by the architecture maintainers
> to ensure that they are safe to run with (local) interrupts enabled.

Thanks for spotting that.  Bug.

How about I make all instances of the above be:

        do {
                seq = fr_read_begin_irqsave(&xtime_lock, flags);
                *tv = xtime;
                tv->tv_usec += do_fast_gettimeoffset();
                tv->tv_usec += lost_ticks;
        } while (seq != fr_read_end_irqrestore(&xtime_lock, flags));

?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
