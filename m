Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id F08786B0073
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:45:07 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so3920216pad.36
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 08:45:07 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ph3si14529760pdb.141.2014.10.22.08.45.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 08:45:06 -0700 (PDT)
Date: Wed, 22 Oct 2014 19:44:57 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 3/4] mm: memcontrol: remove unnecessary PCG_MEM memory
 charge flag
Message-ID: <20141022154457.GA16496@esperanza>
References: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
 <1413818532-11042-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1413818532-11042-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Oct 20, 2014 at 11:22:11AM -0400, Johannes Weiner wrote:
> PCG_MEM is a remnant from an earlier version of 0a31bc97c80c ("mm:
> memcontrol: rewrite uncharge API"), used to tell whether migration
> cleared a charge while leaving pc->mem_cgroup valid and PCG_USED set.
> But in the final version, mem_cgroup_migrate() directly uncharges the
> source page, rendering this distinction unnecessary.  Remove it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

> ---
>  include/linux/page_cgroup.h | 1 -
>  mm/memcontrol.c             | 4 +---
>  2 files changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index da62ee2be28b..97536e685843 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -4,7 +4,6 @@
>  enum {
>  	/* flags for mem_cgroup */
>  	PCG_USED = 0x01,	/* This page is charged to a memcg */
> -	PCG_MEM = 0x02,		/* This page holds a memory charge */
>  };
>  
>  struct pglist_data;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9bab35fc3e9e..1d66ac49e702 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2606,7 +2606,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
>  	 *   have the page locked
>  	 */
>  	pc->mem_cgroup = memcg;
> -	pc->flags = PCG_USED | PCG_MEM;
> +	pc->flags = PCG_USED;
>  
>  	if (lrucare)
>  		unlock_page_lru(page, isolated);
> @@ -6177,8 +6177,6 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  	if (!PageCgroupUsed(pc))
>  		return;
>  
> -	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
> -
>  	if (lrucare)
>  		lock_page_lru(oldpage, &isolated);
>  
> -- 
> 2.1.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
