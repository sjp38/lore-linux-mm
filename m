Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9E66B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 20:12:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a69so204008350pfa.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 17:12:12 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id z8si930759pff.143.2016.06.30.17.12.09
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 17:12:10 -0700 (PDT)
Subject: [PATCH 0/6] [v3] Workaround for Xeon Phi PTE A/D bits erratum
From: Dave Hansen <dave@sr71.net>
Date: Thu, 30 Jun 2016 17:12:09 -0700
Message-Id: <20160701001209.7DA24D1C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, Dave Hansen <dave@sr71.net>, minchan@kernel.org

The Intel(R) Xeon Phi(TM) Processor x200 Family (codename: Knights
Landing) has an erratum where a processor thread setting the Accessed
or Dirty bits may not do so atomically against its checks for the
Present bit.  This may cause a thread (which is about to page fault)
to set A and/or D, even though the Present bit had already been
atomically cleared.

If the PTE is used for storing a swap index or a NUMA migration index,
the A bit could be misinterpreted as part of the swap type.  The stray
bits being set cause a software-cleared PTE to be interpreted as a
swap entry.  In some cases (like when the swap index ends up being
for a non-existent swapfile), the kernel detects the stray value
and WARN()s about it, but there is no guarantee that the kernel can
always detect it.

This patch causes the page unmap path in vmscan/direct reclaim to
flush remote TLBs after clearing each page, and also clears the PTE
again after the flush.  For reclaim, this brings the behavior (and
associated reclaim performance) back to what it was before Mel's
changes that increased TLB flush batching.

For the unmap path, this patch may force some additional flushes, but
they are limited to a maximum of one per PTE page.  This patch clears
these stray A/D bits before releasing the pagetable lock which
prevents other parts of the kernel from observing the stray bits.

Andi Kleen wrote the original version of this patch, and Dave Hansen
added the batching.  The original version was much simpler but it
did too many extra TLB flushes which killed performance.

v3: huge rework to keep batching working in unmap case
v2: out of line. avoid single thread flush. cover more clear
    cases

Cc: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
