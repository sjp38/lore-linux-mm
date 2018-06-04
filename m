Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA5A76B000A
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 08:26:13 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id h12-v6so437230wrq.2
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 05:26:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 19-v6si170895edz.385.2018.06.04.05.26.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jun 2018 05:26:12 -0700 (PDT)
Date: Mon, 4 Jun 2018 14:26:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: propagate memory effective protection on setting
 memory.min/low
Message-ID: <20180604122610.GM19202@dhcp22.suse.cz>
References: <20180522132528.23769-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180522132528.23769-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue 22-05-18 14:25:27, Roman Gushchin wrote:
> Explicitly propagate effective memory min/low values down by the tree.
> 
> If there is the global memory pressure, it's not really necessary.
> Effective memory guarantees will be propagated automatically
> as we traverse memory cgroup tree in the reclaim path.
> 
> But if there is no global memory pressure, effective memory protection
> still matters for local (memcg-scoped) memory pressure.
> So, we have to update effective limits in the subtree,
> if a user changes memory.min and memory.low values.

Please be explicit about the exact problem. Ideally with a memcg tree example.

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/memcontrol.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ab5673dbfc4e..b9cd0bb63759 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5374,7 +5374,7 @@ static int memory_min_show(struct seq_file *m, void *v)
>  static ssize_t memory_min_write(struct kernfs_open_file *of,
>  				char *buf, size_t nbytes, loff_t off)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
> +	struct mem_cgroup *iter, *memcg = mem_cgroup_from_css(of_css(of));
>  	unsigned long min;
>  	int err;
>  
> @@ -5385,6 +5385,11 @@ static ssize_t memory_min_write(struct kernfs_open_file *of,
>  
>  	page_counter_set_min(&memcg->memory, min);
>  
> +	rcu_read_lock();
> +	for_each_mem_cgroup_tree(iter, memcg)
> +		mem_cgroup_protected(NULL, iter);
> +	rcu_read_unlock();
> +
>  	return nbytes;
>  }
>  
> @@ -5404,7 +5409,7 @@ static int memory_low_show(struct seq_file *m, void *v)
>  static ssize_t memory_low_write(struct kernfs_open_file *of,
>  				char *buf, size_t nbytes, loff_t off)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
> +	struct mem_cgroup *iter, *memcg = mem_cgroup_from_css(of_css(of));
>  	unsigned long low;
>  	int err;
>  
> @@ -5415,6 +5420,11 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
>  
>  	page_counter_set_low(&memcg->memory, low);
>  
> +	rcu_read_lock();
> +	for_each_mem_cgroup_tree(iter, memcg)
> +		mem_cgroup_protected(NULL, iter);
> +	rcu_read_unlock();
> +
>  	return nbytes;
>  }
>  
> -- 
> 2.14.3

-- 
Michal Hocko
SUSE Labs
