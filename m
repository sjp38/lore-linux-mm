Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 511926B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 05:13:32 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id t6so5099211wrc.12
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 02:13:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a69si4922772wme.273.2018.02.13.02.13.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Feb 2018 02:13:31 -0800 (PST)
Date: Tue, 13 Feb 2018 11:13:29 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,vmscan: don't pretend forward progress upon
 shrinker_rwsem contention
Message-ID: <20180213101329.GN3443@dhcp22.suse.cz>
References: <1518184544-3293-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518184544-3293-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@gmail.com>

[Fix Glauber's email]

On Fri 09-02-18 22:55:44, Tetsuo Handa wrote:
> Since we no longer use return value of shrink_slab() for normal reclaim,
> the comment is no longer true. If some do_shrink_slab() call takes
> unexpectedly long (root cause of stall is currently unknown) when
> register_shrinker()/unregister_shrinker() is pending, trying to drop
> caches via /proc/sys/vm/drop_caches could become infinite cond_resched()
> loop if many mem_cgroup are defined. For safety, let's not pretend forward
> progress.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Glauber Costa <glommer@parallels.com>
> Cc: Mel Gorman <mgorman@suse.de>

Yes, this makes sense to me. The whole "let's pretend we made some
progress" was an ugly hack IMHO.

Acked-by: Michal Hocko <mhocko@suse.ccom>

> ---
>  mm/vmscan.c | 10 +---------
>  1 file changed, 1 insertion(+), 9 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4447496..17da5a5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -442,16 +442,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
>  		return 0;
>  
> -	if (!down_read_trylock(&shrinker_rwsem)) {
> -		/*
> -		 * If we would return 0, our callers would understand that we
> -		 * have nothing else to shrink and give up trying. By returning
> -		 * 1 we keep it going and assume we'll be able to shrink next
> -		 * time.
> -		 */
> -		freed = 1;
> +	if (!down_read_trylock(&shrinker_rwsem))
>  		goto out;
> -	}
>  
>  	list_for_each_entry(shrinker, &shrinker_list, list) {
>  		struct shrink_control sc = {
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
