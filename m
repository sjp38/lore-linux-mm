Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 367EC6B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 04:05:05 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r18so9069812wmd.1
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 01:05:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si1300353wrh.309.2017.02.10.01.05.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 01:05:03 -0800 (PST)
Date: Fri, 10 Feb 2017 10:05:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2 v5] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170210090501.GE10893@dhcp22.suse.cz>
References: <1486641577-11685-1-git-send-email-vinmenon@codeaurora.org>
 <1486641577-11685-2-git-send-email-vinmenon@codeaurora.org>
 <20170209122007.GG10257@dhcp22.suse.cz>
 <CAOaiJ-nJWeMWeY1S5rBmC3M1EiT+HbiLcPwEMZsDMHemhGO0jA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOaiJ-nJWeMWeY1S5rBmC3M1EiT+HbiLcPwEMZsDMHemhGO0jA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri 10-02-17 14:15:20, vinayak menon wrote:
> On Thu, Feb 9, 2017 at 5:50 PM, Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > I have already said I will _not_ NAK the patch but we need a much better
> > description and justification why the older behavior was better to
> > consider this a regression before this can be merged. It is hard to
> > expect that the underlying implementation of the vmpressure will stay
> > carved in stone and there might be changes in this area in the future. I
> > want to hear why we believe that the tested workload is sufficiently
> > universal and we won't see another report in few months because somebody
> > else will see higher vmpressure levels even though we make reclaim
> > progress. I have asked those questions already but it seems those were
> > ignored.
> 
> The tested workload is not universal. The lowmemorykiller example was used just
> to mention the effect of vmpressure change on one of the workloads. 

My point is whether this workload even matters. AFAIU the test benefits
from killing as quickly as possible, right? So it directly benefits from
seeing critical events as soon as possible even when the reclaim makes
progress.

> I can drop the reclaim stats and just keep the stats of change
> observed in vmpressure critical events.  I am not sure whether we
> would see another issue reported with this patch. We may because
> someone would have written a code that works with this new vmpressure
> values. I am not sure whether that matters because the core issue
> is whether the kernel is reporting the right values.

Right. THe right values is a bit fuzzy, though.

> This could be
> termed as a regression because,
> 
> 1) Accounting only reclaimed pages to a model which works on scanned
> and reclaimed seems like a wrong thing. It is just adding noise to
> it. There could be issues with vmpressure implementation, but it at
> least gives an estimate on what the pressure on LRU is. There are many
> other shrinkers like zsmalloc which does not report reclaimed pages,
> and when add those also in a similar fashion without considering the
> cost part, vmpressure values would always remain low. So util we
> have a way to give correct information to vmpressure about non-LRU
> reclaimers, I feel its better to keep it in its original form.

Yeah, I understand that the current cost model is far from ideal and it
needs fixing. My main question would be whether the model would be much
better if we exclude pages freed from the slab shrinkers. I can only say
it would be more pesimistic that way. Is this a good thing? If yes, why?
 
> 2) As Minchan mentioned, the cost model is different and thus adding
> slab reclaimed would not be the right thing to do at this point.
> 
> But if you feel we don't have to fix this now and that it is better
> to fix the core problems with vmpressure first, that's ok.

Yes, I believe we should reconsider how we calculate the pressure
levels. This seems a larger project but definitely something we need. I
do not have a good ideas how to do this properly
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
