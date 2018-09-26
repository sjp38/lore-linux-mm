Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 79F458E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:14:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v14-v6so1104956edq.10
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:14:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t22-v6si1180459edr.225.2018.09.26.04.14.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 04:14:23 -0700 (PDT)
Subject: Re: [v11 PATCH 3/3] mm: unmap VM_PFNMAP mappings with optimized path
References: <1537376621-51150-1-git-send-email-yang.shi@linux.alibaba.com>
 <1537376621-51150-4-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <889734e0-d2a9-3191-8d48-5c95bf29fb3f@suse.cz>
Date: Wed, 26 Sep 2018 13:11:45 +0200
MIME-Version: 1.0
In-Reply-To: <1537376621-51150-4-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org
Cc: dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/19/18 7:03 PM, Yang Shi wrote:
> When unmapping VM_PFNMAP mappings, vm flags need to be updated. Since
> the vmas have been detached, so it sounds safe to update vm flags with
> read mmap_sem.
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  mm/mmap.c | 9 ---------
>  1 file changed, 9 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 490340e..847a17d 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2771,15 +2771,6 @@ static int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  				munlock_vma_pages_all(tmp);
>  			}
>  
> -			/*
> -			 * Unmapping vmas, which have VM_HUGETLB or VM_PFNMAP,

Ah, the comment should have been already updated with the previous
patch. But nevermind as that all goes away.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> -			 * need get done with write mmap_sem held since they may
> -			 * update vm_flags.
> -			 */
> -			if (downgrade &&
> -			    (tmp->vm_flags & VM_PFNMAP))
> -				downgrade = false;
> -
>  			tmp = tmp->vm_next;
>  		}
>  	}
> 
