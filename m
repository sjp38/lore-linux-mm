Date: Mon, 24 May 2004 14:53:03 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Slab cache reap and CPU availability
Message-Id: <20040524145303.45c8f8a6.akpm@osdl.org>
In-Reply-To: <200405241539.i4OFddJQ016338@fsgi142.americas.sgi.com>
References: <20040521191609.6f4a49a7.akpm@osdl.org>
	<200405241539.i4OFddJQ016338@fsgi142.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dimitri Sivanich <sivanich@sgi.com> wrote:
>
> > Do you have stack backtraces?  I thought the problem was via the RCU
> > softirq callbacks, not via the timer interrupt.  Dipankar spent some time
> > looking at the RCU-related problem but solutions are not comfortable.
> > 
> > What workload is triggering this?
> > 
> 
> The IA/64 backtrace with all the cruft removed looks as follows:
> 
> 0xa000000100149ac0 reap_timer_fnc+0x100
> 0xa0000001000f4d70 run_timer_softirq+0x2d0
> 0xa0000001000e9440 __do_softirq+0x200
> 0xa0000001000e94e0 do_softirq+0x80
> 0xa000000100017f50 ia64_handle_irq+0x190
> 
> The system is running mostly AIM7, but I've seen holdoffs > 30 usec with
> virtually no load on the system.

They're pretty low latencies you're talking about there.

You should be able to reduce the amount of work in that timer handler by
limiting the size of the per-cpu caches in the slab allocator.  You can do
that by writing a magic incantation to /proc/slabinfo or:

--- 25/mm/slab.c~a	Mon May 24 14:51:32 2004
+++ 25-akpm/mm/slab.c	Mon May 24 14:51:37 2004
@@ -2642,6 +2642,7 @@ static void enable_cpucache (kmem_cache_
 	if (limit > 32)
 		limit = 32;
 #endif
+	limit = 8;
 	err = do_tune_cpucache(cachep, limit, (limit+1)/2, shared);
 	if (err)
 		printk(KERN_ERR "enable_cpucache failed for %s, error %d.\n",

_


> Which uncomfortable solutions (which could relate to this case) have been
> investigated?

That work was focussed on the amount of work which is performed in a single
RCU callback, not in the slab timer handler.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
