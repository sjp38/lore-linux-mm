Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 258FF6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 06:37:53 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so8769980pab.40
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 03:37:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131015001242.GF3432@hippobay.mtv.corp.google.com>
References: <20131015001242.GF3432@hippobay.mtv.corp.google.com>
Subject: RE: [PATCH 05/12] mm, thp, tmpfs: request huge page in shm_fault when
 needed
Content-Transfer-Encoding: 7bit
Message-Id: <20131015103744.A0BD3E0090@blue.fi.intel.com>
Date: Tue, 15 Oct 2013 13:37:44 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> Add the function to request huge page in shm_fault when needed.
> And it will fall back to regular page if huge page can't be
> satisfied or allocated.
> 
> If small page requested but huge page is found, the huge page will
> be splitted.
> 
> Signed-off-by: Ning Qu <quning@gmail.com>
> ---
>  mm/shmem.c | 32 +++++++++++++++++++++++++++++---
>  1 file changed, 29 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 68a0e1d..2fc450d 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1472,19 +1472,45 @@ unlock:
>  static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	struct inode *inode = file_inode(vma->vm_file);
> +	struct page *page = NULL;
>  	int error;
>  	int ret = VM_FAULT_LOCKED;
>  	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
> -
> -	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, gfp,
> -				0, &ret);
> +	bool must_use_thp = vmf->flags & FAULT_FLAG_TRANSHUGE;
> +	int flags = 0;
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
> +	flags |= AOP_FLAG_TRANSHUGE;
> +#endif

ifdef is not needed: shmem_getpage will ignore AOP_FLAG_TRANSHUGE if
CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE is not defined.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
