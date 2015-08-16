Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 93DF59003C8
	for <linux-mm@kvack.org>; Sun, 16 Aug 2015 10:04:41 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so89956236pac.2
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 07:04:41 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id xj2si19792888pbc.48.2015.08.16.07.04.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Aug 2015 07:04:40 -0700 (PDT)
Subject: Re: [RFC 3/8] mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1438768284-30927-4-git-send-email-mhocko@kernel.org>
	<201508052128.FIJ56269.QHSFOVFLOJOMFt@I-love.SAKURA.ne.jp>
	<20150805140230.GF11176@dhcp22.suse.cz>
	<201508062050.CAF21340.FJSOQOHVOLMtFF@I-love.SAKURA.ne.jp>
	<20150812091104.GA14940@dhcp22.suse.cz>
In-Reply-To: <20150812091104.GA14940@dhcp22.suse.cz>
Message-Id: <201508162304.FID17148.SOJHOFFtMVLOQF@I-love.SAKURA.ne.jp>
Date: Sun, 16 Aug 2015 23:04:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org

Michal Hocko wrote:
> > Therefore, I worry that, under nearly OOM condition where waiting for kswapd
> > kernel threads for a few seconds will reclaim FS memory which will be enough
> > to succeed the !__GFP_FS allocations, GFP_NOFS allocations start failing
> > prematurely. The toehold (reliability by __GFP_WAIT) is almost gone.
> 
> GFP_NOFS had to go through the full reclaim process to end up in the oom
> path. All that without making _any_ progress. kswapd should be running
> in the background so talking about waiting for few seconds doesn't solve
> much once we have hit the oom path. You can be lucky under some very
> specific conditions but in general we _are_ OOM.

As a GFP_NOFS user from syscalls than filesystem's writebacks (some of LSM
hooks are called with fs locks held), I'm happy to give up upon SIGKILL but
I'm not happy to return -ENOMEM without retrying hard. Returning -ENOMEM to
user space is nearly equals to terminating that process because what user
space programs likely do upon unexpected -ENOMEM is to call exit(). Therefore,
I prefer OOM killing some memory hog process than potentially terminating
important processes which can be controlled via /proc/pid/oom_score_adj .

As a troubleshooting staff, I wish that we have a mechanism for proving that
the cause of silent hang up (hangups without the OOM killer messages) are not
caused by mm subsystem's behavior. How can we prove if memory allocation
requests stuck before reaching the oom path (e.g. inside shrinker functions
or shrink_inactive_list())? I want to use something like khungtaskd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
