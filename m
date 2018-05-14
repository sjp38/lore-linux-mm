Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB1F6B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 13:04:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 62-v6so11039778pfw.21
        for <linux-mm@kvack.org>; Mon, 14 May 2018 10:04:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bd7-v6sor3001122plb.45.2018.05.14.10.04.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 10:04:26 -0700 (PDT)
Date: Mon, 14 May 2018 10:04:23 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] shmem: don't call put_super() when fill_super() failed.
Message-ID: <20180514170423.GA252575@gmail.com>
References: <201805140657.w4E6vV4a035377@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805140657.w4E6vV4a035377@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot+d2586fde8fdcead3647f@syzkaller.appspotmail.com, viro@ZenIV.linux.org.uk, hughd@google.com, syzkaller-bugs@googlegroups.com, linux-mm@kvack.org

Hi Tetsuo,

On Mon, May 14, 2018 at 03:57:31PM +0900, Tetsuo Handa wrote:
> From 193d9cb8b5dfc50c693d4bdd345cedb615bbf5ae Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Mon, 14 May 2018 15:25:13 +0900
> Subject: [PATCH] shmem: don't call put_super() when fill_super() failed.
> 
> syzbot is reporting NULL pointer dereference at shmem_unused_huge_count()
> [1]. This is because shmem_fill_super() is calling shmem_put_super() which
> immediately releases memory before unregister_shrinker() is called by
> deactivate_locked_super() after fill_super() in mount_nodev() failed.
> Fix this by leaving the call to shmem_put_super() to
> generic_shutdown_super() from kill_anon_super() from kill_litter_super()
>  from deactivate_locked_super().
> 
> [1] https://syzkaller.appspot.com/bug?id=46e792849791f4abbac898880e8522054e032391
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-by: syzbot <syzbot+d2586fde8fdcead3647f@syzkaller.appspotmail.com>
> Cc: Al Viro <viro@ZenIV.linux.org.uk>
> ---
>  mm/shmem.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 9d6c7e5..18e134c 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -3843,7 +3843,6 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
>  	return 0;
>  
>  failed:
> -	shmem_put_super(sb);
>  	return err;
>  }
>  
> -- 
> 1.8.3.1

I'm not following, since generic_shutdown_super() only calls ->put_super() if
->s_root is set, which only happens at the end of shmem_fill_super().  Isn't the
real problem that s_shrink is registered too early, causing super_cache_count()
and shmem_unused_huge_count() to potentially run before shmem_fill_super() has
completed?  Or alternatively, the problem is that super_cache_count() doesn't
check for SB_ACTIVE.

Eric
