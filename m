Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id AC3B46B0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 05:43:46 -0400 (EDT)
Date: Wed, 13 Mar 2013 09:42:28 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] bounce:fix bug, avoid to flush dcache on slab page
	from jbd2.
Message-ID: <20130313094228.GZ4977@n2100.arm.linux.org.uk>
References: <5139DB90.5090302@gmail.com> <20130312153221.0d26fe5599d4885e51bb0c7c@linux-foundation.org> <20130313011020.GA5313@blackbox.djwong.org> <513FF3F3.2000509@gmail.com> <20130312211138.a2824b7e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130312211138.a2824b7e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuge <shugelinux@gmail.com>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Kevin <kevin@allwinnertech.com>, linux-arm-kernel@lists.infradead.org

On Tue, Mar 12, 2013 at 09:11:38PM -0700, Andrew Morton wrote:
> Please reread my email.  The page at b_frozen_data was allocated with
> GFP_NOFS.  Hence it should not need bounce treatment (if arm is
> anything like x86).
> 
> And yet it *did* receive bounce treatment.  Why?

If I had to guess, it's because you've uncovered a bug in the utter crap
that we call a "dma mask".

When is a mask not a mask?  When it is used as a numerical limit.  When
is a mask really a mask?  When it indicates which bits are significant in
a DMA address.

The problem here is that there's a duality in the way the mask is used,
and that is caused by memory on x86 always starting at physical address
zero.  The problem is this:

On ARM, we have some platforms which offset the start of physical memory.
This offset can be significant - maybe 3GB.  However, only a limited
amount of that memory may be DMA-able.  So, we may end up with the
maximum physical address of DMA-able memory being 3GB + 64MB for example,
or 0xc4000000, because the DMA controller only has 26 address lines.  So,
this brings up the problem of whether we set the DMA mask to 0xc3ffffff
or 0x03ffffff.

There's places in the kernel which assume that DMA masks are a set of
zero bits followed by a set of one bits, and nothing else does...

Now, max_low_pfn is initialized this way:

/**
 * init_bootmem - register boot memory
 * @start: pfn where the bitmap is to be placed
 * @pages: number of available physical pages
 *
 * Returns the number of bytes needed to hold the bitmap.
 */
unsigned long __init init_bootmem(unsigned long start, unsigned long pages)
{
        max_low_pfn = pages;
        min_low_pfn = start;
        return init_bootmem_core(NODE_DATA(0)->bdata, start, 0, pages);
}

So, min_low_pfn is the PFN offset of the start of physical memory (so
3GB >> PAGE_SHIFT) and max_low_pfn ends up being the number of pages,
_not_ the maximum PFN value - if it were to be the maximum PFN value,
then we end up with a _huge_ bootmem bitmap which may not even fit in
the available memory we have.

However, other places in the kernel treat max_low_pfn entirely
differently:

        blk_max_low_pfn = max_low_pfn - 1;

void blk_queue_bounce_limit(struct request_queue *q, u64 dma_mask)
{
        unsigned long b_pfn = dma_mask >> PAGE_SHIFT;

        if (b_pfn < blk_max_low_pfn)
                dma = 1;
        q->limits.bounce_pfn = b_pfn;

And then we have stuff doing this:

	page_to_pfn(bv->bv_page) > queue_bounce_pfn(q);
                if (page_to_pfn(page) <= queue_bounce_pfn(q) && !force)
                if (queue_bounce_pfn(q) >= blk_max_pfn && !must_bounce)

So, "max_low_pfn" is totally and utterly confused in the kernel as to
what it is, and it only really works on x86 (and other architectures)
that start their memory at physical address 0 (because then it doesn't
matter how you interpret it.)

So the whole thing about "is a DMA mask a mask or a maximum address"
is totally confused in the kernel in such a way that platforms like ARM
get a very hard time, and what we now have in place has worked 100%
fine for all the platforms we've had for the last 10+ years.

It's a very longstanding bug in the kernel, going all the way back to
2.2 days or so.

What to do about it, I have no idea - changing to satisfy the "DMA mask
is a maximum address" is likely to break things.  What we need is a
proper fix, and a consistent way to interpret DMA masks which works not
only on x86, but also on platforms which have limited DMA to memory
which has huge physical offsets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
