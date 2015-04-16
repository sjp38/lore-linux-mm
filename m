Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3A03B6B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 05:19:30 -0400 (EDT)
Received: by wgin8 with SMTP id n8so73714177wgi.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 02:19:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y5si14741456wix.98.2015.04.16.02.19.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 02:19:28 -0700 (PDT)
Date: Thu, 16 Apr 2015 10:19:22 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/4] mm: Send a single IPI to TLB flush multiple pages
 when unmapping
Message-ID: <20150416091922.GN14842@suse.de>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de>
 <1429094576-5877-3-git-send-email-mgorman@suse.de>
 <552ED214.3050105@redhat.com>
 <alpine.LSU.2.11.1504151410150.13745@eggly.anvils>
 <20150415212855.GI14842@suse.de>
 <20150416063826.GA7721@blaptop>
 <20150416080722.GL14842@suse.de>
 <20150416082955.GA10867@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150416082955.GA10867@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 16, 2015 at 05:29:55PM +0900, Minchan Kim wrote:
> On Thu, Apr 16, 2015 at 09:07:22AM +0100, Mel Gorman wrote:
> > On Thu, Apr 16, 2015 at 03:38:26PM +0900, Minchan Kim wrote:
> > > Hello Mel,
> > > 
> > > On Wed, Apr 15, 2015 at 10:28:55PM +0100, Mel Gorman wrote:
> > > > On Wed, Apr 15, 2015 at 02:16:49PM -0700, Hugh Dickins wrote:
> > > > > On Wed, 15 Apr 2015, Rik van Riel wrote:
> > > > > > On 04/15/2015 06:42 AM, Mel Gorman wrote:
> > > > > > > An IPI is sent to flush remote TLBs when a page is unmapped that was
> > > > > > > recently accessed by other CPUs. There are many circumstances where this
> > > > > > > happens but the obvious one is kswapd reclaiming pages belonging to a
> > > > > > > running process as kswapd and the task are likely running on separate CPUs.
> > > > > > > 
> > > > > > > On small machines, this is not a significant problem but as machine
> > > > > > > gets larger with more cores and more memory, the cost of these IPIs can
> > > > > > > be high. This patch uses a structure similar in principle to a pagevec
> > > > > > > to collect a list of PFNs and CPUs that require flushing. It then sends
> > > > > > > one IPI to flush the list of PFNs. A new TLB flush helper is required for
> > > > > > > this and one is added for x86. Other architectures will need to decide if
> > > > > > > batching like this is both safe and worth the memory overhead. Specifically
> > > > > > > the requirement is;
> > > > > > > 
> > > > > > > 	If a clean page is unmapped and not immediately flushed, the
> > > > > > > 	architecture must guarantee that a write to that page from a CPU
> > > > > > > 	with a cached TLB entry will trap a page fault.
> > > > > > > 
> > > > > > > This is essentially what the kernel already depends on but the window is
> > > > > > > much larger with this patch applied and is worth highlighting.
> > > > > > 
> > > > > > This means we already have a (hard to hit?) data corruption
> > > > > > issue in the kernel.  We can lose data if we unmap a writable
> > > > > > but not dirty pte from a file page, and the task writes before
> > > > > > we flush the TLB.
> > > > > 
> > > > > I don't think so.  IIRC, when the CPU needs to set the dirty bit,
> > > > > it doesn't just do that in its TLB entry, but has to fetch and update
> > > > > the actual pte entry - and at that point discovers it's no longer
> > > > > valid so traps, as Mel says.
> > > > > 
> > > > 
> > > > This is what I'm expecting i.e. clean->dirty transition is write-through
> > > > to the PTE which is now unmapped and it traps. I'm assuming there is an
> > > > architectural guarantee that it happens but could not find an explicit
> > > > statement in the docs. I'm hoping Dave or Andi can check with the relevant
> > > > people on my behalf.
> > > 
> > > A dumb question. It's not related to your patch but MADV_FREE.
> > > 
> > > clean->dirty transition is *atomic* as well as write-through?
> > 
> > This is the TLB cache clean->dirty transition so it's not 100% clear what you
> > are asking. It both needs to be write-through and the TLB updates must happen
> > before the actual data write to cache or memory and it must be ordered.
> 
> Sorry for not clear. I will try again.
> 
> In try_to_unmap_one,
> 
> 
>         pteval = ptep_clear_flush(vma, address, pte);
>         {
>                 pte = ptep_get_and_clear(mm, address, ptep);
>                         <-------------- A application write on other CPU.
>                 flush_tlb_page(vma, address);
>         } 
>  
>         /* Move the dirty bit to the physical page now the pte is gone. */
>         dirty = pte_dirty(pteval);
>         if (dirty)
>                 set_page_dirty(page);
>         ...
> 
> 
> In above, ptep_clear_flush just does xchg operation to make pte zero
> in ptep_get_and_clear and return old pte_val but didn't flush TLB yet.

Correct.

> Let's assume old pte_val doesn't have dirty bit(ie, it was clean).
> If application on other CPU does write the memory at the same time,
> what happens?

The comments describe the architectural guarantee I'm looking for. Dave
says he's asking the relevant people within Intel. I revised the comment
in the unreleased V2 so it reads

                /*
                 * We clear the PTE but do not flush so potentially a remote
                 * CPU could still be writing to the page. If the entry was
                 * previously clean then the architecture must guarantee that
                 * a clear->dirty transition on a cached TLB entry is written
                 * through and traps if the PTE is unmapped. If the entry is
                 * already dirty then it's handled below by the
                 * pte_dirty check.
                 */

> I mean (pte cleaning/return old) and (dirty bit setting by CPU itself)
> should be exclusive so application on another CPU should encounter
> page fault or we should see the dirty bit.
> Is it guaranteed?
> 

This is the key question. I think "yes it must be" but Dave is going to
get the definite answer in the x86 case. Each architecture will need to
examine the issue separately.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
