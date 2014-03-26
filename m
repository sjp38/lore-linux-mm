Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id C58AB6B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 18:01:03 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hr14so3754570wib.10
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 15:01:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h5si392356wie.3.2014.03.26.15.01.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 15:01:02 -0700 (PDT)
Date: Wed, 26 Mar 2014 15:00:51 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 3/4] fork: charge threadinfo to memcg explicitly
Message-ID: <20140326220050.GC22656@dhcp22.suse.cz>
References: <cover.1395846845.git.vdavydov@parallels.com>
 <8f98a5160b9e17947cbb25e91944f332679b9c9c.1395846845.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8f98a5160b9e17947cbb25e91944f332679b9c9c.1395846845.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Wed 26-03-14 19:28:06, Vladimir Davydov wrote:
> We have only a few places where we actually want to charge kmem so
> instead of intruding into the general page allocation path with
> __GFP_KMEMCG it's better to explictly charge kmem there. All kmem
> charges will be easier to follow that way.
> 
> This is a step toward removing __GFP_KMEMCG. It makes fork charge task
> threadinfo pages explicitly instead of passing __GFP_KMEMCG to
> alloc_pages.

Looks good from a quick glance. I would also remove
THREADINFO_GFP_ACCOUNTED in this patch.

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Glauber Costa <glommer@gmail.com>
> ---
>  kernel/fork.c |   13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index f4b09bc15f3a..8209780cf732 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -150,15 +150,22 @@ void __weak arch_release_thread_info(struct thread_info *ti)
>  static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
>  						  int node)
>  {
> -	struct page *page = alloc_pages_node(node, THREADINFO_GFP_ACCOUNTED,
> -					     THREAD_SIZE_ORDER);
> +	struct page *page;
> +	struct mem_cgroup *memcg = NULL;
>  
> +	if (!memcg_kmem_newpage_charge(THREADINFO_GFP_ACCOUNTED, &memcg,
> +				       THREAD_SIZE_ORDER))
> +		return NULL;
> +	page = alloc_pages_node(node, THREADINFO_GFP, THREAD_SIZE_ORDER);
> +	memcg_kmem_commit_charge(page, memcg, THREAD_SIZE_ORDER);
>  	return page ? page_address(page) : NULL;
>  }
>  
>  static inline void free_thread_info(struct thread_info *ti)
>  {
> -	free_memcg_kmem_pages((unsigned long)ti, THREAD_SIZE_ORDER);
> +	if (ti)
> +		memcg_kmem_uncharge_pages(virt_to_page(ti), THREAD_SIZE_ORDER);
> +	free_pages((unsigned long)ti, THREAD_SIZE_ORDER);
>  }
>  # else
>  static struct kmem_cache *thread_info_cache;
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
