Date: Fri, 26 May 2000 13:38:12 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000526133812.D21510@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0005251405160.32434-100000@duckman.distro.conectiva> <200005251753.KAA83360@apollo.backplane.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200005251753.KAA83360@apollo.backplane.com>; from dillon@apollo.backplane.com on Thu, May 25, 2000 at 10:53:04AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dillon <dillon@apollo.backplane.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Dillon wrote:
>     When you scan by physical page, then locate the VM mappings for that
>     page, you have:
> 
> 	* a count of the number of mappings
> 	* a count of how many of those referenced the page since the
> 	  last check.
> 	* more determinism (see below)

>     When you scan by virtual page, then locate the physical mapping:
> 
> 	* you cannot tell how many other virtual mappings referenced the
> 	  page (short of checking, at which point you might as well be
> 	  scanning by physical page)

But you can at least accumulate the info.  If it's just a question of
bumping a decaying "page referenced recently" measure, than with virtual
scanning you bump it more often (if it's being used in many places);
with physical scanning you bump it more in one go.

> 	* you have no way of figuring out how many discrete physical pages
> 	  your virtual page scan has covered.  For all you know you could
> 	  scan 500 virtual mappings and still only have gotten through a
> 	  handful of physical pages.  Big problem!

Counters in struct page.

>     Another example of why physical page scanning is better then
>     virtual page scanning:  When there is memory pressure and you are
>     scanning by physical page, and the weight reaches 0, you can then
>     turn around and unmap ALL of its virtual pte's all at once (or mark
>     them read-only for a dirty page to allow it to be flushed).  Sure
>     you have to eat cpu to find those virtual pte's, but the end result
>     is a page which is now cleanable or freeable.

That's obviously a _big_ advantage under memory pressure.  A fast
feedback loop, so much more robust dynamics.

>     Now try this with a virtual scan:  You do a virtual scan, locate
>     a page you decide is idle, and then... what?  Unmap just that one
>     instance of the pte?  What about the others?  You would have to unmap
>     them too, which would cost as much as it would when doing a physical
>     page scan *EXCEPT* that you are running through a whole lot more virtual
>     pages during the virtual page scan to get the same effect as with
>     the physical page scan (when trying to locate idle pages).  It's
>     the difference between O(N) and O(N^2).  If the physical page queues
>     are reasonably well ordered, its the difference between O(1) and O(N^2).

[ Virtual is not O(N^2) if you've limited the number of ptes mapped, but I
agree the fixed overhead of that is rather high. ]

Conclusion: _Everyone_ agrees that physical page scanning is better in
every way except one: Linux 2.4 wants to be released :-)

But, given its conceptual simplicity, I wonder if it isn't worth trying
to implement physical scanning anyway?  It would simplify the paging
dynamics; I expect tuning etc. would be easier and more robust.  And
Rik's queues proposal is more or less orthogonal.  We need good queues
however pages are freed up.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
