Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 276226B0069
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 08:28:53 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id p96so12574603wrb.12
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 05:28:53 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 63si247998edn.197.2017.11.15.05.28.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 Nov 2017 05:28:51 -0800 (PST)
Date: Wed, 15 Nov 2017 08:28:36 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171115132836.GA6524@cmpxchg.org>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171115090251.umpd53zpvp42xkvi@dhcp22.suse.cz>
 <201711151958.CBI60413.FHQMtFLFOOSOJV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711151958.CBI60413.FHQMtFLFOOSOJV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, akpm@linux-foundation.org, shakeelb@google.com, gthelen@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 15, 2017 at 07:58:09PM +0900, Tetsuo Handa wrote:
> I think that Minchan's approach depends on how
> 
>   In our production, we have observed that the job loader gets stuck for
>   10s of seconds while doing mount operation. It turns out that it was
>   stuck in register_shrinker() and some unrelated job was under memory
>   pressure and spending time in shrink_slab(). Our machines have a lot
>   of shrinkers registered and jobs under memory pressure has to traverse
>   all of those memcg-aware shrinkers and do affect unrelated jobs which
>   want to register their own shrinkers.
> 
> is interpreted. If there were 100000 shrinkers and each do_shrink_slab() call
> took 1 millisecond, aborting the iteration as soon as rwsem_is_contended() would
> help a lot. But if there were 10 shrinkers and each do_shrink_slab() call took
> 10 seconds, aborting the iteration as soon as rwsem_is_contended() would help
> less. Or, there might be some specific shrinker where its do_shrink_slab() call
> takes 100 seconds. In that case, checking rwsem_is_contended() is too lazy.

In your patch, unregister() waits for shrinker->nr_active instead of
the lock, which is decreased in the same location where Minchan drops
the lock. How is that different behavior for long-running shrinkers?

Anyway, I suspect it's many shrinkers and many concurrent invocations,
so the lockbreak granularity you both chose should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
