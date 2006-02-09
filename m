Received: by uproxy.gmail.com with SMTP id m3so59076uge
        for <linux-mm@kvack.org>; Wed, 08 Feb 2006 21:19:54 -0800 (PST)
Message-ID: <aec7e5c30602082119v4127aa92ga3c9d9ba6dee0378@mail.gmail.com>
Date: Thu, 9 Feb 2006 14:19:51 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [RFC] Removing page->flags
In-Reply-To: <43EAC2CE.2010108@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <1139381183.22509.186.camel@localhost>
	 <43E9DBE8.8020900@yahoo.com.au>
	 <aec7e5c30602081835s8870713qa40a6cf88431cad1@mail.gmail.com>
	 <43EAC2CE.2010108@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>
List-ID: <linux-mm.kvack.org>

On 2/9/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Magnus Damm wrote:
> > On 2/8/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> >>There are a large number of paths which access essentially random struct
> >>pages (any memory allocation / deallocation, many pagecache operations).
> >>Your proposal basically guarantees at least an extra cache miss on such
> >>paths. On most modern machines the struct page should be less than or
> >>equal to a cacheline I think.
> >
> >
> > And this extra cache miss comes from accessing the flags in a
> > different cache line than the rest of the struct page, right? OTOH,
>
> Yes
>
> > maybe it is more likely that a certain struct page is in the cache if
> > struct page would become smaller.
> >
>
> In some very select cases, yes. Most of the time I'd say it would
> be more likely that you'll actually have to take two cache misses
> (basic operations like page allocation and freeing touch flags).

Yes, that makes sense.

> >>Also, would you mind explaining how you'd allow non-atomic access to
> >>bits which are already protected somewhere else? Without adding extra
> >>cache misses for each different type of bit that is manipulated? Which
> >>bits do you have in mind, exactly?
> >
> >
> > I'm thinking about PG_lru and PG_active. PG_lru is always modified
> > under zone->lru_lock, and the same goes for PG_active (except in
> > shrink_list(), grr). But as you say above, breaking out the page flags
> > may result in an extra cache miss...
> >
>
> Also, it will still be difficult to enable non-atomic operations on
> them while still keeping overhead to just a single cache miss:
>
> If your flags bits are arranged as an array of flag words, eg
> | page 0 flags | page 1 flags | page 2 flags | ... then obviously
> you can't use non atomic operations.
>
> Otherwise if they are arranged as bits
>
> | PG_lru bits for pages 0..n | PG_active bits | PG_locked bits |
>
> Then you take 3 extra cache misses when locking the page, then
> looking at PG_lru and PG_active.

So, if the optimization is to allow non-atomic operations, then a
better way would be to arrange the flags like this:

| page 0 atomic flags | page 1 atomic flags | ....

together with

| page 0 non-atomic flags | page 1 non-atomic flags | ...

But introducing a second page->flags is out of the question, and
breaking out flags and placing a pointer to them in the node data
structure will introduce more cache misses. So it is probably not
worth it.

> > Also, I think it would be interesting to break out the page
> > replacement policy code and make it pluggable. Different page
> > replacement algorithms need different flags/information associated
> > with each page, so moving the flags from struct page was my way of
> > solving that. Page replacement flags would in that case be stored
> > somewhere else than the rest of the flags.
> >
>
> It seems pretty unlikely that we'll get a pluggable replacement
> policy in mainline any time soon though.

So, do you think it is more likely that a ClockPro implementation will
be accepted then? Or is Linux "doomed" to LRU forever?

> >>If we accept that type A bits are a good idea, then removing just type B
> >>is no point. Sometimes the more complex memory layouts will require more
> >>than just arithmetic (ie. memory loads) so I doubt that is worthwhile
> >>either.
> >
> >
> > Yes, removing type B bits only is no point. But I wonder how the
> > performance would be affected by using the "parent" struct page
> > instead of type B bits.
> >
>
> An essentially random memory access is going to be worth hundreds or
> thousands of integer ops though, and you'd increase cache footprint
> of 'struct page' operations by 50-100% on most architectures.

Yeah, that sounds like a bad idea. =)

> I don't see the problem with type B bits in flags?

There are no problems, especially since we already have the bits available in
page->flags.

Thanks for the comments!

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
