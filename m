Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DFF08E0097
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 16:19:02 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id o200so3478542ybc.1
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 13:19:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10sor4102311ywb.110.2019.01.24.13.19.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 13:19:00 -0800 (PST)
Date: Thu, 24 Jan 2019 16:18:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm: Extract memcg maxable seq_file logic to
 seq_show_memcg_tunable
Message-ID: <20190124211858.GB14136@cmpxchg.org>
References: <20190124194100.GA31425@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124194100.GA31425@chrisdown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu, Jan 24, 2019 at 02:41:00PM -0500, Chris Down wrote:
> memcg has a significant number of files exposed to kernfs where their
> value is either exposed directly or is "max" in the case of
> PAGE_COUNTER_MAX.
> 
> This patch makes this generic by providing a single function to do this
> work. In combination with the previous patch adding mem_cgroup_from_seq,
> this makes all of the seq_show feeder functions significantly more
> simple.
> 
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com
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

Thanks for doing this.

The main thing that bugged me about the macro is that the data lookup
was split into two places:

	DEFINE_MEMCG_THING(seq, memory_min_show, memory.min);

where memory.min is just a fragment of a designator and you have to
look at the macro to find out what exactly it gets turned into.

With this patch it's obvious, and you don't have to look at the
implementation of seq_puts_memcg_tunable() to understand what's being
printed out.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
