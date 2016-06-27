Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F18386B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 09:05:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so72099846wma.3
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 06:05:30 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id iq10si26247772wjb.103.2016.06.27.06.05.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 06:05:29 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r201so24451237wme.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 06:05:29 -0700 (PDT)
Date: Mon, 27 Jun 2016 15:05:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH rebase] mm: fix vm-scalability regression in cgroup-aware
 workingset code
Message-ID: <20160627130527.GK31799@dhcp22.suse.cz>
References: <20160622182019.24064-1-hannes@cmpxchg.org>
 <20160624175101.GA3024@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160624175101.GA3024@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ye Xiaolong <xiaolong.ye@intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

[Sorry for a late reply]

On Fri 24-06-16 13:51:01, Johannes Weiner wrote:
> This is a rebased version on top of mmots sans the nodelru stuff.
> 
> ---
> 
> 23047a96d7cf ("mm: workingset: per-cgroup cache thrash detection")
> added a page->mem_cgroup lookup to the cache eviction, refault, and
> activation paths, as well as locking to the activation path, and the
> vm-scalability tests showed a regression of -23%. While the test in
> question is an artificial worst-case scenario that doesn't occur in
> real workloads - reading two sparse files in parallel at full CPU
> speed just to hammer the LRU paths - there is still some optimizations
> that can be done in those paths.
> 
> Inline the lookup functions to eliminate calls. Also, page->mem_cgroup
> doesn't need to be stabilized when counting an activation; we merely
> need to hold the RCU lock to prevent the memcg from being freed.
> 
> This cuts down on overhead quite a bit:
> 
> 23047a96d7cfcfca 063f6715e77a7be5770d6081fe
> ---------------- --------------------------
>          %stddev     %change         %stddev
>              \          |                \
>   21621405 +- 0%     +11.3%   24069657 +- 2%  vm-scalability.throughput
> 
> Reported-by: Ye Xiaolong <xiaolong.ye@intel.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Minor note below

> +static inline struct mem_cgroup *page_memcg_rcu(struct page *page)
> +{

I guess rcu_read_lock_held() here would be appropriate

> +	return READ_ONCE(page->mem_cgroup);
> +}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
