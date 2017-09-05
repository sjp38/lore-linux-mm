Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09FFF280300
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 12:43:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 97so5339727wrb.1
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 09:43:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 36si660961wrf.59.2017.09.05.09.43.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Sep 2017 09:43:57 -0700 (PDT)
Date: Tue, 5 Sep 2017 18:43:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Fix mem_cgroup_oom_disable() call missing
Message-ID: <20170905164342.wrzof7kn4o4ybeg5@dhcp22.suse.cz>
References: <1504625439-31313-1-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1504625439-31313-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, linux-kernel@vger.kernel.org

On Tue 05-09-17 17:30:39, Laurent Dufour wrote:
> Seen while reading the code, in handle_mm_fault(), in the case
> arch_vma_access_permitted() is failing the call to mem_cgroup_oom_disable()
> is not made.
> 
> To fix that, move the call to mem_cgroup_oom_enable() after calling
> arch_vma_access_permitted() as it should not have entered the memcg OOM.
> 
> Fixes: bae473a423f6 ("mm: introduce fault_env")
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 56e48e4593cb..274547075486 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3888,6 +3888,11 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  	/* do counter updates before entering really critical section. */
>  	check_sync_rss_stat(current);
>  
> +	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
> +					    flags & FAULT_FLAG_INSTRUCTION,
> +					    flags & FAULT_FLAG_REMOTE))
> +		return VM_FAULT_SIGSEGV;
> +
>  	/*
>  	 * Enable the memcg OOM handling for faults triggered in user
>  	 * space.  Kernel faults are handled more gracefully.
> @@ -3895,11 +3900,6 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  	if (flags & FAULT_FLAG_USER)
>  		mem_cgroup_oom_enable();
>  
> -	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
> -					    flags & FAULT_FLAG_INSTRUCTION,
> -					    flags & FAULT_FLAG_REMOTE))
> -		return VM_FAULT_SIGSEGV;
> -
>  	if (unlikely(is_vm_hugetlb_page(vma)))
>  		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
>  	else
> -- 
> 2.7.4
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
