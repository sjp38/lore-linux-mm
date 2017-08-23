Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 80B02280757
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 06:02:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y15so10600255pgc.3
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 03:02:24 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o12si857588plg.134.2017.08.23.03.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 03:02:23 -0700 (PDT)
From: =?UTF-8?q?=C5=81ukasz=20Daniluk?= <lukasz.daniluk@intel.com>
Subject: [RESEND PATCH 0/3] mm: Add cache coloring mechanism
Date: Wed, 23 Aug 2017 12:02:02 +0200
Message-Id: <20170823100205.17311-1-lukasz.daniluk@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dave.hansen@intel.com, lukasz.anaczkowski@intel.com, =?UTF-8?q?=C5=81ukasz=20Daniluk?= <lukasz.daniluk@intel.com>

Patches resend with Linux Kernel Mailing List added correctly this time.

This patch series adds cache coloring mechanism that works along buddy
allocator. The solution is opt-in, disabled by default minimally
interferes with default allocation paths due to added if statements.

Why would such patches be needed? Big caches with low associativity
(direct mapped caches, 2-way associative) will benefit from the solution
the most - it allows for near constant performance through the lifetime
of a system, despite the allocations and deallocations happening and
reordering buddy lists.

On KNL system, the STREAM benchmark with problem size resulting in its
internal arrays being of 16GB size will yield bandwidth performance of
336GB/s after fresh boot. With cache coloring patches applied and
enabled, this performance stays near constant (most 1.5% drop observed),
despite running benchmark multiple times with varying sizes over course
of days.  Without these patches however, the bandwidth when using such
allocations drops to 117GB/s - over 65% of irrecoverable performance
penalty. Workloads that exceed set cache size suffer from decreased
randomization of allocations with cache coloring enabled, but effect of
cache usage disappears roughly at the same allocation size.

Solution is divided into three patches. First patch is a preparatory one
that provides interface for retrieving (information about) free lists
contained by particular free_area structure.  Second one (parallel
structure keeping separate list_heads for each cache color in a given
context) shows general solution overview and is working as it is.
However, it has serious performance implications with bigger caches due
to linear search for next color to be used during allocations. Third
patch (sorting list_heads using RB trees) aims to improve solution's
performance by replacing linear search for next color with searching in
RB tree. While improving computational performance, it imposes increased
memory cost of the solution.


A?ukasz Daniluk (3):
  mm: move free_list selection to dedicated functions
  mm: Add page colored allocation path
  mm: Add helper rbtree to search for next cache color

 Documentation/admin-guide/kernel-parameters.txt |   8 +
 include/linux/mmzone.h                          |  12 +-
 mm/compaction.c                                 |   4 +-
 mm/page_alloc.c                                 | 381 ++++++++++++++++++++++--
 mm/vmstat.c                                     |  10 +-
 5 files changed, 383 insertions(+), 32 deletions(-)

-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
