Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF626B0390
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 10:06:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b78so5682233wrd.18
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 07:06:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88si11335589wrb.134.2017.04.11.07.06.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 07:06:16 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 0/6] cpuset/mempolicies related fixes and cleanups
Date: Tue, 11 Apr 2017 16:06:03 +0200
Message-Id: <20170411140609.3787-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

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
 include/uapi/linux/mempolicy.h |   8 --
 kernel/cgroup/cpuset.c         |  33 ++-------
 mm/hugetlb.c                   |  15 ++--
 mm/memory_hotplug.c            |   6 +-
 mm/mempolicy.c                 | 165 +++++++++--------------------------------
 mm/page_alloc.c                |  61 ++++++++++-----
 8 files changed, 109 insertions(+), 202 deletions(-)

-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
