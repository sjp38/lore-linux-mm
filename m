Date: Tue, 9 Nov 2004 18:31:44 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
Message-ID: <20041109203143.GC8414@logos.cnet>
References: <20041109164642.GE7632@logos.cnet> <20041109121945.7f35d104.akpm@osdl.org> <20041109174125.GF7632@logos.cnet> <20041109133343.0b34896d.akpm@osdl.org> <20041109182622.GA8300@logos.cnet> <20041109142257.1d1411e1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041109142257.1d1411e1.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2004 at 02:22:57PM -0800, Andrew Morton wrote:
> Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> >
> > > 
> > > But the patch doesn't have any effect on that, which I can see.
> > 
> > Andrew, it avoids kswapd from sleeping when the machine is OOM.
> 
> I think you mean that it prevents balance_pdget() from falling back to
> kswapd() when the machine is oom, yes?  There are other places where kswapd
> might sleep.

Yes, that is what I meant more precisely.

> > > > No testing has been done, but it is an obvious problem if you read the
> > > > code. 
> > > 
> > > Not really.  The move of the all_unreclaimable test doesn't seem to do
> > > anything, because we'll just skip that zone anyway in the next loop.
> > > 
> > > Maybe you moved the all_unreclaimable test just so that there's an
> > > opportunity to clear all_zones_ok?  I dunno.
> > 
> > Yes, exactly. I moved all_unreclaimable test because then there is 
> > an opportunity to clear all_zones_ok. Otherwise all_zones_ok keeps set
> > even if all_zones are not OK at all!
> 
> OK.
> 
> > > AFAICT, the early clearing of all_zones_ok will have no effect on kswapd
> > > throttling because the total_scanned logic is disabled.
> > 
> > It makes this at the end of balance_pgdat
> > 
> >         if (!all_zones_ok) {
> >                 cond_resched();
> >                 goto loop_again;
> >         }
> > 
> > happen.
> > 
> > > What I think your patch will do is to cause kswapd to do the `goto
> > > loop_again' thing if all zones are unreclaimable.  Which appears to risk
> > > putting kswapd into a busy loop when we're out of memory.
> > 
> > Yes, this is exactly what the patch does. 
> 
> OK.
> 
> > And kswapd has to be into a busy loop when we're out of memory! It has 
> > to be looking for free pages - it should not sleep for god sakes!
> 
> Why?  kswapd's functions are:
> 
> a) To perform scanning when direct-reclaim-capable processes are stuck
>    in disk wait (ie a bit of pipelining for CPU efficiency) and
> 
> b) To keep the free page pools full for interrupt-time allocators.
> 
> If kswapd cannot make forward progress it is quite acceptable to make it
> give up and go back to sleep.  Although it does seem better to keep kswapd
> running (but with throttling) in case there is disk writeout in flight. 

Yes, kswapd has to be "polling" from time to time looking for pages which might 
have become freeable. 

> > Note that it wont cause excessive CPU usage because kswapd will be "polling" 
> > slowly (with priority = DEF_PRIORITY) on the active/inactive lists (shrink_zone).
> > 
> > The cond_resched at the end of balance_pgdat() makes sure no harmful exclusivity
> > of CPU will happen.
> 
> Well it depends on task priorities.  But yeah, when the machine is this
> exhausted for memory we really don't care about CPU consumption.
> 
> > So this way it still does not cause the excessive CPU usage which is avoided by 
> > all_unreclaimable (ie we wont be scanning huge amounts of pages at low priorities)
> > but at the same time avoids kswapd from possibly sleeping, which is IMO
> > very bad.
> > 
> > > So I'm all confused and concerned.  It would help if you were to explain
> > > your thinking more completely... 
> > 
> > I think now you can understand what I'm thinking.
> 
> I do now.  Can we try to avoid the twenty-questions game next time??

I should have put in words what I had in mind in the first place, yes.

Will make sure to avoid it in future occasions.

> > Does it makes sense to you?
> 
> Maybe.  We really shouldn't be sending kswapd into a busy loop if all zones
> are unreclaimable.  Because it could just be that there's some disk I/O in
> flight and we'll find rotated reclaimable pages available once that I/O has
> completed.  (example: all of memory becomes dirty due to a large msync of
> MAP_SHARED memory).  So rather than madly scanning, we should throttle
> kswapd to make it wait for I/O completions.  Via blk_congestion_wait().
> That's what the total_scanned logic is supposed to do.

OK - I see your point - the best thing would be to have the IO completion 
routines (_end_io) asynchronously wake up kswapd.

Back to arguing in favour of my patch - it seemed to me that kswapd could 
go to sleep leaving allocators which can't reclaim pages themselves in a 
bad situation. 

It would have to be waken up by another instance of alloc_pages to then 
execute and start doing its job, while if it was executing already (madly 
scanning as you say), the chance it would find freeable pages quite
earlier.

Note that not only disk IO can cause pages to become freeable. A user
can give up its reference on pagecache page for example (leaving
the page on LRU to be found and freed by kswapd).

So the point was really "do not sleep if you can find freeable pages", 
in another way "its not polling enough".

Testing such modification would also prove if it indeed does what
I think it does, and what are its real effects.

I think I'll start yet another kernel tree "-mt".

Thanks for all your comments! 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
