Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 638596B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 18:17:54 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g61-v6so20871590plb.10
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 15:17:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b24si6858954pfd.391.2018.04.05.15.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 15:17:53 -0700 (PDT)
Date: Thu, 5 Apr 2018 15:17:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/4] mm/vmscan: Don't change pgdat state on base of a
 single LRU list state.
Message-Id: <20180405151751.c07ee14496f9d5b691b49c64@linux-foundation.org>
In-Reply-To: <20180323152029.11084-4-aryabinin@virtuozzo.com>
References: <20180323152029.11084-1-aryabinin@virtuozzo.com>
	<20180323152029.11084-4-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Fri, 23 Mar 2018 18:20:28 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

> We have separate LRU list for each memory cgroup. Memory reclaim iterates
> over cgroups and calls shrink_inactive_list() every inactive LRU list.
> Based on the state of a single LRU shrink_inactive_list() may flag
> the whole node as dirty,congested or under writeback. This is obviously
> wrong and hurtful. It's especially hurtful when we have possibly
> small congested cgroup in system. Than *all* direct reclaims waste time
> by sleeping in wait_iff_congested(). And the more memcgs in the system
> we have the longer memory allocation stall is, because
> wait_iff_congested() called on each lru-list scan.
> 
> Sum reclaim stats across all visited LRUs on node and flag node as dirty,
> congested or under writeback based on that sum. Also call
> congestion_wait(), wait_iff_congested() once per pgdat scan, instead of
> once per lru-list scan.
> 
> This only fixes the problem for global reclaim case. Per-cgroup reclaim
> may alter global pgdat flags too, which is wrong. But that is separate
> issue and will be addressed in the next patch.
> 
> This change will not have any effect on a systems with all workload
> concentrated in a single cgroup.
> 

Could we please get this reviewed?
