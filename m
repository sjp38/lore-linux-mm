Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 980A96B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 07:02:03 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so8679788pbb.28
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 04:02:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131015001304.GH3432@hippobay.mtv.corp.google.com>
References: <20131015001304.GH3432@hippobay.mtv.corp.google.com>
Subject: RE: [PATCH 07/12] mm, thp, tmpfs: handle huge page in
 shmem_undo_range for truncate
Content-Transfer-Encoding: 7bit
Message-Id: <20131015110146.7E8BEE0090@blue.fi.intel.com>
Date: Tue, 15 Oct 2013 14:01:46 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> When comes to truncate file, add support to handle huge page in the
> truncate range.
> 
> Signed-off-by: Ning Qu <quning@gmail.com>
> ---
>  mm/shmem.c | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 86 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 0a423a9..90f2e0e 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -559,6 +559,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
>  	struct shmem_inode_info *info = SHMEM_I(inode);
>  	pgoff_t start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
>  	pgoff_t end = (lend + 1) >> PAGE_CACHE_SHIFT;
> +	/* Whether we have to do partial truncate */
>  	unsigned int partial_start = lstart & (PAGE_CACHE_SIZE - 1);
>  	unsigned int partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
>  	struct pagevec pvec;
> @@ -570,12 +571,16 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
>  	if (lend == -1)
>  		end = -1;	/* unsigned, so actually very big */
>  
> +	i_split_down_read(inode);
>  	pagevec_init(&pvec, 0);
>  	index = start;
>  	while (index < end) {
> +		bool thp = false;
> +
>  		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
>  				min(end - index, (pgoff_t)PAGEVEC_SIZE),
>  							pvec.pages, indices);
> +
>  		if (!pvec.nr)
>  			break;
>  		mem_cgroup_uncharge_start();
> @@ -586,6 +591,25 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
>  			if (index >= end)
>  				break;
>  
> +			thp = PageTransHugeCache(page);
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE

Again. Here and below ifdef is redundant: PageTransHugeCache() is zero
compile-time and  thp case will be optimize out.

And do we really need a copy of truncate logic here? Is there a way to
share code?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
