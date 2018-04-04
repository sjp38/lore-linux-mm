Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAD696B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 10:07:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b76so9601899wmg.9
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 07:07:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d2si1426452edl.391.2018.04.04.07.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Apr 2018 07:07:40 -0700 (PDT)
Date: Wed, 4 Apr 2018 10:08:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] mm: memcontrol: Use cgroup_rstat for event accounting
Message-ID: <20180404140855.GA28966@cmpxchg.org>
References: <20180324160901.512135-1-tj@kernel.org>
 <20180324160901.512135-2-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180324160901.512135-2-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: mhocko@kernel.org, vdavydov.dev@gmail.com, guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Sat, Mar 24, 2018 at 09:08:59AM -0700, Tejun Heo wrote:
> @@ -91,6 +91,9 @@ struct mem_cgroup_stat_cpu {
>  	unsigned long events[MEMCG_NR_EVENTS];
>  	unsigned long nr_page_events;
>  	unsigned long targets[MEM_CGROUP_NTARGETS];
> +
> +	/* for cgroup rstat delta calculation */
> +	unsigned long last_events[MEMCG_NR_EVENTS];
>  };
>  
>  struct mem_cgroup_reclaim_iter {
> @@ -233,7 +236,11 @@ struct mem_cgroup {
>  
>  	struct mem_cgroup_stat_cpu __percpu *stat_cpu;
>  	atomic_long_t		stat[MEMCG_NR_STAT];
> -	atomic_long_t		events[MEMCG_NR_EVENTS];
> +
> +	/* events is managed by cgroup rstat */
> +	unsigned long long	events[MEMCG_NR_EVENTS];	/* local */
> +	unsigned long long	tree_events[MEMCG_NR_EVENTS];	/* subtree */
> +	unsigned long long	pending_events[MEMCG_NR_EVENTS];/* propagation */

The lazy updates are neat, but I'm a little concerned at the memory
footprint. On a 64-cpu machine for example, this adds close to 9000
words to struct mem_cgroup. And we really only need the accuracy for
the 4 cgroup items in memory.events, not all VM events and stats.

Why not restrict the patch to those? It would also get rid of the
weird sharing between VM and cgroup enums.
