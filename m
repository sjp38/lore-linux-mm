Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3A74408E5
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:00:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x43so303951wrb.9
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:28 -0700 (PDT)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id b204si1619469wmh.72.2017.07.14.01.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 01:00:27 -0700 (PDT)
Received: by mail-wr0-f195.google.com with SMTP id 77so11075725wrb.3
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:27 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/9] cleanup zonelists initialization
Date: Fri, 14 Jul 2017 09:59:57 +0200
Message-Id: <20170714080006.7250-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, joonsoo kim <js1304@gmail.com>, linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Shaohua Li <shaohua.li@intel.com>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>

Hi,
this is aimed at cleaning up the zonelists initialization code we have
but the primary motivation was bug report [1] which got resolved but
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
 include/linux/mmzone.h |   3 +-
 init/main.c            |   2 +-
 kernel/sysctl.c        |   2 -
 mm/internal.h          |   1 +
 mm/memory_hotplug.c    |  27 +----
 mm/page_alloc.c        | 293 ++++++++++++-------------------------------------
 mm/page_ext.c          |   5 +-
 mm/sparse-vmemmap.c    |  11 +-
 mm/sparse.c            |  10 +-
 9 files changed, 89 insertions(+), 265 deletions(-)

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

[1] http://lkml.kernel.org/r/alpine.DEB.2.20.1706291803380.1861@nanos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
