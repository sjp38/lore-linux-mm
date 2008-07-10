Date: Thu, 10 Jul 2008 11:33:29 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 12/13] GRU Driver V3 -  export is_uv_system(), zap_page_range() & follow_page()
Message-ID: <20080710163329.GB1860@sgi.com>
References: <20080703213348.489120321@attica.americas.sgi.com> <200807101731.54910.nickpiggin@yahoo.com.au> <20080710132903.GA17830@sgi.com> <200807110021.29392.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200807110021.29392.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Hellwig <hch@infradead.org>, cl@linux-foundation.org, akpm@osdl.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, holt@sgi.com, andrea@qumranet.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 11, 2008 at 12:21:28AM +1000, Nick Piggin wrote:
> On Thursday 10 July 2008 23:29, Jack Steiner wrote:
> > On Thu, Jul 10, 2008 at 05:31:54PM +1000, Nick Piggin wrote:
> > > On Thursday 10 July 2008 05:11, Jack Steiner wrote:
> 
> > > > I'll post the new GRU patch in a few minutes.
> > >
> > > It looks broken to me. How does it determine whether it has a
> > > normal page or not?
> >
> > Right. Hugepages are not currently supported by the GRU. There is code that
> > I know is missing/broken in this path. I'm trying to get the core driver
> > accepted, then I'll get the portion dealing with hugepages working.
> 
> Oh, I meant "normal" pages as in vm_normal_page(), or is there some
> other reason this codepath is exempt from them?

Maybe...

The GRU deals with cacheable memory only (the check is currently missing).
What is the proper way to catch a reference to a PTE that maps something
other than normal cacheable memory. Note that we support XPMEM. Some cacheable
memory that is valid for GRU references will be memory located on other
partitions. No page struct entries will exist nor will the physical address ranges
be known to the kernel. (Not in efi/e820 tables).

One idea that I had was to use the attributes of the PTE. Is there
better way. vm_flags? ???

Ideas???

> 
> Using gup.c code I don't think will prevent your driver from getting
> accepted. Conversely, I would not like the open coded page table walk
> to go upstream...

If that is the concensus, that is ok. How certain are we that gup.c will
go into 2.6.27. Initially, I though it was cleaner to decouple the GRU
from gup.c & to wait until I had all the hugepage & ia64 issues resolved before
trying to push the walker into the kernel. (The driver runs ok as long
as huge pages are not referenced. It detects attempts to reference hugepages
and gives the user an error).

We would also need a gup.c for ia64.

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
