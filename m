From: Dimitri Sivanich <sivanich@sgi.com>
Message-Id: <200406012140.i51LeGjV043356@fsgi142.americas.sgi.com>
Subject: Re: Slab cache reap and CPU availability
Date: Tue, 1 Jun 2004 16:40:16 -0500 (CDT)
In-Reply-To: <20040524145303.45c8f8a6.akpm@osdl.org> from "Andrew Morton" at May 24, 2004 02:53:03 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Dimitri Sivanich <sivanich@sgi.com> wrote:
> >
> > The IA/64 backtrace with all the cruft removed looks as follows:
> > 
> > 0xa000000100149ac0 reap_timer_fnc+0x100
> > 0xa0000001000f4d70 run_timer_softirq+0x2d0
> > 0xa0000001000e9440 __do_softirq+0x200
> > 0xa0000001000e94e0 do_softirq+0x80
> > 0xa000000100017f50 ia64_handle_irq+0x190
> > 
> > The system is running mostly AIM7, but I've seen holdoffs > 30 usec with
> > virtually no load on the system.
> 
> They're pretty low latencies you're talking about there.
> 
> You should be able to reduce the amount of work in that timer handler by
> limiting the size of the per-cpu caches in the slab allocator.  You can do
> that by writing a magic incantation to /proc/slabinfo or:
> 
> --- 25/mm/slab.c~a	Mon May 24 14:51:32 2004
> +++ 25-akpm/mm/slab.c	Mon May 24 14:51:37 2004
> @@ -2642,6 +2642,7 @@ static void enable_cpucache (kmem_cache_
>  	if (limit > 32)
>  		limit = 32;
>  #endif
> +	limit = 8;

I tried several values for this limit, but these had little effect.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
