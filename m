Date: Thu, 3 Aug 2000 23:56:22 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: RFC: design for new VM
Message-ID: <20000803235622.D759@nightmaster.csn.tu-chemnitz.de>
References: <20000803213705.C759@nightmaster.csn.tu-chemnitz.de> <Pine.LNX.4.10.10008031324490.6528-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10008031324490.6528-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Thu, Aug 03, 2000 at 01:40:59PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, Aug 03, 2000 at 01:40:59PM -0700, Linus Torvalds wrote:
> >    -  state transistions _require_ reordering, which will affect
> >       all scanners
> 
> NO.
> 
> All your arguments are wrong.
 
Hmm, so I think I use wrong assumptions then...

I assumed all lists we talk about are circular and double chained
(either your single list or Riks state lists).

I also assumed your markers are nothing but a normal element of
the list, that is just skipped, but don't cause a wraparound of
each of the scanners.

What happens, if one scanner decides to remove an element and
insert it elsewhere (to achieve it's special ordering)?

Or are all elements only touched but the ordering is only changed
by removing in the middle and appending only to either head or
tail of this list?

> Think about it _another_ way instead:
>  - the "multiple lists" case is provably a sub-case of the "one list,
>    scanners only care about their type of entries".

Got this concept (I think).

>  - the "one list" _allows_ for (but does not require) "mixing metaphors",
>    ie a scanner _can_ see and _can_ modify an entry that wouldn't be on
>    "it's list".

That's what I would like to avoid. I don't like to idea of
multiple "states" per page. I would like to scan all pages, that
are *guaranteed* to have a special state and catch their
transistions. I prefer clean automata design for this.

To get back to my encrypted swap example:

   -  I only have to catch the transistions to "inactive_dirty" for
      encryption (if the page is considered for real swap) and
      mark it "PG_Encrypted".

   -  I only have to catch the transition to "active" and only
      have to check for "PG_Encrypted", decrypt and clear this
      flag.
      
   -  Or I use a new list "encrypted" and do a transistion from
      "encryped" to "active" and "inactive_dirty" to "encrypted"
      including right points in the VM, which would be more like
      adding a layer instead of creating a kludge.
      
I still couldn't figure out, how to do it for our kernels
floating around, since I don't get a clean state transition
diagram :-(

> In it's purest case you can think of the list as multiple independent 
> lists. But you can also allow the entries to interact if you wish. 
 
> And that's my beef with this: I can see a direct mapping from the multiple
> list case to the single list case. Which means that the multiple list case
> simply _cannot_ do something that the single-list case couldn't do.
 
Agree. There ist just a bit more atomicy between the scanners,
thats all I think. And of course states are exlusive instead of
possibly inclusive.

> (The reverse is also true: the single list can have the list entries
> interact. That's logically equivalent to the case of the multi-list
> implementation moving an entry from one list to another)
> 
> So a single list is basically equivalent to multi-list, as long as the
> decisions to move and re-order entries are equivalent.

Agreed.

> Let me re-iterate: I'm not arguing against multi-lists. I'm arguing about
> people being apparently dishonest and saying that the multi-lists are
> somehow able to do things that the current VM wouldn't be able to do.

Got that.

Its the features, that multiple lists *lack* , what makes them
attractive to _my_ eyes. You are the one, that has the last
word, I just want to make sure, you've seen all the implications
and I'm only stupid to assume, you didn't do that ;-)

Regards

Ingo Oeser
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
