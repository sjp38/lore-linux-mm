Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id F193E6B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 09:14:13 -0400 (EDT)
Received: by wijq8 with SMTP id q8so129228487wij.0
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 06:14:13 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id ao6si17458693wjc.158.2015.10.15.06.14.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 06:14:12 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so271874362wic.1
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 06:14:12 -0700 (PDT)
Date: Thu, 15 Oct 2015 15:14:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Silent hang up caused by pages being not scanned?
Message-ID: <20151015131409.GD2978@dhcp22.suse.cz>
References: <201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
 <201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
 <201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
 <201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
 <CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com>
 <201510132121.GDE13044.FOSHLJOMFOtQVF@I-love.SAKURA.ne.jp>
 <CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

[CC Mel and Rik as well - this has diverged from the original thread
 considerably but the current topic started here:
 http://lkml.kernel.org/r/201510130025.EJF21331.FFOQJtVOMLFHSO%40I-love.SAKURA.ne.jp
]

On Tue 13-10-15 09:37:06, Linus Torvalds wrote:
> So instead of that senseless thing, how about trying something
> *sensible*. Make the code do something that we can actually explain as
> making sense.

I do agree that zone_reclaimable is subtle and hackish way to wait for
the writeback/kswapd to clean up pages which cannot be reclaimed from
the direct reclaim.

> I'd suggest something like:
> 
>  - add a "retry count"
> 
>  - if direct reclaim made no progress, or made less progress than the target:
> 
>       if (order > PAGE_ALLOC_COSTLY_ORDER) goto noretry;
> 
>  - regardless of whether we made progress or not:
> 
>       if (retry count < X) goto retry;
> 
>       if (retry count < 2*X) yield/sleep 10ms/wait-for-kswapd and then
> goto retry

This will certainly cap the reclaim retries but there are risks with
this approach afaics.

First of all other allocators might piggy back on the current reclaimer
and push it to the OOM killer even when we are not really OOM. Maybe
this is possible currently as well but it is less likely because
NR_PAGES_SCANNED is reset on a freed page which allows the reclaimer
another round.

I am also not sure it would help with pathological cases like the
one discussed here. If you have only a small amount of reclaimable
memory on the LRU lists then you scan them quite quickly which will
consume retries. Maybe a sufficient timeout can help but I am afraid we
can still hit the OOM prematurely because a large part of the memory
is still under writeback (which might be a slow device - e.g. an USB
stick).

We used have this kind of problems in memcg reclaim.  We do not
have (resp. didn't have until recently with CONFIG_CGROUP_WRITEBACK)
dirty memory throttling for memory cgroups so the LRU can become full
of dirty data really quickly and that led to memcg OOM killer.
We are not doing zone_reclaimable and other heuristics so we had to
explicitly wait_on_page_writeback in the reclaim to prevent from
premature OOM killer. Ugly hack but the only thing that worked
reliably. Time based solutions were tried and failed with different
workloads and quite randomly depending on the load/storage.

>    where 'X" is something sane that limits our CPU use, but also
> guarantees that we don't end up waiting *too* long (if a single
> allocation takes more than a big fraction of a second, we should
> probably stop trying).
> 
> The whole time-based thing might even be explicit. There's nothing
> wrong with doing something like
> 
>     unsigned long timeout = jiffies + HZ/4;
> 
> at the top of the function, and making the whole retry logic actually
> say something like
> 
>     if (time_after(timeout, jiffies)) goto noretry;
> 
> (or make *that* trigger the oom logic, or whatever).
> 
> Now, I realize the above suggestions are big changes, and they'll
> likely break things and we'll still need to tweak things, but dammit,
> wouldn't that be better than just randomly tweaking the insane
> zone_reclaimable logic?

Yes zone_reclaimable is subtle and imho it is used even at the
wrong level. We should decide whether we are really OOM at
__alloc_pages_slowpath. We definitely need a big picture logic to tell
us when it makes sense to drop the ball and trigger OOM killer or fail
the allocation request.

E.g. free + reclaimable + writeback < min_wmark on all usable zones for
more than X rounds of direct reclaim without any progress is
a sufficient signal to go OOM. Costly/noretry allocations can fail earlier
of course. This is obviously a half baked idea which needs much more
consideration all I am trying to say is that we need a high level metric
to tell OOM condition.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
