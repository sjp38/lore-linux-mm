Date: Wed, 29 Jan 2003 09:59:49 +0000
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: Linus rollup
Message-ID: <20030129095949.A24161@flint.arm.linux.org.uk>
References: <20030128220729.1f61edfe.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030128220729.1f61edfe.akpm@digeo.com>; from akpm@digeo.com on Tue, Jan 28, 2003 at 10:07:29PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Andi Kleen <ak@muc.de>, "David S. Miller" <davem@redhat.com>, David Mosberger <davidm@napali.hpl.hp.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 28, 2003 at 10:07:29PM -0800, Andrew Morton wrote:
> Possible breakage would be in the new frlock-for-xtime_lock code and the
> get_order() cleanup.
> 
> The frlock code is showing nice speedups, but I think the main reason we want
> this is to fix the problem wherein an application spinning on gettimeofday()
> can make time stop.

I'm slightly concerned about this.  With this patch, we generally seem
to do:

       do {
               seq = fr_read_begin(&xtime_lock);
               *tv = xtime;
               tv->tv_usec += do_fast_gettimeoffset();
               tv->tv_usec += lost_ticks;
       } while (seq != fr_read_end(&xtime_lock));

This is fine when considering xtime.  However, considering the
implementation of do_fast_gettimeoffset().  Notice that
linux/arch/i386/kernel/timers/timer_pit.c:do_offset_pit specifically
makes the comment:

	/* This function must be called with interrupts disabled

which hasn't been true for some time, and is even less true now that
local IRQs don't get disabled.  Does this matter... for UP?

The same is true for other architectures; their gettimeoffset
implementations need to be audited by the architecture maintainers
to ensure that they are safe to run with (local) interrupts enabled.

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
