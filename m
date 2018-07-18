Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68ECF6B0266
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 19:22:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j15-v6so2978865pff.12
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 16:22:43 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id u6-v6si4455910plr.437.2018.07.18.16.22.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 16:22:41 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v5 0/2] mm: zap pages with read mmap_sem in munmap for large mapping
Date: Thu, 19 Jul 2018 07:21:39 +0800
Message-Id: <1531956101-8526-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


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
  * Cana??t handle VM_LOCKED | VM_HUGETLB | VM_PFNMAP and uprobe mappings, which
    is a showstopper from akpm

But, some part may need write mmap_sem, for example, vma splitting. So,
the design is as follows:
        acquire write mmap_sem
        lookup vmas (find and split vmas)
        detach vmas
        deal with special mappings
        downgrade_write

        zap pages
        free page tables
        release mmap_sem

The vm events with read mmap_sem may come in during page zapping, but
since vmas have been detached before, they, i.e. page fault, gup, etc,
will not be able to find valid vma, then just return SIGSEGV or -EFAULT
as expected.

If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, they are
considered as special mappings. They will be dealt with before zapping
pages with write mmap_sem held. Basically, just update vm_flags.

And, since they are also manipulated by unmap_single_vma() which is
called by unmap_vma() with read mmap_sem held in this case, to
prevent from updating vm_flags in read critical section, a new
parameter, called "skip_flags" is added to unmap_region(), unmap_vmas()
and unmap_single_vma(). If it is true, then just skip unmap those
special mappings. Currently, the only place which pass true to this
parameter is us.

With this approach we don't have to re-acquire mmap_sem again to clean
up vmas to avoid race window which might get the address space changed.

And, since the lock acquire/release cost is managed to the minimum and
almost as same as before, the optimization could be extended to any size
of mapping without incuring significant penalty to small mappings.

For the time being, just do this in munmap syscall path. Other vm_munmap() or
do_munmap() call sites (i.e mmap, mremap, etc) remain intact for stability
reason.

Changelog:
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

munmap_test-15002 [008]   594.380138: funcgraph_entry: |  vm_munmap_zap_rlock() {
munmap_test-15002 [008]   594.380146: funcgraph_entry:      !2485684 us |    unmap_region();
munmap_test-15002 [008]   596.865836: funcgraph_exit:       !2485692 us |  }

Here the excution time of unmap_region() is used to evaluate the time of
holding read mmap_sem, then the remaining time is used with holding
exclusive lock.

Yang Shi (2):
      mm: refactor do_munmap() to extract the common part
      mm: mmap: zap pages with read mmap_sem in munmap

 include/linux/mm.h |   2 +-
 mm/memory.c        |  35 +++++++++++++-----
 mm/mmap.c          | 219 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------------------
 3 files changed, 199 insertions(+), 57 deletions(-)
