Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7416F6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:52:07 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 35-v6so6778717pla.18
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:52:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m190sor2887355pgm.318.2018.04.16.13.52.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 13:52:06 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v5 0/2] Directed kmem charging 
Date: Mon, 16 Apr 2018 13:51:48 -0700
Message-Id: <20180416205150.113915-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

This patchset introduces memcg variant memory allocation functions. The
caller can explicitly pass the memcg to charge for kmem allocations.
Currently the kernel, for __GFP_ACCOUNT memory allocation requests,
extract the memcg of the current task to charge for the kmem allocation.
This patch series introduces kmem allocation functions where the caller
can pass the pointer to the remote memcg. The remote memcg will be
charged for the allocation instead of the memcg of the caller. However
the caller must have a reference to the remote memcg.

Fixed the build for SLOB in v2, added the target_memcg in task_struct in
v3, added node variant for kmem allocation functions and rebased fsnotify
patch over Jan's patches in v4 and in v5 fixed CONFIG_MEMCG=n build and
removed the extra branch in the common case of memory allocation.

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
 include/linux/sched/mm.h             | 24 +++++++++++
 include/linux/slab.h                 | 59 ++++++++++++++++++++++++++++
 kernel/fork.c                        |  3 ++
 mm/memcontrol.c                      | 20 ++++++++--
 13 files changed, 141 insertions(+), 14 deletions(-)

-- 
2.17.0.484.g0c8726318c-goog
