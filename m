Received: from blonde.wat.veritas.com([10.10.97.26]) (1869 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1FdQJ1-0002AgC@megami.veritas.com>
	for <linux-mm@kvack.org>; Tue, 9 May 2006 04:23:07 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Tue, 9 May 2006 12:23:00 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Any reason for passing "tlb" to "free_pgtables()" by address?
In-Reply-To: <445FBD1B.6080404@free.fr>
Message-ID: <Pine.LNX.4.64.0605091207030.19410@blonde.wat.veritas.com>
References: <445B2EBD.4020803@bull.net> <Pine.LNX.4.64.0605051337520.6945@blonde.wat.veritas.com>
 <445FBD1B.6080404@free.fr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zoltan Menyhart <Zoltan.Menyhart@free.fr>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 May 2006, Zoltan Menyhart wrote:
> 
> Could you please explain what your plans are?

Nick already answered, and I agree with his answer;
but I get the feeling you'd like to hear it from me too.

My plan (as his) is to rework the mmu_gather TLB flush batching
so that it can be done without disabling preemption, so that it
does not add to latency.

Nick uses the pagetables themselves as buffering, I allocate a
temporary buffer: in each case we abandon the per-cpu arrays which
need preemption disabled.  But neither patch is good enough yet.

> How much do you think it is worth to optimize "free_pgtables()",
> knowing that:
> - PTE, PMD and PUD pages are freed seldom (wrt. the leaf pages)
> - The number of these pages is much more less than
>   that of the leaf pages.

Not worth much at all in comparison: it just falls automatically
out of the mmu_gathering rework which covers the leaf pages too.

But free_pgtables is where I got caught out inadvertently adding
latency in 2.6.15, so I've a responsibility to correct that case.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
