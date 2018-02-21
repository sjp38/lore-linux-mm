Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 371416B0005
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 17:38:05 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id x2so1323315plv.16
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 14:38:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z11sor644136pgc.299.2018.02.21.14.38.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 14:38:04 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v3 0/2] Directed kmem charging
Date: Wed, 21 Feb 2018 14:37:55 -0800
Message-Id: <20180221223757.127213-1-shakeelb@google.com>
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

Fixed the build for SLOB in v2 and added the target_memcg in task_struct
in v3.

Shakeel Butt (2):
  mm: memcg: remote memcg charging for kmem allocations
  fs: fsnotify: account fsnotify metadata to kmemcg

 fs/notify/dnotify/dnotify.c          |  5 +++--
 fs/notify/fanotify/fanotify.c        | 12 ++++++-----
 fs/notify/fanotify/fanotify.h        |  3 ++-
 fs/notify/fanotify/fanotify_user.c   |  7 +++++--
 fs/notify/group.c                    |  4 ++++
 fs/notify/inotify/inotify_fsnotify.c |  2 +-
 fs/notify/inotify/inotify_user.c     |  5 ++++-
 fs/notify/mark.c                     |  6 ++++--
 include/linux/fsnotify_backend.h     | 12 +++++++----
 include/linux/memcontrol.h           |  7 +++++++
 include/linux/sched.h                |  3 +++
 include/linux/sched/mm.h             | 23 +++++++++++++++++++++
 include/linux/slab.h                 | 30 ++++++++++++++++++++++++++++
 kernel/fork.c                        |  3 +++
 mm/memcontrol.c                      | 25 ++++++++++++++++++-----
 15 files changed, 124 insertions(+), 23 deletions(-)

-- 
2.16.1.291.g4437f3f132-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
