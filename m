From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: GRU driver feedback
Date: Thu, 31 Jul 2008 17:14:04 +1000
References: <20080723141229.GB13247@wotan.suse.de> <20080729185315.GA14260@sgi.com> <200807301550.34500.nickpiggin@yahoo.com.au>
In-Reply-To: <200807301550.34500.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807311714.05252.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: "Torvalds, Linus" <torvalds@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 30 July 2008 15:50, Nick Piggin wrote:
> On Wednesday 30 July 2008 04:53, Robin Holt wrote:

> > In the case where unmap_region is clearing page tables, the caller to
> > unmap_region is expected to be holding the mmap_sem writably.  Jacks
> > fault handler will immediately return when it fails on the
> > down_read_trylock().
>
> No, you are right of course. I had in my mind the problems faced by
> lockless get_user_pages, in which case I was worried about the page table
> existence, but missed the fact that you're holding mmap_sem to provide
> existence (which it would, as you note, although one day we may want to
> reclaim page tables or something that doesn't take mmap_sem, so a big
> comment would be nice here).

The other thing is... then GRU should get rid of the local_irq_disable
in the atomic pte lookup. By definition it is worthless if we can be
operating on an mm that is not running on current (and if I understand
correctly, sn2 can avoid sending tlb flush IPIs completely sometimes?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
