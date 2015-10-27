Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 561B66B0038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 05:22:34 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so152583320wic.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 02:22:34 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id dm8si48891385wjb.19.2015.10.27.02.22.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 02:22:33 -0700 (PDT)
Received: by wicfv8 with SMTP id fv8so152582500wic.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 02:22:32 -0700 (PDT)
Date: Tue, 27 Oct 2015 10:22:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151027092231.GC9891@dhcp22.suse.cz>
References: <20151023083316.GB2410@dhcp22.suse.cz>
 <20151023103630.GA4170@mtj.duckdns.org>
 <20151023111145.GH2410@dhcp22.suse.cz>
 <201510232125.DAG82381.LMJtOQFOHVOSFF@I-love.SAKURA.ne.jp>
 <20151023182343.GB14610@mtj.duckdns.org>
 <201510251952.CEF04109.OSOtLFHFVFJMQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510251952.CEF04109.OSOtLFHFVFJMQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: cl@linux.com, htejun@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Sun 25-10-15 19:52:59, Tetsuo Handa wrote:
[...]
> Three approaches are proposed for fixing this silent livelock problem.
> 
>  (1) Use zone_page_state_snapshot() instead of zone_page_state()
>      when doing zone_reclaimable() checks. This approach is clear,
>      straightforward and easy to backport. So far I cannot reproduce
>      this livelock using this change. But there might be more locations
>      which should use zone_page_state_snapshot().
> 
>  (2) Use a dedicated workqueue for vmstat_update item which is guaranteed
>      to be processed immediately. So far I cannot reproduce this livelock
>      using a dedicated workqueue created with WQ_MEM_RECLAIM|WQ_HIGHPRI
>      (patch proposed by Christoph Lameter). But according to Tejun Heo,
>      if we want to guarantee that nobody can reproduce this livelock, we
>      need to modify workqueue API because commit 3270476a6c0c ("workqueue:
>      reimplement WQ_HIGHPRI using a separate worker_pool") which went to
>      Linux 3.6 lost the guarantee.
> 
>  (3) Use a !TASK_RUNNING sleep inside page allocator side. This approach
>      is easy to backport. So far I cannot reproduce this livelock using
>      this approach. And I think that nobody can reproduce this livelock
>      because this changes the page allocator to obey the workqueue's
>      expectations. Even if we leave this livelock problem aside, not
>      entering into !TASK_RUNNING state for too long is an exclusive
>      occupation of workqueue which will make other items in the workqueue
>      needlessly deferred. We don't need to defer other items which do not
>      invoke a __GFP_WAIT allocation.
> 
> This patch does approach (3), by inserting an uninterruptible sleep into
> page allocator side before retrying, in order to make sure that other
> workqueue items (especially vmstat_update item) are given a chance to be
> processed.
> 
> Although a different problem, by using approach (3), we can alleviate
> needlessly burning CPU cycles even when we hit OOM-killer livelock problem
> (hang up after the OOM-killer messages are printed because the OOM victim
> cannot terminate due to dependency).

I really dislike this approach. Waiting without having an event to
wait for is just too ugly. I think 1) is easiest to backport to
stable kernels without causing any other regressions. 2) is the way
to move forward for next kernels and we should really think whether
WQ_MEM_RECLAIM should imply also WQ_HIGHPRI by default. If there is a
general consensus that there are legitimate WQ_MEM_RECLAIM users which
can do without the other flag then I am perfectly OK to use it for
vmstat and oom sysrq dedicated workqueues.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
