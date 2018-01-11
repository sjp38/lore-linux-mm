Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 825926B0266
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 07:46:32 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id q4so1433401wre.14
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 04:46:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 37si6169156wrb.8.2018.01.11.04.46.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 04:46:31 -0800 (PST)
Date: Thu, 11 Jan 2018 13:46:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mm/memcg: try harder to decrease
 [memory,memsw].limit_in_bytes
Message-ID: <20180111124629.GA1732@dhcp22.suse.cz>
References: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
 <20180110124317.28887-1-aryabinin@virtuozzo.com>
 <20180111104239.GZ1732@dhcp22.suse.cz>
 <4a8f667d-c2ae-e3df-00fd-edc01afe19e1@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4a8f667d-c2ae-e3df-00fd-edc01afe19e1@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

On Thu 11-01-18 15:21:33, Andrey Ryabinin wrote:
> 
> 
> On 01/11/2018 01:42 PM, Michal Hocko wrote:
> > On Wed 10-01-18 15:43:17, Andrey Ryabinin wrote:
> > [...]
> >> @@ -2506,15 +2480,13 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> >>  		if (!ret)
> >>  			break;
> >>  
> >> -		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, !memsw);
> >> -
> >> -		curusage = page_counter_read(counter);
> >> -		/* Usage is reduced ? */
> >> -		if (curusage >= oldusage)
> >> -			retry_count--;
> >> -		else
> >> -			oldusage = curusage;
> >> -	} while (retry_count);
> >> +		usage = page_counter_read(counter);
> >> +		if (!try_to_free_mem_cgroup_pages(memcg, usage - limit,
> >> +						GFP_KERNEL, !memsw)) {
> > 
> > If the usage drops below limit in the meantime then you get underflow
> > and reclaim the whole memcg. I do not think this is a good idea. This
> > can also lead to over reclaim. Why don't you simply stick with the
> > original SWAP_CLUSTER_MAX (aka 1 for try_to_free_mem_cgroup_pages)?
> > 
> 
> Because, if new limit is gigabytes bellow the current usage, retrying to set
> new limit after reclaiming only 32 pages seems unreasonable.

Who would do insanity like that?

> @@ -2487,8 +2487,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> -		usage = page_counter_read(counter);
> -		if (!try_to_free_mem_cgroup_pages(memcg, usage - limit,
> +		nr_pages = max_t(long, 1, page_counter_read(counter) - limit);
> +		if (!try_to_free_mem_cgroup_pages(memcg, nr_pages,
>  						GFP_KERNEL, !memsw)) {
>  			ret = -EBUSY;
>  			break;

How does this address the over reclaim concern?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
