Date: Wed, 28 May 2003 01:08:34 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: hard question re: swap cache
In-Reply-To: <20030527214157.31893.qmail@web41501.mail.yahoo.com>
Message-ID: <Pine.LNX.4.44.0305280048380.9660-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carl Spalletta <cspalletta@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 May 2003, Carl Spalletta wrote:
> Assume a shared, anonymous page is referenced by a set of
> processes a,b,c,d,e and the page is marked present in the
> page tables of each process.  Assume then that the page is
> marked for swapout in the pagetables of 'a'. A swap slot is
> filled with a copy of the page, but it is still present in
> memory.
> ....
> Then say b,c,d and e in that order have the page swapped out.
> Either the page is copied to the page slot for each swapout
> or it _must_ be copied on the last swap (when the page usage
> counter goes to zero) else the modifications made by b,c,d,e
> will be lost.

I'm not certain I understand your question (in particular, I don't
understand the page being copied to a page slot), but I might have
your answer.

Observe that mm/mmap.c:do_mmap_pgoff uses mm/shmem.c:shmem_zero_setup
for a shared anonymous mapping.  That creates a tmpfs object to back
the mapping, so its pages are not _directly_ backed by swap.

Under memory pressure, shmem_writepage gets called, which translates
(well, akpm's superb technical term for this is "swizzles") the page
to swap, and then later shmem_getpage may bring it back in.  Note
the BUG_ON(page_mapped(page)) in shmem_writepage, which gives the
assurance I think you're looking for.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
