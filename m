Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id CF7406B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 06:29:20 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so8612990pbc.1
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 03:29:20 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131015001214.GD3432@hippobay.mtv.corp.google.com>
References: <20131015001214.GD3432@hippobay.mtv.corp.google.com>
Subject: RE: [PATCH 03/12] mm, thp, tmpfs: handle huge page cases in
 shmem_getpage_gfp
Content-Transfer-Encoding: 7bit
Message-Id: <20131015102912.2BC99E0090@blue.fi.intel.com>
Date: Tue, 15 Oct 2013 13:29:12 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> We don't support huge page when page is moved from page cache to swap.
> So in this function, we enable huge page handling in two case:
> 
> 1) when a huge page is found in the page cache,
> 2) or we need to alloc a huge page for page cache
> 
> We have to refactor all the calls to shmem_getpages to simplify the job
> of caller. Right now shmem_getpage does:
> 
> 1) simply request a page, default as a small page
> 2) or caller specify a flag to request either a huge page or a small page,
> then leave the caller to decide how to use it
> 
> Signed-off-by: Ning Qu <quning@gmail.com>
> ---
>  mm/shmem.c | 139 +++++++++++++++++++++++++++++++++++++++++++++++--------------
>  1 file changed, 108 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 447bd14..8fe17dd 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -115,15 +115,43 @@ static unsigned long shmem_default_max_inodes(void)
>  static bool shmem_should_replace_page(struct page *page, gfp_t gfp);
>  static int shmem_replace_page(struct page **pagep, gfp_t gfp,
>  				struct shmem_inode_info *info, pgoff_t index);
> +
>  static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
> -	struct page **pagep, enum sgp_type sgp, gfp_t gfp, int *fault_type);
> +	struct page **pagep, enum sgp_type sgp, gfp_t gfp, int flags,
> +	int *fault_type);
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
> +static inline int shmem_getpage(struct inode *inode, pgoff_t index,
> +	struct page **pagep, enum sgp_type sgp, gfp_t gfp, int flags,
> +	int *fault_type)
> +{
> +	int ret = 0;
> +	struct page *page = NULL;
>  
> +	if ((flags & AOP_FLAG_TRANSHUGE) &&
> +	    mapping_can_have_hugepages(inode->i_mapping)) {

I don't think we need ifdef here. mapping_can_have_hugepages() will be 0
compile-time, if CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE is not defined and
compiler should optimize out thp case.

> @@ -1298,27 +1348,37 @@ repeat:
>  				error = -ENOSPC;
>  				goto unacct;
>  			}
> -			percpu_counter_inc(&sbinfo->used_blocks);
>  		}
>  
> -		page = shmem_alloc_page(gfp, info, index);
> +		if (must_use_thp) {
> +			page = shmem_alloc_hugepage(gfp, info, index);
> +			if (page) {
> +				count_vm_event(THP_WRITE_ALLOC);
> +				nr = hpagecache_nr_pages(page);

nr = hpagecache_nr_pages(page) can be moved below if (must_use_thp).
hpagecache_nr_pages(page) evaluates to 0 for small pages.


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
