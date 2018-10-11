Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 76BE66B0269
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 04:26:34 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id i8-v6so3813363wma.9
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 01:26:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j72-v6sor10295093wmj.2.2018.10.11.01.26.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 01:26:32 -0700 (PDT)
Date: Thu, 11 Oct 2018 11:17:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Speed up mremap on large regions
Message-ID: <20181011081719.77f7ihcy6mu2vkkc@kshutemo-mobl1>
References: <20181009201400.168705-1-joel@joelfernandes.org>
 <20181009220222.26nzajhpsbt7syvv@kshutemo-mobl1>
 <20181009230447.GA17911@joelaf.mtv.corp.google.com>
 <20181010100011.6jqjvgeslrvvyhr3@kshutemo-mobl1>
 <20181011004618.GA237677@joelaf.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181011004618.GA237677@joelaf.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@android.com, minchan@google.com, hughd@google.com, lokeshgidra@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Oct 10, 2018 at 05:46:18PM -0700, Joel Fernandes wrote:
> On Wed, Oct 10, 2018 at 01:00:11PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Oct 09, 2018 at 04:04:47PM -0700, Joel Fernandes wrote:
> > > On Wed, Oct 10, 2018 at 01:02:22AM +0300, Kirill A. Shutemov wrote:
> > > > On Tue, Oct 09, 2018 at 01:14:00PM -0700, Joel Fernandes (Google) wrote:
> > > > > Android needs to mremap large regions of memory during memory management
> > > > > related operations. The mremap system call can be really slow if THP is
> > > > > not enabled. The bottleneck is move_page_tables, which is copying each
> > > > > pte at a time, and can be really slow across a large map. Turning on THP
> > > > > may not be a viable option, and is not for us. This patch speeds up the
> > > > > performance for non-THP system by copying at the PMD level when possible.
> > > > > 
> > > > > The speed up is three orders of magnitude. On a 1GB mremap, the mremap
> > > > > completion times drops from 160-250 millesconds to 380-400 microseconds.
> > > > > 
> > > > > Before:
> > > > > Total mremap time for 1GB data: 242321014 nanoseconds.
> > > > > Total mremap time for 1GB data: 196842467 nanoseconds.
> > > > > Total mremap time for 1GB data: 167051162 nanoseconds.
> > > > > 
> > > > > After:
> > > > > Total mremap time for 1GB data: 385781 nanoseconds.
> > > > > Total mremap time for 1GB data: 388959 nanoseconds.
> > > > > Total mremap time for 1GB data: 402813 nanoseconds.
> > > > > 
> > > > > Incase THP is enabled, the optimization is skipped. I also flush the
> > > > > tlb every time we do this optimization since I couldn't find a way to
> > > > > determine if the low-level PTEs are dirty. It is seen that the cost of
> > > > > doing so is not much compared the improvement, on both x86-64 and arm64.
> > > > 
> > > > Okay. That's interesting.
> > > > 
> > > > It makes me wounder why do we pass virtual address to pte_alloc() (and
> > > > pte_alloc_one() inside).
> > > > 
> > > > If an arch has real requirement to tight a page table to a virtual address
> > > > than the optimization cannot be used as it is. Per-arch should be fine
> > > > for this case, I guess.
> > > > 
> > > > If nobody uses the address we should just drop the argument as a
> > > > preparation to the patch.
> > > 
> > > I couldn't find any use of the address. But I am wondering why you feel
> > > passing the address is something that can't be done with the optimization.
> > > The pte_alloc only happens if the optimization is not triggered.
> > 
> > Yes, I now.
> > 
> > My worry is that some architecture has to allocate page table differently
> > depending on virtual address (due to aliasing or something). Original page
> > table was allocated for one virtual address and moving the page table to
> > different spot in virtual address space may break the invariant.
> > 
> > > Also the clean up of the argument that you're proposing is a bit out of scope
> > > of this patch but yeah we could clean it up in a separate patch if needed. I
> > > don't feel too strongly about that. It seems cosmetic and in the future if
> > > the address that's passed in is needed, then the architecture can use it.
> > 
> > Please, do. This should be pretty mechanical change, but it will help to
> > make sure that none of obscure architecture will be broken by the change.
> > 
> 
> The thing is its quite a lot of change, I wrote a coccinelle script to do it
> tree wide, following is the diffstat:
>  48 files changed, 91 insertions(+), 124 deletions(-)
> 
> Imagine then having to add the address argument back in the future in case
> its ever needed. Is it really worth doing it?

This is the point. It will get us chance to consider if the optimization
is still safe.

And it shouldn't be hard: [partially] revert the commit and get the address
back into the interface.

> First script : Remove the address argument from pte_alloc and friends:

...

Please add __pte_alloc(), __pte_alloc_kernel() and pte_alloc() to the
list for patching.

-- 
 Kirill A. Shutemov
