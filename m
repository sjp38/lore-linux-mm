Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 258CE8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:53:51 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e29so6367550ede.19
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 07:53:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h22-v6si117329ejl.15.2018.12.21.07.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 07:53:49 -0800 (PST)
Date: Fri, 21 Dec 2018 16:53:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm: vmalloc: do not allow kzalloc to fail
Message-ID: <20181221155347.GF6410@dhcp22.suse.cz>
References: <1545337437-673-1-git-send-email-hofrat@osadl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1545337437-673-1-git-send-email-hofrat@osadl.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chintan Pandya <cpandya@codeaurora.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Arun KS <arunks@codeaurora.org>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 20-12-18 21:23:57, Nicholas Mc Guire wrote:
> While this is in a very early stage of the system boot and if memory
> were exhausted the system has a more serious problem anyway - but still
> the kzalloc here seems unsafe. Looking at the history it was previously
> switched from alloc_bootmem() to kzalloc() using GFP_NOWAIT flag but
> there never seems to have been a check for NULL return. So if this is
> expected to never fail should it not be using | __GFP_NOFAIL here ?
> Or put differently - what is the rational for GFP_NOWAIT to be safe here ?

Is there an actual problem you are trying to solve? GFP_NOWAIT|
__GFP_NOFAIL is a terrible idea. If this is an early allocation then
what would break this allocation out of the loop? There is nothing to
reclaim, there is nothing to kill. The allocation failure check would be
nice but what can you do except for BUG_ON?

> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> Fixes 43ebdac42f16 ("vmalloc: use kzalloc() instead of alloc_bootmem()")

So no, this is definitely not the right thing to do.
Nacked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
> Problem was found by an experimental coccinelle script
> 
> Patch was only compile tested for x86_64_defconfig
> 
> Patch is against v4.20-rc7 (localversion-next next-20181220)
> 
>  mm/vmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 871e41c..1c118d7 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1258,7 +1258,7 @@ void __init vmalloc_init(void)
>  
>  	/* Import existing vmlist entries. */
>  	for (tmp = vmlist; tmp; tmp = tmp->next) {
> -		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> +		va = kzalloc(sizeof(*va), GFP_NOWAIT | __GFP_NOFAIL);
>  		va->flags = VM_VM_AREA;
>  		va->va_start = (unsigned long)tmp->addr;
>  		va->va_end = va->va_start + tmp->size;
> -- 
> 2.1.4
> 

-- 
Michal Hocko
SUSE Labs
