Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE6786B0003
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 08:13:06 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q65so4544875pga.15
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:13:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i127si4927290pgc.568.2018.03.16.05.13.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Mar 2018 05:13:05 -0700 (PDT)
Date: Fri, 16 Mar 2018 13:13:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/shmem: Do not wait for lock_page() in
 shmem_unused_huge_shrink()
Message-ID: <20180316121303.GI23100@dhcp22.suse.cz>
References: <20180316105908.62516-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180316105908.62516-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Fri 16-03-18 13:59:08, Kirill A. Shutemov wrote:
[..]
> @@ -498,31 +498,42 @@ static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
>  			continue;
>  		}
>  
> -		page = find_lock_page(inode->i_mapping,
> +		page = find_get_page(inode->i_mapping,
>  				(inode->i_size & HPAGE_PMD_MASK) >> PAGE_SHIFT);
>  		if (!page)
>  			goto drop;
>  
> +		/* No huge page at the end of the file: nothing to split */
>  		if (!PageTransHuge(page)) {
> -			unlock_page(page);
>  			put_page(page);
>  			goto drop;
>  		}
>  
> +		/*
> +		 * Leave the inode on the list if we failed to lock
> +		 * the page at this time.
> +		 *
> +		 * Waiting for the lock may lead to deadlock in the
> +		 * reclaim path.
> +		 */
> +		if (!trylock_page(page)) {
> +			put_page(page);
> +			goto leave;
> +		}

Can somebody split the huge page after the PageTransHuge check and
before we lock it?

> +
>  		ret = split_huge_page(page);
>  		unlock_page(page);
>  		put_page(page);
>  
> -		if (ret) {
> -			/* split failed: leave it on the list */
> -			iput(inode);
> -			continue;
> -		}
> +		/* If split failed leave the inode on the list */
> +		if (ret)
> +			goto leave;
>  
>  		split++;
>  drop:
>  		list_del_init(&info->shrinklist);
>  		removed++;
> +leave:
>  		iput(inode);
>  	}
>  
> -- 
> 2.16.1

-- 
Michal Hocko
SUSE Labs
