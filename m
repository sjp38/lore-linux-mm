Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id BA5746B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 03:34:31 -0400 (EDT)
Received: by wieq12 with SMTP id q12so68499843wie.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 00:34:31 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id v12si8867330wjr.183.2015.10.14.00.34.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 00:34:30 -0700 (PDT)
Received: by wieq12 with SMTP id q12so68499131wie.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 00:34:29 -0700 (PDT)
Date: Wed, 14 Oct 2015 09:34:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] gfp: GFP_RECLAIM_MASK should include __GFP_NO_KSWAPD
Message-ID: <20151014073428.GC28333@dhcp22.suse.cz>
References: <561DE9F3.504@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <561DE9F3.504@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pan Xinhui <xinhuix.pan@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, rientjes@google.com, hannes@cmpxchg.org, nasa4836@gmail.com, mgorman@suse.de, alexander.h.duyck@redhat.com, aneesh.kumar@linux.vnet.ibm.com, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>

On Wed 14-10-15 13:36:51, Pan Xinhui wrote:
> From: Pan Xinhui <xinhuix.pan@intel.com>
> 
> GFP_RECLAIM_MASK was introduced in commit 6cb062296f73 ("Categorize GFP
> flags"). In slub subsystem, this macro controls slub's allocation
> behavior. In particular, some flags which are not in GFP_RECLAIM_MASK
> will be cleared. So when slub pass this new gfp_flag into page
> allocator, we might lost some very important flags.
> 
> There are some mistakes when we introduce __GFP_NO_KSWAPD. This flag is
> used to avoid any scheduler-related codes recursive.  But it seems like
> patch author forgot to add it into GFP_RECLAIM_MASK. So lets add it now.

This is no longer needed because GFP_RECLAIM_MASK contains __GFP_RECLAIM
now - have  a look at
http://lkml.kernel.org/r/1442832762-7247-7-git-send-email-mgorman%40techsingularity.net
which is sitting in the mmotm tree.

> Signed-off-by: Pan Xinhui <xinhuix.pan@intel.com>
> ---
>  include/linux/gfp.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index f92cbd2..9ebad4d 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -130,7 +130,8 @@ struct vm_area_struct;
>  /* Control page allocator reclaim behavior */
>  #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
>  			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
> -			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
> +			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC|\
> +			__GFP_NO_KSWAPD)
>  
>  /* Control slab gfp mask during early boot */
>  #define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_WAIT|__GFP_IO|__GFP_FS))
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
