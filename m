Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 251D444084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 09:21:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 23so24226011wry.4
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 06:21:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u74si5785521wmf.54.2017.07.10.06.21.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 06:21:41 -0700 (PDT)
Date: Mon, 10 Jul 2017 15:21:39 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170710132139.GJ19185@dhcp22.suse.cz>
References: <20170601115936.GA9091@dhcp22.suse.cz>
 <201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
 <20170601132808.GD9091@dhcp22.suse.cz>
 <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
 <20170602071818.GA29840@dhcp22.suse.cz>
 <201707081359.JCD39510.OSVOHMFOFtLFQJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707081359.JCD39510.OSVOHMFOFtLFQJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

On Sat 08-07-17 13:59:54, Tetsuo Handa wrote:
[...]
> Quoting from http://lkml.kernel.org/r/20170705081956.GA14538@dhcp22.suse.cz :
> Michal Hocko wrote:
> > On Sat 01-07-17 20:43:56, Tetsuo Handa wrote:
> > > You are rejecting serialization under OOM without giving a chance to test
> > > side effects of serialization under OOM at linux-next.git. I call such attitude
> > > "speculation" which you never accept.
> > 
> > No I am rejecting abusing the lock for purpose it is not aimed for.
> 
> Then, why adding a new lock (not oom_lock but warn_alloc_lock) is not acceptable?
> Since warn_alloc_lock is aimed for avoiding messages by warn_alloc() getting
> jumbled, there should be no reason you reject this lock.
> 
> If you don't like locks, can you instead accept below one?

No, seriously! Just think about what you are proposing. You are stalling
and now you will stall _random_ tasks even more. Some of them for
unbound amount of time because of inherent unfairness of cmpxchg.

If there is a _real_ problem it should be debugged and fixed. If this
is a limitation of what printk can handle then we should think how to
throttle it even more (e.g. does it make much sense to dump_stack when
it hasn't changed since the last time?). If this is about dump_stack
taking too long then we should look into it but we definitely should add
a more on top.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 80e4adb..3ac382c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3900,9 +3900,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  
>  	/* Make sure we know about allocations which stall for too long */
>  	if (time_after(jiffies, alloc_start + stall_timeout)) {
> +		static bool wait;
> +
> +		while (cmpxchg(&wait, false, true))
> +			schedule_timeout_uninterruptible(1);
>  		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
>  			"page allocation stalls for %ums, order:%u",
>  			jiffies_to_msecs(jiffies-alloc_start), order);
> +		wait = false;
>  		stall_timeout += 10 * HZ;
>  	}
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
