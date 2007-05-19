Date: Sat, 19 May 2007 11:15:01 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070519181501.GC19966@holomorphy.com>
References: <20070518040854.GA15654@wotan.suse.de> <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com> <20070519012530.GB15569@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070519012530.GB15569@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2007 at 11:14:26AM -0700, Christoph Lameter wrote:
>> Right. That would simplify the calculations.

On Sat, May 19, 2007 at 03:25:30AM +0200, Nick Piggin wrote:
> It isn't the calculations I'm worried about, although they'll get simpler
> too. It is the cache cost.

The cache cost argument is specious. Even misaligned, smaller is
smaller. The cache footprint reduction is merely amortized,
probabilistic, etc.


On Fri, May 18, 2007 at 11:14:26AM -0700, Christoph Lameter wrote:
>> I wonder if there are other uses for the free space?

On Sat, May 19, 2007 at 03:25:30AM +0200, Nick Piggin wrote:
> Hugh points out that we should make _count and _mapcount atomic_long_t's,
> which would probably be a better use of the space once your vmemmap goes
> in.

I'm not so sure about that. I doubt we have issues with that. I say
if there's to be padding to 64B to use the of the whole additional
space for additional flag bits. I'm sure fs's could make good use of
64 spare flag bits, or whatever's left over after the VM has its fill.
Perhaps so many spare flag bits could be used in lieu of buffer_heads.

page->virtual is the same old mistake as it was when it was removed.
The virtual mem_map code should be used to resolve the computational
expense. Much the same holds for the atomic_t's; 32 + PAGE_SHIFT is
44 bits or more, about as much as is possible, and one reference per
page per page is not even feasible. Full-length atomic_t's are just
not necessary.

However, there are numerous optimizations and features made possible
with flag bits, which might as could be made cheap by padding struct
page up to the next highest power of 2 bytes with space for flag bits.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
