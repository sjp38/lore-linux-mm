Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E92566B010F
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 16:35:30 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so718886pab.40
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:35:30 -0700 (PDT)
Received: from mail-pb0-x24a.google.com (mail-pb0-x24a.google.com [2607:f8b0:400e:c01::24a])
        by mx.google.com with ESMTPS id bi5si1885279pbb.363.2014.04.02.13.35.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 13:35:29 -0700 (PDT)
Received: by mail-pb0-f74.google.com with SMTP id md12so128733pbc.5
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:35:29 -0700 (PDT)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH v2 0/3] Per-cgroup swap file support
Date: Wed,  2 Apr 2014 13:34:06 -0700
Message-Id: <1396470849-26154-1-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, jamieliu@google.com, suleiman@google.com, hannes@cmpxchg.org, Yu Zhao <yuzhao@google.com>

This series of patches adds support to configure a cgroup to swap to a
particular file by using control file memory.swapfile.

Originally, cgroups share system-wide swap space and limiting cgroup swapping
is not possible. This patchset solves the problem by adding mechanism that
isolates cgroup swap spaces (i.e. per-cgroup swap file) so users can safely
enable swap for particular cgroups without worrying about one cgroup uses up
all swap space.

A value of "default" in memory.swapfile indicates that this cgroup should
use the default, system-wide, swap files. A value of "none" indicates that
this cgroup should never swap. Other values are interpreted as the path
to a private swap file that can only be used by the owner (and its children).

The swap file has to be created and swapon() has to be done on it with
SWAP_FLAG_PRIVATE, before it can be used. This flag ensures that the swap
file is private and does not get used by others.

Changelog since v1:
  - Fixed typos in comment and commit message
  - Added rationale to this cover letter (Johannes Weiner)

Jamie Liu (1):
  swap: do not store private swap files on swap_list

Suleiman Souhlal (2):
  mm/swap: support per memory cgroup swapfiles
  swap: Increase the max swap files to 8192 on x86_64

 Documentation/cgroups/memory.txt  |  15 ++
 arch/x86/include/asm/pgtable_64.h |  62 ++++++--
 include/linux/memcontrol.h        |   2 +
 include/linux/swap.h              |  45 +++---
 mm/memcontrol.c                   |  76 ++++++++++
 mm/memory.c                       |   3 +-
 mm/shmem.c                        |   2 +-
 mm/swap_state.c                   |   2 +-
 mm/swapfile.c                     | 307 +++++++++++++++++++++++++++++++-------
 mm/vmscan.c                       |   2 +-
 10 files changed, 422 insertions(+), 94 deletions(-)

-- 
1.9.1.423.g4596e3a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
