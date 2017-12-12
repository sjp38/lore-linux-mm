Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 683B16B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 02:50:19 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id w22so15142367pge.10
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 23:50:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si11255629pgr.491.2017.12.11.23.50.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Dec 2017 23:50:17 -0800 (PST)
Date: Tue, 12 Dec 2017 08:50:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: Release a semaphore in 'get_vaddr_frames()'
Message-ID: <20171212075014.GH4779@dhcp22.suse.cz>
References: <20171211211009.4971-1-christophe.jaillet@wanadoo.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171211211009.4971-1-christophe.jaillet@wanadoo.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Cc: dan.j.williams@intel.com, akpm@linux-foundation.org, borntraeger@de.ibm.com, dsterba@suse.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On Mon 11-12-17 22:10:09, Christophe JAILLET wrote:
> A semaphore is acquired before this check, so we must release it before
> leaving.
> 
> Fixes: b7f0554a56f2 ("mm: fail get_vaddr_frames() for filesystem-dax mappings")
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Looks good to me now.
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks

> ---
> -- Untested --
> 
> v1 -> v2: 'goto out' instead of duplicating code
> ---
>  mm/frame_vector.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/frame_vector.c b/mm/frame_vector.c
> index 297c7238f7d4..c64dca6e27c2 100644
> --- a/mm/frame_vector.c
> +++ b/mm/frame_vector.c
> @@ -62,8 +62,10 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
>  	 * get_user_pages_longterm() and disallow it for filesystem-dax
>  	 * mappings.
>  	 */
> -	if (vma_is_fsdax(vma))
> -		return -EOPNOTSUPP;
> +	if (vma_is_fsdax(vma)) {
> +		ret = -EOPNOTSUPP;
> +		goto out;
> +	}
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
