Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4026B0069
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 11:01:50 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id an2so5210433wjc.3
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 08:01:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r29si29081253wra.194.2017.02.02.08.01.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Feb 2017 08:01:48 -0800 (PST)
Date: Thu, 2 Feb 2017 17:01:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170202160145.GK22806@dhcp22.suse.cz>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
 <20170202104422.GF22806@dhcp22.suse.cz>
 <20170202104808.GG22806@dhcp22.suse.cz>
 <CAOaiJ-nyZtgrCHjkGJeG3nhGFes5Y7go3zZwa3SxGrZV=LV0ag@mail.gmail.com>
 <20170202115222.GH22806@dhcp22.suse.cz>
 <CAOaiJ-=pCUzaVbte-+QiQoN_XtB0KFbcB40yjU9r7OV8VOkmFg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOaiJ-=pCUzaVbte-+QiQoN_XtB0KFbcB40yjU9r7OV8VOkmFg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu 02-02-17 21:00:10, vinayak menon wrote:
> On Thu, Feb 2, 2017 at 5:22 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 02-02-17 16:55:49, vinayak menon wrote:
> >> On Thu, Feb 2, 2017 at 4:18 PM, Michal Hocko <mhocko@kernel.org> wrote:
> >> > On Thu 02-02-17 11:44:22, Michal Hocko wrote:
> >> >> On Tue 31-01-17 14:32:08, Vinayak Menon wrote:
> >> >> > During global reclaim, the nr_reclaimed passed to vmpressure
> >> >> > includes the pages reclaimed from slab. But the corresponding
> >> >> > scanned slab pages is not passed. This can cause total reclaimed
> >> >> > pages to be greater than scanned, causing an unsigned underflow
> >> >> > in vmpressure resulting in a critical event being sent to root
> >> >> > cgroup. So do not consider reclaimed slab pages for vmpressure
> >> >> > calculation. The reclaimed pages from slab can be excluded because
> >> >> > the freeing of a page by slab shrinking depends on each slab's
> >> >> > object population, making the cost model (i.e. scan:free) different
> >> >> > from that of LRU.
> >> >>
> >> >> This might be true but what happens if the slab reclaim contributes
> >> >> significantly to the overal reclaim? This would be quite rare but not
> >> >> impossible.
> >> >>
> >> >> I am wondering why we cannot simply make cap nr_reclaimed to nr_scanned
> >> >> and be done with this all? Sure it will be imprecise but the same will
> >> >> be true with this approach.
> >>
> >> Thinking of a case where 100 LRU pages were scanned and only 10 were
> >> reclaimed.  Now, say slab reclaimed 100 pages and we have no idea
> >> how many were scanned.  The actual vmpressure of 90 will now be 0
> >> because of the addition on 100 slab pages. So underflow was not the
> >> only issue, but incorrect vmpressure.
> >
> > Is this actually a problem. The end result - enough pages being
> > reclaimed should matter, no?
> >
>
> But vmpressure is incorrect now, no ?

What does it mean incorrect? vmpressure is just an approximation that
tells us how much we struggle to reclaim memory. If we are making a
progress then we shouldn't reach higher levels.

> Because the scanned slab pages
> is not included in nr_scanned (the cost). The 100 scanned and 10
> reclaimed from LRU were a reasonable estimate as you said, and to that
> we are adding a reclaimed value alone without scanned and thus making
> it incorrect ? Because the cost of slab reclaim is not accounted.

there are other costs which are not included. E.g. stalling because of
dirty pages etc...

> But
> I agree that the vmpressure value would have been more correct if it
> could include both scanned and reclaimed from slab. And may be more
> correct if we can include the scanned and reclaimed from all shrinkers
> which I think is not the case right now (lowmemorykiller, zsmalloc
> etc). But as Minchan was pointing out, since the cost model for slab
> is different, would it be fine to just add reclaimed from slab to
> vmpressure ?

Get back to your example. Do you really prefer seeing an alarm just
because we had hard time reclaiming LRU pages which might be pinned due
to reclaimable slab pages (e.g. fs metadata) when the slab reclaim can
free enough of them?

vmpressure never had a good semantic, it is just an approximation that
happened to work for some workloads which it was proposed for.

[...]
> >> Our
> >> internal tests on Android actually shows the problem. When vmpressure
> >> with slab reclaimed added is used to kill tasks, it does not kick in
> >> at the right time.
> >
> > With the skewed reclaimed? How that happens? Could you elaborate more?
>
> Yes. Because of the skewed reclaim. The observation is that the vmpressure
> critical events are received late. Because of adding slab reclaimed without
> corresponding scanned, the vmpressure values are diluted resulting in lesser
> number of critical events at the beginning, resulting in tasks not
> being chosen to be killed.

Why would you like to chose and kill a task when the slab reclaim can
still make sufficient progres? Are you sure that the slab contribution
to the stats makes all the above happening?

> This increases the memory pressure and
> finally result in late critical events, but by that time the task
> launch latencies are impacted.

I have seen vmpressure hitting critical events really quickly but that
is mostly because the vmpressure uses only very simplistic
approximation. Usually the reclaim goes well, until you hit to dirty
or pinned pages. Then it can get really bad, so you can get from high
effectiveness to 0 pretty quickly.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
