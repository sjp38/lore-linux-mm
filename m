Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE556B0258
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:34:11 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id c17so23550459wmd.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:34:11 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f194si7005983wmd.103.2015.12.11.11.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 11:34:10 -0800 (PST)
Date: Fri, 11 Dec 2015 14:33:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] mm: free swap cache aggressively if memcg swap is
 full
Message-ID: <20151211193358.GE3773@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <2c7ac3a5c2a2fb9b1c5136d8409652ed7ecc260f.1449742561.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2c7ac3a5c2a2fb9b1c5136d8409652ed7ecc260f.1449742561.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 10, 2015 at 02:39:19PM +0300, Vladimir Davydov wrote:
> Swap cache pages are freed aggressively if swap is nearly full (>50%
> currently), because otherwise we are likely to stop scanning anonymous
> when we near the swap limit even if there is plenty of freeable swap
> cache pages. We should follow the same trend in case of memory cgroup,
> which has its own swap limit.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

One note:

> @@ -5839,6 +5839,29 @@ long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
>  	return nr_swap_pages;
>  }
>  
> +bool mem_cgroup_swap_full(struct page *page)
> +{
> +	struct mem_cgroup *memcg;
> +
> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +
> +	if (vm_swap_full())
> +		return true;
> +	if (!do_swap_account || !PageSwapCache(page))
> +		return false;

The callers establish PageSwapCache() under the page lock, which makes
sense since they only inquire about the swap state when deciding what
to do with a swapcache page at hand. So this check seems unnecessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
