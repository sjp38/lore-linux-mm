Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 828DF6B0253
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 13:41:48 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z190so10589391qkc.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 10:41:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x130si2017657ywd.295.2016.09.15.10.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 10:41:47 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/2] vma_merge vs rmap_walk SMP race condition fix
Date: Thu, 15 Sep 2016 19:41:42 +0200
Message-Id: <1473961304-19370-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Vorlicek <janvorli@microsoft.com>, Aditya Mandaleeka <adityam@microsoft.com>

Hello,

Aditya reported the CLR JIT was segfaulting on older kernels.

It turns out newer kernels have do_numa_page using pte_modify instead
of pte_mknotnuma, that by luck corrects any broken invariant of a
PAGE_NONE pte on a VM_READ|WRITE vma even on non-NUMA systems, and
establishes a proper pte with PAGE_USER set.

However the opposite version of the race condition can still happen
even upstream and that generates silent data corruption with a pte
that should be PAGE_NONE and is not.

The testcase source is on github.

https://github.com/dotnet/coreclr/tree/784f4d93d43f29cc52d41ec9fae5a96ad68633cb/src

To verify the bug upstream, I verified that do_page_numa indeed is
invoked on non-NUMA guests, despite NUMA balancing obviously was never
enabled on non-NUMA guests. With the fix applied do_numa_page is never
executed anymore.

-->	*pprev = vma_merge(mm, *pprev, start, end, newflags,
			   vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
			   vma->vm_userfaultfd_ctx);
	if (*pprev) {
		vma = *pprev;
		goto success;
[..]
success:
	/*
	 * vm_flags and vm_page_prot are protected by the mmap_sem
	 * held in write mode.
	 */
	vma->vm_flags = newflags;
	dirty_accountable = vma_wants_writenotify(vma);
-->	vma_set_page_prot(vma);

If remove_migration_ptes runs before vma_set_page_prot run but after
the current vma was extended and the "next" vma was removed, and the
page migration happened in an address in the "next->vma_start/end"
range, the pte of the "next" range gets established by
remove_migration_ptes using the vm_page_prot of the prev vma, but
change_protection of course won't run on the next range, but only in
the current vma range.

There are already fields in the vma that must be updated inside the
anon_vma/i_mmap locks, to avoid screwing the rmap_walk,
vm_start/vm_pgoff are two of them, but vm_page_prot/vm_flags got
overlooked and wasn't properly transferred from the removed_next vma
to the importer current vma, before releasing the rmap locks.

Now the bug happens because of vm_page_prot, but I copied over
vm_flags too as often it's used by maybe_mkwrite and other pte/pmd
manipulations that might run in rmap walks. It's just safer to update
both before releasing the rmap serializing locks.

This fixes the race and it is confirmed by do_numa_page never running
anymore as after mprotect(PROT_READ|WRITE) returns on non-NUMA
systems.

So no pte is left as PAGE_NONE by mistake (the other way around too
even though it's harder to verify as the other way is silent, but the
fix is obviously going to correct the reverse condition too).

Then there's patch 1/2 too where half updated vm_page_prot could
become visible to rmap walks but that is a theoretical problem noticed
only during code review that I fixed along the way. The real practical
fix that solves the pgtable going out of sync with vm_flags is 2/2.

Andrea Arcangeli (2):
  mm: vm_page_prot: update with WRITE_ONCE/READ_ONCE
  mm: vma_merge: fix race vm_page_prot race condition against rmap_walk

 mm/huge_memory.c |  2 +-
 mm/migrate.c     |  2 +-
 mm/mmap.c        | 23 +++++++++++++++++++----
 3 files changed, 21 insertions(+), 6 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
