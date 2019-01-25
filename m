Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 53E4B8E00C2
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 02:24:34 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so3373533edc.9
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 23:24:34 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kq26si1441069ejb.228.2019.01.24.23.24.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 23:24:32 -0800 (PST)
Date: Fri, 25 Jan 2019 08:24:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: Extract memcg maxable seq_file logic to
 seq_show_memcg_tunable
Message-ID: <20190125072429.GA3560@dhcp22.suse.cz>
References: <20190124194100.GA31425@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124194100.GA31425@chrisdown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu 24-01-19 14:41:00, Chris Down wrote:
> memcg has a significant number of files exposed to kernfs where their
> value is either exposed directly or is "max" in the case of
> PAGE_COUNTER_MAX.
> 
> This patch makes this generic by providing a single function to do this
> work. In combination with the previous patch adding mem_cgroup_from_seq,
> this makes all of the seq_show feeder functions significantly more
> simple.

Yeah this is what I've had in mind when mentioning a helper in the
previous version of the patch. I like this more even though the
resulting savings are not that large.

> Signed-off-by: Chris Down <chris@chrisdown.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 64 +++++++++++++++----------------------------------
>  1 file changed, 19 insertions(+), 45 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 98aad31f5226..81b6f752471a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5375,6 +5375,16 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
>  		root_mem_cgroup->use_hierarchy = false;
>  }
>  
> +static int seq_puts_memcg_tunable(struct seq_file *m, unsigned long value)
> +{
> +	if (value == PAGE_COUNTER_MAX)
> +		seq_puts(m, "max\n");
> +	else
> +		seq_printf(m, "%llu\n", (u64)value * PAGE_SIZE);
> +
> +	return 0;
> +}
> +
>  static u64 memory_current_read(struct cgroup_subsys_state *css,
>  			       struct cftype *cft)
>  {
> @@ -5385,15 +5395,8 @@ static u64 memory_current_read(struct cgroup_subsys_state *css,
>  
>  static int memory_min_show(struct seq_file *m, void *v)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
> -	unsigned long min = READ_ONCE(memcg->memory.min);
> -
> -	if (min == PAGE_COUNTER_MAX)
> -		seq_puts(m, "max\n");
> -	else
> -		seq_printf(m, "%llu\n", (u64)min * PAGE_SIZE);
> -
> -	return 0;
> +	return seq_puts_memcg_tunable(m,
> +		READ_ONCE(mem_cgroup_from_seq(m)->memory.min));
>  }
>  
>  static ssize_t memory_min_write(struct kernfs_open_file *of,
> @@ -5415,15 +5418,8 @@ static ssize_t memory_min_write(struct kernfs_open_file *of,
>  
>  static int memory_low_show(struct seq_file *m, void *v)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
> -	unsigned long low = READ_ONCE(memcg->memory.low);
> -
> -	if (low == PAGE_COUNTER_MAX)
> -		seq_puts(m, "max\n");
> -	else
> -		seq_printf(m, "%llu\n", (u64)low * PAGE_SIZE);
> -
> -	return 0;
> +	return seq_puts_memcg_tunable(m,
> +		READ_ONCE(mem_cgroup_from_seq(m)->memory.low));
>  }
>  
>  static ssize_t memory_low_write(struct kernfs_open_file *of,
> @@ -5445,15 +5441,7 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
>  
>  static int memory_high_show(struct seq_file *m, void *v)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
> -	unsigned long high = READ_ONCE(memcg->high);
> -
> -	if (high == PAGE_COUNTER_MAX)
> -		seq_puts(m, "max\n");
> -	else
> -		seq_printf(m, "%llu\n", (u64)high * PAGE_SIZE);
> -
> -	return 0;
> +	return seq_puts_memcg_tunable(m, READ_ONCE(mem_cgroup_from_seq(m)->high));
>  }
>  
>  static ssize_t memory_high_write(struct kernfs_open_file *of,
> @@ -5482,15 +5470,8 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
>  
>  static int memory_max_show(struct seq_file *m, void *v)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
> -	unsigned long max = READ_ONCE(memcg->memory.max);
> -
> -	if (max == PAGE_COUNTER_MAX)
> -		seq_puts(m, "max\n");
> -	else
> -		seq_printf(m, "%llu\n", (u64)max * PAGE_SIZE);
> -
> -	return 0;
> +	return seq_puts_memcg_tunable(m,
> +		READ_ONCE(mem_cgroup_from_seq(m)->memory.max));
>  }
>  
>  static ssize_t memory_max_write(struct kernfs_open_file *of,
> @@ -6622,15 +6603,8 @@ static u64 swap_current_read(struct cgroup_subsys_state *css,
>  
>  static int swap_max_show(struct seq_file *m, void *v)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
> -	unsigned long max = READ_ONCE(memcg->swap.max);
> -
> -	if (max == PAGE_COUNTER_MAX)
> -		seq_puts(m, "max\n");
> -	else
> -		seq_printf(m, "%llu\n", (u64)max * PAGE_SIZE);
> -
> -	return 0;
> +	return seq_puts_memcg_tunable(m,
> +		READ_ONCE(mem_cgroup_from_seq(m)->swap.max));
>  }
>  
>  static ssize_t swap_max_write(struct kernfs_open_file *of,
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs
