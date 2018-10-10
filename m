Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EAD676B026B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 06:00:19 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z28-v6so3979139pff.4
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 03:00:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 92-v6sor18455212pli.51.2018.10.10.03.00.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 03:00:18 -0700 (PDT)
Date: Wed, 10 Oct 2018 13:00:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Speed up mremap on large regions
Message-ID: <20181010100011.6jqjvgeslrvvyhr3@kshutemo-mobl1>
References: <20181009201400.168705-1-joel@joelfernandes.org>
 <20181009220222.26nzajhpsbt7syvv@kshutemo-mobl1>
 <20181009230447.GA17911@joelaf.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009230447.GA17911@joelaf.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@android.com, minchan@google.com, hughd@google.com, lokeshgidra@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Oct 09, 2018 at 04:04:47PM -0700, Joel Fernandes wrote:
> On Wed, Oct 10, 2018 at 01:02:22AM +0300, Kirill A. Shutemov wrote:
> > On Tue, Oct 09, 2018 at 01:14:00PM -0700, Joel Fernandes (Google) wrote:
> > > Android needs to mremap large regions of memory during memory management
> > > related operations. The mremap system call can be really slow if THP is
> > > not enabled. The bottleneck is move_page_tables, which is copying each
> > > pte at a time, and can be really slow across a large map. Turning on THP
> > > may not be a viable option, and is not for us. This patch speeds up the
> > > performance for non-THP system by copying at the PMD level when possible.
> > > 
> > > The speed up is three orders of magnitude. On a 1GB mremap, the mremap
> > > completion times drops from 160-250 millesconds to 380-400 microseconds.
> > > 
> > > Before:
> > > Total mremap time for 1GB data: 242321014 nanoseconds.
> > > Total mremap time for 1GB data: 196842467 nanoseconds.
> > > Total mremap time for 1GB data: 167051162 nanoseconds.
> > > 
> > > After:
> > > Total mremap time for 1GB data: 385781 nanoseconds.
> > > Total mremap time for 1GB data: 388959 nanoseconds.
> > > Total mremap time for 1GB data: 402813 nanoseconds.
> > > 
> > > Incase THP is enabled, the optimization is skipped. I also flush the
> > > tlb every time we do this optimization since I couldn't find a way to
> > > determine if the low-level PTEs are dirty. It is seen that the cost of
> > > doing so is not much compared the improvement, on both x86-64 and arm64.
> > 
> > Okay. That's interesting.
> > 
> > It makes me wounder why do we pass virtual address to pte_alloc() (and
> > pte_alloc_one() inside).
> > 
> > If an arch has real requirement to tight a page table to a virtual address
> > than the optimization cannot be used as it is. Per-arch should be fine
> > for this case, I guess.
> > 
> > If nobody uses the address we should just drop the argument as a
> > preparation to the patch.
> 
> I couldn't find any use of the address. But I am wondering why you feel
> passing the address is something that can't be done with the optimization.
> The pte_alloc only happens if the optimization is not triggered.

Yes, I now.

My worry is that some architecture has to allocate page table differently
depending on virtual address (due to aliasing or something). Original page
table was allocated for one virtual address and moving the page table to
different spot in virtual address space may break the invariant.

> Also the clean up of the argument that you're proposing is a bit out of scope
> of this patch but yeah we could clean it up in a separate patch if needed. I
> don't feel too strongly about that. It seems cosmetic and in the future if
> the address that's passed in is needed, then the architecture can use it.

Please, do. This should be pretty mechanical change, but it will help to
make sure that none of obscure architecture will be broken by the change.

-- 
 Kirill A. Shutemov
