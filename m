Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id BB3F66B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 06:33:43 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so8701811pad.7
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 03:33:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131015001228.GE3432@hippobay.mtv.corp.google.com>
References: <20131015001228.GE3432@hippobay.mtv.corp.google.com>
Subject: RE: [PATCH 04/12] mm, thp, tmpfs: split huge page when moving from
 page cache to swap
Content-Transfer-Encoding: 7bit
Message-Id: <20131015103334.E3877E0090@blue.fi.intel.com>
Date: Tue, 15 Oct 2013 13:33:34 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> in shmem_writepage, we have to split the huge page when moving pages
> from page cache to swap because we don't support huge page in swap
> yet.
> 
> Signed-off-by: Ning Qu <quning@gmail.com>
> ---
>  mm/shmem.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 8fe17dd..68a0e1d 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -898,6 +898,13 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
>  	swp_entry_t swap;
>  	pgoff_t index;
>  
> +	/* TODO: we have to break the huge page at this point,
> +	 * since we have no idea how to recover a huge page from
> +	 * swap.
> +	 */
> +	if (PageTransCompound(page))
> +		split_huge_page(compound_trans_head(page));
> +

After the split you handle here only first small page of the huge page.
Is it what we want to do? Should we swap out all small pages of the huge
page?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
