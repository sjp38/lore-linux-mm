Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 833FE6B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 03:20:53 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id i9-v6so714495ybj.21
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 00:20:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d69-v6sor37130ybc.199.2018.06.19.00.20.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 00:20:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180619051327.149716-3-shakeelb@google.com>
References: <20180619051327.149716-1-shakeelb@google.com> <20180619051327.149716-3-shakeelb@google.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Tue, 19 Jun 2018 10:20:51 +0300
Message-ID: <CAOQ4uxgACdbNryEKdcngy+Fm9vOdFQNrioPuHFULa8gmA-gYaQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, linux-kernel <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>

On Tue, Jun 19, 2018 at 8:13 AM, Shakeel Butt <shakeelb@google.com> wrote:
> A lot of memory can be consumed by the events generated for the huge or
> unlimited queues if there is either no or slow listener.  This can cause
> system level memory pressure or OOMs.  So, it's better to account the
> fsnotify kmem caches to the memcg of the listener.
>
> There are seven fsnotify kmem caches and among them allocations from
> dnotify_struct_cache, dnotify_mark_cache, fanotify_mark_cache and
> inotify_inode_mark_cachep happens in the context of syscall from the
> listener.  So, SLAB_ACCOUNT is enough for these caches.
>
> The objects from fsnotify_mark_connector_cachep are not accounted as they
> are small compared to the notification mark or events and it is unclear
> whom to account connector to since it is shared by all events attached to
> the inode.
>
> The allocations from the event caches happen in the context of the event
> producer.  For such caches we will need to remote charge the allocations
> to the listener's memcg.  Thus we save the memcg reference in the
> fsnotify_group structure of the listener.
>
> This patch has also moved the members of fsnotify_group to keep the size
> same, at least for 64 bit build, even with additional member by filling
> the holes.
>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Acked-by: Jan Kara <jack@suse.cz>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Amir Goldstein <amir73il@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
> Changelog since v5:
> - None
>
> Changelog since v4:
> - Fixed the build for CONFIG_MEMCG=n
>
> Changelog since v3:
> - Rebased over Jan's patches.
> - Some cleanup based on Amir's comments.
>
> Changelog since v2:
> - None
>
> Changelog since v1:
> - no more charging fsnotify_mark_connector objects
> - Fixed the build for SLOB
>
>  fs/notify/dnotify/dnotify.c          |  5 +++--
>  fs/notify/fanotify/fanotify.c        |  6 ++++--
>  fs/notify/fanotify/fanotify_user.c   |  5 ++++-
>  fs/notify/group.c                    |  6 ++++++
>  fs/notify/inotify/inotify_fsnotify.c |  2 +-
>  fs/notify/inotify/inotify_user.c     |  5 ++++-
>  include/linux/fsnotify_backend.h     | 12 ++++++++----
>  include/linux/memcontrol.h           |  7 +++++++
>  mm/memcontrol.c                      | 15 +++++++++++++--
>  9 files changed, 50 insertions(+), 13 deletions(-)
>
> diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
> index e2bea2ac5dfb..a6365e6bc047 100644
> --- a/fs/notify/dnotify/dnotify.c
> +++ b/fs/notify/dnotify/dnotify.c
> @@ -384,8 +384,9 @@ int fcntl_dirnotify(int fd, struct file *filp, unsigned long arg)
>
>  static int __init dnotify_init(void)
>  {
> -       dnotify_struct_cache = KMEM_CACHE(dnotify_struct, SLAB_PANIC);
> -       dnotify_mark_cache = KMEM_CACHE(dnotify_mark, SLAB_PANIC);
> +       dnotify_struct_cache = KMEM_CACHE(dnotify_struct,
> +                                         SLAB_PANIC|SLAB_ACCOUNT);
> +       dnotify_mark_cache = KMEM_CACHE(dnotify_mark, SLAB_PANIC|SLAB_ACCOUNT);
>
>         dnotify_group = fsnotify_alloc_group(&dnotify_fsnotify_ops);
>         if (IS_ERR(dnotify_group))
> diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
> index f90842efea13..c8d6e37a4855 100644
> --- a/fs/notify/fanotify/fanotify.c
> +++ b/fs/notify/fanotify/fanotify.c
> @@ -154,14 +154,16 @@ struct fanotify_event_info *fanotify_alloc_event(struct fsnotify_group *group,
>         if (fanotify_is_perm_event(mask)) {
>                 struct fanotify_perm_event_info *pevent;
>
> -               pevent = kmem_cache_alloc(fanotify_perm_event_cachep, gfp);
> +               pevent = kmem_cache_alloc_memcg(fanotify_perm_event_cachep, gfp,
> +                                               group->memcg);
>                 if (!pevent)
>                         return NULL;
>                 event = &pevent->fae;
>                 pevent->response = 0;
>                 goto init;
>         }
> -       event = kmem_cache_alloc(fanotify_event_cachep, gfp);
> +       event = kmem_cache_alloc_memcg(fanotify_event_cachep, gfp,
> +                                      group->memcg);
>         if (!event)
>                 return NULL;
>  init: __maybe_unused
> diff --git a/fs/notify/fanotify/fanotify_user.c b/fs/notify/fanotify/fanotify_user.c
> index ec4d8c59d0e3..0cf45041dc32 100644
> --- a/fs/notify/fanotify/fanotify_user.c
> +++ b/fs/notify/fanotify/fanotify_user.c
> @@ -16,6 +16,7 @@
>  #include <linux/uaccess.h>
>  #include <linux/compat.h>
>  #include <linux/sched/signal.h>
> +#include <linux/memcontrol.h>
>
>  #include <asm/ioctls.h>
>
> @@ -756,6 +757,7 @@ SYSCALL_DEFINE2(fanotify_init, unsigned int, flags, unsigned int, event_f_flags)
>
>         group->fanotify_data.user = user;
>         atomic_inc(&user->fanotify_listeners);
> +       group->memcg = get_mem_cgroup_from_mm(current->mm);
>

It seem to me that you should export a wrapper to modules with
the mem_cgroup_ prefix and not sure that need to pass current->mm
to this wrapper.

>         oevent = fanotify_alloc_event(group, NULL, FS_Q_OVERFLOW, NULL);
>         if (unlikely(!oevent)) {
> @@ -957,7 +959,8 @@ COMPAT_SYSCALL_DEFINE6(fanotify_mark,
>   */
>  static int __init fanotify_user_setup(void)
>  {
> -       fanotify_mark_cache = KMEM_CACHE(fsnotify_mark, SLAB_PANIC);
> +       fanotify_mark_cache = KMEM_CACHE(fsnotify_mark,
> +                                        SLAB_PANIC|SLAB_ACCOUNT);
>         fanotify_event_cachep = KMEM_CACHE(fanotify_event_info, SLAB_PANIC);
>         if (IS_ENABLED(CONFIG_FANOTIFY_ACCESS_PERMISSIONS)) {
>                 fanotify_perm_event_cachep =
> diff --git a/fs/notify/group.c b/fs/notify/group.c
> index aa5468f23e45..300fc0f62115 100644
> --- a/fs/notify/group.c
> +++ b/fs/notify/group.c
> @@ -22,6 +22,7 @@
>  #include <linux/srcu.h>
>  #include <linux/rculist.h>
>  #include <linux/wait.h>
> +#include <linux/memcontrol.h>
>
>  #include <linux/fsnotify_backend.h>
>  #include "fsnotify.h"
> @@ -36,6 +37,11 @@ static void fsnotify_final_destroy_group(struct fsnotify_group *group)
>         if (group->ops->free_group_priv)
>                 group->ops->free_group_priv(group);
>
> +#ifdef CONFIG_MEMCG
> +       if (group->memcg)
> +               css_put(&group->memcg->css);
> +#endif
> +

This looks very much like an internal implementation detail that has no
business in an external module. I see evidence that you have used
mem_cgroup_put() in the patch at some point and I agree that you
need to export a pair of matching helpers to external modules.

Thanks,
Amir.
