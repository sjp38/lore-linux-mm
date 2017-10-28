Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA2176B0033
	for <linux-mm@kvack.org>; Sat, 28 Oct 2017 10:19:39 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id y127so16206970ywf.13
        for <linux-mm@kvack.org>; Sat, 28 Oct 2017 07:19:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k19sor3748698ywe.475.2017.10.28.07.19.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 28 Oct 2017 07:19:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1509128538-50162-1-git-send-email-yang.s@alibaba-inc.com>
References: <1509128538-50162-1-git-send-email-yang.s@alibaba-inc.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Sat, 28 Oct 2017 17:19:36 +0300
Message-ID: <CAOQ4uxiFA8FDoFU8cNGYoJeiuTFOE9-fgsG4xtnM=9zfAJ+k2g@mail.gmail.com>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Oct 27, 2017 at 9:22 PM, Yang Shi <yang.s@alibaba-inc.com> wrote:
> If some process generates events into a huge or unlimit event queue, but no
> listener read them, they may consume significant amount of memory silently
> until oom happens or some memory pressure issue is raised.
> It'd better to account those slab caches in memcg so that we can get heads
> up before the problematic process consume too much memory silently.
>
> But, the accounting might be heuristic if the producer is in the different
> memcg from listener if the listener doesn't read the events. Due to the
> current design of kmemcg, who does the allocation, who gets the accounting.

<suggest rephrase>
Due to the current design of kmemcg, the memcg of the process who does the
allocation gets the accounting, so event allocations get accounted for
the memcg of
the event producer process, even though the misbehaving process is the listener.
The event allocations won't be freed if the producer exits, only if
the listener exists.
Nevertheless, it is still better to account event allocations to memcg
of producer
process and not to root memcg, because heuristically producer is many
time in the
same memcg as the listener. For example, this is the case with listeners inside
containers that listen on events for files or mounts that are private
to the container.
<\suggest rephrase>

And the same comment should be above creation of event kmem caches,
so we know this is the lesser evil and not the perfect solution.

>
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> ---
> v1 --> v2:
> * Updated commit log per Amir's suggestion
>
>  fs/notify/dnotify/dnotify.c        | 4 ++--
>  fs/notify/fanotify/fanotify_user.c | 6 +++---
>  fs/notify/fsnotify.c               | 2 +-
>  fs/notify/inotify/inotify_user.c   | 2 +-
>  4 files changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
> index cba3283..3ec6233 100644
> --- a/fs/notify/dnotify/dnotify.c
> +++ b/fs/notify/dnotify/dnotify.c
> @@ -379,8 +379,8 @@ int fcntl_dirnotify(int fd, struct file *filp, unsigned long arg)
>
>  static int __init dnotify_init(void)
>  {
> -       dnotify_struct_cache = KMEM_CACHE(dnotify_struct, SLAB_PANIC);
> -       dnotify_mark_cache = KMEM_CACHE(dnotify_mark, SLAB_PANIC);
> +       dnotify_struct_cache = KMEM_CACHE(dnotify_struct, SLAB_PANIC|SLAB_ACCOUNT);
> +       dnotify_mark_cache = KMEM_CACHE(dnotify_mark, SLAB_PANIC|SLAB_ACCOUNT);
>
>         dnotify_group = fsnotify_alloc_group(&dnotify_fsnotify_ops);
>         if (IS_ERR(dnotify_group))
> diff --git a/fs/notify/fanotify/fanotify_user.c b/fs/notify/fanotify/fanotify_user.c
> index 907a481..7d62dee 100644
> --- a/fs/notify/fanotify/fanotify_user.c
> +++ b/fs/notify/fanotify/fanotify_user.c
> @@ -947,11 +947,11 @@ static int fanotify_add_inode_mark(struct fsnotify_group *group,
>   */
>  static int __init fanotify_user_setup(void)
>  {
> -       fanotify_mark_cache = KMEM_CACHE(fsnotify_mark, SLAB_PANIC);
> -       fanotify_event_cachep = KMEM_CACHE(fanotify_event_info, SLAB_PANIC);
> +       fanotify_mark_cache = KMEM_CACHE(fsnotify_mark, SLAB_PANIC|SLAB_ACCOUNT);
> +       fanotify_event_cachep = KMEM_CACHE(fanotify_event_info, SLAB_PANIC|SLAB_ACCOUNT);
>  #ifdef CONFIG_FANOTIFY_ACCESS_PERMISSIONS
>         fanotify_perm_event_cachep = KMEM_CACHE(fanotify_perm_event_info,
> -                                               SLAB_PANIC);
> +                                               SLAB_PANIC|SLAB_ACCOUNT);
>  #endif
>
>         return 0;
> diff --git a/fs/notify/fsnotify.c b/fs/notify/fsnotify.c
> index 0c4583b..82620ac 100644
> --- a/fs/notify/fsnotify.c
> +++ b/fs/notify/fsnotify.c
> @@ -386,7 +386,7 @@ static __init int fsnotify_init(void)
>                 panic("initializing fsnotify_mark_srcu");
>
>         fsnotify_mark_connector_cachep = KMEM_CACHE(fsnotify_mark_connector,
> -                                                   SLAB_PANIC);
> +                                                   SLAB_PANIC|SLAB_ACCOUNT);
>
>         return 0;
>  }
> diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
> index 7cc7d3f..57b32ff 100644
> --- a/fs/notify/inotify/inotify_user.c
> +++ b/fs/notify/inotify/inotify_user.c
> @@ -785,7 +785,7 @@ static int __init inotify_user_setup(void)
>
>         BUG_ON(hweight32(ALL_INOTIFY_BITS) != 21);
>
> -       inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC);
> +       inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC|SLAB_ACCOUNT);
>
>         inotify_max_queued_events = 16384;
>         init_user_ns.ucount_max[UCOUNT_INOTIFY_INSTANCES] = 128;
> --
> 1.8.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
