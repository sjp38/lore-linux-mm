Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A2D976B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 09:21:30 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u23so6025560pgo.4
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 06:21:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s67si3662287pgc.832.2017.11.02.06.21.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 06:21:29 -0700 (PDT)
Date: Thu, 2 Nov 2017 14:21:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm,oom: Move last second allocation to inside the
 OOM killer.
Message-ID: <20171102132127.pteu2jvvg5g47dle@dhcp22.suse.cz>
References: <201711022015.BBE95844.QOHtJFMLFOOSVF@I-love.SAKURA.ne.jp>
 <1509621408-4066-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509621408-4066-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 02-11-17 20:16:47, Tetsuo Handa wrote:
> __alloc_pages_may_oom() is doing last second allocation attempt using
> ALLOC_WMARK_HIGH before calling out_of_memory(). This had two reasons.
> 
> The first reason is explained in the comment that it aims to catch
> potential parallel OOM killing. But there is no longer parallel OOM
> killing (in the sense that out_of_memory() is called "concurrently")
> because we serialize out_of_memory() calls using oom_lock.
> 
> The second reason is explained by Andrea Arcangeli (who added that code)
> that it aims to reduce the likelihood of OOM livelocks and be sure to
> invoke the OOM killer. There was a risk of livelock or anyway of delayed
> OOM killer invocation if ALLOC_WMARK_MIN is used, for relying on last
> few pages which are constantly allocated and freed in the meantime will
> not improve the situation.

> But there is no longer possibility of OOM
> livelocks or failing to invoke the OOM killer because we need to mask
> __GFP_DIRECT_RECLAIM for last second allocation attempt because oom_lock
> prevents __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations which last
> second allocation attempt indirectly involve from failing.

I really fail to see how this has anything to do with the paragraph
above. We are not talking about the reclaim for the last attempt. We are
talking about reclaim that might have happened in _other_ context. Why
don't you simply stick with the changelog which I've suggested and which
is much more clear and easier to read.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
