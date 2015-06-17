Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8F20F6B0071
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:56:48 -0400 (EDT)
Received: by wifx6 with SMTP id x6so56448993wif.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 07:56:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fy6si30634454wib.38.2015.06.17.07.56.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 07:56:46 -0700 (PDT)
Date: Wed, 17 Jun 2015 16:56:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 06/51] memcg: add mem_cgroup_root_css
Message-ID: <20150617145642.GI25056@dhcp22.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-7-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-7-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:20, Tejun Heo wrote:
> Add global mem_cgroup_root_css which points to the root memcg css.

Is there any reason to using css rather than mem_cgroup other than the
structure is not visible outside of memcontrol.c? Because I have a
patchset which exports it. It is not merged yet so a move to mem_cgroup
could be done later. I am just interested whether there is a stronger
reason.

> This will be used by cgroup writeback support.  If memcg is disabled,
> it's defined as ERR_PTR(-EINVAL).

Hmm. Why EINVAL? I can see only mm/backing-dev.c (in
review-cgroup-writeback-switch-20150528 branch) which uses it and that
shouldn't even try to compile if !CONFIG_MEMCG no? Otherwise we would
simply blow up.

> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> aCc: Michal Hocko <mhocko@suse.cz>
> ---
>  include/linux/memcontrol.h | 4 ++++
>  mm/memcontrol.c            | 2 ++
>  2 files changed, 6 insertions(+)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 5fe6411..294498f 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -68,6 +68,8 @@ enum mem_cgroup_events_index {
>  };
>  
>  #ifdef CONFIG_MEMCG
> +extern struct cgroup_subsys_state *mem_cgroup_root_css;
> +
>  void mem_cgroup_events(struct mem_cgroup *memcg,
>  		       enum mem_cgroup_events_index idx,
>  		       unsigned int nr);
> @@ -196,6 +198,8 @@ void mem_cgroup_split_huge_fixup(struct page *head);
>  #else /* CONFIG_MEMCG */
>  struct mem_cgroup;
>  
> +#define mem_cgroup_root_css ((struct cgroup_subsys_state *)ERR_PTR(-EINVAL))
> +
>  static inline void mem_cgroup_events(struct mem_cgroup *memcg,
>  				     enum mem_cgroup_events_index idx,
>  				     unsigned int nr)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c23c1a3..b22a92b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -77,6 +77,7 @@ EXPORT_SYMBOL(memory_cgrp_subsys);
>  
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
>  static struct mem_cgroup *root_mem_cgroup __read_mostly;
> +struct cgroup_subsys_state *mem_cgroup_root_css __read_mostly;
>  
>  /* Whether the swap controller is active */
>  #ifdef CONFIG_MEMCG_SWAP
> @@ -4441,6 +4442,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>  	/* root ? */
>  	if (parent_css == NULL) {
>  		root_mem_cgroup = memcg;
> +		mem_cgroup_root_css = &memcg->css;
>  		page_counter_init(&memcg->memory, NULL);
>  		memcg->high = PAGE_COUNTER_MAX;
>  		memcg->soft_limit = PAGE_COUNTER_MAX;
> -- 
> 2.4.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
