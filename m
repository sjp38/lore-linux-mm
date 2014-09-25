Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id D801F6B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 07:43:43 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id fb4so8147488wid.3
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 04:43:43 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id d4si2350183wje.123.2014.09.25.04.43.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 04:43:42 -0700 (PDT)
Received: by mail-wg0-f47.google.com with SMTP id y10so8169631wgg.30
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 04:43:42 -0700 (PDT)
Date: Thu, 25 Sep 2014 13:43:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] mm: memcontrol: do not iterate uninitialized memcgs
Message-ID: <20140925114339.GD12090@dhcp22.suse.cz>
References: <1411612278-4707-1-git-send-email-hannes@cmpxchg.org>
 <20140925024054.GA4888@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140925024054.GA4888@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 24-09-14 22:40:55, Johannes Weiner wrote:
> Argh, buggy css_put() against the root.  Hand grenades, everywhere.
> Update:
> 
> ---
> From 9b0b4d72d71cd8acd7aaa58d2006c751decc8739 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Wed, 24 Sep 2014 22:00:20 -0400
> Subject: [patch] mm: memcontrol: do not iterate uninitialized memcgs
> 
> The cgroup iterators yield css objects that have not yet gone through
> css_online(), but they are not complete memcgs at this point and so
> the memcg iterators should not return them.  d8ad30559715 ("mm/memcg:
> iteration skip memcgs not yet fully initialized") set out to implement
> exactly this, but it uses CSS_ONLINE, a cgroup-internal flag that does
> not meet the ordering requirements for memcg, and so we still may see
> partially initialized memcgs from the iterators.

I do not see how would this happen. CSS_ONLINE is set after css_online
callback returns and mem_cgroup_css_online ends the core initialization
with mutex_unlock which should provide sufficient memory ordering
requirements (kmem is not covered but activate_kmem_mutex kmem.tcp by
proto_list_mutex). So the worst thing that might happen is that we miss
an already initialized memcg but that shouldn't matter because such a
memcg doesn't contain any tasks nor memory. memcg_has_children doesn't
rely on our iterators so important parts will not miss anything.

So I do not see any bug right now. The flag abuse is another story and I
do agree we should use proper memcg specific synchronization here as
explained by Tejun in other email.

> The cgroup core can not reasonably provide a clear answer on whether
> the object around the css has been fully initialized, as that depends
> on controller-specific locking and lifetime rules.  Thus, introduce a
> memcg-specific flag that is set after the memcg has been initialized
> in css_online(), and read before mem_cgroup_iter() callers access the
> memcg members.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

With updated changelog
Acked-by: Michal Hocko <mhocko@suse.cz>

> Cc: <stable@vger.kernel.org>	[3.12+]

This is not necessary IMO

> ---
>  mm/memcontrol.c | 36 +++++++++++++++++++++++++++++++-----
>  1 file changed, 31 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 306b6470784c..bafdac0f724e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -292,6 +292,9 @@ struct mem_cgroup {
>  	/* vmpressure notifications */
>  	struct vmpressure vmpressure;
>  
> +	/* css_online() has been completed */
> +	bool initialized;
> +
>  	/*
>  	 * the counter to account for mem+swap usage.
>  	 */
> @@ -1090,10 +1093,23 @@ skip_node:
>  	 * skipping css reference should be safe.
>  	 */
>  	if (next_css) {
> -		if ((next_css == &root->css) ||
> -		    ((next_css->flags & CSS_ONLINE) &&
> -		     css_tryget_online(next_css)))
> -			return mem_cgroup_from_css(next_css);
> +		struct mem_cgroup *memcg = mem_cgroup_from_css(next_css);
> +
> +		if (next_css == &root->css)
> +			return memcg;
> +
> +		if (css_tryget_online(next_css)) {
> +			if (memcg->initialized) {
> +				/*
> +				 * Make sure the caller's accesses to
> +				 * the memcg members are issued after
> +				 * we see this flag set.
> +				 */
> +				smp_rmb();
> +				return memcg;
> +			}
> +			css_put(next_css);
> +		}
>  
>  		prev_css = next_css;
>  		goto skip_node;
> @@ -5413,6 +5429,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup *parent = mem_cgroup_from_css(css->parent);
> +	int ret;
>  
>  	if (css->id > MEM_CGROUP_ID_MAX)
>  		return -ENOSPC;
> @@ -5449,7 +5466,16 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  	}
>  	mutex_unlock(&memcg_create_mutex);
>  
> -	return memcg_init_kmem(memcg, &memory_cgrp_subsys);
> +	ret = memcg_init_kmem(memcg, &memory_cgrp_subsys);
> +	if (ret)
> +		return ret;
> +
> +	/* Make sure the initialization is visible before the flag */
> +	smp_wmb();
> +
> +	memcg->initialized = true;
> +
> +	return 0;
>  }
>  
>  /*
> -- 
> 2.1.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
