Message-ID: <39DBB745.7D652E4E@sgi.com>
Date: Wed, 04 Oct 2000 16:03:33 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Odd swap behavior
References: <Pine.LNX.4.21.0010041909570.1054-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:

> > Does that mean stack pages of processes are not included?
> > Non-aggressive swap can hurt performance.
> 
> I don't really see a clean way to do that in 2.4 ...

We can perhaps talk about this at the Storage Workshop ...

	[ ... ]

> > Would it not be more efficient to bung clean (read) pages directly
> > to inactive_clean on age = 0?
> 
> I don't know if this would make any difference...

I think it would. Consider steady state where pages
are all "in use". Any new allocation has to start with
pushing a page from active -> inactive, and then
inactive -> inactive_clean, if necessary, and then reclaim.
Now,  if we had pages which _are_ clean, then the path taken
is simply active -> inactive_clean -> reclaim.


> 
> And in fact, I'm contemplating adding /all/ pages
> that are deactivated to the inactive_dirty list,
> since that way we'll reclaim all inactive pages
> in FIFO order.
> 
> Currently we may "skip" some pages that were put
> on the inactive_dirty list but were cleaned up
> subsequently because we can find enough active
> pages that can be moved to the inactive_clean
> list immediately ...
> 

This is an interesting idea, although it seems
antithetical to what I said above. I think pure
FIFO has its merits in accomodating longer locality of
reference; it can help dbench.

If you have a patch (to always deactivate to inactive_dirty),
I can help you gauge it with the benchmarks ...

 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
