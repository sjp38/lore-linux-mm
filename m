Date: Thu, 3 Jul 2003 14:58:39 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030703125839.GZ23578@dualathlon.random>
References: <20030702174700.GJ23578@dualathlon.random> <20030702214032.GH20413@holomorphy.com> <20030702220246.GS23578@dualathlon.random> <20030702221551.GH26348@holomorphy.com> <20030702222641.GU23578@dualathlon.random> <20030702231122.GI26348@holomorphy.com> <20030702233014.GW23578@dualathlon.random> <20030702235540.GK26348@holomorphy.com> <20030703113144.GY23578@dualathlon.random> <20030703114626.GP26348@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030703114626.GP26348@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 03, 2003 at 04:46:26AM -0700, William Lee Irwin III wrote:
> Actually it's not entirely for vma overhead. Compacting the virtual
> address space allows users to be "friendly" with respect to pagetable
> space or other kernel metadata space consumption whether on 32-bit or
> 64-bit. For instance, the "vast and extremely sparsely accessed"
> mapping on 64-bit machines can have its pagetable space mitigated by
> userspace using the remap_file_pages() API, where otherwise it would
> either OOM or incur pagetable reclamation overhead (where pagetable
> reclamation is not yet implemented).

apps should never try to use remap_file_pages like that in 64bit,
mangling the ptes, flushing tlb and entering kernel is an huge overhead
compared to the static pte ram cost that nobody can care about on 64bit
since as worse you can plug some more giga of ram. If you really have an
huge chunk that you've to release (and the problem isn't at all the pte,
the problem if something is the page pointed by the pte that you may
want to free if you know it'll never be useful again), munmap will work
fine too and it won't be slower than remap_file_pages and if it's a
really huge chunk munmap will get rid of the ptes too.

btw, for the really huge mappings largepages are always required anyways
which means the pte cost is zero because there aren't ptes at all.

even if you don't use largepages as you should, the ram cost of the pte
is nothing on 64bit archs, all you care about is to use all the mhz and
tlb entries of the cpu.

remap_file_pages is useful only for VLM in 32bit and theoretically
emulators (but I didn't hear any emulator developer ask for this feature
yet, and I doubt it would make a significant performance difference
anyways since the only thing that saves is the vma cost for the emulator
since you want to leave rmap behind it)

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
