Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC5BB6B0010
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 13:30:33 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 101-v6so8466909ple.19
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 10:30:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1-v6sor4143108plu.114.2018.03.05.10.30.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 10:30:32 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v4 0/2] Directed kmem charging
Date: Mon,  5 Mar 2018 10:29:49 -0800
Message-Id: <20180305182951.34462-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

This patchset introduces memcg variant memory allocation functions. The
caller can explicitly pass the memcg to charge for kmem allocations.
Currently the kernel, for __GFP_ACCOUNT memory allocation requests,
extract the memcg of the current task to charge for the kmem allocation.
This patch series introduces kmem allocation functions where the caller
can pass the pointer to the remote memcg. The remote memcg will be
charged for the allocation instead of the memcg of the caller. However
the caller must have a reference to the remote memcg.

Fixed the build for SLOB in v2, added the target_memcg in task_struct in
v3 and in v4, added node variant for kmem allocation functions and
rebased fsnotify patch over Jan's patches.


Shakeel Butt (2):
  mm: memcg: remote memcg charging for kmem allocations
  fs: fsnotify: account fsnotify metadata to kmemcg

 fs/notify/dnotify/dnotify.c          |  5 ++-
 fs/notify/fanotify/fanotify.c        |  6 ++-
 fs/notify/fanotify/fanotify_user.c   |  5 ++-
 fs/notify/group.c                    |  4 ++
 fs/notify/inotify/inotify_fsnotify.c |  2 +-
 fs/notify/inotify/inotify_user.c     |  5 ++-
 include/linux/fsnotify_backend.h     | 12 ++++--
 include/linux/memcontrol.h           |  7 ++++
 include/linux/sched.h                |  3 ++
 include/linux/sched/mm.h             | 23 +++++++++++
 include/linux/slab.h                 | 59 ++++++++++++++++++++++++++++
 kernel/fork.c                        |  3 ++
 mm/memcontrol.c                      | 25 +++++++++---
 13 files changed, 143 insertions(+), 16 deletions(-)

-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
