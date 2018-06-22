Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2024F6B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 04:00:00 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z5-v6so3286001pln.20
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 01:00:00 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d14-v6si7421906pln.206.2018.06.22.00.59.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 00:59:58 -0700 (PDT)
Date: Fri, 22 Jun 2018 10:59:58 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [v2 PATCH 1/2] mm: thp: register mm for khugepaged when merging
 vma for shmem
Message-ID: <20180622075958.mzagr2ayufiuokea@black.fi.intel.com>
References: <1529622949-75504-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529622949-75504-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.shi@linux.alibaba.com
Cc: hughd@google.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 21, 2018 at 11:15:48PM +0000, yang.shi@linux.alibaba.com wrote:
> When merging anonymous page vma, if the size of vma can fit in at least
> one hugepage, the mm will be registered for khugepaged for collapsing
> THP in the future.
> 
> But, it skips shmem vma. Doing so for shmem too, but not file-private
> mapping, when merging vma in order to increase the odd to collapse
> hugepage by khugepaged.
> 
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> ---
> v1 --> 2:
> * Exclude file-private mapping per Kirill's comment
> 
>  mm/khugepaged.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index d7b2a4b..9b0ec30 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -440,8 +440,12 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
>  		 * page fault if needed.
>  		 */
>  		return 0;
> -	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
> -		/* khugepaged not yet working on file or special mappings */
> +	if ((vma->vm_ops && (!shmem_file(vma->vm_file) || vma->anon_vma)) ||
> +	    (vm_flags & VM_NO_KHUGEPAGED))
> +		/*
> +		 * khugepaged not yet working on non-shmem file or special
> +		 * mappings. And, file-private shmem THP is not supported.
> +		 */
>  		return 0;

My point was that vma->anon_vma check above this one should not prevent
collapse for shmem.

Looking into this more, I think we should just replace all these checks
with hugepage_vma_check() call.

-- 
 Kirill A. Shutemov
