From: Dimitri Sivanich <sivanich@sgi.com>
Message-Id: <200405241539.i4OFddJQ016338@fsgi142.americas.sgi.com>
Subject: Re: Slab cache reap and CPU availability
Date: Mon, 24 May 2004 10:39:39 -0500 (CDT)
In-Reply-To: <20040521191609.6f4a49a7.akpm@osdl.org> from "Andrew Morton" at May 21, 2004 07:16:09 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Dimitri Sivanich <sivanich@sgi.com> wrote:
> >
> > Hi all,
> > 
> > I have a fairly general question about the slab cache reap code.
> > 
> > In running realtime noise tests on the 2.6 kernels (spinning to detect periods
> > of CPU unavailability to RT threads) on an IA/64 Altix system, I have found the
> > cache_reap code to be the source of a number of larger holdoffs (periods of
> > CPU unavailability).  These can last into the 100's of usec on 1300 MHz CPUs.
> > Since this code runs periodically every few seconds as a timer softirq on all
> > CPUs, holdoffs can occur frequently.
> > 
> > Has anyone looked into less interruptive alternatives to running cache_reap
> > this way (for the 2.6 kernel), or maybe looked into potential optimizations
> > to the routine itself?
> > 
> 
> Do you have stack backtraces?  I thought the problem was via the RCU
> softirq callbacks, not via the timer interrupt.  Dipankar spent some time
> looking at the RCU-related problem but solutions are not comfortable.
> 
> What workload is triggering this?
> 

The IA/64 backtrace with all the cruft removed looks as follows:

0xa000000100149ac0 reap_timer_fnc+0x100
0xa0000001000f4d70 run_timer_softirq+0x2d0
0xa0000001000e9440 __do_softirq+0x200
0xa0000001000e94e0 do_softirq+0x80
0xa000000100017f50 ia64_handle_irq+0x190

The system is running mostly AIM7, but I've seen holdoffs > 30 usec with
virtually no load on the system.

Which uncomfortable solutions (which could relate to this case) have been
investigated?


Dimitri Sivanich <sivanich@sgi.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
