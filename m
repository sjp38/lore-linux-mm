Date: Fri, 14 Jul 2000 11:31:35 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: map_user_kiobuf problem in 2.4.0-test3
Message-ID: <20000714113135.V3113@redhat.com>
References: <396C9188.523658B9@sangate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <396C9188.523658B9@sangate.com>; from mark@sangate.com on Wed, Jul 12, 2000 at 06:40:56PM +0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Mokryn <mark@sangate.com>
Cc: linux-kernel@vger.rutgers.edu, linux-scsi@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jul 12, 2000 at 06:40:56PM +0300, Mark Mokryn wrote:

> Here's the scenario:
> 2.4.0-test3 SMP build running on a single 800MHz PIII (Dell GX-300)
> After obtaining a mapping to a high memory region (i.e. either
> PCI memory or physical memory reserved by passing mem=XXX to the kernel
> at boot), I am trying to write a raw device with data in the mapped
> region.
> This fails, with map_user_kiobuf spitting out "Mapped page missing"
> The raw write works, of course, if the mapping is to a kmalloc'ed
> buffer.
> 
> I have tried the above with 2.2.14 SMP, and it works, so something in
> 2.4 is broken.

No.  2.4 is merely "changed" --- that's different!

The 2.2 mechanism was fine for all memory under 4GB --- ie. memory you
can address with an unsigned 32 bit integer.  2.4 includes large
memory support for 64GB memory on Intel, and we looked at ways of
making kiobufs work with this.  The only reasonable solution was to
use "struct page *" pointers in the kiobuf in 2.4.  

That is a design decision, and is deliberate.  It means that we don't
have the ability to address IO aperture pages directly using the
normal struct page *'s from the mem_map array.  

Eventually we want to be able to allow new struct page arrays to be
allocated at run time to describe arbitrary high-memory ranges, and
that will provide natural support for kiobufs on IO apertures.  For
now, however, it just won't work, and we're aware of the missing
functionality.

> On another interesting note: The raw devices I'm writing to are Fibre
> Channel drives controlled by a Qlogic 2200 adapter (in 2.2.14 I'm using
> the Qlogic driver). When writing large sequential blocks to a single
> drive, I reached 8MB/s when the memory was mapped to the high reserved
> region, while CPU utilization was down to about 5%. When the mapping was
> to PCI space, I was able to write at only 4MB/s, and CPU utilization was
> up to 60%! This is very strange, since if the transfer rate was for some
> unknown reason lower in the case of PCI (vs. high physical memory), then
> one would expect the CPU utilization to be even lower, since the adapter
> performs DMA. But instead, the CPU is sweating...

PCI reads are very, very slow.  If the CPU is contending with a large
DMA transfer for access to the bus, then you might find that the high
CPU utilisation is just coming about due to the CPU's IO or memory
accesses experiencing a massive slowdown due to bus contention.  PCI
is a _lot_ faster for write than for read to PCI-mapped memory.

> So, it appears that
> there's a problem in 2.2.14 as well, when the mapping is to PCI space...

I'd need to see a bus analysis first --- this could well be
hardware...

> Additionally, the max transfer rate of 8MB/s seems rather slow - don't
> know why yet...

I have no trouble getting much more than that from raw I/O, but the
qlogics may have bandwidth problems if the IO size is small (current
raw IO for 2.2 limits the IO chunk size to 64kB).

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
