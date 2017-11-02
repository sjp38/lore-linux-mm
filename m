Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B72CD6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 09:22:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b79so5294087pfk.9
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 06:22:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a91si2256062pla.788.2017.11.02.06.22.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 06:22:50 -0700 (PDT)
Date: Thu, 2 Nov 2017 14:22:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: try to free swap only for reading swap fault
Message-ID: <20171102132245.imhcjqbsuaub6dhj@dhcp22.suse.cz>
References: <1509626119-39916-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509626119-39916-1-git-send-email-zhouxianrong@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, jack@suse.cz, kirill.shutemov@linux.intel.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, aneesh.kumar@linux.vnet.ibm.com, minchan@kernel.org, mingo@kernel.org, jglisse@redhat.com, willy@linux.intel.com, hughd@google.com, zhouxiyu@huawei.com, weidu.du@huawei.com, fanghua3@huawei.com, hutj@huawei.com, won.ho.park@huawei.com

On Thu 02-11-17 20:35:19, zhouxianrong@huawei.com wrote:
> From: zhouxianrong <zhouxianrong@huawei.com>
> 
> the purpose of this patch is that when a reading swap fault
> happens on a clean swap cache page whose swap count is equal
> to one, then try_to_free_swap could remove this page from 
> swap cache and mark this page dirty. so if later we reclaimed
> this page then we could pageout this page due to this dirty.
> so i want to allow this action only for writing swap fault.
> 
> i sampled the data of non-dirty anonymous pages which is no
> need to pageout and total anonymous pages in shrink_page_list.
> 
> the results are:
> 
>         non-dirty anonymous pages     total anonymous pages
> before  26343                         635218
> after   36907                         634312

This data is absolutely pointless without describing the workload.
You patch also stil fails to explain which workloads are going to
benefit/suffer from the change and why it is a good thing to do in
general.

> Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
> ---
>  mm/memory.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index a728bed..5a944fe 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2999,7 +2999,7 @@ int do_swap_page(struct vm_fault *vmf)
>  	}
>  
>  	swap_free(entry);
> -	if (mem_cgroup_swap_full(page) ||
> +	if (((vmf->flags & FAULT_FLAG_WRITE) && mem_cgroup_swap_full(page)) ||
>  	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
>  		try_to_free_swap(page);
>  	unlock_page(page);
> -- 
> 1.7.9.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
