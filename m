Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f41.google.com (mail-oa0-f41.google.com [209.85.219.41])
	by kanga.kvack.org (Postfix) with ESMTP id D9EB16B0038
	for <linux-mm@kvack.org>; Thu, 22 May 2014 23:33:37 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id m1so5056912oag.28
        for <linux-mm@kvack.org>; Thu, 22 May 2014 20:33:37 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id tp9si2208294obb.27.2014.05.22.20.33.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 May 2014 20:33:37 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 0/5] mm: i_mmap_mutex to rwsem
Date: Thu, 22 May 2014 20:33:21 -0700
Message-Id: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mingo@kernel.org, peterz@infradead.org, riel@redhat.com, mgorman@suse.de, davidlohr@hp.com, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

This patchset extends the work started by Ingo Molnar in late 2012,
optimizing the anon-vma mutex lock, converting it from a exclusive mutex
to a rwsem, and sharing the lock for read-only paths when walking the
the vma-interval tree. More specifically commits 5a505085 and 4fc3f1d6.

The i_mmap_mutex has similar responsibilities with the anon-vma, protecting
file backed pages. Therefore we can use similar locking techniques: covert
the mutex to a rwsem and share the lock when possible.

With the new optimistic spinning property we have in rwsems, we no longer
take a hit in performance when using this lock, and we can therefore
safely do the conversion. Tests show no throughput regressions in aim7 or
pgbench runs, and we can see gains from sharing the lock, in disk workloads
~+15% for over 1000 users on a 8-socket Westmere system.

This patchset applies on linux-next-20140522.

Thanks!

Davidlohr Bueso (5):
  mm,fs: introduce helpers around i_mmap_mutex
  mm: use new helper functions around the i_mmap_mutex
  mm: convert i_mmap_mutex to rwsem
  mm/rmap: share the i_mmap_rwsem
  mm: rename leftover i_mmap_mutex

 fs/hugetlbfs/inode.c         | 14 +++++++-------
 fs/inode.c                   |  2 +-
 include/linux/fs.h           | 23 ++++++++++++++++++++++-
 include/linux/mmu_notifier.h |  2 +-
 kernel/events/uprobes.c      |  6 +++---
 kernel/fork.c                |  4 ++--
 mm/filemap.c                 | 10 +++++-----
 mm/filemap_xip.c             |  4 ++--
 mm/hugetlb.c                 | 22 +++++++++++-----------
 mm/memory-failure.c          |  4 ++--
 mm/memory.c                  |  8 ++++----
 mm/mmap.c                    | 22 +++++++++++-----------
 mm/mremap.c                  |  6 +++---
 mm/nommu.c                   | 14 +++++++-------
 mm/rmap.c                    | 10 +++++-----
 15 files changed, 86 insertions(+), 65 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
