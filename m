Date: Wed, 16 Aug 2000 16:10:03 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: RFC: design for new VM
Message-ID: <20000816161003.G19260@redhat.com>
References: <Pine.LNX.4.21.0008021212030.16377-100000@duckman.distro.conectiva> <Pine.LNX.4.10.10008031020440.6384-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10008031020440.6384-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Thu, Aug 03, 2000 at 11:05:47AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

I'm coming to this late -- I've been getting drenched in the Scottish
rain up in Orkney and Skye for the past couple of weeks.

On Thu, Aug 03, 2000 at 11:05:47AM -0700, Linus Torvalds wrote:

> Why don't you just do it with the current scheme (the only thing needed to
> be added to the current scheme being the aging, which we've had before),
> and prove that the _balancing_ works. If you can prove that the balancing
> works but that we spend unnecessary time in scanning the pages, then
> you've proven that the basic VM stuff is right, and then the multiple
> queues becomes a performance optimization.
> 
> Yet you seem to sell the "multiple queues" idea as some fundamental
> change. I don't see that. Please explain what makes your ideas so
> radically different?

> As far as I can tell, the above is _exactly_ equivalent to having one
> single list, and multiple "scan-points" on that list. 

I've been talking with Rik about some of the other requirements that
filesystems have of the VM.  What came out of it was a strong
impression that the VM is currently confusing too many different
tasks.

We have the following tasks:

 * Aging of pages (maintaining the information about which pages are
   good to reclaim)

 * Reclaiming of pages (doesn't necessarily have to be done until 
   the free list gets low, even if we are still doing aging)

 * Write-back of dirty pages when under memory pressure (including
   swap write)

 * Write-behind of dirty buffers on timeout

 * Flow-control in the VM --- preventing aggressive processes from 
   consuming all free pages to the detriment of the rest of the
   system, or from filling all of memory with dirty, non-reclaimable
   pages

Rik's design specified that page aging --- the location of pages
suitable for freeing --- was to be done on a physical basis, using
something similar to 2.0's page walk (or FreeBSD's physical clock).
That scan doesn't have to walk lists: its main interaction with the
lists would be to populate the list of pages suitable for reclaim.

Once page aging is cleaned up in that way, we don't have to worry
overly about the scan order for pages on the page lists.  It's much
like the buffer cache --- we can use the buffer cache locked and dirty
lists to simplify the tracking of dirty data in the buffer cache
without having to worry about how those lists interact with the buffer
reclaim scan, since the reclaim scan is done using a completely
different scanning mechanism (the page list).

The presence of multiple queues isn't the Radically Different feature
of Rik's outline.  The fact that aging is independent of those queues
is.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
