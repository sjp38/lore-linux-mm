Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 102316B02EC
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 05:37:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id s11so31576447pgc.15
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:37:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m3si24501834pgs.471.2017.11.28.02.37.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 02:37:27 -0800 (PST)
Date: Tue, 28 Nov 2017 11:37:23 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Message-ID: <20171128103723.GK5977@quack2.suse.cz>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Yafang Shao <laoar.shao@gmail.com>, akpm@linux-foundation.org, jack@suse.cz, linux-mm@kvack.org

On Mon 27-11-17 10:19:39, Michal Hocko wrote:
> Andrew,
> could you simply send this to Linus. If we _really_ need something to
> prevent misconfiguration, which I doubt to be honest, then it should be
> thought through much better.

What's so bad about the warning? I think warning about such
misconfiguration is not a bad thing per se. Maybe it should be ratelimited
and certainly the condition is too loose as your example shows but in
principle I'm not against it and e.g. making the inequality in the condition
strict like:

	if (unlikely(bg_thresh > thresh))

or at least

	if (unlikely(bg_thresh >= thresh && thresh > 0))

would warn about cases where domain_dirty_limits() had to fixup bg_thresh
manually to make writeback throttling work and avoid reclaim stalls which
is IMHO a sane thing...

								Honza

> ---
> From 4ef6b1cbf98ea5dae155ab3303c4ae1d93411b79 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 27 Nov 2017 10:12:15 +0100
> Subject: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
>  dirtiness settings are illogical"
> 
> This reverts commit 0f6d24f878568fac579a1962d0bf7cb9f01e0ceb because
> it causes false positive warnings during OOM situations as noticed by
> Tetsuo Handa:
> [  621.814512] Node 0 active_anon:3525940kB inactive_anon:8372kB active_file:216kB inactive_file:1872kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:2504kB dirty:52kB writeback:0kB shmem:8660kB s
> hmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 636928kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
> [  621.821534] Node 0 DMA free:14848kB min:284kB low:352kB high:420kB active_anon:992kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocke
> d:0kB kernel_stack:0kB pagetables:24kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [  621.829035] lowmem_reserve[]: 0 2687 3645 3645
> [  621.831655] Node 0 DMA32 free:53004kB min:49608kB low:62008kB high:74408kB active_anon:2712648kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:
> 2773132kB mlocked:0kB kernel_stack:96kB pagetables:5096kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [  621.839945] lowmem_reserve[]: 0 0 958 958
> [  621.842811] Node 0 Normal free:17140kB min:17684kB low:22104kB high:26524kB active_anon:812300kB inactive_anon:8372kB active_file:1228kB inactive_file:1868kB unevictable:0kB writepending:52kB present:1048576k
> B managed:981224kB mlocked:0kB kernel_stack:3520kB pagetables:8552kB bounce:0kB free_pcp:120kB local_pcp:120kB free_cma:0kB
> [  621.852473] lowmem_reserve[]: 0 0 0 0
> [...]
> [  621.891477] Out of memory: Kill process 8459 (a.out) score 999 or sacrifice child
> [  621.894363] Killed process 8459 (a.out) total-vm:4180kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
> [  621.897172] oom_reaper: reaped process 8459 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  622.424664] vm direct limit must be set greater than background limit.
> 
> The problem is that both thresh and bg_thresh will be 0 if available_memory
>  is less than 4 pages when evaluating global_dirtyable_memory. While
> this might be worked around the whole point of the warning is dubious at
> best. We do rely on admins to do sensible things when changing tunable
> knobs. Dirty memory writeback knobs are not any special in that regards
> so revert the warning rather than adding more hacks to work this around.
> 
> Rerported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Debugged-by: Yafang Shao <laoar.shao@gmail.com>
> Fixes: 0f6d24f87856 ("mm/page-writeback.c: print a warning if the vm dirtiness settings are illogical")
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  Documentation/sysctl/vm.txt | 7 -------
>  mm/page-writeback.c         | 5 +----
>  2 files changed, 1 insertion(+), 11 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index b920423f88cb..5025ff9307e6 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -158,10 +158,6 @@ Note: the minimum value allowed for dirty_bytes is two pages (in bytes); any
>  value lower than this limit will be ignored and the old configuration will be
>  retained.
>  
> -Note: the value of dirty_bytes also must be set greater than
> -dirty_background_bytes or the amount of memory corresponding to
> -dirty_background_ratio.
> -
>  ==============================================================
>  
>  dirty_expire_centisecs
> @@ -181,9 +177,6 @@ generating disk writes will itself start writing out dirty data.
>  
>  The total available memory is not equal to total system memory.
>  
> -Note: dirty_ratio must be set greater than dirty_background_ratio or
> -ratio corresponding to dirty_background_bytes.
> -
>  ==============================================================
>  
>  dirty_writeback_centisecs
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index e7095030aa1f..586f31261c83 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -433,11 +433,8 @@ static void domain_dirty_limits(struct dirty_throttle_control *dtc)
>  	else
>  		bg_thresh = (bg_ratio * available_memory) / PAGE_SIZE;
>  
> -	if (unlikely(bg_thresh >= thresh)) {
> -		pr_warn("vm direct limit must be set greater than background limit.\n");
> +	if (bg_thresh >= thresh)
>  		bg_thresh = thresh / 2;
> -	}
> -
>  	tsk = current;
>  	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
>  		bg_thresh += bg_thresh / 4 + global_wb_domain.dirty_limit / 32;
> -- 
> 2.15.0
> 
> -- 
> Michal Hocko
> SUSE Labs
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
