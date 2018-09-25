Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70A358E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 11:59:03 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id c18-v6so148626oiy.3
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:59:03 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id r33-v6si1317269otc.157.2018.09.25.08.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 08:59:02 -0700 (PDT)
Date: Tue, 25 Sep 2018 16:58:26 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH RESEND] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Message-ID: <20180925155825.GA11552@castle.DHCP.thefacebook.com>
References: <20180917230846.31027-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180917230846.31027-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, Sep 17, 2018 at 04:08:46PM -0700, Roman Gushchin wrote:
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
> 
> Fix this by moving MEMCG_OOM raising to mem_cgroup_oom() after
> allocation order check, so that the event won't be raised for high
> order allocations. This change doesn't affect regular pages allocation
> and charging.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>

I've tried to address all concerns and questions in the updated
changelog, so, hopefully, now it's clear why do we need this change.

Are there any comments, thoughts or objections left?

Thanks!
