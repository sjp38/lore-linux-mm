Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6C62B6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 11:34:37 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so16160428pab.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 08:34:37 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id nl4si9366778pbc.114.2015.06.09.08.34.36
        for <linux-mm@kvack.org>;
        Tue, 09 Jun 2015 08:34:36 -0700 (PDT)
Message-ID: <5577078B.2000503@intel.com>
Date: Tue, 09 Jun 2015 08:34:35 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
References: <1433767854-24408-1-git-send-email-mgorman@suse.de> <20150608174551.GA27558@gmail.com> <20150609084739.GQ26425@suse.de> <20150609103231.GA11026@gmail.com> <20150609112055.GS26425@suse.de> <20150609124328.GA23066@gmail.com>
In-Reply-To: <20150609124328.GA23066@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 06/09/2015 05:43 AM, Ingo Molnar wrote:
> I cited very real numbers about the direct costs of TLB flushes, and plausible 
> speculation about why the indirect costs are low on the achitecture you are trying 
> to modify here.

We should be careful to extrapolate what the real-world cost of a TLB
flush is from the cost of running a kernel function in a loop.

Let's look at what got measured:

> +static char tlb_flush_target[PAGE_SIZE] __aligned(4096);
> +static void fn_flush_tlb_one(void)
> +{
> +	unsigned long addr = (unsigned long)&tlb_flush_target;
> +
> +	tlb_flush_target[0]++;
> +	__flush_tlb_one(addr);
> +}

So we've got an increment of a variable in kernel memory (which is
almost surely in the L1), then we flush that memory location, and repeat
the increment.

I assume the increment is so that the __flush_tlb_one() has some "real"
work to do and is not just flushing an address which is not in the TLB.
 This is almost certainly a departure from workloads like Mel is
addressing where we (try to) flush pages used long ago that will
hopefully *not* be in the TLB.

But, that unfortunately means that we're measuring a TLB _miss_ here in
addition to the flush.  A TLB miss shouldn't be *that* expensive, right?
 The SDM says: "INVLPG also invalidates all entries in all
paging-structure caches ... regardless of the linear addresses to which
they correspond."  Ugh, so the TLB refill has to also refill the paging
structure caches.  At least the page tables will be in the L1.

Since "tlb_flush_target" is in kernel mapping, you might also be
shooting down the TLB entry for kernel text, or who knows what else.
The TLB entry might be 1G or 2M which might never be in the STLB
(second-level TLB), which could have *VERY* different behavior than a 4k
flush or a flush of an entry in the first-level TLB.

I'm not sure that these loop-style tests are particularly valuable, but
if we're going to do it, I think we should consider:
1. We need to separate the TLB fill portion from the flush and not
   measure any part of a fill along with the flush
2. We should measure flushing of ascending, adjacent virtual addresses
   mapped with 4k pages since that is the normal case.  Perhaps
   vmalloc(16MB) or something.
3. We should flush a mix of virtual addresses that are in and out of the
   TLB.
4. To measure instruction (as opposed to instruction+software)
   overhead, use __flush_tlb_single(), not __flush_tlb_one()

P.S.  I think I'm responsible for it, but we should probably also move
the count_vm_tlb_event() to outside the loop in flush_tlb_mm_range().
invlpg is not a "normal" instruction and could potentially increase the
overhead of incrementing the counter.  But, I guess the kernel mappings
_should_ stay in the TLB over an invlpg and shouldn't pay any cost to be
refilled in to the TLB despite the paging-structure caches going away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
