Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 18FFE6B000D
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 01:13:43 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b65-v6so10329324plb.5
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 22:13:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y12-v6sor4367613plt.115.2018.06.18.22.13.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Jun 2018 22:13:41 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v6 0/3] Directed kmem charging
Date: Mon, 18 Jun 2018 22:13:24 -0700
Message-Id: <20180619051327.149716-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Shakeel Butt <shakeelb@google.com>

This patchset introduces memcg variant memory allocation functions.  The
caller can explicitly pass the memcg to charge for kmem allocations.
Currently the kernel, for __GFP_ACCOUNT memory allocation requests,
extract the memcg of the current task to charge for the kmem allocation.
This patch series introduces kmem allocation functions where the caller
can pass the pointer to the remote memcg.  The remote memcg will be
charged for the allocation instead of the memcg of the caller.  However
the caller must have a reference to the remote memcg.  This patch series
also introduces scope API for targeted memcg charging. So, all the
__GFP_ACCOUNT alloctions within the specified scope will be charged to
the given target memcg.

Shakeel Butt (3):
  mm: memcg: remote memcg charging for kmem allocations
  fs: fsnotify: account fsnotify metadata to kmemcg
  fs, mm: account buffer_head to kmemcg

 fs/buffer.c                          | 14 ++++-
 fs/notify/dnotify/dnotify.c          |  5 +-
 fs/notify/fanotify/fanotify.c        |  6 +-
 fs/notify/fanotify/fanotify_user.c   |  5 +-
 fs/notify/group.c                    |  6 ++
 fs/notify/inotify/inotify_fsnotify.c |  2 +-
 fs/notify/inotify/inotify_user.c     |  5 +-
 include/linux/fsnotify_backend.h     | 12 ++--
 include/linux/memcontrol.h           | 14 +++++
 include/linux/sched.h                |  3 +
 include/linux/sched/mm.h             | 24 ++++++++
 include/linux/slab.h                 | 83 ++++++++++++++++++++++++++++
 kernel/fork.c                        |  3 +
 mm/memcontrol.c                      | 54 ++++++++++++++++--
 14 files changed, 220 insertions(+), 16 deletions(-)

-- 
2.18.0.rc1.244.gcf134e6275-goog
