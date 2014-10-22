Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id AFC386B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 12:11:42 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id mc6so3256079lab.2
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 09:11:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rj3si23896711lbb.85.2014.10.22.09.11.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 09:11:40 -0700 (PDT)
Date: Wed, 22 Oct 2014 18:11:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 4/4] mm: memcontrol: remove unnecessary PCG_USED
 pc->mem_cgroup valid flag
Message-ID: <20141022161140.GG30802@dhcp22.suse.cz>
References: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
 <1413818532-11042-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413818532-11042-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 20-10-14 11:22:12, Johannes Weiner wrote:
> pc->mem_cgroup had to be left intact after uncharge for the final LRU
> removal, and !PCG_USED indicated whether the page was uncharged.  But
> since 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API") pages are
> uncharged after the final LRU removal.  Uncharge can simply clear the
> pointer and the PCG_USED/PageCgroupUsed sites can test that instead.
> 
> Because this is the last page_cgroup flag, this patch reduces the
> memcg per-page overhead to a single pointer.

Nice. I have an old patch which stuck this flag into page_cgroup pointer
but this is of course much much better!
 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

Just a nit below

[...]
> @@ -2525,9 +2523,10 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)

memcg = NULL initialization is not needed now

>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  
>  	pc = lookup_page_cgroup(page);
> -	if (PageCgroupUsed(pc)) {
> -		memcg = pc->mem_cgroup;
> -		if (memcg && !css_tryget_online(&memcg->css))
> +	memcg = pc->mem_cgroup;
> +
> +	if (memcg) {
> +		if (!css_tryget_online(&memcg->css))
>  			memcg = NULL;
>  	} else if (PageSwapCache(page)) {
>  		ent.val = page_private(page);

>  #else
>  static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
