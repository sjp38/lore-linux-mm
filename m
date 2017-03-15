Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF386B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 05:00:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c23so18978413pfj.0
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 02:00:00 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n16si1050996pfk.309.2017.03.15.01.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 01:59:59 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v2 0/5] mm: support parallel free of memory
Date: Wed, 15 Mar 2017 16:59:59 +0800
Message-Id: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>

For regular processes, the time taken in its exit() path to free its
used memory is not a problem. But there are heavy ones that consume
several Terabytes memory and the time taken to free its memory in its
exit() path could last more than ten minutes if THP is not used.

As Dave Hansen explained why do this in kernel:
"
One of the places we saw this happen was when an app crashed and was
exit()'ing under duress without cleaning up nicely.  The time that it
takes to unmap a few TB of 4k pages is pretty excessive.
"

To optimize this use case, a parallel free method is proposed here and
it is based on the current gather batch free(the following description
is taken from patch 2/5's changelog).

The current gather batch free works like this:
For each struct mmu_gather *tlb, there is a static buffer to store those
to-be-freed page pointers. The size is MMU_GATHER_BUNDLE, which is
defined to be 8. So if a tlb tear down doesn't free more than 8 pages,
that is all we need. If 8+ pages are to be freed, new pages will need
to be allocated to store those to-be-freed page pointers.

The structure used to describe the saved page pointers is called
struct mmu_gather_batch and tlb->local is of this type. tlb->local is
different than other struct mmu_gather_batch(es) in that the page
pointer array used by tlb->local points to the previouslly described
static buffer while the other struct mmu_gather_batch(es) page pointer
array points to the dynamically allocated pages.

These batches will form a singly linked list, starting from &tlb->local.

tlb->local.pages  => tlb->pages(8 pointers)
      \|/
      next => batch1->pages => about 510 pointers
                \|/
                next => batch2->pages => about 510 pointers
                          \|/
                          next => batch3->pages => about 510 pointers
                                    ... ...

The proposed parallel free did this: if the process has many pages to be
freed, accumulate them in these struct mmu_gather_batch(es) one after
another till 256K pages are accumulated. Then take this singly linked
list starting from tlb->local.next off struct mmu_gather *tlb and free
them in a worker thread. The main thread can return to continue zap
other pages(after freeing pages pointed by tlb->local.pages).

A test program that did a single malloc() of 320G memory is used to see
how useful the proposed parallel free solution is, the time calculated
is for the free() call. Test machine is a Haswell EX which has
4nodes/72cores/144threads with 512G memory. All tests are done with THP
disabled.

kernel                             time
v4.10                              10.8s  A+-2.8%
this patch(with default setting)   5.795s A+-5.8%

Patch 3/5 introduced a dedicated workqueue for the free workers and
here are more results when setting different values for max_active of
this workqueue:

max_active:   time
1             8.9s   A+-0.5%
2             5.65s  A+-5.5%
4             4.84s  A+-0.16%
8             4.77s  A+-0.97%
16            4.85s  A+-0.77%
32            6.21s  A+-0.46%

Comments are welcome and appreciated.

v2 changes: Nothing major, only minor ones.
 - rebased on top of v4.11-rc2-mmotm-2017-03-14-15-41;
 - use list_add_tail instead of list_add to add worker to tlb's worker
   list so that when doing flush, the first queued worker gets flushed
   first(based on the comsumption that the first queued worker has a
   better chance of finishing its job than those later queued workers);
 - use bool instead of int for variable free_batch_page in function
   tlb_flush_mmu_free_batches;
 - style change according to ./scripts/checkpatch;
 - reword some of the changelogs to make it more readable.

v1 is here:
https://lkml.org/lkml/2017/2/24/245

Aaron Lu (5):
  mm: add tlb_flush_mmu_free_batches
  mm: parallel free pages
  mm: use a dedicated workqueue for the free workers
  mm: add force_free_pages in zap_pte_range
  mm: add debugfs interface for parallel free tuning

 include/asm-generic/tlb.h |  15 ++---
 mm/memory.c               | 141 +++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 128 insertions(+), 28 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
