Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9806B0069
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 18:56:25 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so135600193pgc.1
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 15:56:25 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id l7si12864330plg.100.2016.11.24.15.56.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 15:56:24 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id p66so4278898pga.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 15:56:24 -0800 (PST)
Subject: Re: [PATCH 1/5] mm: migrate: Add mode parameter to support additional
 page copy routines.
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-2-zi.yan@sent.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <dbb93172-4dd1-e88e-f65d-321ac7882999@gmail.com>
Date: Fri, 25 Nov 2016 10:56:16 +1100
MIME-Version: 1.0
In-Reply-To: <20161122162530.2370-2-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>



On 23/11/16 03:25, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> From: Zi Yan <ziy@nvidia.com>
> 
> migrate_page_copy() and copy_huge_page() are affected.
> 
> Signed-off-by: Zi Yan <ziy@nvidia.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  fs/aio.c                |  2 +-
>  fs/hugetlbfs/inode.c    |  2 +-
>  fs/ubifs/file.c         |  2 +-
>  include/linux/migrate.h |  6 ++++--
>  mm/migrate.c            | 14 ++++++++------
>  5 files changed, 15 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/aio.c b/fs/aio.c
> index 428484f..a67c764 100644
> --- a/fs/aio.c
> +++ b/fs/aio.c
> @@ -418,7 +418,7 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
>  	 * events from being lost.
>  	 */
>  	spin_lock_irqsave(&ctx->completion_lock, flags);
> -	migrate_page_copy(new, old);
> +	migrate_page_copy(new, old, 0);

Can we have a useful enum instead of 0, its harder to read and understand
0

>  	BUG_ON(ctx->ring_pages[idx] != old);
>  	ctx->ring_pages[idx] = new;
>  	spin_unlock_irqrestore(&ctx->completion_lock, flags);
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 4fb7b10..a17bfef 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -850,7 +850,7 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
>  	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
>  	if (rc != MIGRATEPAGE_SUCCESS)
>  		return rc;
> -	migrate_page_copy(newpage, page);
> +	migrate_page_copy(newpage, page, 0);

Ditto

>  
>  	return MIGRATEPAGE_SUCCESS;
>  }
> diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
> index b4fbeef..bf54e32 100644
> --- a/fs/ubifs/file.c
> +++ b/fs/ubifs/file.c
> @@ -1468,7 +1468,7 @@ static int ubifs_migrate_page(struct address_space *mapping,
>  		SetPagePrivate(newpage);
>  	}
>  
> -	migrate_page_copy(newpage, page);
> +	migrate_page_copy(newpage, page, 0);

Here as well


Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
