Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 008406B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 11:50:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l66so37773359pfl.6
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 08:50:44 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id a19si2440643pgk.243.2017.03.15.08.50.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 08:50:44 -0700 (PDT)
Date: Wed, 15 Mar 2017 23:50:52 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170315155052.GA9585@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <c2e172b1-fb2a-57a0-0074-a07a61693e6c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c2e172b1-fb2a-57a0-0074-a07a61693e6c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Wed, Mar 15, 2017 at 03:56:02PM +0100, Vlastimil Babka wrote:
> On 03/15/2017 09:59 AM, Aaron Lu wrote:
> > For regular processes, the time taken in its exit() path to free its
> > used memory is not a problem. But there are heavy ones that consume
> > several Terabytes memory and the time taken to free its memory in its
> > exit() path could last more than ten minutes if THP is not used.
> > 
> > As Dave Hansen explained why do this in kernel:
> > "
> > One of the places we saw this happen was when an app crashed and was
> > exit()'ing under duress without cleaning up nicely.  The time that it
> > takes to unmap a few TB of 4k pages is pretty excessive.
> > "
> 
> Yeah, it would be nice to improve such cases.

Glad to hear this.

> 
> > To optimize this use case, a parallel free method is proposed here and
> > it is based on the current gather batch free(the following description
> > is taken from patch 2/5's changelog).
> > 
> > The current gather batch free works like this:
> > For each struct mmu_gather *tlb, there is a static buffer to store those
> > to-be-freed page pointers. The size is MMU_GATHER_BUNDLE, which is
> > defined to be 8. So if a tlb tear down doesn't free more than 8 pages,
> > that is all we need. If 8+ pages are to be freed, new pages will need
> > to be allocated to store those to-be-freed page pointers.
> > 
> > The structure used to describe the saved page pointers is called
> > struct mmu_gather_batch and tlb->local is of this type. tlb->local is
> > different than other struct mmu_gather_batch(es) in that the page
> > pointer array used by tlb->local points to the previouslly described
> > static buffer while the other struct mmu_gather_batch(es) page pointer
> > array points to the dynamically allocated pages.
> > 
> > These batches will form a singly linked list, starting from &tlb->local.
> > 
> > tlb->local.pages  => tlb->pages(8 pointers)
> >       \|/
> >       next => batch1->pages => about 510 pointers
> >                 \|/
> >                 next => batch2->pages => about 510 pointers
> >                           \|/
> >                           next => batch3->pages => about 510 pointers
> >                                     ... ...
> > 
> > The proposed parallel free did this: if the process has many pages to be
> > freed, accumulate them in these struct mmu_gather_batch(es) one after
> > another till 256K pages are accumulated. Then take this singly linked
> > list starting from tlb->local.next off struct mmu_gather *tlb and free
> > them in a worker thread. The main thread can return to continue zap
> > other pages(after freeing pages pointed by tlb->local.pages).
> > 
> > A test program that did a single malloc() of 320G memory is used to see
> > how useful the proposed parallel free solution is, the time calculated
> > is for the free() call. Test machine is a Haswell EX which has
> > 4nodes/72cores/144threads with 512G memory. All tests are done with THP
> > disabled.
> > 
> > kernel                             time
> > v4.10                              10.8s  +-2.8%
> > this patch(with default setting)   5.795s +-5.8%
> 
> I wonder if the difference would be larger if the parallelism was done
> on a higher level, something around unmap_page_range(). IIUC the current

We have tried to do it at the VMA level, but there is a problem: suppose
a program has many VMAs but only one or two of them are big/huge ones,
the parallism is not good.

I also considered PUD based parallel free, the potential issue with it
is: there could be very few physical pages actually present for that
PUD so the worker may have very few things to do.
For the test case used here though, PUD based one should work better
since all PTEs are faulted in.

> approach still leaves a lot of work to a single thread, right?

Yes, the main thread will be responsible for page table walk, PTE clear
and possibly flushing TLB in race condition. But considering the issues
of the other two mentioned approaches, I chose the current approach.

Perhaps I should also implement a PUD based parallel free and then use a
program that has 2 huge VMAs with equal size, one with all pages faulted
in RAM while the other has none and then compare the two approaches'
performance, does this make sense?

> I assume it would be more complicated, but doable as we already have the
> OOM reaper doing unmaps parallel to other activity? Has that been
> considered?

Since the tlb structure is not meant to be accessed concurrently, I
assume there will be some trouble to handle it if going the PUD based
approach. Will take a look at it tomorrow(it's late here).

Thanks.
-Aaron

> 
> Thanks, Vlastimil
> 
> > 
> > Patch 3/5 introduced a dedicated workqueue for the free workers and
> > here are more results when setting different values for max_active of
> > this workqueue:
> > 
> > max_active:   time
> > 1             8.9s   +-0.5%
> > 2             5.65s  +-5.5%
> > 4             4.84s  +-0.16%
> > 8             4.77s  +-0.97%
> > 16            4.85s  +-0.77%
> > 32            6.21s  +-0.46%
> > 
> > Comments are welcome and appreciated.
> > 
> > v2 changes: Nothing major, only minor ones.
> >  - rebased on top of v4.11-rc2-mmotm-2017-03-14-15-41;
> >  - use list_add_tail instead of list_add to add worker to tlb's worker
> >    list so that when doing flush, the first queued worker gets flushed
> >    first(based on the comsumption that the first queued worker has a
> >    better chance of finishing its job than those later queued workers);
> >  - use bool instead of int for variable free_batch_page in function
> >    tlb_flush_mmu_free_batches;
> >  - style change according to ./scripts/checkpatch;
> >  - reword some of the changelogs to make it more readable.
> > 
> > v1 is here:
> > https://lkml.org/lkml/2017/2/24/245
> > 
> > Aaron Lu (5):
> >   mm: add tlb_flush_mmu_free_batches
> >   mm: parallel free pages
> >   mm: use a dedicated workqueue for the free workers
> >   mm: add force_free_pages in zap_pte_range
> >   mm: add debugfs interface for parallel free tuning
> > 
> >  include/asm-generic/tlb.h |  15 ++---
> >  mm/memory.c               | 141 +++++++++++++++++++++++++++++++++++++++-------
> >  2 files changed, 128 insertions(+), 28 deletions(-)
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
