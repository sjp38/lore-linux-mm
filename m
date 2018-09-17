Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36B438E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 13:53:47 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f32-v6so6630801pgm.14
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 10:53:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c64-v6sor2593329pfe.54.2018.09.17.10.53.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Sep 2018 10:53:45 -0700 (PDT)
Date: Tue, 18 Sep 2018 03:53:37 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 3/3] mm: optimise pte dirty/accessed bit setting by
 demand based pte insertion
Message-ID: <20180918035337.0727dad0@roar.ozlabs.ibm.com>
In-Reply-To: <20180905142951.GA15680@roeck-us.net>
References: <20180828112034.30875-1-npiggin@gmail.com>
	<20180828112034.30875-4-npiggin@gmail.com>
	<20180905142951.GA15680@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ley Foon Tan <lftan@altera.com>, nios2-dev@lists.rocketboards.org

On Wed, 5 Sep 2018 07:29:51 -0700
Guenter Roeck <linux@roeck-us.net> wrote:

> Hi,
> 
> On Tue, Aug 28, 2018 at 09:20:34PM +1000, Nicholas Piggin wrote:
> > Similarly to the previous patch, this tries to optimise dirty/accessed
> > bits in ptes to avoid access costs of hardware setting them.
> >   
> 
> This patch results in silent nios2 boot failures, silent meaning that
> the boot stalls.

Okay I just got back to looking at this. The reason for the hang is
I think a bug in the nios2 TLB code, but maybe other archs have similar
issues.

In case of a missing / !present Linux pte, nios2 installs a TLB entry
with no permissions via its fast TLB exception handler (software TLB
fill). Then it relies on that causing a TLB permission exception in a
slower handler that calls handle_mm_fault to set the Linux pte and
flushes the old TLB. Then the fast exception handler will find the new
Linux pte.

With this patch, nios2 has a case where handle_mm_fault does not flush
the old TLB, which results in the TLB permission exception continually
being retried.

What happens now is that fault paths like do_read_fault will install a
Linux pte with the young bit clear and return. That will cause nios2 to
fault again but this time go down the bottom of handle_pte_fault and to
the access flags update with the young bit set. The young bit is seen to
be different, so that causes ptep_set_access_flags to do a TLB flush and
that finally allows the fast TLB handler to fire and pick up the new
Linux pte.

With this patch, the young bit is set in the first handle_mm_fault, so
the second handle_mm_fault no longer sees the ptes are different and
does not flush the TLB. The spurious fault handler also does not flush
them unless FAULT_FLAG_WRITE is set.

What nios2 should do is invalidate the TLB in update_mmu_cache. What it
*really* should do is install the new TLB entry, I have some patches to
make that work in qemu I can submit. But I would like to try getting
these dirty/accessed bit optimisation in 4.20, so I will send a simple
path to just do the TLB invalidate that could go in Andrew's git tree.

Is that agreeable with the nios2 maintainers?

Thanks,
Nick
