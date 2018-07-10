Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE8A6B000D
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:34:31 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id m2-v6so13473324plt.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:34:31 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id a10-v6si17823008pff.304.2018.07.10.16.34.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:34:28 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v4 0/3] mm: zap pages with read mmap_sem in munmap for large mapping
Date: Wed, 11 Jul 2018 07:34:06 +0800
Message-Id: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
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

And, some part may need write mmap_sem, for example, vma splitting. So, the
design is as follows:
        acquire write mmap_sem
        lookup vmas (find and split vmas)
        set VM_DEAD flags
        deal with special mappings
        downgrade_write

        zap pages
        release mmap_sem

        retake mmap_sem exclusively
        cleanup vmas
        release mmap_sem

Define large mapping size thresh as PUD size, just zap pages with read mmap_sem
for mappings which are >= PUD_SIZE. So, unmapping less than PUD_SIZE area still
goes with the regular path.

All vmas which will be zapped soon will have VM_DEAD flag set. Since PF may race
with munmap, may just return the right content or SIGSEGV before the optimization,
but with the optimization, it may return a zero page. Here use this flag to mark
PF to this area is unstable, will trigger SIGSEGV, in order to prevent from the
unexpected 3rd state.

If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, they are considered
as special mappings. They will be dealt with before zapping pages with write
mmap_sem held. Basically, just update vm_flags. The actual unmapping is still
done with read mmap_sem.

And, since they are also manipulated by unmap_single_vma() which is called by
zap_page_range() with read mmap_sem held in this case, to prevent from updating
vm_flags in read critical section and considering the complexity of coding, just
check if VM_DEAD is set, then skip any VM_DEAD area since they should be handled
before.

When cleaning up vmas, just call do_munmap() without carrying vmas from the above
to avoid race condition, since the address space might be already changed under
our feet after retaking exclusive lock.

For the time being, just do this in munmap syscall path. Other vm_munmap() or
do_munmap() call sites (i.e mmap, mremap, etc) remain intact for stability reason.
And, make this 64 bit only explicitly per akpm's suggestion.

Changelog:
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

v2 a??> v3:
* Refactor do_munmap code to extract the common part per Peter's sugestion
* Introduced VM_DEAD flag per Michal's suggestion. Just handled VM_DEAD in 
  x86's page fault handler for the time being. Other architectures will be covered
  once the patch series is reviewed
* Now lookup vma (find and split) and set VM_DEAD flag with write mmap_sem, then
  zap mapping with read mmap_sem, then clean up pgtables and vmas with write
  mmap_sem per Peter's suggestion

v1 a??> v2:
* Re-implemented the code per the discussion on LSFMM summit

 
Regression and performance data:
Did the below regression test with setting thresh to 4K manually in the code:
  * Full LTP
  * Trinity (munmap/all vm syscalls)
  * Stress-ng mmap
  * mm-tests: kernbench, phpbench, sysbench-mariadb, will-it-scale
  * vm-scalability

With the patches, exclusive mmap_sem hold time when munmap a 80GB address
space on a machine with 32 cores of E5-2680 @ 2.70GHz dropped to us level
from second.

                w/o             w/
do_munmap    2165433 us      35148.923 us
SyS_munmap   2165369 us      2166535 us


Yang Shi (3):
      mm: introduce VM_DEAD flag and extend check_stable_address_space to check it
      mm: refactor do_munmap() to extract the common part
      mm: mmap: zap pages with read mmap_sem for large mapping

 include/linux/mm.h  |   8 +++
 include/linux/oom.h |  20 -------
 mm/huge_memory.c    |   4 +-
 mm/hugetlb.c        |   5 ++
 mm/memory.c         |  57 ++++++++++++++++---
 mm/mmap.c           | 221 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------------
 mm/shmem.c          |   9 ++-
 7 files changed, 255 insertions(+), 69 deletions(-)
