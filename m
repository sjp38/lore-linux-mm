Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id DE3B66B0289
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 18:51:05 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id i50so9003627qgf.0
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 15:51:05 -0700 (PDT)
Received: from mail-qa0-x24a.google.com (mail-qa0-x24a.google.com [2607:f8b0:400d:c00::24a])
        by mx.google.com with ESMTPS id c7si2804046qar.7.2014.03.21.15.51.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Mar 2014 15:51:05 -0700 (PDT)
Received: by mail-qa0-f74.google.com with SMTP id w5so369124qac.5
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 15:51:00 -0700 (PDT)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH 0/3] Per cgroup swap file support
Date: Fri, 21 Mar 2014 15:50:31 -0700
Message-Id: <1395442234-7493-1-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, jamieliu@google.com, suleiman@google.com, Yu Zhao <yuzhao@google.com>

This series of patches adds support to configure a cgroup to swap to a
particular file by using control file memory.swapfile.

A value of "default" in memory.swapfile indicates that this cgroup should
use the default, system-wide, swap files. A value of "none" indicates that
this cgroup should never swap. Other values are interpreted as the path
to a private swap file that can only be used by the owner (and its children).

The swap file has to be created and swapon() has to be done on it with
SWAP_FLAG_PRIVATE, before it can be used. This flag ensures that the swap
file is private and does not get used by others.

Jamie Liu (1):
  swap: do not store private swap files on swap_list

Suleiman Souhlal (2):
  mm/swap: support per memory cgroup swapfiles
  swap: Increase the maximum number of swap files to 8192.

 Documentation/cgroups/memory.txt  |  15 ++
 arch/x86/include/asm/pgtable_64.h |  63 ++++++--
 include/linux/memcontrol.h        |   2 +
 include/linux/swap.h              |  45 +++---
 mm/memcontrol.c                   |  76 ++++++++++
 mm/memory.c                       |   3 +-
 mm/shmem.c                        |   2 +-
 mm/swap_state.c                   |   2 +-
 mm/swapfile.c                     | 307 +++++++++++++++++++++++++++++++-------
 mm/vmscan.c                       |   2 +-
 10 files changed, 423 insertions(+), 94 deletions(-)

-- 
1.9.1.423.g4596e3a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
