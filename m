Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3CA6B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 19:40:03 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s8-v6so6873225pgf.0
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 16:40:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q62-v6si6772120pgq.297.2018.04.30.16.40.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 16:40:02 -0700 (PDT)
Date: Mon, 30 Apr 2018 16:40:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v5 PATCH] mm: shmem: make stat.st_blksize return huge page
 size if THP is on
Message-Id: <20180430164000.00f92084ecb1876e481c6a11@linux-foundation.org>
In-Reply-To: <1524665633-83806-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1524665633-83806-1-git-send-email-yang.shi@linux.alibaba.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, mhocko@kernel.org, hch@infradead.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>

On Wed, 25 Apr 2018 22:13:53 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> Since tmpfs THP was supported in 4.8, hugetlbfs is not the only
> filesystem with huge page support anymore. tmpfs can use huge page via
> THP when mounting by "huge=" mount option.
> 
> When applications use huge page on hugetlbfs, it just need check the
> filesystem magic number, but it is not enough for tmpfs. Make
> stat.st_blksize return huge page size if it is mounted by appropriate
> "huge=" option to give applications a hint to optimize the behavior with
> THP.
> 
> Some applications may not do wisely with THP. For example, QEMU may mmap
> file on non huge page aligned hint address with MAP_FIXED, which results
> in no pages are PMD mapped even though THP is used. Some applications
> may mmap file with non huge page aligned offset. Both behaviors make THP
> pointless.
> 
> statfs.f_bsize still returns 4KB for tmpfs since THP could be split, and it
> also may fallback to 4KB page silently if there is not enough huge page.
> Furthermore, different f_bsize makes max_blocks and free_blocks
> calculation harder but without too much benefit. Returning huge page
> size via stat.st_blksize sounds good enough.
> 
> Since PUD size huge page for THP has not been supported, now it just
> returns HPAGE_PMD_SIZE.
> 
> ...
>
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -571,6 +571,16 @@ static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGE_PAGECACHE */
>  
> +static inline bool is_huge_enabled(struct shmem_sb_info *sbinfo)
> +{
> +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
> +	    (shmem_huge == SHMEM_HUGE_FORCE || sbinfo->huge) &&
> +	    shmem_huge != SHMEM_HUGE_DENY)
> +		return true;
> +	else
> +		return false;
> +}

Nit: we don't need that `else'.  Checkpatch normally warns about this,
but not in this case.

--- a/mm/shmem.c~mm-shmem-make-statst_blksize-return-huge-page-size-if-thp-is-on-fix
+++ a/mm/shmem.c
@@ -577,8 +577,7 @@ static inline bool is_huge_enabled(struc
 	    (shmem_huge == SHMEM_HUGE_FORCE || sbinfo->huge) &&
 	    shmem_huge != SHMEM_HUGE_DENY)
 		return true;
-	else
-		return false;
+	return false;
 }
 
 /*
_
