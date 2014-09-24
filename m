Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0858D6B0037
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 11:43:19 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id t60so6426006wes.22
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:43:19 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ep3si92031wib.35.2014.09.24.08.43.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 08:43:18 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/3] mm: memcontrol: lockless page counters v2
Date: Wed, 24 Sep 2014 11:43:07 -0400
Message-Id: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

this series replaces the spinlock_irq-protected 64-bit res_counters
with lockless word-sized page counters.

Version 2 has many changes over the first submission.  Among a ton of
bugfixes and performance improvements (thanks, Vladimir!), the series
has also been restructured to improve reviewability, and to address
concerns about the hugetlb controller depending on compile-time memcg:

    optimizations:
    - converted page_counter_try_charge() from CAS to FAA [vladimir]

    fixes:
    - fixed kmem's notion of "unlimited" [vladimir]
    - fixed page_counter_cancel() return value [vladimir]
    - based page counter range on atomic_long_t's max [vladimir]
    - fixed tcp memcontrol's usage reporting [vladimir]
    - fixed hugepage limit page alignment [vladimir]
    - fixed page_counter_limit() serialization [vladimir]

    cleanups:
    - moved new page_counter API to its own file [vladimir, michal]
    - documented page counter API [vladimir]
    - documented acceptable race conditions [vladimir]
    - split out res_counter removal to reduce patch size [vladimir]
    - split out hugetlb controller conversion to reduce patch size
    - split page_counter_charge and page_counter_try_charge [vladimir]
    - wrapped signed-to-unsigned read in page_counter_read() [vladimir]
    - wrapped watermark reset in page_counter_reset_watermark() [vladimir]
    - reverted counter->limited back to counter->failcnt [vladimir]
    - changed underflow to WARN_ON_ONCE and counter revert [kame, vladimir]

 Documentation/cgroups/hugetlb.txt          |   2 +-
 Documentation/cgroups/memory.txt           |   4 +-
 Documentation/cgroups/resource_counter.txt | 197 ---------
 include/linux/hugetlb_cgroup.h             |   1 -
 include/linux/memcontrol.h                 |   5 +-
 include/linux/page_counter.h               |  49 +++
 include/linux/res_counter.h                | 223 ----------
 include/net/sock.h                         |  26 +-
 init/Kconfig                               |  12 +-
 kernel/Makefile                            |   1 -
 kernel/res_counter.c                       | 211 ---------
 mm/Makefile                                |   1 +
 mm/hugetlb_cgroup.c                        | 104 +++--
 mm/memcontrol.c                            | 635 +++++++++++++--------------
 mm/page_counter.c                          | 191 ++++++++
 net/ipv4/tcp_memcontrol.c                  |  87 ++--
 16 files changed, 659 insertions(+), 1090 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
