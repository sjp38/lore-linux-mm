Date: Sat, 17 May 2003 19:29:42 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <20030517172942.GS1429@dualathlon.random>
References: <20030515004915.GR1429@dualathlon.random> <20030515013245.58bcaf8f.akpm@digeo.com> <20030515085519.GV1429@dualathlon.random> <20030515022000.0eb9db29.akpm@digeo.com> <20030515094041.GA1429@dualathlon.random> <1053016706.2693.10.camel@ibm-c.pdx.osdl.net> <20030515191921.GJ1429@dualathlon.random> <1053036250.2696.33.camel@ibm-c.pdx.osdl.net> <20030515231714.GL1429@dualathlon.random> <1053131245.2690.78.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1053131245.2690.78.camel@ibm-c.pdx.osdl.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel McNeil <daniel@osdl.org>
Cc: Andrew Morton <akpm@digeo.com>, dmccr@us.ibm.com, mika.penttila@kolumbus.fi, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 16, 2003 at 05:27:25PM -0700, Daniel McNeil wrote:
> On Thu, 2003-05-15 at 16:17, Andrea Arcangeli wrote:
> 
> > no, the spin_lock only acts as a barrier in one way, not both ways, so
> > an smp_something is still needed.
> > 
> 
> Can you explain this more?  On a x86, isn't a spin_lock a lock; dec
> instruction and the rmb() a lock; addl.  I thought x86 instructions
> with lock prefix provided a memory barrier.

spin_lock yes on x86, but spin_unlock isn't a two way barrier even on
x86. Other archs like ia64 have special ways to declare the direction of
the barrier so they can do it for spin_lock too, not only for
spin_unlock like on the x86.

In short stuff outside the critical section can anways enter inside
unless a full mb() is executed either before or after the
spin_lock/spin_unlock. Never rely on a single spin_lock/spin_unlock to be a mb().

In short:

	spin_lock
	spin_unlock

is a mb().

But:

	spin_unlock
	spin_lock

is not an mb (and the above is what we have in our code, and this is why
I had to add the mb(), of course we just agreed it can be reduced to
smp_rmb()).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
