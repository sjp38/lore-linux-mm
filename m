Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F15AB6B0005
	for <linux-mm@kvack.org>; Thu, 24 May 2018 06:56:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t195-v6so906228wmt.9
        for <linux-mm@kvack.org>; Thu, 24 May 2018 03:56:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j12-v6si1199922eda.453.2018.05.24.03.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 24 May 2018 03:56:05 -0700 (PDT)
Date: Thu, 24 May 2018 06:58:07 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH REPOST] mm: memcg: allow lowering memory.swap.max below
 the current usage
Message-ID: <20180524105807.GA1362@cmpxchg.org>
References: <20180523185041.GR1718769@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523185041.GR1718769@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@kernel.org>, Shaohua Li <shli@fb.com>, Rik van Riel <riel@surriel.com>, cgroups@vger.kernel.org

On Wed, May 23, 2018 at 11:50:41AM -0700, Tejun Heo wrote:
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
> Acked-by: Roman Gushchin <guro@fb.com>
> Acked-by: Rik van Riel <riel@surriel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Shaohua Li <shli@fb.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: cgroups@vger.kernel.org

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
