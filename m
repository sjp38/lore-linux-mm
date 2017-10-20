Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 260736B025F
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 23:14:44 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id t71so8551414ywc.22
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 20:14:44 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id j131si485ybc.226.2017.10.19.20.14.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 20:14:43 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id w5so5308883ywg.11
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 20:14:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1508448056-21779-1-git-send-email-yang.s@alibaba-inc.com>
References: <1508448056-21779-1-git-send-email-yang.s@alibaba-inc.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 20 Oct 2017 06:14:37 +0300
Message-ID: <CAOQ4uxhPhXrMLu18TGKDA=ezUVHara95qJQ+BTCio8BHm-u6NA@mail.gmail.com>
Subject: Re: [RFC PATCH] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Oct 20, 2017 at 12:20 AM, Yang Shi <yang.s@alibaba-inc.com> wrote:
> We observed some misbehaved user applications might consume significant
> amount of fsnotify slabs silently. It'd better to account those slabs in
> kmemcg so that we can get heads up before misbehaved applications use too
> much memory silently.

In what way do they misbehave? create a lot of marks? create a lot of events?
Not reading events in their queue?
The latter case is more interesting:

Process A is the one that asked to get the events.
Process B is the one that is generating the events and queuing them on
the queue that is owned by process A, who is also to blame if the queue
is not being read.

So why should process B be held accountable for memory pressure
caused by, say, an FAN_UNLIMITED_QUEUE that process A created and
doesn't read from.

Is it possible to get an explicit reference to the memcg's  events cache
at fsnotify_group creation time, store it in the group struct and then allocate
events from the event cache associated with the group (the listener) rather
than the cache associated with the task generating the event?

Amir.

>
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> ---
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
