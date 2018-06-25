Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14BE96B0003
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 19:07:11 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 70-v6so8940701plc.1
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 16:07:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a23-v6sor29371pgv.34.2018.06.25.16.07.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 16:07:09 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v7 0/2] Directed kmem charging
Date: Mon, 25 Jun 2018 16:06:57 -0700
Message-Id: <20180625230659.139822-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, Amir Goldstein <amir73il@gmail.com>, Roman Gushchin <guro@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Shakeel Butt <shakeelb@google.com>

The Linux kernel's memory cgroup allows limiting the memory usage of
the jobs running on the system to provide isolation between the jobs.
All the kernel memory allocated in the context of the job and marked
with __GFP_ACCOUNT will also be included in the memory usage and be
limited by the job's limit.

The kernel memory can only be charged to the memcg of the process in
whose context kernel memory was allocated. However there are cases where
the allocated kernel memory should be charged to the memcg different
from the current processes's memcg. This patch series contains two such
concrete use-cases i.e. fsnotify and buffer_head.

The fsnotify event objects can consume a lot of system memory for large
or unlimited queues if there is either no or slow listener. The events
are allocated in the context of the event producer. However they should
be charged to the event consumer. Similarly the buffer_head objects can
be allocated in a memcg different from the memcg of the page for which
buffer_head objects are being allocated.

To solve this issue, this patch series introduces mechanism to charge
kernel memory to a given memcg. In case of fsnotify events, the memcg of
the consumer can be used for charging and for buffer_head, the memcg of
the page can be charged. For directed charging, the caller can use the
scope API memalloc_[un]use_memcg() to specify the memcg to charge for
all the __GFP_ACCOUNT allocations within the scope.

Shakeel Butt (2):
  fs: fsnotify: account fsnotify metadata to kmemcg
  fs, mm: account buffer_head to kmemcg

 fs/buffer.c                          | 15 ++++++-
 fs/notify/dnotify/dnotify.c          |  5 ++-
 fs/notify/fanotify/fanotify.c        | 17 ++++++--
 fs/notify/fanotify/fanotify_user.c   |  5 ++-
 fs/notify/group.c                    |  4 ++
 fs/notify/inotify/inotify_fsnotify.c | 15 ++++++-
 fs/notify/inotify/inotify_user.c     |  5 ++-
 include/linux/fsnotify_backend.h     | 12 ++++--
 include/linux/memcontrol.h           | 14 +++++++
 include/linux/sched.h                |  3 ++
 include/linux/sched/mm.h             | 41 +++++++++++++++++++
 kernel/fork.c                        |  3 ++
 mm/memcontrol.c                      | 60 ++++++++++++++++++++++++++--
 13 files changed, 182 insertions(+), 17 deletions(-)

-- 
2.18.0.rc2.346.g013aa6912e-goog
