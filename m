Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 414AA6B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 08:48:46 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id c11so115659lbj.41
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 05:48:45 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id y8si13408353lal.87.2014.07.03.05.48.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 05:48:44 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 0/5] Virtual Memory Resource Controller for cgroups
Date: Thu, 3 Jul 2014 16:48:16 +0400
Message-ID: <cover.1404383187.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

Hi,

Typically, when a process calls mmap, it isn't given all the memory pages it
requested immediately. Instead, only its address space is grown, while the
memory pages will be actually allocated on the first use. If the system fails
to allocate a page, it will have no choice except invoking the OOM killer,
which may kill this or any other process. Obviously, it isn't the best way of
telling the user that the system is unable to handle his request. It would be
much better to fail mmap with ENOMEM instead.

That's why Linux has the memory overcommit control feature, which accounts and
limits VM size that may contribute to mem+swap, i.e. private writable mappings
and shared memory areas. However, currently it's only available system-wide,
and there's no way of avoiding OOM in cgroups.

This patch set is an attempt to fill the gap. It implements the resource
controller for cgroups that accounts and limits address space allocations that
may contribute to mem+swap.

The interface is similar to the one of the memory cgroup except it controls
virtual memory usage, not actual memory allocation:

  vm.usage_in_bytes            current vm usage of processes inside cgroup
                               (read-only)

  vm.max_usage_in_bytes        max vm.usage_in_bytes, can be reset by writing 0

  vm.limit_in_bytes            vm.usage_in_bytes must be <= vm.limite_in_bytes;
                               allocations that hit the limit will be failed
                               with ENOMEM

  vm.failcnt                   number of times the limit was hit, can be reset
                               by writing 0

In future, the controller can be easily extended to account for locked pages
and shmem.

Note, for the sake of simplicity, task migrations and mm->owner changes are not
handled yet. I'm planning to fix this in the next version if the need in this
cgroup is confirmed.

It isn't the first attempt to introduce VM accounting per cgroup. Several years
ago Balbir Singh almost pushed his memrlimit cgroup, but it was finally shelved
(see http://lwn.net/Articles/283287/). Balbir's cgroup has one principal
difference from the vm cgroup I'm presenting here: it limited the sum of
mm->total_vm of tasks inside a cgroup, i.e. it worked like an RLIMIT_AS, but
for the whole cgroup. IMO, it isn't very useful, because shared memory areas
are accounted more than once, which can lead to failing mmap even if there's
plenty of free memory and OOM is impossible.

Any comments are highly appreciated.

Thanks,

Vladimir Davydov (5):
  vm_cgroup: basic infrastructure
  vm_cgroup: private writable mappings accounting
  shmem: pass inode to shmem_acct_* methods
  vm_cgroup: shared memory accounting
  vm_cgroup: do not charge tasks in root cgroup

 include/linux/cgroup_subsys.h |    4 +
 include/linux/mm_types.h      |    3 +
 include/linux/shmem_fs.h      |    6 +
 include/linux/vm_cgroup.h     |   79 +++++++++++++
 init/Kconfig                  |    4 +
 kernel/fork.c                 |   12 +-
 mm/Makefile                   |    1 +
 mm/mmap.c                     |   43 ++++++--
 mm/mprotect.c                 |    8 +-
 mm/mremap.c                   |   15 ++-
 mm/shmem.c                    |   94 +++++++++++-----
 mm/vm_cgroup.c                |  244 +++++++++++++++++++++++++++++++++++++++++
 12 files changed, 471 insertions(+), 42 deletions(-)
 create mode 100644 include/linux/vm_cgroup.h
 create mode 100644 mm/vm_cgroup.c

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
