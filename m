Date: Mon, 14 Jun 1999 16:28:51 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: process selection
In-Reply-To: <Pine.LNX.4.03.9906142120170.534-100000@mirkwood.nl.linux.org>
Message-ID: <Pine.LNX.3.96.990614153405.4584A-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jun 1999, Rik van Riel wrote:

> On Mon, 14 Jun 1999, Benjamin C.R. LaHaise wrote:
> 
> > I'm starting to think that going back and benchmarking my vm
> > patches against 2.1.47 or 66 might prove useful as they used a
> > physical page scanning with the old LFU technique,
> 
> I don't think this will be worth the effort. Firstly, physical
> scanning is disastrous for effective I/O clustering (once we
> hit swap, disk seek is _far_ more important than CPU time) and
> LFU just isn't as good as LRU.

Physical scanning might be bad for IO clustering as we're doing it right
now, but it provides significantly more graceful performance degredation
under high load because we're not blowing the cache away for every single
attempt to find a page to release.  The old patch I was referring to
cached the vma the page was last mapped into, which meant that the
overhead as compared to what we're doing for the normal privately mapped
case was negligable.  I suppose that once a region is found that's
inactive, one could deal with neighbours to achive reasonable clustering.

> If you want a real improvement, you should port over some of
> the (very nice) FreeBSD algorithms for I/O clustering and
> assorted stuff.

I've started looking at FreeBSD, and boy is it... different.  (Still on a
really steep learning curve, looking for a guide to the internals as it
doesn't feel nearly as readable as Linux code.)  There are a couple of
ideas bouncing about my head in the last little while that might be worth
sharing now: vm_store -- I like the idea of having an object that manages
a cache for an object.  Something like vm_store could be generic enough to
replace both the page cache and buffer cache code which suffers from a
good deal of duplication of hashing code, locking, updating and waiting... 
Towards this end I wrote a light hash template that deals with SMP (it's
made mostly lockless by using a singly linked list for the hash along with
an atomic generation counter).  I stopped fiddling with the page cache
since Ingo's stuff was coming, but now that I can see what it looks like,
it'll be worth poking at again.

One of the things I thought about doing when starting this was to make a
hash bucket for each object, rather than the overall system as is
currently done: it would allow the bucket size to be tuned to the size of
the object, and get rid of the need for having a doubly linked inode list
(as all pages for an inode could now be found by walking the inode's hash
queues).  Another thought was to also have a second bucket for a dirty
object hash to make fsync/fdatasync fast.  Basically, the idea is making a
beast that's just as light as the page-cache, but used for everything
(fs metadata would be a separate store so readahead on the damn indirect
blocks would happen automatically, as would the inode tables and so on).
With that in place, making the buffer_head an io placeholder becomes easy,
and clustering the bh's would be much more effective.

> As for including the sleep time in VMA selection. I think we
> should just give an added 'bonus' if the process to which the
> VMA belongs has been sleeping for a long time. If it's been
> sleeping for a very long time (> 15 minutes) and the VMA is
> not shared, we might even consider swapping the whole thing
> out in one (physically contiguous for easy reading) swoop.

That sounds like a very good idea, and in fact would give us the ability
to truely swap out a process for free. =)  And it's only one extra flag to
the swap code! 

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
