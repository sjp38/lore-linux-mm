Date: Thu, 3 Aug 2000 13:40:59 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: RFC: design for new VM
In-Reply-To: <20000803213705.C759@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.10.10008031324490.6528-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Thu, 3 Aug 2000, Ingo Oeser wrote:

> On Thu, Aug 03, 2000 at 11:05:47AM -0700, Linus Torvalds wrote:
> > As far as I can tell, the only advantage of multiple lists compared to the
> > current one is to avoid overhead in walking extra pages, no?
> 
> [...]
> 
> > As far as I can tell, the above is _exactly_ equivalent to having one
> > single list, and multiple "scan-points" on that list. 
> 
> [...]
> 
> 3 keywords:
> 
>    -  reordering of the list breaks _all_ scanpoints

No.

Think about it.

The separate lists are _completely_ independent. That's why they are
separate, after all. So quite provably they do not interact with each
other, no?

So tell me, why would an algorithm that works on a single list, and on
that single lists re-orders only those entries that would be on the
private lists act any differently?

>    -  wraparound inside the scanner breaks ordering or it should
>       store it's starting point globally

No. Read the email again. It uses markers: essentially virtual entries in
the list that simply get ignored by the other markers.

>    -  state transistions _require_ reordering, which will affect
>       all scanners

NO.

All your arguments are wrong.

Think about it _another_ way instead:
 - the "multiple lists" case is provably a sub-case of the "one list,
   scanners only care about their type of entries".
 - the "one list" _allows_ for (but does not require) "mixing metaphors",
   ie a scanner _can_ see and _can_ modify an entry that wouldn't be on
   "it's list".

>    -  scanners can only run exclusive (spinlock()ed) one at a
>       point, if they can ever reorder the list, until the reach
>       their temporally success or wrap point

No. I guess you didn't understand what the "virtual page" anchor was all
about. It's adding an entry to the list that nobody uses (it could be
marked by an explicit flag in page->flags, if you will - it can be easier
thinking about it that way, although it is not required if there are other
heuristics that just make the marker something that other scanners don't
touch. 

It's akin to the head of the list - except a page list doesn't actually
need to have a head at all - _any_ of these virtual pages act as anchors
for the list.

In it's purest case you can think of the list as multiple independent 
lists. But you can also allow the entries to interact if you wish. 

And that's my beef with this: I can see a direct mapping from the multiple
list case to the single list case. Which means that the multiple list case
simply _cannot_ do something that the single-list case couldn't do.

(The reverse is also true: the single list can have the list entries
interact. That's logically equivalent to the case of the multi-list
implementation moving an entry from one list to another)

So a single list is basically equivalent to multi-list, as long as the
decisions to move and re-order entries are equivalent.

> Isn't this really bad for performance? It would imply a lot of
> waiting, but I haven't measured this ;-)

Not waiting. The multi-lists have the advantage of caching the state of a
page, and I see why we may want to go to multi-lists. I do not see why Rik
claims that multi-lists introduce anything _new_. That's my beef. 

> With the multiple list approach we can skip pages easily and
> avoid contention and stuck scanners (waiting for the list_lock to
> become free). 

The multi-list scanners will probably have multiple spinlocks, and that's
nice. But they will also have to move entries from one list to another,
which can be deadlock country etc (think of one CPU that wants to move
from the free list to the in-use list and another CPU that does the
reverse). 

But again, I claim that multi-lists are a CPU optimization, not a
"behaviour" optimization. Yet everybody seems to claim that multi-lists
will help balance the VM better - implying that they have fundamentally
different _behaviour_. Which is not true, as far as I can tell.

Let me re-iterate: I'm not arguing against multi-lists. I'm arguing about
people being apparently dishonest and saying that the multi-lists are
somehow able to do things that the current VM wouldn't be able to do.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
