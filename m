From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199908162339.QAA67278@google.engr.sgi.com>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
Date: Mon, 16 Aug 1999 16:39:47 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9908170100030.13378-100000@laser.random> from "Andrea Arcangeli" at Aug 17, 99 01:26:56 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> But now IMO there's to choose between one of the below options:
> 
> 1) should we change all device drivers to allow us to do I/O over
>    bigmem pages? NOTE: all DMA engine are just fine since virt_to_bus
>    just works right as Gerhard pointed out to me. The only problem is for
>    drivers that reads and writes to the b_data in software.
> 2) should we change ll_rw_block to force an high limit of bh queued in
>    the same request and then remap the b_data in the ll_rw_block layer
>    with a NR_REQUEST*MAX_BH_PER_REQUEST array of virtual-pages in the
>    fixmap area? (many tlb_flush_all... or at least many SMP-invlpg with a 
>    smarter cross-CPU-invlpg message)
>    virt_to_bus must be able to resolve the bus address starting from
>    the fixmap virtual address.
> 3) using the remap trick that I am just using in the swapout/swapin code,
>    I could just do raw-io on anonymous memory but I get stuck with the shm
>    memory where I can't simply realloc a page without browsing all
>    processes VM. Should I take a list of all pte that are mapping
>    each smp page and doing the remap trick also on shm memory?
> 4) should I avoid raw-io in the shm memory and use the remap trick
>    with the anonymous memory?
> 5) should I avoid bigmem in shm memory and simply use the remap trick
>    with the anonymous memory?

Avoiding raw-io is not a good solution. Remapping would be a performance 
hit anyway (other than having other problems, namely, you might not find 
a page to remap to). Remapping in just the swap code is acceptable, but
probably not for other cases (like rawio).

> 
> I guess big databases uses the shm memory as cache. And I guess they use
> raw-io to fill the shm memory with proper data. Am I right about this? If

Yes, I believe so ...

> so I can't choose (4). And since I would like to use the bigmem as shm
> memory I would like to avoid also (5).
> 
> (3) looks dirty and add a performance hit in the shm_nopage hander.
> 
> (2) looks dirty and slow due the SMP tlb flushes.
> 
> (1) looks clean and efficient (100% efficient in the DMA case!) but it
>     breaks all drivers out there... :(((
> 
> Theorically the cleanest solution would be (1) but I don't know if this
> will be a good choice on the long run (theorically on 2038 we won't need
							^^^ What is 2038?
> CONFIG_BIGMEM anymore...).

Part of the reason my bigmem patch for 2.2 has been implemented the
way it is, is so that drivers don't break. I think 2.3 is the place to 
teach the kernel and drivers that all of memory is not directly mappable.
Specially, if we hope to put in the PAE/36bit stuff in anytime. Yes,
that means fixing drivers. Of course, that's just my opinion ...

> 
> Right now I temporary applyed solution (0): the patch at the top of this
> email so if you want to use raw-io on anonymous or shm memory you'll have
> to recompile with CONFIG_BIGMEM not set.
> 
> Comments? (very welcome :)
> 

Once you can get resolution and decision on the driver issue, bigmem
pages can also exist in the page cache. And kmalloc could also use
bigmem pages for holding kernel data structures ...

Kanoj

> Andrea
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
