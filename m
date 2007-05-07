Date: Mon, 7 May 2007 13:20:52 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: What is the right way to prefault and pin pages for perfmon?
Message-ID: <20070507122052.GA1670@infradead.org>
References: <20070507114838.GD14010@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070507114838.GD14010@lnx-holt.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: linux-mm@kvack.org, Stephane Eranian <eranian@hpl.hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 07, 2007 at 06:48:38AM -0500, Robin Holt wrote:
> perfmon has a need to get memory allocated and prefaulted for a shared
> buffer between user and kernel.  The memory is read-only to the user.
> The hardware performance counter values are inserted into those pages.
> Pages can not be faulted during sampling as we only have nano to micro
> seconds to capture the values with accuracy.  What is the right way to
> accomplish this?

Allocate the pages using alloc_page and then insert it using vm_insert_page.
In case you need a contiguous mapping use vmap to establish it, but it
would be better if we could avoid that part to not eat up too much
vmalloc space.

Note that all this should happen from a ->mmap method and not from
other magic calls.  Nothing but calls to mmap (or related syscalls)
should change the user address space.

> Currently, the user is calling the kernel with a number of sample entries
> for a single cpu's buffers.  The kernel turns this into a buffer size
> and calls vmalloc to get a kernel virtually contiguous address range.
> It then sets PG_RESERVED on all those pages and calls remap_pfn_range()
> to insert page table entries into the users address space.  Additionally,
> it is updating locked_vm on the tasks mm.
> 
> I think this should really become do_mmap(), followed by get_user_pages().

Not at all.  do_mmap is not something anyone but the various mmap
implementation should call.  Having this function exported at all
is a tragic historic coincidence  involving a few graphics hackers
and lots of illegal drugs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
