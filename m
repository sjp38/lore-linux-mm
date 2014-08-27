Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A0B846B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 08:50:38 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so362372wib.16
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 05:50:36 -0700 (PDT)
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
        by mx.google.com with ESMTPS id ey16si1447337wid.15.2014.08.27.05.50.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 05:50:35 -0700 (PDT)
Received: by mail-we0-f176.google.com with SMTP id q58so172838wes.21
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 05:50:35 -0700 (PDT)
Date: Wed, 27 Aug 2014 13:50:28 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATH V2 1/6] mm: Introduce a general RCU get_user_pages_fast.
Message-ID: <20140827125027.GA7765@linaro.org>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-2-git-send-email-steve.capper@linaro.org>
 <20140827085442.GD16376@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827085442.GD16376@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, Aug 27, 2014 at 09:54:42AM +0100, Will Deacon wrote:
> Hi Steve,
> 

Hey Will,

> A few minor comments (took me a while to understand how this works, so I
> thought I'd make some noise :)

A big thank you for reading through it :-).

> 
> On Thu, Aug 21, 2014 at 04:43:27PM +0100, Steve Capper wrote:
> > get_user_pages_fast attempts to pin user pages by walking the page
> > tables directly and avoids taking locks. Thus the walker needs to be
> > protected from page table pages being freed from under it, and needs
> > to block any THP splits.
> > 
> > One way to achieve this is to have the walker disable interrupts, and
> > rely on IPIs from the TLB flushing code blocking before the page table
> > pages are freed.
> > 
> > On some platforms we have hardware broadcast of TLB invalidations, thus
> > the TLB flushing code doesn't necessarily need to broadcast IPIs; and
> > spuriously broadcasting IPIs can hurt system performance if done too
> > often.
> > 
> > This problem has been solved on PowerPC and Sparc by batching up page
> > table pages belonging to more than one mm_user, then scheduling an
> > rcu_sched callback to free the pages. This RCU page table free logic
> > has been promoted to core code and is activated when one enables
> > HAVE_RCU_TABLE_FREE. Unfortunately, these architectures implement
> > their own get_user_pages_fast routines.
> > 
> > The RCU page table free logic coupled with a an IPI broadcast on THP
> > split (which is a rare event), allows one to protect a page table
> > walker by merely disabling the interrupts during the walk.
> 
> Disabling interrupts isn't completely free (it's a self-synchronising
> operation on ARM). It would be interesting to see if your futex workload
> performance is improved by my simple irq_save optimisation for ARM:
> 
>   https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/commit/?h=misc-patches&id=312a70adfa6f22e9d62803dd21400f481253e58b
> 
> (I've been struggling to show anything other than tiny improvements from
> that patch).
> 

This looks like a useful optimisation; I'll have a think about workloads that
fire many futexes on THP tails. (The test I used only fired off one futex).

> > This patch provides a general RCU implementation of get_user_pages_fast
> > that can be used by architectures that perform hardware broadcast of
> > TLB invalidations.
> > 
> > It is based heavily on the PowerPC implementation by Nick Piggin.
> 
> [...]
> 
> > diff --git a/mm/gup.c b/mm/gup.c
> > index 91d044b..2f684fa 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -10,6 +10,10 @@
> >  #include <linux/swap.h>
> >  #include <linux/swapops.h>
> >  
> > +#include <linux/sched.h>
> > +#include <linux/rwsem.h>
> > +#include <asm/pgtable.h>
> > +
> >  #include "internal.h"
> >  
> >  static struct page *no_page_table(struct vm_area_struct *vma,
> > @@ -672,3 +676,277 @@ struct page *get_dump_page(unsigned long addr)
> >  	return page;
> >  }
> >  #endif /* CONFIG_ELF_CORE */
> > +
> > +#ifdef CONFIG_HAVE_RCU_GUP
> > +
> > +#ifdef __HAVE_ARCH_PTE_SPECIAL
> 
> Do we actually require this (pte special) if hugepages are disabled or
> not supported?

We need this logic if we want use fast_gup on normal pages safely. The special
bit indicates that we should not attempt to take a reference to the underlying
page.

Huge pages are guaranteed not to be special.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
