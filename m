Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1946B0032
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 16:06:54 -0500 (EST)
Received: by lbjb6 with SMTP id b6so2362248lbj.12
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 13:06:53 -0800 (PST)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com. [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id eh1si16417966lbb.134.2015.02.19.13.06.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Feb 2015 13:06:52 -0800 (PST)
Received: by lbjb6 with SMTP id b6so2507783lbj.2
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 13:06:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150219171934.20458.30175.stgit@buzz>
References: <20150219171934.20458.30175.stgit@buzz>
Date: Fri, 20 Feb 2015 00:06:51 +0300
Message-ID: <CALYGNiPwR8Qy2iHrSSYyJXxE8eAn4PuK5a+u4XtWS2dFjwNqjw@mail.gmail.com>
Subject: Re: [PATCH] fs: avoid locking sb_lock in grab_super_passive()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

On Thu, Feb 19, 2015 at 8:19 PM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> I've noticed significant locking contention in memory reclaimer around
> sb_lock inside grab_super_passive(). Grab_super_passive() is called from
> two places: in icache/dcache shrinkers (function super_cache_scan) and
> from writeback (function __writeback_inodes_wb). Both are required for
> progress in memory reclaimer.
>
> Also this lock isn't irq-safe. And I've seen suspicious livelock under
> serious memory pressure where reclaimer was called from interrupt which

s/reclaimer/allocator/

> have happened right in place where sb_lock is held in normal context,
> so all other cpus were stuck on that lock too.
>
> Grab_super_passive() acquires sb_lock to increment sb->s_count and check
> sb->s_instances. It seems sb->s_umount locked for read is enough here:
> super-block deactivation always runs under sb->s_umount locked for write.
> Protecting super-block itself isn't a problem: in super_cache_scan() sb
> is protected by shrinker_rwsem: it cannot be freed if its slab shrinkers
> are still active. Inside writeback super-block comes from inode from bdi
> writeback list under wb->list_lock.
>
> This patch removes locking sb_lock and checks s_instances under s_umount:
> generic_shutdown_super() unlinks it under sb->s_umount locked for write.
> Now successful grab_super_passive() only locks semaphore, callers must
> call up_read(&sb->s_umount) instead of drop_super(sb) when they're done.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  fs/fs-writeback.c |    2 +-
>  fs/super.c        |   18 ++++--------------
>  2 files changed, 5 insertions(+), 15 deletions(-)
>
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 073657f..3e92bb7 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -779,7 +779,7 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
>                         continue;
>                 }
>                 wrote += writeback_sb_inodes(sb, wb, work);
> -               drop_super(sb);
> +               up_read(&sb->s_umount);
>
>                 /* refer to the same tests at the end of writeback_sb_inodes */
>                 if (wrote) {
> diff --git a/fs/super.c b/fs/super.c
> index 65a53ef..6ae33ed 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -105,7 +105,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
>                 freed += sb->s_op->free_cached_objects(sb, sc);
>         }
>
> -       drop_super(sb);
> +       up_read(&sb->s_umount);
>         return freed;
>  }
>
> @@ -356,27 +356,17 @@ static int grab_super(struct super_block *s) __releases(sb_lock)
>   *     superblock does not go away while we are working on it. It returns
>   *     false if a reference was not gained, and returns true with the s_umount
>   *     lock held in read mode if a reference is gained. On successful return,
> - *     the caller must drop the s_umount lock and the passive reference when
> - *     done.
> + *     the caller must drop the s_umount lock when done.
>   */
>  bool grab_super_passive(struct super_block *sb)
>  {
> -       spin_lock(&sb_lock);
> -       if (hlist_unhashed(&sb->s_instances)) {
> -               spin_unlock(&sb_lock);
> -               return false;
> -       }
> -
> -       sb->s_count++;
> -       spin_unlock(&sb_lock);
> -
>         if (down_read_trylock(&sb->s_umount)) {
> -               if (sb->s_root && (sb->s_flags & MS_BORN))
> +               if (!hlist_unhashed(&sb->s_instances) &&
> +                   sb->s_root && (sb->s_flags & MS_BORN))
>                         return true;
>                 up_read(&sb->s_umount);
>         }
>
> -       put_super(sb);
>         return false;
>  }
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
