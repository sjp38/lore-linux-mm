Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA14255
	for <linux-mm@kvack.org>; Thu, 21 Jan 1999 15:41:29 -0500
Date: Thu, 21 Jan 1999 20:32:32 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: VM20 behavior on a 486DX/66Mhz with 16mb of RAM
In-Reply-To: <199901211447.OAA01170@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990121200340.1387C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: John Alvord <jalvo@cloud9.net>, Nimrod Zimerman <zimerman@deskmail.com>, Linux Kernel mailing list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 1999, Stephen C. Tweedie wrote:

> No.  The algorithm should react to the current *load*, not to what it
> thinks the ideal parameters should be.  There are specific things you

Obviously when the system has a lot of freeable memory in fly there are
not constraints. When instead the system is very low on memory you have to
choose what to do.

Two choices:

1. You want to give the most of available memory to the process that is
   trashing the VM, in this case you left the balance percentage of
   freeable pages low.

2. You leave the number of freeable pages more high, this way other
   iteractive processes will run smoothly even if with the trashing proggy
   in background. 

This percentage of freeable page balance you want at your time can't be
known by the algorithm. 5% of freeable pages work always well here but you
may want 30% of freeable pages (but note too much pages in the swap cache
are a real risk for the __ugly__ O(n) seach we handle right now in the
cache so rising too much the freeable percentage could theorically
decrease performances (and obviously increase the swap space
really available for not in ram pages)).

> can do to the VM which completely invalidate any single set of cache
> figures.  For example, you can create large ramdisks which effectively
> lock large amounts of memory into the buffer cache, and there's nothing
> you can do about that.  If you rely on magic numbers to get the
> balancing right, then performance simply disappears when you do
> something unexpected like that.

My current (not yet diffed and released VM due not time to play with Linux
today due offtopic lessions at University) try to go close the a balance
percentage (5%) of freeable pages.  Note: for freeable pages I mean pages
in the file cache (swapper_inode included) with a reference count of 1,
really shrunkable (exists "shrunkable" ? ;) from shrink_mmap(). I
implemented two new functions page_get() and page_put()  (and hacked
free_pages and friends) to take nr_freeable_pages uptodate. 

> This is not supposition.  This is the observed performance of VMs which
> think they know how much memory should be allocated for different
> purposes.  You cannot say that cache should be larger than or smaller
> than a particular value, because only the current load can tell you how
> big the cache should be and that load can vary over time.

I just know that (not noticed, because the old code was just quite good).
The reason I can't trust the cache size is because some part of cache are
not freeable and infact I just moved my VM to check the percentage of
_freeable_ pages. And the algorithm try to go close to such percentage
because it know that it's rasonable, but it works fine even if it can't
reach such vale. If you don't try to go in a rasonable direction you could
risk to swapout even if there are tons of freeable pages in the swap cache
(maybe because the pages are not distributed equally on the mmap so
shrink_mmap() exires too early). 

The current VM balance is based on the (num_physpages << 1) / (priority+1)
and I find this bogus. My current VM change really nothing using a
starting prio of 6 or of 1. Sure starting from 1 is less responsive but
the numbers of vmstat are the ~same.

> > If I am missing something (again ;) comments are always welcome.
> 
> Yes.  Offer the functionality of VM limits, sure.  Relying on it is a
> disaster if the user does something you didn't predict.

Do still think this even if I am trying to give a balance to the number of
_freeable_ pages? Note, I never studied about the memory management.
Everything I do came from my instinct, so I can be wrong of course... but
I am telling you what I think right now.

BTW, do you remeber the benchmark that I am using that dirtyfy 160Mbyte in
loop and tell me how many seconds take each loop? 

Well it was taking 100 sec in pre1, it started to take 50 sec since I
killed kswapd and I started to async swapout also from process context,
and with my current experimental code (not yet released) is running in 20
sec each loop (the record ever seen here ;). I don't know if my new
experimental code (with the new nr_freeable_pages) is good under all
aspects but sure it gives a big boost and it's a real fun (at least Linux
is fun, University is going worse and worse). 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
