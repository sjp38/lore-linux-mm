Date: Fri, 11 May 2007 17:56:21 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] convert mmap_sem to a scalable rw_mutex
Message-ID: <20070511155621.GA13150@elte.hu>
References: <20070511131541.992688403@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070511131541.992688403@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> I was toying with a scalable rw_mutex and found that it gives ~10% 
> reduction in system time on ebizzy runs (without the MADV_FREE patch).
> 
> 2-way x86_64 pentium D box:
> 
> 2.6.21
> 
> /usr/bin/time ./ebizzy -m -P
> 59.49user 137.74system 1:49.22elapsed 180%CPU (0avgtext+0avgdata 0maxresident)k
> 0inputs+0outputs (0major+33555877minor)pagefaults 0swaps
> 
> 2.6.21-rw_mutex
> 
> /usr/bin/time ./ebizzy -m -P
> 57.85user 124.30system 1:42.99elapsed 176%CPU (0avgtext+0avgdata 0maxresident)k
> 0inputs+0outputs (0major+33555877minor)pagefaults 0swaps

nice! This 6% runtime reduction on a 2-way box will i suspect get 
exponentially better on systems with more CPUs/cores.

i also like the design, alot: instead of doing a full new lock type 
(with per-arch changes, extra lockdep support, etc. etc) you layered the 
new abstraction ontop of mutexes. This makes this hard locking 
abstraction look really, really simple, while the percpu_counter trick 
makes it scale _perfectly_ for the reader case. Congratulations!

given how nice this looks already, have you considered completely 
replacing rwsems with this? I suspect you could test the correctness of 
that without doing a mass API changeover, by embedding struct rw_mutex 
in struct rwsem and implementing kernel/rwsem.c's API that way. (the 
real patch would just flip it all over to rw-mutexes)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
