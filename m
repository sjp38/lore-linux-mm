Date: Thu, 3 Aug 2000 15:12:50 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: RFC: design for new VM
In-Reply-To: <20000803235622.D759@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.10.10008031505170.6698-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Thu, 3 Aug 2000, Ingo Oeser wrote:
> 
> I also assumed your markers are nothing but a normal element of
> the list, that is just skipped, but don't cause a wraparound of
> each of the scanners.

Right.

Think of them as invisible.

> What happens, if one scanner decides to remove an element and
> insert it elsewhere (to achieve it's special ordering)?

Nothing, as far as the other scanners are aware, as they won't even look
at that element anyway (assuming they work the same way as a multi-list
scanner would work).

See?

One list is equivalent to multiple lists, assuming the scanners honour the
same logic as a multi-list scanner would (ie ignore entries that they
aren't designed for).

> > Think about it _another_ way instead:
> >  - the "multiple lists" case is provably a sub-case of the "one list,
> >    scanners only care about their type of entries".
> 
> Got this concept (I think).
> 
> >  - the "one list" _allows_ for (but does not require) "mixing metaphors",
> >    ie a scanner _can_ see and _can_ modify an entry that wouldn't be on
> >    "it's list".
> 
> That's what I would like to avoid. I don't like to idea of
> multiple "states" per page. I would like to scan all pages, that
> are *guaranteed* to have a special state and catch their
> transistions. I prefer clean automata design for this.

I would tend to agree with you. It's much easier to think about the
problems when you don't start "mixing" behaviour. 

And getting a more explicit state transition may well be a good thing.

However, considering that right now we do not have that explicit code, I'd
hate to add it and require it to be 100% correct for 2.4.x. See?

And I dislike the mental dishonesty of claiming that multiple lists are
somehow different.

> > And that's my beef with this: I can see a direct mapping from the multiple
> > list case to the single list case. Which means that the multiple list case
> > simply _cannot_ do something that the single-list case couldn't do.
>  
> Agree. There ist just a bit more atomicy between the scanners,
> thats all I think. And of course states are exlusive instead of
> possibly inclusive.

I do like the notion of having stricter rules, and that is a huge bonus
for multi-lists.

But one downside of multi-lists is that we've had problems with them in
the past. fs/buffer.c used to use them even more than it does now, and it
was a breeding ground of bugs. fs/buffer.c got cleaned up, and the current
multi-list stuff is not at all that horrible any more, so multi-lists
aren't necessarily evil.

> > Let me re-iterate: I'm not arguing against multi-lists. I'm arguing about
> > people being apparently dishonest and saying that the multi-lists are
> > somehow able to do things that the current VM wouldn't be able to do.
> 
> Got that.
> 
> Its the features, that multiple lists *lack* , what makes them
> attractive to _my_ eyes.

Oh, I can agree with that. Discipline can be good for you.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
