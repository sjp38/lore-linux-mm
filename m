Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B007D6B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 14:03:30 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r144so4870267wme.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 11:03:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si3395615wmf.115.2017.01.18.11.03.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 11:03:29 -0800 (PST)
Date: Wed, 18 Jan 2017 20:03:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/mempolicy.c: do not put mempolicy before using its
 nodemask
Message-ID: <20170118190324.GD17135@dhcp22.suse.cz>
References: <20170118141124.8345-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118141124.8345-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed 18-01-17 15:11:24, Vlastimil Babka wrote:
> Since commit be97a41b291e ("mm/mempolicy.c: merge alloc_hugepage_vma to
> alloc_pages_vma") alloc_pages_vma() can potentially free a mempolicy by
> mpol_cond_put() before accessing the embedded nodemask by
> __alloc_pages_nodemask(). The commit log says it's so "we can use a single
> exit path within the function" but that's clearly wrong. We can still do that
> when doing mpol_cond_put() after the allocation attempt.
> 
> Make sure the mempolicy is not freed prematurely, otherwise
> __alloc_pages_nodemask() can end up using a bogus nodemask, which could lead
> e.g. to premature OOM.
> 
> Fixes: be97a41b291e ("mm/mempolicy.c: merge alloc_hugepage_vma to alloc_pages_vma")
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: stable@vger.kernel.org
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/mempolicy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 2e346645eb80..1e7873e40c9a 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2017,8 +2017,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  
>  	nmask = policy_nodemask(gfp, pol);
>  	zl = policy_zonelist(gfp, pol, node);
> -	mpol_cond_put(pol);
>  	page = __alloc_pages_nodemask(gfp, order, zl, nmask);
> +	mpol_cond_put(pol);
>  out:
>  	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
>  		goto retry_cpuset;
> -- 
> 2.11.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
