Date: Wed, 23 Feb 2000 16:44:01 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: mmap/munmap semantics
Message-ID: <20000223164401.D5598@pcep-jamie.cern.ch>
References: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de> <m1hff0fuiu.fsf@flinx.hidden>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m1hff0fuiu.fsf@flinx.hidden>; from Eric W. Biederman on Tue, Feb 22, 2000 at 09:49:13PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Richard Guenther <richard.guenther@student.uni-tuebingen.de>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Eric W. Biederman wrote:
> > For the second case either the munmap call needs to be extended or
> > some sort of madvise with a MADV_CLEAN flag? 
> Poking holes is probably not what you want.  The zeroing cost
> will be paid somewhere.

MADV_CLEAN, or perhaps a different syscall mdiscard() (as it's page
based and doesn't change vmas) looks utterly wrong for this application,
but it does have a very nice use for memory allocators.

With memory allocators you could use mdiscard to tell the kernel to
decide whether to replace a privately mapped page by its original
backing page.

For /dev/zero that means you can let the kernel decide whether to
reclaim the memory, or if the application can keep the page.  The nice
part is that the decision can be deferred: you are simply informing the
kernel that a page can be reclaimed later on demand.  But the
application doesn't need to know when the decision happens -- it assumes
it is immediate.

This is appropriate for freed memory areas, and is not something that
the application can do itself.  mmaping /dev/zero over the page doesn't
work because that _always_ causes an undesirable zero copy, not to
mention expensive vma operations, when what you want is to simply mark
pages for potential reclaim _if_ the kernel decides it could reclaim the
page in the intervening time.

enjoy,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
