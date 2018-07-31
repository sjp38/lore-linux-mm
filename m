Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3273E6B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 04:45:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i26-v6so3249782edr.4
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 01:45:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m45-v6si908284edc.143.2018.07.31.01.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 01:45:11 -0700 (PDT)
Date: Tue, 31 Jul 2018 10:45:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: introduce mem_cgroup_put() helper
Message-ID: <20180731084509.GE4557@dhcp22.suse.cz>
References: <20180730180100.25079-1-guro@fb.com>
 <20180730180100.25079-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730180100.25079-2-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Mon 30-07-18 11:00:58, Roman Gushchin wrote:
> Introduce the mem_cgroup_put() helper, which helps to eliminate guarding
> memcg css release with "#ifdef CONFIG_MEMCG" in multiple places.

Is there any reason for this to be a separate patch? I usually do not
like to add helpers without their users because this makes review
harder. This one is quite trivial to fit into Patch3 easilly.

> Link: http://lkml.kernel.org/r/20180623000600.5818-2-guro@fb.com
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  include/linux/memcontrol.h | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 6c6fb116e925..e53e00cdbe3f 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -375,6 +375,11 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
>  	return css ? container_of(css, struct mem_cgroup, css) : NULL;
>  }
>  
> +static inline void mem_cgroup_put(struct mem_cgroup *memcg)
> +{
> +	css_put(&memcg->css);
> +}
> +
>  #define mem_cgroup_from_counter(counter, member)	\
>  	container_of(counter, struct mem_cgroup, member)
>  
> @@ -837,6 +842,10 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
>  	return true;
>  }
>  
> +static inline void mem_cgroup_put(struct mem_cgroup *memcg)
> +{
> +}
> +
>  static inline struct mem_cgroup *
>  mem_cgroup_iter(struct mem_cgroup *root,
>  		struct mem_cgroup *prev,
> -- 
> 2.14.4
> 

-- 
Michal Hocko
SUSE Labs
