Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 89C8A440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 15:11:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u23so5838937wma.14
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 12:11:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 96si4899213wrk.320.2017.07.13.12.11.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Jul 2017 12:11:57 -0700 (PDT)
Subject: Re: [PATCH] mm/mremap: Fail map duplication attempts for private
 mappings
References: <1499961495-8063-1-git-send-email-mike.kravetz@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4e921eb5-8741-3337-9a7d-5ec9473412da@suse.cz>
Date: Thu, 13 Jul 2017 21:11:08 +0200
MIME-Version: 1.0
In-Reply-To: <1499961495-8063-1-git-send-email-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Linux API <linux-api@vger.kernel.org>

[+CC linux-api]

On 07/13/2017 05:58 PM, Mike Kravetz wrote:
> mremap will create a 'duplicate' mapping if old_size == 0 is
> specified.  Such duplicate mappings make no sense for private
> mappings.  If duplication is attempted for a private mapping,
> mremap creates a separate private mapping unrelated to the
> original mapping and makes no modifications to the original.
> This is contrary to the purpose of mremap which should return
> a mapping which is in some way related to the original.
> 
> Therefore, return EINVAL in the case where if an attempt is
> made to duplicate a private mapping.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/mremap.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index cd8a1b1..076f506 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -383,6 +383,13 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
>  	if (!vma || vma->vm_start > addr)
>  		return ERR_PTR(-EFAULT);
>  
> +	/*
> +	 * !old_len  is a special case where a mapping is 'duplicated'.
> +	 * Do not allow this for private mappings.
> +	 */
> +	if (!old_len && !(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)))
> +		return ERR_PTR(-EINVAL);
> +
>  	if (is_vm_hugetlb_page(vma))
>  		return ERR_PTR(-EINVAL);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
