Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1408E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 14:58:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x24-v6so11486210edm.13
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 11:58:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m12-v6si17669151edl.377.2018.09.25.11.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 11:58:48 -0700 (PDT)
Date: Tue, 25 Sep 2018 20:58:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RESEND] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Message-ID: <20180925185845.GX18685@dhcp22.suse.cz>
References: <20180917230846.31027-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180917230846.31027-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon 17-09-18 23:10:59, Roman Gushchin wrote:
> The memcg OOM killer is never invoked due to a failed high-order
> allocation, however the MEMCG_OOM event can be raised.
> 
> As shown below, it can happen under conditions, which are very
> far from a real OOM: e.g. there is plenty of clean pagecache
> and low memory pressure.
> 
> There is no sense in raising an OOM event in such a case,
> as it might confuse a user and lead to wrong and excessive actions.
> 
> Let's look at the charging path in try_caharge(). If the memory usage
> is about memory.max, which is absolutely natural for most memory cgroups,
> we try to reclaim some pages. Even if we were able to reclaim
> enough memory for the allocation, the following check can fail due to
> a race with another concurrent allocation:
> 
>     if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
>         goto retry;
> 
> For regular pages the following condition will save us from triggering
> the OOM:
> 
>    if (nr_reclaimed && nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER))
>        goto retry;
> 
> But for high-order allocation this condition will intentionally fail.
> The reason behind is that we'll likely fall to regular pages anyway,
> so it's ok and even preferred to return ENOMEM.
> 
> In this case the idea of raising MEMCG_OOM looks dubious.

I would really appreciate an example of application that would get
confused by consuming this event and an explanation why. I do agree that
the event itself is kinda weird because it doesn't give you any context
for what kind of requests the memcg is OOM. Costly orders are a little
different story than others and users shouldn't care about this because
this is a mere implementation detail.

In other words, do we have any users to actually care about this half
baked event at all? Shouldn't we simply stop emiting it (or make it an
alias of OOM_KILL) rather than making it slightly better but yet kinda
incomplete?

Jeez, we really suck at defining proper interfaces. Things seem so cool
when they are proposed, then those users come and ruin our lives...
-- 
Michal Hocko
SUSE Labs
