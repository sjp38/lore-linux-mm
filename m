Date: Sun, 20 May 2007 19:13:48 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070520171348.GC7653@v2.random>
References: <20070518040854.GA15654@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070518040854.GA15654@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2007 at 06:08:54AM +0200, Nick Piggin wrote:
> If we add 8 bytes to struct page on 64-bit machines, it becomes 64 bytes,
> which is quite a nice number for cache purposes.

We had those hardware alignment for many data structures where they
were only wasting memory (i.e. vmas).

There are few places where the hardware alignment matters, page struct
isn't going to be one of them. But feel free to measure yourself.

> I'd say all up this is going to decrease overall cache footprint in 
> fastpaths, both by reducing text and data footprint of page_address and
> related operations, and by reducing cacheline footprint of most batched
> operations on struct pages.

IIRC the math is faster for any x86. Overall I doubt the change is
measurable.

Even if this would be a microoptimization barely measurable in some
microbenchmark, I don't think this one is worth doing. mem_map is such
a bloat that it really has to be as small as it can unless we can
improve performance _significantly_ by enlarging it.

> Interestingly, the irony of 32-bit architectures setting WANT_PAGE_VIRTUAL
> because they have slow multiplications is that without WANT_PAGE_VIRTUAL, the
> struct is 32-bytes and so page_address can usually be calculated with a shift.
> So WANT_PAGE_VIRTUAL just bloats up the size of struct page for those guys!

If you want to drop it you can, there's nothing fundamental that
prevents you to drop the 'virtual' completely from page struct, by
just making the vaddr per-process and storing it on the stack like
with the atomic kmaps, but passing it up the stack may require heavy
changes to various apis, which is why we've taken the few-changes lazy
way back then. If it wasn't worth back then, I doubt it worth now for
just pae36.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
