Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF796B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 07:24:13 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id t92so13827324wrc.13
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 04:24:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d35si8282523edd.352.2017.11.24.04.24.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 04:24:12 -0800 (PST)
Date: Fri, 24 Nov 2017 13:24:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] mm,vmscan: Mark register_shrinker() as
 __must_check
Message-ID: <20171124122410.s7lyzfmkhlm6awes@dhcp22.suse.cz>
References: <1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1511523385-6433-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511523385-6433-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, Glauber Costa <glauber@scylladb.com>

On Fri 24-11-17 20:36:25, Tetsuo Handa wrote:
> Commit 1d3d4437eae1bb29 ("vmscan: per-node deferred work") changed
> register_shrinker() to fail when memory allocation failed.
> Since that commit did not take appropriate precautions before allowing
> register_shrinker() to fail, there are many register_shrinker() users
> who continue running when register_shrinker() failed.
> Since continuing when register_shrinker() failed can cause memory
> pressure related issues (e.g. needless OOM killer invocations),
> this patch marks register_shrinker() as __must_check in order to
> encourage all register_shrinker() users to add error recovery path.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Glauber Costa <glauber@scylladb.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>

As already pointed out, I do not think this is worth it. This function
is no different than many others which need error handling. The system
will work suboptimally when the shrinker is missing, no question about
that, but there is no immediate blow up otherwise. It is not all that
hard to find all those places and fix them up. We do not have hundreds
of them...

> ---
>  include/linux/shrinker.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index 388ff29..a389491 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -75,6 +75,6 @@ struct shrinker {
>  #define SHRINKER_NUMA_AWARE	(1 << 0)
>  #define SHRINKER_MEMCG_AWARE	(1 << 1)
>  
> -extern int register_shrinker(struct shrinker *);
> +extern __must_check int register_shrinker(struct shrinker *);
>  extern void unregister_shrinker(struct shrinker *);
>  #endif
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
