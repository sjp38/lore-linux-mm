Date: Thu, 3 Jul 2003 11:53:41 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030703185341.GJ20413@holomorphy.com>
References: <20030703125839.GZ23578@dualathlon.random> <Pine.LNX.4.44.0307030904260.16582-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0307030904260.16582-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, "Martin J. Bligh" <mbligh@aracnet.com>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jul 2003, Andrea Arcangeli wrote:
>> even if you don't use largepages as you should, the ram cost of the pte
>> is nothing on 64bit archs, all you care about is to use all the mhz and
>> tlb entries of the cpu.

On Thu, Jul 03, 2003 at 09:06:32AM -0400, Rik van Riel wrote:
> That depends on the number of Oracle processes you have.
> Say that page tables need 0.1% of the space of the virtual
> space they map.  With 1000 Oracle users you'd end up needing
> as much memory in page tables as your shm segment is large.
> Of course, in this situation either the application should
> use large pages or the kernel should simply reclaim the
> page tables (possible while holding the mmap_sem for write).

No, it is not true that pagetable space can be wantonly wasted
on 64-bit.

Try mmap()'ing something sufficiently huge and accessing on average
every PAGE_SIZE'th virtual page, in a single-threaded single process.
e.g. various indexing schemes might do this. This is 1 pagetable page
per page of data (worse if shared), which blows major goats.

There's a reason why those things use inverted pagetables... at any
rate, compacting virtualspace with remap_file_pages() solves it too.

Large pages won't help, since the data isn't contiguous.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
