Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] Accelerate dbench
Date: Mon, 6 Aug 2001 19:20:56 +0200
References: <Pine.LNX.4.33L.0108042338130.2526-100000@imladris.rielhome.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0108042338130.2526-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Message-Id: <0108061920560E.00294@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Sunday 05 August 2001 04:39, Rik van Riel wrote:
> On Sun, 5 Aug 2001, Daniel Phillips wrote:
> > -  	SetPageReferenced(page);
> > +	if (PageActive(page))
> > +	  	SetPageReferenced(page);
> > +	else
> > +		activate_page(page);
> >
> > So I'll try it...<time passes>...OK, it doesn't make a lot of
> > difference, results still range from "pretty good" to "really
> > great".  Not really suprising, I have this growing gut feeling
> > that we're not doing that well on the active page aging anyway,
>
> Yes, I have the feeling that exponential down aging wasn't
> such a good idea in combination with the fact that most of
> the access bits are "hidden" in page tables ...

Ignoring the hardware access bits in page_launder has to hurt.  I'm
playing with an idea now to get access to the hardware referenced
bit for swap pages on the inactive queue, needs more research.

> > and that random selection of candidates for trial on the
> > inactive queue would perform almost as well - which might be
> > worth testing.  Anyway, I'm putting this on the back burner for
> > now.  Interesting as it is, it's hardly a burning issue.
>
> Well, we found that doing instant activation gives a huge
> performance increase. That's one important point already ;)

*Note*: only for dbench, a bizarre load I don't fully understand.
For my more realistic make+grep load, this change slows it down as
I would expect.  But yes, it indicates that there may be more big
gains to get from replacement policy once we understand what the
dbench load really is and how to detect that kind of load
automatically.  Or maybe if it just results in a useful
adjustment available from userlond it would be worth the effort.

There is one disturbing possibility I haven't looked into: what if
dbench has a bug?  What if its not really doing all the IO its
supposed to on those really fast runs?

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
