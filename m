Date: Thu, 3 Jul 2003 21:27:50 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030703192750.GM23578@dualathlon.random>
References: <20030703125839.GZ23578@dualathlon.random> <Pine.LNX.4.44.0307030904260.16582-100000@chimarrao.boston.redhat.com> <20030703185341.GJ20413@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030703185341.GJ20413@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@redhat.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 03, 2003 at 11:53:41AM -0700, William Lee Irwin III wrote:
> On Thu, 3 Jul 2003, Andrea Arcangeli wrote:
> >> even if you don't use largepages as you should, the ram cost of the pte
> >> is nothing on 64bit archs, all you care about is to use all the mhz and
> >> tlb entries of the cpu.
> 
> On Thu, Jul 03, 2003 at 09:06:32AM -0400, Rik van Riel wrote:
> > That depends on the number of Oracle processes you have.
> > Say that page tables need 0.1% of the space of the virtual
> > space they map.  With 1000 Oracle users you'd end up needing
> > as much memory in page tables as your shm segment is large.
> > Of course, in this situation either the application should
> > use large pages or the kernel should simply reclaim the
> > page tables (possible while holding the mmap_sem for write).
> 
> No, it is not true that pagetable space can be wantonly wasted
> on 64-bit.
> 
> Try mmap()'ing something sufficiently huge and accessing on average
> every PAGE_SIZE'th virtual page, in a single-threaded single process.
> e.g. various indexing schemes might do this. This is 1 pagetable page
> per page of data (worse if shared), which blows major goats.

that's the very old exploit that touches 1 page per pmd.

> 
> There's a reason why those things use inverted pagetables... at any
> rate, compacting virtualspace with remap_file_pages() solves it too.
> 
> Large pages won't help, since the data isn't contiguous.

if you can't use a sane design it's not a kernel issue.  this is bad
userspace code seeking like crazy on disk too, working around it with a
kernel feature sounds worthless. If algorithms have no locality at all,
and they spread 1 page per pmd that's their problem.

the easiest way to waste ram with bad code is to add this in the first
line of the main of a program:

	p = malloc(1G)
	bzero(p, 1G)

you don't need 1 page per pmd to waste ram. Should we also write a
kernel feature that checks if the page is zero and drops it so the above
won't swap etc..?

If you can come up with a real life example where the 1 page per pmd
scattered over 1T of address space (we're talking about the file here of
course, the on disk representation of the data) is the very best design
possible ever (without any concept of locality at all) and it speeds up
things of orders of magnitude not to have any locality at all,
especially for the huge seeking it will generate no matter what the
pagetable side is, you will then change my mind about it.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
