Date: Mon, 5 Aug 2002 14:54:03 -0400
Subject: Re: [RFC] start_aggressive_readahead
Content-Type: text/plain; charset=US-ASCII; format=flowed
Mime-Version: 1.0 (Apple Message framework v482)
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
In-Reply-To: <646802512.1028022723@[10.10.2.3]>
Message-Id: <B5FE047C-A8A4-11D6-A6B5-000393829FA4@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Martin,

Sorry for the slowness of the response, but just a thought or two...

> Both sets of heuristics seem backwards to me, depending on the
> circumstances ;-)

I don't agree, but more on that in a moment.  First, I'd like to point out 
a minor difference between what I meant by my suggestion and your 
interpretation of it.  The heuristic that I was suggesting -- grow in 
response to read-ahead misses, shrink in response to hits -- was not 
intended as a mere replacement.  It was meant as a ``blind'' approach to 
discovering the reference distribution for read-ahead pages.  So, the 
heuristic wouldn't be used simply as stated; instead, it would be a first 
approach to changing the read-ahead window size until evidence was 
gathered to make higher-level decisions.

For example, the VM system could shrink the window in response to hits, 
but if that shrinking decreased the hit count ``significantly'', it would 
return to the smallest window size that did not cause a hit decrease.  
Similarly, the VM system could increase the window size in response to 
misses, but after reaching some limit of increase where the misses do not 
decrease ``sufficiently'', it could return the window to the smallest size 
at which miss decrease was observed.

Now back to my claim that the heuristic that I suggested is not just the 
flip side of the original heuristics, where both are roughly equivalent, 
and the success of one or the other is just a matter of the reference 
behavior.  Assuming that an LRU-like replacement strategy is in place -- 
and I believe that page aging is LRU-like in the vast majority of 
situations -- the only way to turn a miss into a hit is to increase the 
window size.  Thus, the original heuristic's approach of shrinking the 
window in response to misses is a guarantee that future references that 
are part of the same reference behavior will remain misses.  Put 
differently, the *only* case in which it makes sense to shrink the 
read-ahead window in response to misses is one in which the misses are the 
result of un-cache-able references -- ones that would have required an 
absurdly large window, and so no window would be the best choice.  However,
  the heuristic that I described above will reach the same conclusion, 
although more slowly.  After growing the cache in response to the misses 
and observing no miss decrease, it would revert to a zero-sized window.

Granted, this discussion is based only on the read-ahead references, and 
not on the references to other, used pages.  However, even with that 
consideration, there's almost no situation in which you want to respond to 
read-ahead misses by shrinking the window -- and in those cases where you 
do, it's because of other factors, such as the need for a hopeless large 
window or a heavy demand on used pages that are near eviction that you 
want to shrink the window.  Read-ahead misses may not motivate larger 
read-ahead windows, but alone they *never* motivate smaller read-ahead 
windows.

>> So, while it is ideal to have some foresight before resizing the
>> window -- some calculation that determines whether or not growth
>> will help or shrinkage will hurt -- it will require the VM system
>> to gather hit distributions.
>
> Yup, but I think it's almost certainly worth that expense.

I'm happy that you think so, because I'm trying to do that now, and it's 
going to create some overhead.  Much like current rmap implementations, it'
s going to be the most intrusive for those cases where no paging is 
involved, and so the gains of tracking such information cannot be realized.

> How you actually calculate the window is a matter for debate and
> experimentation, but just growing and shrinking based on purely the
> hit rate seems like a bad idea.

Here I do agree.  Rather than finding the hit distribution by blindly 
setting allocations and observing the outcome, we can gather data to 
indicate what the outcome *would* be for that allocation.  Note, however, 
that VM systems have a long, long history of doing things like just 
responding to blind data gathering, much like increasing or decreasing 
allocation due to hit rate.  It's a matter of convincing people that 
gathering data that shows you the search space on-line is worth the 
complexity and the overhead.

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9TsnO8eFdWQtoOmgRAiC1AJsE3nhGa5zIGtkTsn7FBEuwrhX2uwCfcgzK
x7JgsWbQcQIhk3BSS2Wyu/o=
=oSsq
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
