Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 215106B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 06:40:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v82so4136319pgb.5
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 03:40:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3si489383pld.531.2017.09.15.03.40.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 03:40:00 -0700 (PDT)
Date: Fri, 15 Sep 2017 12:39:57 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
Message-ID: <20170915103957.64r5xln7s6wlu3ro@dhcp22.suse.cz>
References: <20170915095849.9927-1-yuwang668899@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170915095849.9927-1-yuwang668899@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wang Yu <yuwang668899@gmail.com>
Cc: penguin-kernel@i-love.sakura.ne.jp, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com

On Fri 15-09-17 17:58:49, wang Yu wrote:
> From: "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>
> 
> I found a softlockup when running some stress testcase in 4.9.x,
> but i think the mainline have the same problem.
> 
> call trace:
> [365724.502896] NMI watchdog: BUG: soft lockup - CPU#31 stuck for 22s!
> [jbd2/sda3-8:1164]
> ...
> ...
> [365724.503258] Call Trace:
> [365724.503260]  [<ffffffff811ace5f>] warn_alloc+0x13f/0x170
> [365724.503264]  [<ffffffff811ad8c2>] __alloc_pages_slowpath+0x9b2/0xc10
> [365724.503265]  [<ffffffff811add43>] __alloc_pages_nodemask+0x223/0x2a0
> [365724.503268]  [<ffffffff811fe838>] alloc_pages_current+0x88/0x120
> [365724.503270]  [<ffffffff811a3644>] __page_cache_alloc+0xb4/0xc0
> [365724.503272]  [<ffffffff811a49e9>] pagecache_get_page+0x59/0x230
> [365724.503275]  [<ffffffff8126b2db>] __getblk_gfp+0xfb/0x2f0
> [365724.503281]  [<ffffffffa00f9cee>]
> jbd2_journal_get_descriptor_buffer+0x5e/0xe0 [jbd2]
> [365724.503286]  [<ffffffffa00f2a01>]
> jbd2_journal_commit_transaction+0x901/0x1880 [jbd2]
> [365724.503291]  [<ffffffff8102d6a5>] ? __switch_to+0x215/0x730
> [365724.503294]  [<ffffffff810f962d>] ? lock_timer_base+0x7d/0xa0
> [365724.503298]  [<ffffffffa00f7cda>] kjournald2+0xca/0x260 [jbd2]
> [365724.503300]  [<ffffffff810cfb00>] ? prepare_to_wait_event+0xf0/0xf0
> [365724.503304]  [<ffffffffa00f7c10>] ? commit_timeout+0x10/0x10 [jbd2]
> [365724.503307]  [<ffffffff810a8d66>] kthread+0xe6/0x100
> [365724.503309]  [<ffffffff810a8c80>] ? kthread_park+0x60/0x60
> [365724.503313]  [<ffffffff816f3795>] ret_from_fork+0x25/0x30
> 
> we can limit the warn_alloc caller to workaround it.
> __alloc_pages_slowpath only call once warn_alloc each time.

similar attempts to add a lock there were tried in the past and refused.
Anyway using a normal lock would be preferred over a bit lock. But the
most important part is to identify _why_ we see the lockup trigerring in
the first place. And try to fix it rather than workaround it here.

> Signed-off-by: yuwang.yuwang <yuwang.yuwang@alibaba-inc.com>
> Suggested-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> ---
>  mm/page_alloc.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2abf8d5..8b86686 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3525,6 +3525,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	unsigned long alloc_start = jiffies;
>  	unsigned int stall_timeout = 10 * HZ;
>  	unsigned int cpuset_mems_cookie;
> +	static unsigned long stall_warn_lock;
>  
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3698,11 +3699,13 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  		goto nopage;
>  
>  	/* Make sure we know about allocations which stall for too long */
> -	if (time_after(jiffies, alloc_start + stall_timeout)) {
> +	if (time_after(jiffies, alloc_start + stall_timeout) &&
> +		!test_and_set_bit_lock(0, &stall_warn_lock)) {
>  		warn_alloc(gfp_mask,
>  			"page allocation stalls for %ums, order:%u",
>  			jiffies_to_msecs(jiffies-alloc_start), order);
> -		stall_timeout += 10 * HZ;
> +		stall_timeout = jiffies - alloc_start + 10 * HZ;
> +		clear_bit_unlock(0, &stall_warn_lock);
>  	}
>  
>  	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
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
