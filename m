Date: Tue, 9 Nov 2004 14:22:57 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
Message-Id: <20041109142257.1d1411e1.akpm@osdl.org>
In-Reply-To: <20041109182622.GA8300@logos.cnet>
References: <20041109164642.GE7632@logos.cnet>
	<20041109121945.7f35d104.akpm@osdl.org>
	<20041109174125.GF7632@logos.cnet>
	<20041109133343.0b34896d.akpm@osdl.org>
	<20041109182622.GA8300@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> > 
> > But the patch doesn't have any effect on that, which I can see.
> 
> Andrew, it avoids kswapd from sleeping when the machine is OOM.

I think you mean that it prevents balance_pdget() from falling back to
kswapd() when the machine is oom, yes?  There are other places where kswapd
might sleep.


> > > No testing has been done, but it is an obvious problem if you read the
> > > code. 
> > 
> > Not really.  The move of the all_unreclaimable test doesn't seem to do
> > anything, because we'll just skip that zone anyway in the next loop.
> > 
> > Maybe you moved the all_unreclaimable test just so that there's an
> > opportunity to clear all_zones_ok?  I dunno.
> 
> Yes, exactly. I moved all_unreclaimable test because then there is 
> an opportunity to clear all_zones_ok. Otherwise all_zones_ok keeps set
> even if all_zones are not OK at all!

OK.

> > AFAICT, the early clearing of all_zones_ok will have no effect on kswapd
> > throttling because the total_scanned logic is disabled.
> 
> It makes this at the end of balance_pgdat
> 
>         if (!all_zones_ok) {
>                 cond_resched();
>                 goto loop_again;
>         }
> 
> happen.
> 
> > What I think your patch will do is to cause kswapd to do the `goto
> > loop_again' thing if all zones are unreclaimable.  Which appears to risk
> > putting kswapd into a busy loop when we're out of memory.
> 
> Yes, this is exactly what the patch does. 

OK.

> And kswapd has to be into a busy loop when we're out of memory! It has 
> to be looking for free pages - it should not sleep for god sakes!

Why?  kswapd's functions are:

a) To perform scanning when direct-reclaim-capable processes are stuck
   in disk wait (ie a bit of pipelining for CPU efficiency) and

b) To keep the free page pools full for interrupt-time allocators.

If kswapd cannot make forward progress it is quite acceptable to make it
give up and go back to sleep.  Although it does seem better to keep kswapd
running (but with throttling) in case there is disk writeout in flight.

> Note that it wont cause excessive CPU usage because kswapd will be "polling" 
> slowly (with priority = DEF_PRIORITY) on the active/inactive lists (shrink_zone).
> 
> The cond_resched at the end of balance_pgdat() makes sure no harmful exclusivity
> of CPU will happen.

Well it depends on task priorities.  But yeah, when the machine is this
exhausted for memory we really don't care about CPU consumption.

> So this way it still does not cause the excessive CPU usage which is avoided by 
> all_unreclaimable (ie we wont be scanning huge amounts of pages at low priorities)
> but at the same time avoids kswapd from possibly sleeping, which is IMO
> very bad.
> 
> > So I'm all confused and concerned.  It would help if you were to explain
> > your thinking more completely... 
> 
> I think now you can understand what I'm thinking.

I do now.  Can we try to avoid the twenty-questions game next time??

> Does it makes sense to you?

Maybe.  We really shouldn't be sending kswapd into a busy loop if all zones
are unreclaimable.  Because it could just be that there's some disk I/O in
flight and we'll find rotated reclaimable pages available once that I/O has
completed.  (example: all of memory becomes dirty due to a large msync of
MAP_SHARED memory).  So rather than madly scanning, we should throttle
kswapd to make it wait for I/O completions.  Via blk_congestion_wait(). 
That's what the total_scanned logic is supposed to do.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
