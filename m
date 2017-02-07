Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 337196B025E
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 03:10:07 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r141so23777949wmg.4
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 00:10:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h28si4082350wrc.131.2017.02.07.00.10.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 00:10:06 -0800 (PST)
Date: Tue, 7 Feb 2017 09:10:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2 v4] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170207081002.GB5065@dhcp22.suse.cz>
References: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
 <20170206125240.GB10298@dhcp22.suse.cz>
 <CAOaiJ-=ovwZ53nqNLRtP=sCY=+4s1-1r_soBXvam42bxDeUdAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOaiJ-=ovwZ53nqNLRtP=sCY=+4s1-1r_soBXvam42bxDeUdAQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Mon 06-02-17 20:40:10, vinayak menon wrote:
> On Mon, Feb 6, 2017 at 6:22 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Mon 06-02-17 17:54:09, Vinayak Menon wrote:
> >> During global reclaim, the nr_reclaimed passed to vmpressure includes the
> >> pages reclaimed from slab.  But the corresponding scanned slab pages is
> >> not passed.  This can cause total reclaimed pages to be greater than
> >> scanned, causing an unsigned underflow in vmpressure resulting in a
> >> critical event being sent to root cgroup.
> >
> > If you switched the ordering then this wouldn't be a problem, right?
>
> You mean calling vmpressure first and then shrink_slab ?

No, I meant the scanned vs. reclaim normalization patch first and than do
whatever slab related thing later on. This would have an advantage that
we can rule the underflow issue out and only focus on why the slab
numbers actually matter.

> That also can be done. Would completing shrink_slab before vmpressure
> be of any use to a userspace task that takes into account both
> vmpressure and reclaimable slab size ?

Is this the case in your lowmemmory killer implementation? If yes how
does it actually work?

[...]
> > It would be also more than useful to say how much the slab reclaim
> > really contributed.
>
> The 70% less events is caused by slab reclaim being added to
> vmpressure, which is confirmed by running the test with and without
> the fix.  But it is hard to say the effect on reclaim stats is caused
> by this problem because, the lowmemorykiller can be written with
> different heuristics to make the reclaim look better.

Exactly! And this is why I am not still happy with the current
justification of this patch. It seems to be tuning for a particular
consumer of vmpressure events. Others might depend on a less pessimistic
events because we are making some progress afterall. Being more
pessimistic can lead to premature oom or other performance related
decisions and that is why I am not happy about that.

Btw. could you be more specific about your particular test? What is
desired/acceptable result?

> The issue we see
> in the above reclaim stats is entirely because of task kills being
> delayed. That is the reason why I did not include the vmstat stats in
> the changelog in the earlier versions.
> 
> >
> >> This is a regression introduced by commit 6b4f7799c6a5 ("mm: vmscan:
> >> invoke slab shrinkers from shrink_zone()").
> >
> > I am not really sure this is a regression, though. Maybe your heuristic
> > which consumes events is just too fragile?
> >
> Yes it could be. A different kind of lowmemorykiller may not show up
> this issue at all. In my opinion the regression here is the difference
> in vmpressure values and thus the vmpressure events because of passing
> slab reclaimed pages to vmpressure without considering the scanned
> pages and cost model.
> So would it be better to drop the vmstat data from changelog ?

No! The main question is whether being more pessimistic and report
higher reclaim levels really does make sense even when there is a slab
reclaim progress. This hasn't been explained and I _really_ do not like
a patch which optimizes for a particular consumer of events.

I understand that the change of the behavior is unexpeted and that
might be reason to revert to the original one. But if this is the only
reasonable way to go I would, at least, like to understand what is going
on here. Why cannot your lowmemorykiller cope with the workload? Why
starting to kill sooner (at the time when the slab still reclaims enough
pages to report lower critical events) helps to pass your test. Maybe it
is the implementation of the lmk which needs to be changed because it
has some false expectations? Or the memory reclaim just behaves in an
unpredictable manner?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
