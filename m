Message-ID: <46368FAA.3080104@redhat.com>
Date: Mon, 30 Apr 2007 20:54:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: MADV_FREE functionality
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>  lazy-freeing-of-memory-through-madv_free.patch
>  lazy-freeing-of-memory-through-madv_free-vs-mm-madvise-avoid-exclusive-mmap_sem.patch
>  restore-madv_dontneed-to-its-original-linux-behaviour.patch
> 
> I think the MADV_FREE changes need more work:
> 
> We need crystal-clear statements regarding the present functionality, the new
> functionality and how these relate to the spec and to implmentations in other
> OS'es.  Once we have that info we are in a position to work out whether the
> code can be merged as-is, or if additional changes are needed.

There are two MADV variants that free pages, both do the exact
same thing with mapped file pages, but both do something slightly
different with anonymous pages.

MADV_DONTNEED will unmap file pages and free anonymous pages.
When a process accesses anonymous memory at an address that
was zapped with MADV_DONTNEED, it will return fresh zero filled
pages.

MADV_FREE will unmap file pages.  MADV_FREE on anonymous pages
is interpreted as a signal that the application no longer needs
the data in the pages, and they can be thrown away if the kernel
needs the memory for something else.  However, if the process
accesses the memory again before the kernel needs it, the process
will simply get the original pages back.  If the kernel needed
the memory first, the process will get a fresh zero filled page
like with MADV_DONTNEED.

In short:
- both MADV_FREE and MADV_DONTNEED only unmap file pages
- after MADV_DONTNEED the application will always get back
   fresh zero filled anonymous pages when accessing the
   memory
- after MADV_FREE the application can either get back the
   original data (without a page fault) or zero filled
   anonymous memory

The Linux MADV_DONTNEED behavior is not POSIX compliant.
POSIX says that with MADV_DONTNEED the application's data
will be preserved.

Currently glibc simply ignores POSIX_MADV_DONTNEED requests
from applications on Linux.  Changing the behaviour which
some Linux applications may rely on might not be the best
idea.

If you want POSIX_MADV_DONTNEED behaviour added, please let
me know and I'll whip up a patch.

> Because right now, I don't know where we are with respect to these things and
> I doubt if many of our users know either.  How can Michael write a manpage for
> this is we don't tell him what it all does?

If you need any additional information, please let me know.

If you still think the MADV_FREE patches themselves should
not be merged yet, can we at least merge the #defines, so
the Fedora kernel can get the MADV_FREE functionality?

Again, I'd be more than willing to whip up a patch for that.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
