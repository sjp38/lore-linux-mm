Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDDA6B02F4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 04:11:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w79so880201wme.7
        for <linux-mm@kvack.org>; Wed, 17 May 2017 01:11:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b141si16400789wme.27.2017.05.17.01.11.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 01:11:56 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 0/6] cpuset/mempolicies related fixes and cleanups
Date: Wed, 17 May 2017 10:11:34 +0200
Message-Id: <20170517081140.30654-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

Changes since RFC v1 [3]:

- Reworked patch 2 after discussion with Christoph Lameter.
- Fix bug in patch 5 spotted by Hillf Danton.
- Rebased to mmotm-2017-05-12-15-53

I would like to stress that this patchset aims to fix issues and cleanup the
code *within the existing documented semantics*, i.e. patch 1 ignores mempolicy
restrictions if the set of allowed nodes has no intersection with set of nodes
allowed by cpuset. I believe discussing potential changes of the semantics can
be better done once we have a baseline with no known bugs of the current
semantics.

===

I've recently summarized the cpuset/mempolicy issues in a LSF/MM proposal [1]
and the discussion itself [2]. I've been trying to rewrite the handling as
proposed, with the idea that changing semantics to make all mempolicies static
wrt cpuset updates (and discarding the relative and default modes) can be tried
on top, as there's a high risk of being rejected/reverted because somebody
might still care about the removed modes.

However I haven't yet figured out how to properly:

1) make mempolicies swappable instead of rebinding in place. I thought mbind()
already works that way and uses refcounting to avoid use-after-free of the old
policy by a parallel allocation, but turns out true refcounting is only done
for shared (shmem) mempolicies, and the actual protection for mbind() comes
from mmap_sem. Extending the refcounting means more overhead in allocator hot
path. Also swapping whole mempolicies means that we have to allocate the new
ones, which can fail, and reverting of the partially done work also means
allocating (note that mbind() doesn't care and will just leave part of the
range updated and part not updated when returning -ENOMEM...).

2) make cpuset's task->mems_allowed also swappable (after converting it from
nodemask to zonelist, which is the easy part) for mostly the same reasons.

The good news is that while trying to do the above, I've at least figured out
how to hopefully close the remaining premature OOM's, and do a buch of cleanups
on top, removing quite some of the code that was also supposed to prevent the
cpuset update races, but doesn't work anymore nowadays. This should fix the
most pressing concerns with this topic and give us a better baseline before
either proceeding with the original proposal, or pushing a change of semantics
that removes the problem 1) above. I'd be then fine with trying to change the
semantic first and rewrite later.

Patchset is based on next-20170411 and has been tested with the LTP cpuset01
stress test.

[1] https://lkml.kernel.org/r/4c44a589-5fd8-08d0-892c-e893bb525b71@suse.cz
[2] https://lwn.net/Articles/717797/
[3] https://marc.info/?l=linux-mm&m=149191957922828&w=2

Vlastimil Babka (6):
  mm, page_alloc: fix more premature OOM due to race with cpuset update
  mm, mempolicy: stop adjusting current->il_next in
    mpol_rebind_nodemask()
  mm, page_alloc: pass preferred nid instead of zonelist to allocator
  mm, mempolicy: simplify rebinding mempolicies when updating cpusets
  mm, cpuset: always use seqlock when changing task's nodemask
  mm, mempolicy: don't check cpuset seqlock where it doesn't matter

 include/linux/gfp.h            |  11 ++-
 include/linux/mempolicy.h      |  12 ++-
 include/linux/sched.h          |   2 +-
 include/uapi/linux/mempolicy.h |   8 --
 kernel/cgroup/cpuset.c         |  33 ++------
 mm/hugetlb.c                   |  15 ++--
 mm/memory_hotplug.c            |   6 +-
 mm/mempolicy.c                 | 181 ++++++++++-------------------------------
 mm/page_alloc.c                |  61 ++++++++++----
 9 files changed, 118 insertions(+), 211 deletions(-)

-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
