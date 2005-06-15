Date: Thu, 16 Jun 2005 09:23:28 +1000
From: Dave Chinner <dgc@sgi.com>
Subject: Re: 2.6.12-rc6-mm1 & 2K lun testing
Message-ID: <20050616092328.D125706@melbourne.sgi.com>
References: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com> <42B073C1.3010908@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42B073C1.3010908@yahoo.com.au>; from nickpiggin@yahoo.com.au on Thu, Jun 16, 2005 at 04:30:25AM +1000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 16, 2005 at 04:30:25AM +1000, Nick Piggin wrote:
> Badari Pulavarty wrote:
> 
> > ------------------------------------------------------------------------
> > 
> > elm3b29 login: dd: page allocation failure. order:0, mode:0x20
> > 
> > Call Trace: <IRQ> <ffffffff801632ae>{__alloc_pages+990} <ffffffff801668da>{cache_grow+314}
> >        <ffffffff80166d7f>{cache_alloc_refill+543} <ffffffff80166e86>{kmem_cache_alloc+54}
> >        <ffffffff8033d021>{scsi_get_command+81} <ffffffff8034181d>{scsi_prep_fn+301}
> 
> They look like they're all in scsi_get_command.

I've seen this before on a system with lots of luns, lots of memory
and lots of dd write I/O. basically, all the memory being flushed
was being pushed into the elevator queues before block congestion
was triggered (58GiB of RAM in the elevator queues waiting for I/O
to be done on them!) This caused OOM problems when things like slab
allocations were necessary and the above was a common location for
failures.

If you've got command tag queueing turned on, then you need a
scsi command structure for every I/O on the fly. Assuming the default
depth for linux (32 IIRC) - that's 2048 x 32 = 64k request structures.
Hence you're doing a few allocations here.

However, when you are oversubscribing the system like this, you can run
out of memory by the time you get to the SCSI layer because there's
so many block devices that none of them get enough I/O queued to
trigger congestion and throttle the incoming writers.

You can WAR this is to reduce the /sys/block/*/queue/nr_requests to a
small number (say 4 or 8). This should cause the system to throttle
writers at /proc/sys/vm/dirty_ratio percent of memory dirtied and
prevent these failures. The system responsiveness should be far
better as well.

HTH.

Cheers,

Dave.
-- 
Dave Chinner
R&D Software Engineer
SGI Australian Software Group
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
