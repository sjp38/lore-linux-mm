Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6B9440460
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 20:40:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v78so3805822pfk.8
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 17:40:45 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k66si4965144pgk.665.2017.11.08.17.40.43
        for <linux-mm@kvack.org>;
        Wed, 08 Nov 2017 17:40:44 -0800 (PST)
Date: Thu, 9 Nov 2017 10:40:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm, shrinker: make shrinker_list lockless
Message-ID: <20171109014041.GA10143@bbox>
References: <20171108173740.115166-1-shakeelb@google.com>
 <20171109000735.GA9883@bbox>
 <CALvZod4ercfnebabcMEfxmwcRwdpu7xsPhjX4oyRHh2+5U8h1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod4ercfnebabcMEfxmwcRwdpu7xsPhjX4oyRHh2+5U8h1A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 08, 2017 at 05:07:08PM -0800, Shakeel Butt wrote:
> On Wed, Nov 8, 2017 at 4:07 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Hi,
> >
> > On Wed, Nov 08, 2017 at 09:37:40AM -0800, Shakeel Butt wrote:
> >> In our production, we have observed that the job loader gets stuck for
> >> 10s of seconds while doing mount operation. It turns out that it was
> >> stuck in register_shrinker() and some unrelated job was under memory
> >> pressure and spending time in shrink_slab(). Our machines have a lot
> >> of shrinkers registered and jobs under memory pressure has to traverse
> >> all of those memcg-aware shrinkers and do affect unrelated jobs which
> >> want to register their own shrinkers.
> >>
> >> This patch has made the shrinker_list traversal lockless and shrinker
> >> register remain fast. For the shrinker unregister, atomic counter
> >> has been introduced to avoid synchronize_rcu() call. The fields of
> >
> > So, do you want to enhance unregister shrinker path as well as registering?
> >
> 
> Yes, I don't want to add delay to unregister_shrinker for the normal
> case where there isn't any readers (i.e. unconditional
> synchronize_rcu).

Not sure how it makes bad.
It would be better to add opinion in description about why unregister path is
important and how synchronize_rcu might makeA slow for usual cases.

> 
> >> struct shrinker has been rearraged to make sure that the size does
> >> not increase for x86_64.
> >>
> >> The shrinker functions are allowed to reschedule() and thus can not
> >> be called with rcu read lock. One way to resolve that is to use
> >> srcu read lock but then ifdefs has to be used as SRCU is behind
> >> CONFIG_SRCU. Another way is to just release the rcu read lock before
> >> calling the shrinker and reacquire on the return. The atomic counter
> >> will make sure that the shrinker entry will not be freed under us.
> >
> > Instead of adding new lock, could we simply release shrinker_rwsem read-side
> > lock in list traveral periodically to give a chance to hold a write-side
> > lock?
> >
> 
> Greg has already pointed out that this patch is still not right/safe
> and now I am getting to the opinion that without changing the shrinker
> API, it might not be possible to do lockless shrinker traversal and
> unregister shrinker without synchronize_rcu().
> 
> Regarding your suggestion, do you mean to add periodic release lock
> and reacquire using down_read_trylock() or down_read()?

Yub with down_read. Actually, I do not see point of down_read_trylock
when considering write-lock path in reigster_shinker is too short.

The problem in suggested approach is we should traverse list from the
beginning again after reacquiring, which breaks fairness of each
shrinker.

Maybe, we can introduce rwlock_is_contended which checks wait_list
and returns true if wait_list is not empty.

Thanks.




> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
