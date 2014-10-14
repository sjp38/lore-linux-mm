Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 758206B0071
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 12:20:48 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id k14so11272513wgh.31
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 09:20:47 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kb4si21909846wjc.46.2014.10.14.09.20.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Oct 2014 09:20:46 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/5] mm: memcontrol: eliminate charge reparenting v2
Date: Tue, 14 Oct 2014 12:20:32 -0400
Message-Id: <1413303637-23862-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

this series gets rid of charge reparenting at cgroup deletion, which
is possible now that the css can outlive the user-visible cgroup.  Any
cache charges left after cgroup deletion simply remain with their css,
where they continue to get reclaimed during pressure on the parent.

Version 2:

    - remove memcg->dead_count [vladimir]
    - restore iterator generations [vladimir]
    - restore memcg-initialized test [michal]
    - document shared walk lockless magic [michal]
    - split out sync stock draining removal [michal]

 include/linux/cgroup.h          |  26 ++
 include/linux/page_counter.h    |   4 +-
 include/linux/percpu-refcount.h |  47 ++-
 mm/memcontrol.c                 | 593 ++++++--------------------------------
 mm/page_counter.c               |  23 +-
 5 files changed, 163 insertions(+), 530 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
