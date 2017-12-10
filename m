Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 005066B0033
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 04:45:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id o2so3020201wmf.2
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 01:45:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z185si3756649wmc.247.2017.12.10.01.45.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Dec 2017 01:45:49 -0800 (PST)
Date: Sun, 10 Dec 2017 10:45:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Release a semaphore in 'get_vaddr_frames()'
Message-ID: <20171210094545.GW20234@dhcp22.suse.cz>
References: <20171209070941.31828-1-christophe.jaillet@wanadoo.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171209070941.31828-1-christophe.jaillet@wanadoo.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Cc: dan.j.williams@intel.com, akpm@linux-foundation.org, borntraeger@de.ibm.com, dsterba@suse.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On Sat 09-12-17 08:09:41, Christophe JAILLET wrote:
> A semaphore is acquired before this check, so we must release it before
> leaving.
> 
> Fixes: b7f0554a56f2 ("mm: fail get_vaddr_frames() for filesystem-dax mappings")
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
> -- Untested --
> 
> The wording of the commit entry and log description could be improved
> but I didn't find something better.

The changelog is ok imo.

> ---
>  mm/frame_vector.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/frame_vector.c b/mm/frame_vector.c
> index 297c7238f7d4..e0c5e659fa82 100644
> --- a/mm/frame_vector.c
> +++ b/mm/frame_vector.c
> @@ -62,8 +62,10 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
>  	 * get_user_pages_longterm() and disallow it for filesystem-dax
>  	 * mappings.
>  	 */
> -	if (vma_is_fsdax(vma))
> +	if (vma_is_fsdax(vma)) {
> +		up_read(&mm->mmap_sem);
>  		return -EOPNOTSUPP;
> +	}

Is there any reason to do a different error handling than other error
paths? Namely not going without goto out?

>  
>  	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
>  		vec->got_ref = true;
> -- 
> 2.14.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
