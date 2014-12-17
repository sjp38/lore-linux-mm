Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D3DAF6B006E
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 05:08:23 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so13855494pdi.7
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 02:08:23 -0800 (PST)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id au1si4902426pbc.117.2014.12.17.02.08.21
        for <linux-mm@kvack.org>;
        Wed, 17 Dec 2014 02:08:22 -0800 (PST)
Date: Wed, 17 Dec 2014 10:08:11 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: post-3.18 performance regression in TLB flushing code
Message-ID: <20141217100810.GA3461@arm.com>
References: <5490A5F8.6050504@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5490A5F8.6050504@sr71.net>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Simek <monstr@monstr.eu>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi Dave,

Thanks for reporting this.

On Tue, Dec 16, 2014 at 09:36:56PM +0000, Dave Hansen wrote:
> I'm running the 'brk1' test from will-it-scale:
> 
> > https://github.com/antonblanchard/will-it-scale/blob/master/tests/brk1.c
> 
> on a 8-socket/160-thread system.  It's seeing about a 6% drop in
> performance (263M -> 247M ops/sec at 80-threads) from this commit:

This is x86, right?

> 	commit fb7332a9fedfd62b1ba6530c86f39f0fa38afd49
> 	Author: Will Deacon <will.deacon@arm.com>
> 	Date:   Wed Oct 29 10:03:09 2014 +0000
> 
> 	 mmu_gather: move minimal range calculations into generic code
> 
> tlb_finish_mmu() goes up about 9x in the profiles (~0.4%->3.6%) and
> tlb_flush_mmu_free() takes about 3.1% of CPU time with the patch
> applied, but does not show up at all on the commit before.

Ouch...

> This isn't a major regression, but it is rather unfortunate for a patch
> that is apparently a code cleanup.  It also _looks_ to show up even when
> things are single-threaded, although I haven't looked at it in detail.

Ok, so there are two parts to this patch:

  (1) Fixing an issue where the arch code (arm64 in my case) wanted to
      adjust the range behind the back of the core code, which resulted
      in negative ranges being flushed

  (2) A cleanup removing the need_flush field, since we can now rely
      on tlb->end != 0 to indicate that a flush is needed

> I suspect the tlb->need_flush logic was serving some role that the
> modified code isn't capturing like in this hunk:
> 
> >  void tlb_flush_mmu(struct mmu_gather *tlb)
> >  {
> > -       if (!tlb->need_flush)
> > -               return;
> >         tlb_flush_mmu_tlbonly(tlb);
> >         tlb_flush_mmu_free(tlb);
> >  }
> 
> tlb_flush_mmu_tlbonly() has tlb->end check (which replaces the
> ->need_flush logic), but tlb_flush_mmu_free() does not.

Yes, I thought tlb_flush_mmu_free wouldn't do anything if we hadn't batched,
but actually free_pages_and_swap_cache does have work outside of the loop.

> If we add a !tlb->end (patch attached) to tlb_flush_mmu(), that gets us
> back up to ~258M ops/sec, but that's still ~2% down from where we started.

I think there are a couple of things you could try to see if that 2% comes
back:

  * Revert the patch and try the one here [1] instead (which only does part
    (1) of the above).

-- or --

  * Instead of adding the tlb->end check to tlb_flush_mmu, add it to
    tlb_flush_mmu_free

Could you give that a go, please?

Cheers,

Will

[1] http://www.spinics.net/lists/kernel/msg1855260.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
