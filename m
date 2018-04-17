Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3BCB6B0010
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:07:16 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id z1so12259839qtz.12
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 04:07:16 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v1si7182933qtg.211.2018.04.17.04.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 04:07:15 -0700 (PDT)
Date: Tue, 17 Apr 2018 12:06:49 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: allow to decrease swap.max below actual swap usage
Message-ID: <20180417110643.GA28901@castle.DHCP.thefacebook.com>
References: <20180412132705.30316-1-guro@fb.com>
 <20180416013902.GD1911913@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180416013902.GD1911913@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Shaohua Li <shli@fb.com>, Rik van Riel <riel@surriel.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com

Hi, Tejun!

On Sun, Apr 15, 2018 at 06:39:02PM -0700, Tejun Heo wrote:
> Hello, Roman.
> 
> The reclaim behavior is a bit worrisome.
> 
> * It disables an entire swap area while reclaim is in progress.  Most
>   systems only have one swap area, so this would disable allocating
>   new swap area for everyone.
> 
> * The reclaim seems very inefficient.  IIUC, it has to read every swap
>   page to see whether the page belongs to the target memcg and for
>   each matching page, which involves walking page mm's and page
>   tables.
> 
> An easy optimization would be walking swap_cgroup_ctrl so that it only
> reads swap entries which belong to the target cgroup and avoid
> disabling swap for others, but looking at the code, I wonder whether
> we need active reclaim at all.
> 
> Swap already tries to aggressively reclaim swap entries when swap
> usage > 50% of the limit, so simply reducing the limit already
> triggers aggressive reclaim, and given that it's swap, just waiting it
> out could be the better behavior anyway, so how about something like
> the following?
> 
> ------ 8< ------
> From: Tejun Heo <tj@kernel.org>
> Subject: mm: memcg: allow lowering memory.swap.max below the current usage
> 
> Currently an attempt to set swap.max into a value lower than the
> actual swap usage fails, which causes configuration problems as
> there's no way of lowering the configuration below the current usage
> short of turning off swap entirely.  This makes swap.max difficult to
> use and allows delegatees to lock the delegator out of reducing swap
> allocation.
> 
> This patch updates swap_max_write() so that the limit can be lowered
> below the current usage.  It doesn't implement active reclaiming of
> swap entries for the following reasons.

This is definitely better than existing state of things, and it's also safe.

I assume, that active swap reclaim can be useful in some cases,
but we can return to this question later.

Acked-by: Roman Gushchin <guro@fb.com>

> 
> * mem_cgroup_swap_full() already tells the swap machinary to
>   aggressively reclaim swap entries if the usage is above 50% of
>   limit, so simply lowering the limit automatically triggers gradual
>   reclaim.
> 
> * Forcing back swapped out pages is likely to heavily impact the
>   workload and mess up the working set.  Given that swap usually is a
>   lot less valuable and less scarce, letting the existing usage
>   dissipate over time through the above gradual reclaim and as they're
>   falted back in is likely the better behavior.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Shaohua Li <shli@fb.com>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: cgroups@vger.kernel.org
> ---
>  Documentation/cgroup-v2.txt |    5 +++++
>  mm/memcontrol.c             |    6 +-----
>  2 files changed, 6 insertions(+), 5 deletions(-)
> 
> --- a/Documentation/cgroup-v2.txt
> +++ b/Documentation/cgroup-v2.txt
> @@ -1199,6 +1199,11 @@ PAGE_SIZE multiple when read back.
>  	Swap usage hard limit.  If a cgroup's swap usage reaches this
>  	limit, anonymous memory of the cgroup will not be swapped out.
>  
> +	When reduced under the current usage, the existing swap
> +	entries are reclaimed gradually and the swap usage may stay
> +	higher than the limit for an extended period of time.  This
> +	reduces the impact on the workload and memory management.

I would probably drop the last sentence: it looks like an excuse
for the defined semantics; but it's totally fine.

Thanks!
