Date: Sun, 20 May 2007 01:46:47 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070520084647.GF19966@holomorphy.com>
References: <20070518040854.GA15654@wotan.suse.de> <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com> <20070519012530.GB15569@wotan.suse.de> <20070519181501.GC19966@holomorphy.com> <20070520052229.GA9372@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070520052229.GA9372@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, May 19, 2007 at 11:15:01AM -0700, William Lee Irwin III wrote:
>> The cache cost argument is specious. Even misaligned, smaller is
>> smaller.

On Sun, May 20, 2007 at 07:22:29AM +0200, Nick Piggin wrote:
> Of course smaller is smaller ;) Why would that make the cache cost
> argument specious?

It's not possible to ignore aggregation. For instance, for a subset
of mem_map whose size ignoring alignment would otherwise fit in the
cache to completely avoid sharing any cachelines between page
structures requires page structures to be separated by at least one
mem_map index. This is highly unlikely in uniform distributions.


On Sat, May 19, 2007 at 11:15:01AM -0700, William Lee Irwin III wrote:
>> The cache footprint reduction is merely amortized,
>> probabilistic, etc.

On Sun, May 20, 2007 at 07:22:29AM +0200, Nick Piggin wrote:
> I don't really know what you mean by this, or what part of my cache cost
> argument you disagree with...
> I think it is that you could construct mem_map access patterns, without
> specifically looking at alignment, where a 56 byte struct page would suffer
> about 75% more cache misses than a 64 byte aligned one (and you could also
> get about 12% fewer cache misses with other access patterns).
> I also think the kernel's mem_map access patterns would be more on the
> random side, so overall would result in significantly fewer cache misses
> with 64 byte aligned pages.
> Which part do you disagree with?

The lack of consideration of the average case. I'll see what I can smoke
out there.


On Sat, May 19, 2007 at 11:15:01AM -0700, William Lee Irwin III wrote:
>> I'm not so sure about that. I doubt we have issues with that. I say

On Sun, May 20, 2007 at 07:22:29AM +0200, Nick Piggin wrote:
> The issue is that userspace can DOS or crash the kernel by deliberately
> overflowing count or mapcount.

This was a flat out error.


On Sat, May 19, 2007 at 11:15:01AM -0700, William Lee Irwin III wrote:
>> if there's to be padding to 64B to use the of the whole additional
>> space for additional flag bits. I'm sure fs's could make good use of
>> 64 spare flag bits, or whatever's left over after the VM has its fill.
>> Perhaps so many spare flag bits could be used in lieu of buffer_heads.

On Sun, May 20, 2007 at 07:22:29AM +0200, Nick Piggin wrote:
> Really? 64-bit architectures can already use about maybe 16 or 32 more
> page flag bits than 32-bit architectures, and I definitely do not want
> to increase the size of 32-bit struct page, so I think this wouldn't
> work.

Actually they can't use most of those flag bits on account of
portability to the 32-bit case. A 32-bit flags on 64-bit is rather
plausible due to such.


On Sat, May 19, 2007 at 11:15:01AM -0700, William Lee Irwin III wrote:
>> page->virtual is the same old mistake as it was when it was removed.
>> The virtual mem_map code should be used to resolve the computational

On Sun, May 20, 2007 at 07:22:29AM +0200, Nick Piggin wrote:
> Don't get too hung up on the page->virtual thing. I'll send another
> patch with atomic_t/atomic_long_t conversion.

That's fine.


On Sat, May 19, 2007 at 11:15:01AM -0700, William Lee Irwin III wrote:
>> expense. Much the same holds for the atomic_t's; 32 + PAGE_SHIFT is
>> 44 bits or more, about as much as is possible, and one reference per
>> page per page is not even feasible. Full-length atomic_t's are just
>> not necessary.

On Sun, May 20, 2007 at 07:22:29AM +0200, Nick Piggin wrote:
> I don't know what your 32 + PAGE_SHIFT calculation is for, but yes you
> can wrap these counters from userspace on 64-bit architectures.

That's just an error.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
