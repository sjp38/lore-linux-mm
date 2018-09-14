Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA6E8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 16:35:22 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 186-v6so4457519pgc.12
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 13:35:22 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id b35-v6si7905634plh.308.2018.09.14.13.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 13:35:19 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v10 PATCH 0/3] mm: zap pages with read mmap_sem in munmap for large mapping
Date: Sat, 15 Sep 2018 04:34:56 +0800
Message-Id: <1536957299-43536-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org
Cc: dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Background:
Recently, when we ran some vm scalability tests on machines with large memory,
we ran into a couple of mmap_sem scalability issues when unmapping large memory
space, please refer to https://lkml.org/lkml/2017/12/14/733 and
https://lkml.org/lkml/2018/2/20/576.


History:
Then akpm suggested to unmap large mapping section by section and drop mmap_sem
at a time to mitigate it (see https://lkml.org/lkml/2018/3/6/784).

V1 patch series was submitted to the mailing list per Andrew's suggestion
(see https://lkml.org/lkml/2018/3/20/786). Then I received a lot great feedback
and suggestions.

Then this topic was discussed on LSFMM summit 2018. In the summit, Michal Hocko
suggested (also in the v1 patches review) to try "two phases" approach. Zapping
pages with read mmap_sem, then doing via cleanup with write mmap_sem (for
discussion detail, see https://lwn.net/Articles/753269/)


Approach:
Zapping pages is the most time consuming part, according to the suggestion from
Michal Hocko [1], zapping pages can be done with holding read mmap_sem, like
what MADV_DONTNEED does. Then re-acquire write mmap_sem to cleanup vmas.

But, we can't call MADV_DONTNEED directly, since there are two major drawbacks:
  * The unexpected state from PF if it wins the race in the middle of munmap.
    It may return zero page, instead of the content or SIGSEGV.
  * Can't handle VM_LOCKED | VM_HUGETLB | VM_PFNMAP and uprobe mappings, which
    is a showstopper from akpm

But, some part may need write mmap_sem, for example, vma splitting. So,
the design is as follows:
        acquire write mmap_sem
        lookup vmas (find and split vmas)
        deal with special mappings
        detach vmas
        downgrade_write

        zap pages
        free page tables
        release mmap_sem

The vm events with read mmap_sem may come in during page zapping, but
since vmas have been detached before, they, i.e. page fault, gup, etc,
will not be able to find valid vma, then just return SIGSEGV or -EFAULT
as expected.

If the vma has VM_HUGETLB | VM_PFNMAP, they are considered as special
mappings. They will be handled by falling back to regular do_munmap()
with exclusive mmap_sem held in this patch since they may update vm flags.

But, with the "detach vmas first" approach, the vmas have been detached
when vm flags are updated, so it sounds safe to update vm flags with
read mmap_sem for this specific case. So, VM_HUGETLB and VM_PFNMAP will
be handled by using the optimized path in the following separate patches
for bisectable sake.

Unmapping uprobe areas may need update mm flags (MMF_RECALC_UPROBES).
However it is fine to have false-positive MMF_RECALC_UPROBES according
to uprobes developer. So, uprobe unmap will not be handled by the
regular path.

With the "detach vmas first" approach we don't have to re-acquire
mmap_sem again to clean up vmas to avoid race window which might get the
address space changed since downgrade_write() doesn't release the lock
to lead regression, which simply downgrades to read lock.

And, since the lock acquire/release cost is managed to the minimum and
almost as same as before, the optimization could be extended to any size
of mapping without incurring significant penalty to small mappings.

For the time being, just do this in munmap syscall path. Other
vm_munmap() or do_munmap() call sites (i.e mmap, mremap, etc) remain
intact due to some implementation difficulties since they acquire write
mmap_sem from very beginning and hold it until the end, do_munmap()
might be called in the middle. But, the optimized do_munmap would like
to be called without mmap_sem held so that we can do the optimization.
So, if we want to do the similar optimization for mmap/mremap path, I'm
afraid we would have to redesign them. mremap might be called on very
large area depending on the usecases, the optimization to it will be
considered in the future.


Changelog
v9 -> v10:
* Adopted the suggestion from Willy by not duplicating do_munmap. No change to
  the overall design of the optimization.

v8 -> v9:
* Uprobe developer (Oleg Nesterov and Srikar Dronamraju) helped to confirm it is
  fine to have a false-positive MMF_RECALC_UPROBES. So, unmapping uprobe areas
  doesn't have to be handled by regular path. Thanks Oleg.
* Dave hansen helped to confirm mpx unmap has to be called under write mmap_sem,
  but it has not to be after unmap_region(). So move arch_unmap() before
  downgrade_write(). The other user of arch_unmap() is PowerPC, which just set
  mm->context.vdso_base, so it sounds fine for this change too. Thanks Dave.
* The above two resolved the concern from Vlastimil.

v7 -> v8:
* Added Acked-by from Vlastimil for patch 1/5. Thanks.
* Fixed the wrong "evolution" direction. Converted VM_HUGETLB and VM_PFNMAP
  mapping use the optimized path in separate patches respectively for safe and
  bisectable sake per Michal's suggestion.
* Extracted has_uprobes() helper from uprobes_munmap() to check if mm or vmas
  have uprobes, which could save some cycles instead of calling
  vma_has_uprobes() directly for some cases. Per Vlastimil's suggestion.
* Keep unmapping uprobes area using regular do_munmap() since it might update
  mm flags, that might be not safe with read mmap_sem even though vmas have
  been detached.
* Fixed some comments from Willy.

v6 -> v7:
* Rename some helper functions per Michal and Vlastimil's comments.
* Refactor munmap_lookup_vma() to return the pointer of start vma per Michal's
  suggestion.
* Rephrase some commit log for patch 2/4 per Michal's comments.
* Deal with special mappings (VM_HUGETLB | VM_PFNMAP | uprobes) with regular
  do_munmap() in a separate patch per Michal's suggestion.
* Bring the patch which makes vma_has_uprobes() non-static back since it is
  needed to check if a vma has uprobes or not.

v5 -> v6:
* Fixed the comments from Kirill and Laurent
* Added Laurent's reviewed-by to patch 1/2. Thanks.

v4 -> v5:
* Detach vmas before zapping pages so that we don't have to use VM_DEAD to mark
  a being unmapping vma since they have been detached from rbtree when zapping
  pages. Per Kirill
* Eliminate VM_DEAD stuff
* With this change we don't have to re-acquire write mmap_sem to do cleanup.
  So, we could eliminate a potential race window
* Eliminate PUD_SIZE check, and extend this optimization to all size

v3 -> v4:
* Extend check_stable_address_space to check VM_DEAD as Michal suggested
* Deal with vm_flags update of VM_LOCKED | VM_HUGETLB | VM_PFNMAP and uprobe
  mappings with exclusive lock held. The actual unmapping is still done with read
  mmap_sem to solve akpm's concern
* Clean up vmas with calling do_munmap to prevent from race condition by not
  carrying vmas as Kirill suggested
* Extracted more common code
* Solved some code cleanup comments from akpm
* Dropped uprobe and arch specific code, now all the changes are mm only
* Still keep PUD_SIZE threshold, if everyone thinks it is better to extend to all
  sizes or smaller size, will remove it
* Make this optimization 64 bit only explicitly per akpm's suggestion

v2 -> v3:
* Refactor do_munmap code to extract the common part per Peter's sugestion
* Introduced VM_DEAD flag per Michal's suggestion. Just handled VM_DEAD in
  x86's page fault handler for the time being. Other architectures will be covered
  once the patch series is reviewed
* Now lookup vma (find and split) and set VM_DEAD flag with write mmap_sem, then
  zap mapping with read mmap_sem, then clean up pgtables and vmas with write
  mmap_sem per Peter's suggestion

v1 -> v2:
* Re-implemented the code per the discussion on LSFMM summit


Regression and performance data:
Did the below regression test with setting thresh to 4K manually in the code:
  * Full LTP
  * Trinity (munmap/all vm syscalls)
  * Stress-ng: mmap/mmapfork/mmapfixed/mmapaddr/mmapmany/vm
  * mm-tests: kernbench, phpbench, sysbench-mariadb, will-it-scale
  * vm-scalability

With the patches, exclusive mmap_sem hold time when munmap a 80GB address
space on a machine with 32 cores of E5-2680 @ 2.70GHz dropped to us level
from second.

munmap_test-15002 [008]   594.380138: funcgraph_entry: |  __vm_munmap {
munmap_test-15002 [008]   594.380146: funcgraph_entry:      !2485684 us |    unmap_region();
munmap_test-15002 [008]   596.865836: funcgraph_exit:       !2485692 us |  }

Here the excution time of unmap_region() is used to evaluate the time of
holding read mmap_sem, then the remaining time is used with holding
exclusive lock.


Yang Shi (3):
      mm: mmap: zap pages with read mmap_sem in munmap
      mm: unmap VM_HUGETLB mappings with optimized path
      mm: unmap VM_PFNMAP mappings with optimized path

 mm/mmap.c | 50 +++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 39 insertions(+), 11 deletions(-)
