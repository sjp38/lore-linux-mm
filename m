Date: Tue, 28 Mar 2000 14:22:53 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: how text page of executable are shared ?
Message-ID: <20000328142253.A16752@redhat.com>
References: <CA2568B0.0015EFDB.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568B0.0015EFDB.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Tue, Mar 28, 2000 at 09:21:59AM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Mar 28, 2000 at 09:21:59AM +0530, pnilesh@in.ibm.com wrote:
> 
> Suppose a text page of an executable is mapped in the address space of 2
> processes. The page count will be one.

No, the page count will be three at least.  The presence of the page 
in the page cache counts as one, and both of the page-table mappings of
the page each count as a further reference.

> The page table entries of both the process will have entry for this page.
> But when the page is discarded only the page entry of only one process get
> cleared , this is what I have understood from the swap_out () function .

Yes.  swap_out() is responsible for unlinking pages from process page 
tables.  In the case you describe, the page will still have outstanding
references, from the other process and from the page cache.  Only when
the page cache cleanup function (shrink_mmap) gets called, after all of
the ptes to the page have been cleared, will the page be freed.

If you think about it, this is natural: when a process pages in a binary
and then exits, we really want the pages still to remain in memory so 
that if you immediately rerun the program, we don't have to go back to
disk for the pages.  The process exiting acts a bit like a complete
swap_out, freeing up the pte reference to the page, but the page still
remains in the page cache until the memory is needed for something else.

> Q    When a page of a file is in page hash queue, does this page have page
> table entry in any process ?

It may have, but it doesn't have to.

> Q     Can this be discarded right away , if the need arises?

Not without first doing a swap_out() on all the references to the page.
The Linux VM does its swapout based on virtual, not physical, page
scanning (although shrink_mmap() is physical).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
