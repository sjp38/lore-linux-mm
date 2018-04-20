Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F41946B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 16:42:53 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 88-v6so8869610wrc.21
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:42:53 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h63si5081736edd.398.2018.04.20.13.42.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 13:42:52 -0700 (PDT)
Date: Fri, 20 Apr 2018 16:44:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm: introduce memory.min
Message-ID: <20180420204429.GA24563@cmpxchg.org>
References: <20180420163632.3978-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420163632.3978-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

Hi Roman,

this looks cool, and the implementation makes sense to me, so the
feedback I have is just smaller stuff.

On Fri, Apr 20, 2018 at 05:36:31PM +0100, Roman Gushchin wrote:
> Memory controller implements the memory.low best-effort memory
> protection mechanism, which works perfectly in many cases and
> allows protecting working sets of important workloads from
> sudden reclaim.
> 
> But it's semantics has a significant limitation: it works

its

> only until there is a supply of reclaimable memory.

s/until/as long as/

Maybe "as long as there is an unprotected supply of reclaimable memory
from other groups"?

> This makes it pretty useless against any sort of slow memory
> leaks or memory usage increases. This is especially true
> for swapless systems. If swap is enabled, memory soft protection
> effectively postpones problems, allowing a leaking application
> to fill all swap area, which makes no sense.
> The only effective way to guarantee the memory protection
> in this case is to invoke the OOM killer.

This makes it sound like it has no purpose at all. But like with
memory.high, the point is to avoid the kernel OOM killer, which knows
jack about how the system is structured, and instead allow userspace
management software to monitor MEMCG_LOW and make informed decisions.

memory.min again is the fail-safe for memory.low, not the primary way
of implementing guarantees.

> @@ -297,7 +297,14 @@ static inline bool mem_cgroup_disabled(void)
>  	return !cgroup_subsys_enabled(memory_cgrp_subsys);
>  }
>  
> -bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg);
> +enum mem_cgroup_protection {
> +	MEM_CGROUP_UNPROTECTED,
> +	MEM_CGROUP_PROTECTED_LOW,
> +	MEM_CGROUP_PROTECTED_MIN,
> +};

These look a bit unwieldy. How about

MEMCG_PROT_NONE,
MEMCG_PROT_LOW,
MEMCG_PROT_HIGH,

> +enum mem_cgroup_protection
> +mem_cgroup_protected(struct mem_cgroup *root, struct mem_cgroup *memcg);

Please don't wrap at the return type, wrap the parameter list instead.

>  int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>  			  gfp_t gfp_mask, struct mem_cgroup **memcgp,
> @@ -756,6 +763,12 @@ static inline void memcg_memory_event(struct mem_cgroup *memcg,
>  {
>  }
>  
> +static inline bool mem_cgroup_min(struct mem_cgroup *root,
> +				  struct mem_cgroup *memcg)
> +{
> +	return false;
> +}
> +
>  static inline bool mem_cgroup_low(struct mem_cgroup *root,
>  				  struct mem_cgroup *memcg)
>  {

The real implementation has these merged into the single
mem_cgroup_protected(). Probably a left-over from earlier versions?

It's always a good idea to build test the !CONFIG_MEMCG case too.

> @@ -5685,44 +5723,71 @@ struct cgroup_subsys memory_cgrp_subsys = {
>   * for next usage. This part is intentionally racy, but it's ok,
>   * as memory.low is a best-effort mechanism.
>   */
> -bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
> +enum mem_cgroup_protection
> +mem_cgroup_protected(struct mem_cgroup *root, struct mem_cgroup *memcg)

Please fix the wrapping here too.

> @@ -2525,12 +2525,29 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  			unsigned long reclaimed;
>  			unsigned long scanned;
>  
> -			if (mem_cgroup_low(root, memcg)) {
> +			switch (mem_cgroup_protected(root, memcg)) {
> +			case MEM_CGROUP_PROTECTED_MIN:
> +				/*
> +				 * Hard protection.
> +				 * If there is no reclaimable memory, OOM.
> +				 */
> +				continue;
> +
> +			case MEM_CGROUP_PROTECTED_LOW:

Please drop that newline after continue.

> +				/*
> +				 * Soft protection.
> +				 * Respect the protection only until there is
> +				 * a supply of reclaimable memory.

Same feedback here as in the changelog:

s/until/as long as/

Maybe "as long as there is an unprotected supply of reclaimable memory
from other groups"?

> +				 */
>  				if (!sc->memcg_low_reclaim) {
>  					sc->memcg_low_skipped = 1;
>  					continue;
>  				}
>  				memcg_memory_event(memcg, MEMCG_LOW);
> +				break;
> +
> +			case MEM_CGROUP_UNPROTECTED:

Please drop that newline after break, too.

Thanks!
Johannes
