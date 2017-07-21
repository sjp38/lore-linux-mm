Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B64E6B025F
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 10:39:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g28so17070425wrg.3
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:25 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id c19si7925550wre.235.2017.07.21.07.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 07:39:24 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id m75so893714wmb.2
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:24 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH -v1 0/9] cleanup zonelists initialization
Date: Fri, 21 Jul 2017 16:39:06 +0200
Message-Id: <20170721143915.14161-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.com>, Shaohua Li <shaohua.li@intel.com>, Toshi Kani <toshi.kani@hpe.com>

Hi,
previous version of the series has been posted here [1]. I have hopefully
addressed all review feedback. There are some small fixes/cleanups
here and there but no fundamental changes since the last time.

This is aimed at cleaning up the zonelists initialization code we have
but the primary motivation was bug report [2] which got resolved but
the usage of stop_machine is just too ugly to live. Most patches are
straightforward but 3 of them need a special consideration.

Patch 1 removes zone ordered zonelists completely. I am CCing linux-api
because this is a user visible change. As I argue in the patch
description I do not think we have a strong usecase for it these days.
I have kept sysctl in place and warn into the log if somebody tries to
configure zone lists ordering. If somebody has a real usecase for it
we can revert this patch but I do not expect anybody will actually notice
runtime differences. This patch is not strictly needed for the rest but
it made patch 6 easier to implement.

Patch 7 removes stop_machine from build_all_zonelists without adding any
special synchronization between iterators and updater which I _believe_
is acceptable as explained in the changelog. I hope I am not missing
anything.

Patch 8 then removes zonelists_mutex which is kind of ugly as well and
not really needed AFAICS but a care should be taken when double checking
my thinking.

This has passed my light testing but I currently do not have a HW to
test hotadd_new_pgdat path (aka a completely new node added to the
system in runtime).

This is based on the current mmomt git tree (mmotm-2017-07-12-15-11).
Any feedback is highly appreciated.

The diffstat looks really promissing
 Documentation/admin-guide/kernel-parameters.txt |   2 +-
 Documentation/sysctl/vm.txt                     |   4 +-
 Documentation/vm/numa                           |   7 +-
 include/linux/mmzone.h                          |   5 +-
 init/main.c                                     |   2 +-
 kernel/sysctl.c                                 |   2 -
 mm/internal.h                                   |   1 +
 mm/memory_hotplug.c                             |  27 +-
 mm/page_alloc.c                                 | 335 +++++++-----------------
 mm/page_ext.c                                   |   5 +-
 mm/sparse-vmemmap.c                             |  11 +-
 mm/sparse.c                                     |  10 +-
 12 files changed, 119 insertions(+), 292 deletions(-)

Shortlog says
Michal Hocko (9):
      mm, page_alloc: rip out ZONELIST_ORDER_ZONE
      mm, page_alloc: remove boot pageset initialization from memory hotplug
      mm, page_alloc: do not set_cpu_numa_mem on empty nodes initialization
      mm, memory_hotplug: drop zone from build_all_zonelists
      mm, memory_hotplug: remove explicit build_all_zonelists from try_online_node
      mm, page_alloc: simplify zonelist initialization
      mm, page_alloc: remove stop_machine from build_all_zonelists
      mm, memory_hotplug: get rid of zonelists_mutex
      mm, sparse, page_ext: drop ugly N_HIGH_MEMORY branches for allocations

[1] http://lkml.kernel.org/r/20170714080006.7250-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/alpine.DEB.2.20.1706291803380.1861@nanos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
