Received: from funky.monkey.org (smtp@funky.monkey.org [152.160.231.196])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA04144
	for <linux-mm@kvack.org>; Mon, 5 Apr 1999 17:32:02 -0400
Date: Mon, 5 Apr 1999 17:31:43 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.LNX.4.05.9904050033340.779-100000@laser.random>
Message-ID: <Pine.BSF.4.03.9904051658150.25730-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Apr 1999, Andrea Arcangeli wrote:
> >first, i notice you've altered the page hash function and quadrupled the
> 
> The page hash function change is from Stephen (I did it here too because I
> completly agreed with it). The point is that shm entries uses the lower
> bits of the pagemap->offset field.

hmmm.  wouldn't you think that hashing with the low order bits in the
offset would cause two different offsets against the same page to result
in the hash function generating different output?  the performance
difference isn't too bad with Stephen's hash function -- i tried it out
last night, and it's on the order of 1% slower on a 233Mhz K6 for general
lookups.  i didn't try shm (not sure how i would :)

> >kernel compares to one that has just the page hash changes without the
> >rest of your VM modifications? the reason i ask is because i've played
> 
> The reason of that is that it's an obvious improvement. And since it's
> statically allocated (not dynamically allocated at boot in function of the
> memory size) a bit larger default can be desiderable, I can safely alloc
> some more bit of memory (some decade of kbyte) without harming the
> avalilable mm here. Well, as I just said many times I think someday we'll
> need RB-trees instead of fuzzy hash but it's not a big issue right now
> due the so low number of pages available.
> 
> Returning to your question in my tree I enlarged the hashtable to 13 bit.
> This mean that in the best case I'll be able to address in O(1) up to 8192
> pages. Here I have 32752 pages so as worse I'll have 4 pages chained on
> every hash entry. 13 bits of hash-depth will alloc for the hash 32k of
> memory (really not an issue ;).
> 
> In the stock kernel instead the hash size is 2^11 = 2048 so in the worst
> case I would have 16 pages chained in the same hash entry.

unfortunately it doesn't work that way.  i've measured the buffer hash
function in real-world tests, and found that the worst case is
significantly bad (try this: most buckets are unused, while several
buckets out of 32K buckets have hundreds of buffers).  i have a new hash
function that works very well, and even helps inter-run variance and
perceived interactive response.  i'll post more on this soon.

but also the page hash function uses the hash table size as a shift value
when computing the index, so it may combine the interesting bits in a
different (worse) way when you change the hash table size.  i'm planning
to instrument the page hash to see exactly what's going on.

> >that the buffer hash table is orders of magnitude larger, yet hashes about
> >the same number of objects.  can someone provide history on the design of
> >the page hash function?
> 
> I can't help you into this, but looks Ok to me ;). If somebody did the
> math on it I'd like to try understanding it.

IMHO, i'd think if the buffer cache has a large hash table, you'd want the
page cache to have a table as large or larger.  both track roughly the
same number of objects...  and the page cache is probably used more often
than the buffer cache.  i can experiment with this; i've already been
looking at this behavior for a couple of weeks.

a good reason to try this is to get immediate scalability gains in terms
of the number of objects these hash functions can handle before lookup
time becomes unacceptible.

> >also, can you tell what improvement you expect from the additional logic
> >in try_to_free_buffers() ?
> 
> Eh, my shrink_mmap() is is a black magic and it's long to explain what I
> thought ;). Well one of the reasons is that ext2 take used the superblock
> all the time and so when I reach an used buffers I'll put back at the top
> of the lru list since I don't want to go in swap because there are some
> unfreeable superblock that live forever at the end of the pagemap
> lru_list.

i agree that the whole point of the modification is to help the system
choose the best page to get rid of -- swapping a superblock is probably a
bad idea.  :)

someone mentioned putting these on a separate LRU list, or something like
that.  maybe you should try that instead?  i suspect it might be cleaner
logic?

> Note also (you didn't asked about that but I bet you noticed that ;) that
> in my tree I also made every pagemap entry L1 cacheline aliged. I asked to
> people that was complainig about page colouring (and I still don't know
> what is exactly page colouring , I only have a guess but I would like to
> read something about implementation details, pointers???) to try out my
> patch to see if it made differences; but I had no feedback :(. I also
> made the irq_state entry cacheline aligned (when I understood the
> cacheline issue I agreed with it).

if i can, i'd like to separate out the individual modifications and try
them each compared to a stock kernel.  that usually shows exactly which
changes are useful.

if you want to learn more about page coloring, here are some excellent
references:

Hennessy & Patterson, "Computer Architecture: A Quantitative Approach,"
2nd edition, Morgan Kaufman Publishers, 1998.  look in the chapter on CPU
caches (i'd cite the page number here, but my copy is at home).

Lynch, William, "The Interaction of Virtual Memory and Cache Memory,"
Technical Report CSL-TR-93-587, Stanford University Department of
Electrical Engineering and Computer Science, October 1993.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/citi-netscape/

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
