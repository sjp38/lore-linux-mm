Date: Tue, 9 Nov 2004 16:26:22 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
Message-ID: <20041109182622.GA8300@logos.cnet>
References: <20041109164642.GE7632@logos.cnet> <20041109121945.7f35d104.akpm@osdl.org> <20041109174125.GF7632@logos.cnet> <20041109133343.0b34896d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041109133343.0b34896d.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2004 at 01:33:43PM -0800, Andrew Morton wrote:
> Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> >
> > On Tue, Nov 09, 2004 at 12:19:45PM -0800, Andrew Morton wrote:
> > > Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> > > >
> > > > 
> > > > Andrew,
> > > > 
> > > > I was wrong last time I read balance_pgdat() when I thought kswapd
> > > > couldnt sleep under page shortage. 
> > > > 
> > > > It can, because all_zones_ok is set to "1" inside the 
> > > > "priority=DEF_PRIORITY; priority >= 0; priority--" loop.
> > > > 
> > > > So this patch sets "all_zones_ok" to zero even if all_unreclaimable 
> > > > is set, avoiding it from sleeping when zones are under page short.
> > > > 
> > > 
> > > Does this solve any observed problem?  What testing was done, and what were
> > > the results??
> > 
> > 
> > The observed problem are the page allocation failures!
> 
> But the patch doesn't have any effect on that, which I can see.

Andrew, it avoids kswapd from sleeping when the machine is OOM.

> > No testing has been done, but it is an obvious problem if you read the
> > code. 
> 
> Not really.  The move of the all_unreclaimable test doesn't seem to do
> anything, because we'll just skip that zone anyway in the next loop.
> 
> Maybe you moved the all_unreclaimable test just so that there's an
> opportunity to clear all_zones_ok?  I dunno.

Yes, exactly. I moved all_unreclaimable test because then there is 
an opportunity to clear all_zones_ok. Otherwise all_zones_ok keeps set
even if all_zones are not OK at all!

> AFAICT, the early clearing of all_zones_ok will have no effect on kswapd
> throttling because the total_scanned logic is disabled.

It makes this at the end of balance_pgdat

        if (!all_zones_ok) {
                cond_resched();
                goto loop_again;
        }

happen.

> What I think your patch will do is to cause kswapd to do the `goto
> loop_again' thing if all zones are unreclaimable.  Which appears to risk
> putting kswapd into a busy loop when we're out of memory.

Yes, this is exactly what the patch does. 

And kswapd has to be into a busy loop when we're out of memory! It has 
to be looking for free pages - it should not sleep for god sakes!

Note that it wont cause excessive CPU usage because kswapd will be "polling" 
slowly (with priority = DEF_PRIORITY) on the active/inactive lists (shrink_zone).

The cond_resched at the end of balance_pgdat() makes sure no harmful exclusivity
of CPU will happen.

So this way it still does not cause the excessive CPU usage which is avoided by 
all_unreclaimable (ie we wont be scanning huge amounts of pages at low priorities)
but at the same time avoids kswapd from possibly sleeping, which is IMO
very bad.

> So I'm all confused and concerned.  It would help if you were to explain
> your thinking more completely... 

I think now you can understand what I'm thinking.

Does it makes sense to you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
