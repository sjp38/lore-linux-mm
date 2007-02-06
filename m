Date: Tue, 6 Feb 2007 11:51:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 0/7] Move mlocked pages off the LRU and track them
Message-Id: <20070206115113.4a5db10c.akpm@linux-foundation.org>
In-Reply-To: <1170777882.4945.31.camel@localhost>
References: <20070205205235.4500.54958.sendpatchset@schroedinger.engr.sgi.com>
	<1170777882.4945.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 06 Feb 2007 11:04:42 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> Note that anon [and shmem] pages in excess of available swap are
> effectively mlocked().  In the field, we have seen non-NUMA x86_64
> systems with 64-128GB [16-32million 4k pages] with little to no
> swap--big data base servers.  The majority of the memory is dedicated to
> large data base shared memory areas.  The remaining is divided between
> program anon and page cache [executable, libs] pages and any other page
> cache pages used by data base utilities, system daemons, ...
> 
> The system runs fine until someone runs a backup [or multiple, as there
> are multiple data base instances running].  This over commits memory and
> we end up with all cpus in reclaim, contending for the zone lru lock,
> and walking an active list of 10s of millions of pages looking for pages
> to reclaim.  The reclaim logic spends a lot of time walking the lru
> lists, nominating shmem pages [the majority of pages on the list] for
> reclaim, only to find in shrink_pages() that it can't move the page to
> swap.  So, it puts it back on the list to be retried by the other cpus
> once they obtain the zone lru lock.  System appears to be hung for long
> periods of time.
> 
> There are a lot of behaviors in the reclaim code that exacerbate the
> problems when we get into this mode, but the long lists of unswappable
> anon/shmem pages is the major culprit.  One of the guys at Red Hat has
> tried a "proof of concept" patch to move all anon/shmem pages in excess
> of swap space to "wired list" [currently global, per node/zone in
> progress] and it seems to alleviate the problem.  
> 
> So, Christoph's patch addresses a real problem that we've seen.
> Unfortunately, not all data base applications lock their shmem areas
> into memory.  Excluding pages from consideration for reclaim that can't
> possibly be swapped out due to lack of swap space seems a natural
> extension of this concept.  I expect that many Christoph's customers run
> with swap space that is much smaller than system memory and would
> benefit from this extension.

Yeah.

The scanner at present tries to handle out-of-swap by moving these pages
onto the active list (shrink_page_list) then keeping them there
(shrink_active_list) so it _should_ be the case that the performance
problems which you're observing are due to active list scanning.  Is that
correct?

If not, something's busted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
