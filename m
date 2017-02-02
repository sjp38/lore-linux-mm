Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 536AE6B0033
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 06:52:26 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v77so11866534wmv.5
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 03:52:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g4si1859723wmf.46.2017.02.02.03.52.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Feb 2017 03:52:24 -0800 (PST)
Date: Thu, 2 Feb 2017 12:52:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170202115222.GH22806@dhcp22.suse.cz>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
 <20170202104422.GF22806@dhcp22.suse.cz>
 <20170202104808.GG22806@dhcp22.suse.cz>
 <CAOaiJ-nyZtgrCHjkGJeG3nhGFes5Y7go3zZwa3SxGrZV=LV0ag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOaiJ-nyZtgrCHjkGJeG3nhGFes5Y7go3zZwa3SxGrZV=LV0ag@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu 02-02-17 16:55:49, vinayak menon wrote:
> On Thu, Feb 2, 2017 at 4:18 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 02-02-17 11:44:22, Michal Hocko wrote:
> >> On Tue 31-01-17 14:32:08, Vinayak Menon wrote:
> >> > During global reclaim, the nr_reclaimed passed to vmpressure
> >> > includes the pages reclaimed from slab. But the corresponding
> >> > scanned slab pages is not passed. This can cause total reclaimed
> >> > pages to be greater than scanned, causing an unsigned underflow
> >> > in vmpressure resulting in a critical event being sent to root
> >> > cgroup. So do not consider reclaimed slab pages for vmpressure
> >> > calculation. The reclaimed pages from slab can be excluded because
> >> > the freeing of a page by slab shrinking depends on each slab's
> >> > object population, making the cost model (i.e. scan:free) different
> >> > from that of LRU.
> >>
> >> This might be true but what happens if the slab reclaim contributes
> >> significantly to the overal reclaim? This would be quite rare but not
> >> impossible.
> >>
> >> I am wondering why we cannot simply make cap nr_reclaimed to nr_scanned
> >> and be done with this all? Sure it will be imprecise but the same will
> >> be true with this approach.
>
> Thinking of a case where 100 LRU pages were scanned and only 10 were
> reclaimed.  Now, say slab reclaimed 100 pages and we have no idea
> how many were scanned.  The actual vmpressure of 90 will now be 0
> because of the addition on 100 slab pages. So underflow was not the
> only issue, but incorrect vmpressure.

Is this actually a problem. The end result - enough pages being
reclaimed should matter, no?

> Even though the slab reclaimed is not accounted in vmpressure, the
> slab reclaimed pages will have a feedback effect on the LRU pressure
> right ? i.e. the next LRU scan will either be less or delayed if
> enough slab pages are reclaimed, in turn lowering the vmpressure or
> delaying it ?

Not sure what you mean but we can break out from the direct reclaim
because we have fulfilled the reclaim target and that is why I think
that it shouldn't be really harmful to consider them in the pressure
calculation. After all we are making reclaim progress and that should
be considered. reclaimed/scanned is a reasonable estimation but it has
many issues because it doesn't really tell how hard it was to get that
number of pages reclaimed. We might have to wait for writeback which is
something completely different from a clean page cache. There are
certainly different possible metrics.

> If that is so, the
> current approach of neglecting slab reclaimed will provide more
> accurate vmpressure than capping nr_reclaimed to nr_scanned ?

The problem I can see is that you can get serious vmpressure events
while the reclaim manages to provide pages we are asking for and later
decisions might be completely inappropriate.

> Our
> internal tests on Android actually shows the problem. When vmpressure
> with slab reclaimed added is used to kill tasks, it does not kick in
> at the right time.

With the skewed reclaimed? How that happens? Could you elaborate more?

> > In other words something as "beautiful" as the following:
> > diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> > index 149fdf6c5c56..abea42817dd0 100644
> > --- a/mm/vmpressure.c
> > +++ b/mm/vmpressure.c
> > @@ -236,6 +236,15 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
> >                 return;
> >
> >         /*
> > +        * Due to accounting issues - e.g. THP contributing 1 to scanned but
> > +        * potentially much more to reclaimed or SLAB pages not contributing
> > +        * to scanned at all - we have to skew reclaimed to prevent from
> > +        * wrong pressure levels due to overflows.
> > +        */
> > +       if (reclaimed > scanned)
> > +               reclaimed = scanned;
> > +
> > +       /*
> 
> This underflow problem is fixed by a separate patch
> https://lkml.org/lkml/2017/1/27/48
> That patch performs this check only once at the end of a window period.
> Is that ok ?

I have seen that patch but pushing that up into the vmpressure makes
more sense to me because it is more obvious. Not something I would
insist on, though.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
