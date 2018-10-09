Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3826B0005
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 18:02:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z12-v6so2997608pfl.17
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 15:02:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b3-v6sor11964671pgw.3.2018.10.09.15.02.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 15:02:29 -0700 (PDT)
Date: Wed, 10 Oct 2018 01:02:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Speed up mremap on large regions
Message-ID: <20181009220222.26nzajhpsbt7syvv@kshutemo-mobl1>
References: <20181009201400.168705-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009201400.168705-1-joel@joelfernandes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@android.com, minchan@google.com, hughd@google.com, lokeshgidra@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Oct 09, 2018 at 01:14:00PM -0700, Joel Fernandes (Google) wrote:
> Android needs to mremap large regions of memory during memory management
> related operations. The mremap system call can be really slow if THP is
> not enabled. The bottleneck is move_page_tables, which is copying each
> pte at a time, and can be really slow across a large map. Turning on THP
> may not be a viable option, and is not for us. This patch speeds up the
> performance for non-THP system by copying at the PMD level when possible.
> 
> The speed up is three orders of magnitude. On a 1GB mremap, the mremap
> completion times drops from 160-250 millesconds to 380-400 microseconds.
> 
> Before:
> Total mremap time for 1GB data: 242321014 nanoseconds.
> Total mremap time for 1GB data: 196842467 nanoseconds.
> Total mremap time for 1GB data: 167051162 nanoseconds.
> 
> After:
> Total mremap time for 1GB data: 385781 nanoseconds.
> Total mremap time for 1GB data: 388959 nanoseconds.
> Total mremap time for 1GB data: 402813 nanoseconds.
> 
> Incase THP is enabled, the optimization is skipped. I also flush the
> tlb every time we do this optimization since I couldn't find a way to
> determine if the low-level PTEs are dirty. It is seen that the cost of
> doing so is not much compared the improvement, on both x86-64 and arm64.

Okay. That's interesting.

It makes me wounder why do we pass virtual address to pte_alloc() (and
pte_alloc_one() inside).

If an arch has real requirement to tight a page table to a virtual address
than the optimization cannot be used as it is. Per-arch should be fine
for this case, I guess.

If nobody uses the address we should just drop the argument as a
preparation to the patch.

Anyway, I think the optimization requires some groundwork before it can be
accepted. At least some explanation why it is safe to move page table from
one spot in virtual address space to another.

-- 
 Kirill A. Shutemov
