Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 197D26B0007
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 01:49:51 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id z96-v6so10757422ybh.2
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 22:49:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5-v6sor191118ybc.118.2018.06.25.22.49.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 22:49:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180625230659.139822-2-shakeelb@google.com>
References: <20180625230659.139822-1-shakeelb@google.com> <20180625230659.139822-2-shakeelb@google.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Tue, 26 Jun 2018 08:49:48 +0300
Message-ID: <CAOQ4uxiV75+X3dMLS93iXqwmSU6eKPOUocdkXiR7MQZhEjotQg@mail.gmail.com>
Subject: Re: [PATCH 1/2] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>

On Tue, Jun 26, 2018 at 2:06 AM, Shakeel Butt <shakeelb@google.com> wrote:
> A lot of memory can be consumed by the events generated for the huge or
> unlimited queues if there is either no or slow listener.  This can cause
> system level memory pressure or OOMs.  So, it's better to account the
> fsnotify kmem caches to the memcg of the listener.
>
> However the listener can be in a different memcg than the memcg of the
> producer and these allocations happen in the context of the event
> producer. This patch introduces remote memcg charging scope API which the
> producer can use to charge the allocations to the memcg of the listener.
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
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Amir Goldstein <amir73il@gmail.com>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Roman Gushchin <guro@fb.com>
> ---
> Changelog since v6:
> - Removed Jan's ACK as the code has changed a lot
> - Squashed the separate remote charging API path into this one
> - Removed kmalloc* & kmem_cache_alloc* APIs and only kept the scope API
> - Changed fsnotify remote charging code to use scope API
>
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
>  fs/notify/dnotify/dnotify.c          |  5 ++--
>  fs/notify/fanotify/fanotify.c        | 17 ++++++++++--
>  fs/notify/fanotify/fanotify_user.c   |  5 +++-
>  fs/notify/group.c                    |  4 +++
>  fs/notify/inotify/inotify_fsnotify.c | 15 +++++++++-
>  fs/notify/inotify/inotify_user.c     |  5 +++-
>  include/linux/fsnotify_backend.h     | 12 +++++---
>  include/linux/memcontrol.h           |  7 +++++
>  include/linux/sched.h                |  3 ++
>  include/linux/sched/mm.h             | 41 ++++++++++++++++++++++++++++
>  kernel/fork.c                        |  3 ++
>  mm/memcontrol.c                      | 38 +++++++++++++++++++++++---
>  12 files changed, 139 insertions(+), 16 deletions(-)
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
> index f90842efea13..d6dfcf0ec21f 100644
> --- a/fs/notify/fanotify/fanotify.c
> +++ b/fs/notify/fanotify/fanotify.c
> @@ -11,6 +11,7 @@
>  #include <linux/types.h>
>  #include <linux/wait.h>
>  #include <linux/audit.h>
> +#include <linux/sched/mm.h>
>
>  #include "fanotify.h"
>
> @@ -140,8 +141,9 @@ struct fanotify_event_info *fanotify_alloc_event(struct fsnotify_group *group,
>                                                  struct inode *inode, u32 mask,
>                                                  const struct path *path)
>  {
> -       struct fanotify_event_info *event;
> +       struct fanotify_event_info *event = NULL;
>         gfp_t gfp = GFP_KERNEL;
> +       struct mem_cgroup *old_memcg = NULL;
>
>         /*
>          * For queues with unlimited length lost events are not expected and
> @@ -151,19 +153,25 @@ struct fanotify_event_info *fanotify_alloc_event(struct fsnotify_group *group,
>         if (group->max_events == UINT_MAX)
>                 gfp |= __GFP_NOFAIL;
>
> +       /* Whoever is interested in the event, pays for the allocation. */
> +       if (group->memcg) {
> +               gfp |= __GFP_ACCOUNT;
> +               old_memcg = memalloc_use_memcg(group->memcg);
> +       }
> +
>         if (fanotify_is_perm_event(mask)) {
>                 struct fanotify_perm_event_info *pevent;
>
>                 pevent = kmem_cache_alloc(fanotify_perm_event_cachep, gfp);
>                 if (!pevent)
> -                       return NULL;
> +                       goto out;
>                 event = &pevent->fae;
>                 pevent->response = 0;
>                 goto init;
>         }
>         event = kmem_cache_alloc(fanotify_event_cachep, gfp);
>         if (!event)
> -               return NULL;
> +               goto out;
>  init: __maybe_unused
>         fsnotify_init_event(&event->fse, inode, mask);
>         event->tgid = get_pid(task_tgid(current));
> @@ -174,6 +182,9 @@ init: __maybe_unused
>                 event->path.mnt = NULL;
>                 event->path.dentry = NULL;
>         }
> +out:
> +       if (group->memcg)
> +               memalloc_unuse_memcg(old_memcg);
>         return event;
>  }
>
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
> index aa5468f23e45..cbcda1cb9a74 100644
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
> @@ -36,6 +37,9 @@ static void fsnotify_final_destroy_group(struct fsnotify_group *group)
>         if (group->ops->free_group_priv)
>                 group->ops->free_group_priv(group);
>
> +       if (group->memcg)
> +               mem_cgroup_put(group->memcg);
> +
>         kfree(group);
>  }
>
> diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
> index 9ab6dde38a14..73b4d6c55497 100644
> --- a/fs/notify/inotify/inotify_fsnotify.c
> +++ b/fs/notify/inotify/inotify_fsnotify.c
> @@ -31,6 +31,7 @@
>  #include <linux/types.h>
>  #include <linux/sched.h>
>  #include <linux/sched/user.h>
> +#include <linux/sched/mm.h>
>
>  #include "inotify.h"
>
> @@ -73,9 +74,11 @@ int inotify_handle_event(struct fsnotify_group *group,
>         struct inotify_inode_mark *i_mark;
>         struct inotify_event_info *event;
>         struct fsnotify_event *fsn_event;
> +       struct mem_cgroup *old_memcg = NULL;
>         int ret;
>         int len = 0;
>         int alloc_len = sizeof(struct inotify_event_info);
> +       gfp_t gfp = GFP_KERNEL;
>
>         if (WARN_ON(fsnotify_iter_vfsmount_mark(iter_info)))
>                 return 0;
> @@ -98,7 +101,17 @@ int inotify_handle_event(struct fsnotify_group *group,
>         i_mark = container_of(inode_mark, struct inotify_inode_mark,
>                               fsn_mark);
>
> -       event = kmalloc(alloc_len, GFP_KERNEL);
> +       /* Whoever is interested in the event, pays for the allocation. */
> +       if (group->memcg) {
> +               gfp |= __GFP_ACCOUNT;
> +               old_memcg = memalloc_use_memcg(group->memcg);
> +       }
> +
> +       event = kmalloc(alloc_len, gfp);
> +
> +       if (group->memcg)
> +               memalloc_unuse_memcg(old_memcg);
> +
>         if (unlikely(!event)) {
>                 /*
>                  * Treat lost event due to ENOMEM the same way as queue
> diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
> index 1cf5b779d862..749c46ababa0 100644
> --- a/fs/notify/inotify/inotify_user.c
> +++ b/fs/notify/inotify/inotify_user.c
> @@ -38,6 +38,7 @@
>  #include <linux/uaccess.h>
>  #include <linux/poll.h>
>  #include <linux/wait.h>
> +#include <linux/memcontrol.h>
>
>  #include "inotify.h"
>  #include "../fdinfo.h"
> @@ -636,6 +637,7 @@ static struct fsnotify_group *inotify_new_group(unsigned int max_events)
>         oevent->name_len = 0;
>
>         group->max_events = max_events;
> +       group->memcg = get_mem_cgroup_from_mm(current->mm);
>
>         spin_lock_init(&group->inotify_data.idr_lock);
>         idr_init(&group->inotify_data.idr);
> @@ -808,7 +810,8 @@ static int __init inotify_user_setup(void)
>
>         BUG_ON(hweight32(ALL_INOTIFY_BITS) != 21);
>
> -       inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC);
> +       inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark,
> +                                              SLAB_PANIC|SLAB_ACCOUNT);
>
>         inotify_max_queued_events = 16384;
>         init_user_ns.ucount_max[UCOUNT_INOTIFY_INSTANCES] = 128;
> diff --git a/include/linux/fsnotify_backend.h b/include/linux/fsnotify_backend.h
> index b38964a7a521..a0c4790c5302 100644
> --- a/include/linux/fsnotify_backend.h
> +++ b/include/linux/fsnotify_backend.h
> @@ -84,6 +84,8 @@ struct fsnotify_event_private_data;
>  struct fsnotify_fname;
>  struct fsnotify_iter_info;
>
> +struct mem_cgroup;
> +
>  /*
>   * Each group much define these ops.  The fsnotify infrastructure will call
>   * these operations for each relevant group.
> @@ -127,6 +129,8 @@ struct fsnotify_event {
>   * everything will be cleaned up.
>   */
>  struct fsnotify_group {
> +       const struct fsnotify_ops *ops; /* how this group handles things */
> +
>         /*
>          * How the refcnt is used is up to each group.  When the refcnt hits 0
>          * fsnotify will clean up all of the resources associated with this group.
> @@ -137,8 +141,6 @@ struct fsnotify_group {
>          */
>         refcount_t refcnt;              /* things with interest in this group */
>
> -       const struct fsnotify_ops *ops; /* how this group handles things */
> -
>         /* needed to send notification to userspace */
>         spinlock_t notification_lock;           /* protect the notification_list */
>         struct list_head notification_list;     /* list of event_holder this group needs to send to userspace */
> @@ -160,6 +162,8 @@ struct fsnotify_group {
>         atomic_t num_marks;             /* 1 for each mark and 1 for not being
>                                          * past the point of no return when freeing
>                                          * a group */
> +       atomic_t user_waits;            /* Number of tasks waiting for user
> +                                        * response */
>         struct list_head marks_list;    /* all inode marks for this group */
>
>         struct fasync_struct *fsn_fa;    /* async notification */
> @@ -167,8 +171,8 @@ struct fsnotify_group {
>         struct fsnotify_event *overflow_event;  /* Event we queue when the
>                                                  * notification list is too
>                                                  * full */
> -       atomic_t user_waits;            /* Number of tasks waiting for user
> -                                        * response */
> +
> +       struct mem_cgroup *memcg;       /* memcg to charge allocations */
>
>         /* groups can define private fields here or use the void *private */
>         union {
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 3607913032be..6c857be8a9b7 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -378,6 +378,8 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
>  bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
>  struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
>
> +struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm);
> +
>  static inline
>  struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
>         return css ? container_of(css, struct mem_cgroup, css) : NULL;
> @@ -857,6 +859,11 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
>         return true;
>  }
>
> +static inline struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
> +{
> +       return NULL;
> +}
> +
>  static inline void mem_cgroup_put(struct mem_cgroup *memcg)
>  {
>  }
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 87bf02d93a27..9cba7f874443 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1149,6 +1149,9 @@ struct task_struct {
>
>         /* Number of pages to reclaim on returning to userland: */
>         unsigned int                    memcg_nr_pages_over_high;
> +
> +       /* Used by memcontrol for targeted memcg charge: */
> +       struct mem_cgroup               *active_memcg;
>  #endif
>
>  #ifdef CONFIG_UPROBES
> diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
> index 44d356f5e47c..75f2d6ee2b72 100644
> --- a/include/linux/sched/mm.h
> +++ b/include/linux/sched/mm.h
> @@ -248,6 +248,47 @@ static inline void memalloc_noreclaim_restore(unsigned int flags)
>         current->flags = (current->flags & ~PF_MEMALLOC) | flags;
>  }
>
> +#ifdef CONFIG_MEMCG
> +/**
> + * memalloc_use_memcg - Starts the remote memcg charging scope.
> + * @memcg: memcg to charge.
> + *
> + * This function marks the beginning of the remote memcg charging scope. All the
> + * __GFP_ACCOUNT allocations till the end of the scope will be charged to the
> + * given memcg. Passing NULL will disable the remote memcg charging of the outer
> + * scope.
> + */
> +static inline struct mem_cgroup *memalloc_use_memcg(struct mem_cgroup *memcg)
> +{
> +       struct mem_cgroup *old_memcg = current->active_memcg;
> +
> +       current->active_memcg = memcg;
> +       return old_memcg;
> +}
> +
> +/**
> + * memalloc_unuse_memcg - Ends the remote memcg charging scope.
> + * @memcg: outer scope memcg to restore.
> + *
> + * This function marks the end of the remote memcg charging scope started by
> + * memalloc_use_memcg(). Always make sure the given memcg is the return valure
> + * from the pairing memalloc_use_memcg call.
> + */
> +static inline void memalloc_unuse_memcg(struct mem_cgroup *memcg)
> +{
> +       current->active_memcg = memcg;
> +}

The verb 'unuse' takes an argument memcg and 'uses' it - too weird.
You can use 'override'/'revert' verbs like override_creds or just call
memalloc_use_memcg(old_memcg) since there is no reference taken
anyway in use_memcg and no reference released in unuse_memcg.

Otherwise looks good to me.

Thanks,
Amir,
