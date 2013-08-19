Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 67A356B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 03:44:09 -0400 (EDT)
Date: Mon, 19 Aug 2013 09:44:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH mmotm,next] mm: fix memcg-less page reclaim
Message-ID: <20130819074407.GA3396@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1308182254220.1040@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1308182254220.1040@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sun 18-08-13 23:05:25, Hugh Dickins wrote:
> Now that everybody loves memcg, configures it on, and would not dream
> of booting with cgroup_disable=memory, it can pass unnoticed for weeks
> that memcg-less page reclaim is completely broken.
> 
> mmotm's "memcg: enhance memcg iterator to support predicates" replaces
> __shrink_zone()'s "do { } while (memcg);" loop by a "while (memcg) {}"
> loop: which is nicer for memcg, but does nothing for !CONFIG_MEMCG or
> cgroup_disable=memory.  Page reclaim hangs, making no progress.

Ouch. Very well spotted, Hugh! I have totally missed this...
 
> Adding mem_cgroup_disabled() and once++ test there is ugly.  Ideally,
> even a !CONFIG_MEMCG build might in future have a stub root_mem_cgroup,
> which would get around this: but that's not so at present.
> 
> However, it appears that nothing actually dereferences the memcg pointer
> in the mem_cgroup_disabled() case, here or anywhere else that case can
> reach mem_cgroup_iter() (mem_cgroup_iter_break() is not called in
> global reclaim).
> 
> So, simply pass back an ordinarily-oopsing non-NULL address the first
> time, and we shall hear about it if I'm wrong.

This is a bit tricky but it seems like the easiest way for now. I will
look at the fake root cgroup for !CONFIG_MEMCG.

> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
> By all means fold in to
> memcg-enhance-memcg-iterator-to-support-predicates.patch
> 
>  include/linux/memcontrol.h |    3 ++-
>  mm/memcontrol.c            |    6 ++++--
>  2 files changed, 6 insertions(+), 3 deletions(-)
> 
> --- 3.11-rc5-mm1/include/linux/memcontrol.h	2013-08-15 18:10:50.504539510 -0700
> +++ linux/include/linux/memcontrol.h	2013-08-18 12:30:58.116460318 -0700
> @@ -370,7 +370,8 @@ mem_cgroup_iter_cond(struct mem_cgroup *
>  		struct mem_cgroup_reclaim_cookie *reclaim,
>  		mem_cgroup_iter_filter cond)
>  {
> -	return NULL;
> +	/* first call must return non-NULL, second return NULL */
> +	return (struct mem_cgroup *)(unsigned long)!prev;
>  }
>  
>  static inline struct mem_cgroup *
> --- 3.11-rc5-mm1/mm/memcontrol.c	2013-08-15 18:10:50.720539516 -0700
> +++ linux/mm/memcontrol.c	2013-08-18 12:29:15.352460818 -0700
> @@ -1086,8 +1086,10 @@ struct mem_cgroup *mem_cgroup_iter_cond(
>  	struct mem_cgroup *memcg = NULL;
>  	struct mem_cgroup *last_visited = NULL;
>  
> -	if (mem_cgroup_disabled())
> -		return NULL;
> +	if (mem_cgroup_disabled()) {
> +		/* first call must return non-NULL, second return NULL */
> +		return (struct mem_cgroup *)(unsigned long)!prev;
> +	}
>  
>  	if (!root)
>  		root = root_mem_cgroup;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
