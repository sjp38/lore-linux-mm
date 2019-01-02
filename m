Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH 0/3] mm: memcontrol: delayed force empty
Date: Thu,  3 Jan 2019 04:05:30 +0800
Message-Id: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: linux-kernel-owner@vger.kernel.org
To: mhocko@suse.com, hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Currently, force empty reclaims memory synchronously when writing to
memory.force_empty.  It may take some time to return and the afterwards
operations are blocked by it.  Although it can be interrupted by signal,
it still seems suboptimal.

Now css offline is handled by worker, and the typical usecase of force
empty is before memcg offline.  So, handling force empty in css offline
sounds reasonable.

The user may write into any value to memory.force_empty, but I'm
supposed the most used value should be 0 and 1.  To not break existing
applications, writing 0 or 1 still do force empty synchronously, any
other value will tell kernel to do force empty in css offline worker.

Patch #1: Fix some obsolete information about force_empty in the document
Patch #2: A minor improvement to skip swap for force_empty
Patch #3: Implement delayed force_empty

Yang Shi (3):
      doc: memcontrol: fix the obsolete content about force empty
      mm: memcontrol: do not try to do swap when force empty
      mm: memcontrol: delay force empty to css offline

 Documentation/cgroup-v1/memory.txt | 15 ++++++++++-----
 include/linux/memcontrol.h         |  2 ++
 mm/memcontrol.c                    | 20 +++++++++++++++++++-
 3 files changed, 31 insertions(+), 6 deletions(-)
