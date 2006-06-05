Content-class: urn:content-classes:message
Subject: RE: ECC error correction - page isolation
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Date: Mon, 5 Jun 2006 16:36:50 -0700
Message-ID: <069061BE1B26524C85EC01E0F5CC3CC30163E1F3@rigel.headquarters.spacedev.com>
From: "Brian Lindahl" <Brian.Lindahl@SpaceDev.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> If it's kernel space there are several cases:
> - Free page (count == 0). Easy: ignore it.
> - Reserved - e.g. page itself or kernel code - panic
> - Slab (slab bit set) - panic
> - Page table (cannot be detected right now, but you could
> change your architecture to set special bits) - handle like
> process error
> - buffer cache: toss or IO/error if it was dirty
> - Probably more cases
> Most can be figured out by looking at the various bits in struct page

Right, this sort of activity will be the main guts of error recovery.
Nothing too fancy I'm guessing, just requires a bit of digging. If we
can do something moderately intelligent (toss it), do that, otherwise
panic.

> I think he means uncorrected errors. Correctable errors can be fixed 
> up by a scrubber without anything else noticing.

This is correct in our environment.

> Ok if your system doesn't support getting rid of them without 
> an atomic operation you might need to "stop the world" on MP, 
> but that's relatively easy using stop_machine().

It's a UP, but I have no qualms about extending it to MP as we go. I
assume "start_machine()" brings us back up again?

> Interesting background, Brian might find it useful. He did say 
> he wanted to isolate the pages if they're unused, so perhaps
non-transient
> errors can be detected. Or the system just wants to be overly
paranoid?

It's more of a "nice to have" feature in case our customers are overly
paranoid :) The main idea here, is to retest pages that have been
isolated when memory gets tight (if it ever does). After several retests
with no errors, we'll be releasing the pages back to the kernel. This is
mostly to avoid tossing the same page(s) over and over in case they're
susceptible, for some reason.

For a sanity check, so far, I have something like this:

u32 pfn; /* = some page number */
struct * page = pfn_to_page(pfn);

To get an address for the read/rewrite cycle:

atomic_long_t * p = (atomic_long_t *) page_address(page);

To do the read/rewrite cycle, for each atomic_long_t, p, in the page:

atomic_long_add(0, p);

That should trigger the ECC without muddling with the data in a MP-safe
fashion (this should be a fun test, we get to make some RAM physically
fail). So check the ECC error count, and if it changed, do something
smart with 'page'.

One thing I'm having trouble with is finding out what page number to
start with and end with to make the scrubbing simple for the user (the
ioctl returns two u32s). Is there a better way to do this (i.e. existing
globals)?

pfn_beg = pfn_end = 0;
for_each_pgdat(pgdat)
{
  pfn_beg = min(pfn_beg, pgdat->node_start_pfn);
  pfn_end = max(pfn_end, pgdat->node_start_pfn +
pgdat->node_spanned_pages);
}

I also validate the page number using 'pfn_valid(pfn)' before retrieving
the struct page from the page number (fails silently to act like
contiguous memory to the user).

Does this hit every physical page? Or am I missing pages that may have
been allocated by the bootmem allocator?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
