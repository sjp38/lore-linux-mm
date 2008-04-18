Date: Fri, 18 Apr 2008 09:37:32 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.25-mm1: not looking good
Message-ID: <20080418073732.GA22724@elte.hu>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <20080417164034.e406ef53.akpm@linux-foundation.org> <20080417171413.6f8458e4.akpm@linux-foundation.org> <48080FE7.1070400@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48080FE7.1070400@windriver.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Wessel <jason.wessel@windriver.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, penberg@cs.helsinki.fi, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jmorris@namei.org, sds@tycho.nsa.gov
List-ID: <linux-mm.kvack.org>

* Jason Wessel <jason.wessel@windriver.com> wrote:

> > [...] The final initcall is init_kgdbts() and disabling KGDB 
> > prevents the hang.

> That enables verbose logging of exactly what is going on and will show 
> where wheels fall off the cart.  If the kernel is dying silently it 
> means the early exception code has completely failed in some way on 
> the kernel architecture that was selected, and of course the .config 
> is always useful in this case.

incidentally, just today, in overnight testing i triggered a similar 
hang in the KGDB self-test:

  http://redhat.com/~mingo/misc/config-Thu_Apr_17_23_46_36_CEST_2008.bad

to get a similar tree to the one i tested, pick up sched-devel/latest 
from:

   http://people.redhat.com/mingo/sched-devel.git/README 

pick up that failing .config, do 'make oldconfig' and accept all the 
defaults to get a comparable kernel to mine. (kgdb is embedded in 
sched-devel.git.)

the hang was at:

[   12.504057] Calling initcall 0xffffffff80b800c1: init_kgdbts+0x0/0x1b()
[   12.511298] kgdb: Registered I/O driver kgdbts.
[   12.515062] kgdbts:RUN plant and detach test
[   12.520283] kgdbts:RUN sw breakpoint test
[   12.524651] kgdbts:RUN bad memory access test
[   12.529052] kgdbts:RUN singlestep breakpoint test

full log:

  http://redhat.com/~mingo/misc/log-Thu_Apr_17_23_46_36_CEST_2008.bad

note that this was a 64-bit config too - our tests do a perfect mix of 
50% 32-bit and 50% 64-bit kernels. So single-stepping of the kernel 
broke in some circumstances.

find the boot log below. (it also includes all command line parameters) 

This is the first time ever i saw the self-test in KGDB hanging, so it's 
some recent non-KGDB change that provoked it or made it more likely. The 
KGDB self-test runs very frequently in my bootup tests:

[   12.508236] kgdb: Registered I/O driver kgdbts.
[   12.511245] kgdbts:RUN plant and detach test
[   12.517418] kgdbts:RUN sw breakpoint test
[   12.521056] kgdbts:RUN bad memory access test
[   12.525515] kgdbts:RUN singlestep breakpoint test
[   12.531483] kgdbts:RUN hw breakpoint test
[   12.536142] kgdbts:RUN hw write breakpoint test
[   12.541007] kgdbts:RUN access write breakpoint test
[   12.546223] kgdbts:RUN do_fork for 100 breakpoints

so the latest kgdb-light tree literally survived thousands of such tests 
since it was changed last.

unfortunately, the condition was not reproducible - i booted it once 
more and then it came up just fine - using the same bzImage.

there's no recent change in x86.git related to the TF flag that i could 
think of to cause something like this. I checked changes to traps_64.c 
and entry_64.S, and nothing suspicious.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
