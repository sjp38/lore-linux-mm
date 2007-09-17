Date: Mon, 17 Sep 2007 13:15:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: VM/VFS bug with large amount of memory and file systems?
Message-Id: <20070917131526.e8db80fe.akpm@linux-foundation.org>
In-Reply-To: <46EEB532.3060804@redhat.com>
References: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk>
	<1189850897.21778.301.camel@twins>
	<20070915035228.8b8a7d6d.akpm@linux-foundation.org>
	<13126578-A4F8-43EA-9B0D-A3BCBFB41FEC@cam.ac.uk>
	<20070917163257.331c7605@twins>
	<46EEB532.3060804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Anton Altaparmakov <aia21@cam.ac.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, marc.smith@esmail.mcc.edu
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007 13:11:14 -0400
Rik van Riel <riel@redhat.com> wrote:

> > I'm guessing there is no pressure at all on zone_highmem so the
> > kernel will not try to reclaim pagecache. And because the pagecache
> > pages are happily sitting there, the buggerheads are pinned and do not
> > get reclaimed.

yeah, this got pretty unavoidably broken when we killed the global LRU
in 2.5.early. It's odd that it took this long for someone to hit it.

> I've got code for this in RHEL 3, but never bothered to
> merge it upstream since I thought people with large memory
> systems would be running 64 bit kernels by now.
> 
> Obviously I was wrong.  Andrew, are you interested in a
> fix for this problem?
> 
> IIRC I simply kept a list of all buffer heads and walked
> that to reclaim pages when the number of buffer heads is
> too high (and we need memory).  This list can be maintained
> in places where we already hold the lock for the buffer head
> freelist, so there should be no additional locking overhead
> (again, IIRC).

Christoph's slab defragmentation code should permit us to fix this:
grab a page of buffer_heads off the slab lists, trylock the page,
strip the buffer_heads.  I think that would be a better approach
if we can get it going because it's more general.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
