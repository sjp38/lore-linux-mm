Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5816B006E
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 14:14:33 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id i57so2390715yha.12
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 11:14:33 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id n132si11291398ykc.92.2015.01.13.11.14.32
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 11:14:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] Account PMD page tables to the process
Date: Tue, 13 Jan 2015 21:14:14 +0200
Message-Id: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently we don't account PMD page tables to the process. It can lead to
local DoS: unprivileged user can allocate >500 MiB on x86_64 per process
without being noticed by oom-killer or memory cgroup.

Proposed fix adds accounting for PMD table the same way we account for PTE
tables.

There're few corner case in the accounting (see patch 2/2) which have not
well tested yet. If anybody know any other cases we should handle, please
let me know.

Kirill A. Shutemov (2):
  mm: rename mm->nr_ptes to mm->nr_pgtables
  mm: account pmd page tables to the process

 Documentation/sysctl/vm.txt |  2 +-
 arch/x86/mm/pgtable.c       | 13 ++++++++-----
 fs/proc/task_mmu.c          |  2 +-
 include/linux/mm_types.h    |  2 +-
 kernel/fork.c               |  2 +-
 mm/debug.c                  |  4 ++--
 mm/huge_memory.c            | 10 +++++-----
 mm/hugetlb.c                |  8 ++++++--
 mm/memory.c                 |  6 ++++--
 mm/mmap.c                   |  9 +++++++--
 mm/oom_kill.c               |  8 ++++----
 11 files changed, 40 insertions(+), 26 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
