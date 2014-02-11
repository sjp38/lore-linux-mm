Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 71E146B0037
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 22:06:10 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so7132952pbc.38
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 19:06:10 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id b4si5750583pbe.328.2014.02.10.19.06.09
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 19:06:09 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 0/2] mm: map few pages around fault address if they are in page cache
Date: Tue, 11 Feb 2014 05:05:55 +0200
Message-Id: <1392087957-15730-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Okay, it's RFC only. I haven't stabilize it yet. And it's 5 AM...

It kind of work on small test-cases in kvm, but hung my laptop shortly
after boot. So no benchmark data.

The patches are on top of mine __do_fault() cleanup.

The idea is to minimize number of minor page faults by mapping pages around
the fault address if they are already in page cache.

With the patches we try to map up to 32 pages (subject to change) on read
page fault. Later can extended to write page faults to shared mappings if
works well.

The pages must be on the same page table so we can change all ptes under
one lock.

I tried to avoid additional latency, so we don't wait page to get ready,
just skip to the next one.

The only place where we can get stuck for relatively long time is
do_async_mmap_readahead(): it allocates pages and submits IO. We can't
just skip readahead, otherwise it will stop working and we will get miss
all the time. On other hand keeping do_async_mmap_readahead() there will
probably break readahead heuristics: interleaving access looks as
sequential.

Any comments are welcome.

Kirill A. Shutemov (2):
  mm: extend ->fault interface to fault in few pages around fault
    address
  mm: implement FAULT_FLAG_AROUND in filemap_fault()

 include/linux/mm.h | 24 +++++++++++++++++
 mm/filemap.c       | 77 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 mm/memory.c        | 61 +++++++++++++++++++++++++++++++++++++-----
 3 files changed, 152 insertions(+), 10 deletions(-)

-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
