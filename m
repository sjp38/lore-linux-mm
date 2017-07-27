Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91AE86B04B9
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 15:10:43 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id t139so268278717ywg.6
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:10:43 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p15si4754601ybe.101.2017.07.27.12.10.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 12:10:41 -0700 (PDT)
Subject: Re: [PATCH 07/10] hugetlbfs: Use pagevec_lookup_range() in
 remove_inode_hugepages()
References: <20170726114704.7626-1-jack@suse.cz>
 <20170726114704.7626-8-jack@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <37d1740a-5ec4-1383-e862-a69ce6456353@oracle.com>
Date: Thu, 27 Jul 2017 12:10:34 -0700
MIME-Version: 1.0
In-Reply-To: <20170726114704.7626-8-jack@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Nadia Yvette Chambers <nyc@holomorphy.com>

On 07/26/2017 04:47 AM, Jan Kara wrote:
> We want only pages from given range in remove_inode_hugepages(). Use
> pagevec_lookup_range() instead of pagevec_lookup().
> 
> CC: Nadia Yvette Chambers <nyc@holomorphy.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Nice.  I like the new interface.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

> ---
>  fs/hugetlbfs/inode.c | 18 ++----------------
>  1 file changed, 2 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index b9678ce91e25..8931236f3ef4 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -403,7 +403,6 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>  	struct pagevec pvec;
>  	pgoff_t next, index;
>  	int i, freed = 0;
> -	long lookup_nr = PAGEVEC_SIZE;
>  	bool truncate_op = (lend == LLONG_MAX);
>  
>  	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
> @@ -412,30 +411,17 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>  	next = start;
>  	while (next < end) {
>  		/*
> -		 * Don't grab more pages than the number left in the range.
> -		 */
> -		if (end - next < lookup_nr)
> -			lookup_nr = end - next;
> -
> -		/*
>  		 * When no more pages are found, we are done.
>  		 */
> -		if (!pagevec_lookup(&pvec, mapping, &next, lookup_nr))
> +		if (!pagevec_lookup_range(&pvec, mapping, &next, end - 1,
> +					  PAGEVEC_SIZE))
>  			break;
>  
>  		for (i = 0; i < pagevec_count(&pvec); ++i) {
>  			struct page *page = pvec.pages[i];
>  			u32 hash;
>  
> -			/*
> -			 * The page (index) could be beyond end.  This is
> -			 * only possible in the punch hole case as end is
> -			 * max page offset in the truncate case.
> -			 */
>  			index = page->index;
> -			if (index >= end)
> -				break;
> -
>  			hash = hugetlb_fault_mutex_hash(h, current->mm,
>  							&pseudo_vma,
>  							mapping, index, 0);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
