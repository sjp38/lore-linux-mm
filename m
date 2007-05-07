Date: Mon, 7 May 2007 06:48:38 -0500
From: Robin Holt <holt@sgi.com>
Subject: What is the right way to prefault and pin pages for perfmon?
Message-ID: <20070507114838.GD14010@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Stephane Eranian <eranian@hpl.hp.com>
List-ID: <linux-mm.kvack.org>

perfmon has a need to get memory allocated and prefaulted for a shared
buffer between user and kernel.  The memory is read-only to the user.
The hardware performance counter values are inserted into those pages.
Pages can not be faulted during sampling as we only have nano to micro
seconds to capture the values with accuracy.  What is the right way to
accomplish this?

Currently, the user is calling the kernel with a number of sample entries
for a single cpu's buffers.  The kernel turns this into a buffer size
and calls vmalloc to get a kernel virtually contiguous address range.
It then sets PG_RESERVED on all those pages and calls remap_pfn_range()
to insert page table entries into the users address space.  Additionally,
it is updating locked_vm on the tasks mm.

I think this should really become do_mmap(), followed by get_user_pages().
I don't think we have a need to update locked_vm and we also should
not need to insert page table entries, but let the kernel do the work.
This will require perfmon to adjust to using a virtually discontiguous
address range, but that seems reasonable.

What is the "right" way to do this?  Is there precedence for this sort
of thing elsewhere in the kernel that I can look at?

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
