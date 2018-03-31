Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 31CEF6B0270
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 20:17:39 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i205-v6so8985511ita.3
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 17:17:39 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m11si6981967iog.120.2018.03.30.17.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Mar 2018 17:17:38 -0700 (PDT)
Subject: Re: [PATCH v10 44/62] memfd: Convert shmem_wait_for_pins to XArray
References: <20180330034245.10462-1-willy@infradead.org>
 <20180330034245.10462-45-willy@infradead.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <4b70ad17-a176-9510-5525-30da01eba18e@oracle.com>
Date: Fri, 30 Mar 2018 17:07:34 -0700
MIME-Version: 1.0
In-Reply-To: <20180330034245.10462-45-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>

On 03/29/2018 08:42 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> As with shmem_tag_pins(), hold the lock around the entire loop instead
> of acquiring & dropping it for each entry we're going to untag.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Same comments as with with the previous shmem_tag_pins patch.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

> ---
>  mm/memfd.c | 61 +++++++++++++++++++++++++------------------------------------
>  1 file changed, 25 insertions(+), 36 deletions(-)
> 
> diff --git a/mm/memfd.c b/mm/memfd.c
> index 3b299d72df78..0e0835e63af2 100644
> --- a/mm/memfd.c
> +++ b/mm/memfd.c
> @@ -64,9 +64,7 @@ static void shmem_tag_pins(struct address_space *mapping)
>   */
>  static int shmem_wait_for_pins(struct address_space *mapping)
>  {
> -	struct radix_tree_iter iter;
> -	void __rcu **slot;
> -	pgoff_t start;
> +	XA_STATE(xas, &mapping->i_pages, 0);
>  	struct page *page;
>  	int error, scan;
>  
> @@ -74,7 +72,9 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>  
>  	error = 0;
>  	for (scan = 0; scan <= LAST_SCAN; scan++) {
> -		if (!radix_tree_tagged(&mapping->i_pages, SHMEM_TAG_PINNED))
> +		unsigned int tagged = 0;
> +
> +		if (!xas_tagged(&xas, SHMEM_TAG_PINNED))
>  			break;
>  
>  		if (!scan)
> @@ -82,45 +82,34 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>  		else if (schedule_timeout_killable((HZ << scan) / 200))
>  			scan = LAST_SCAN;
>  
> -		start = 0;
> -		rcu_read_lock();
> -		radix_tree_for_each_tagged(slot, &mapping->i_pages, &iter,
> -					   start, SHMEM_TAG_PINNED) {
> -
> -			page = radix_tree_deref_slot(slot);
> -			if (radix_tree_exception(page)) {
> -				if (radix_tree_deref_retry(page)) {
> -					slot = radix_tree_iter_retry(&iter);
> -					continue;
> -				}
> -
> -				page = NULL;
> -			}
> -
> -			if (page &&
> -			    page_count(page) - page_mapcount(page) != 1) {
> -				if (scan < LAST_SCAN)
> -					goto continue_resched;
> -
> +		xas_set(&xas, 0);
> +		xas_lock_irq(&xas);
> +		xas_for_each_tag(&xas, page, ULONG_MAX, SHMEM_TAG_PINNED) {
> +			bool clear = true;
> +			if (xa_is_value(page))
> +				continue;
> +			if (page_count(page) - page_mapcount(page) != 1) {
>  				/*
>  				 * On the last scan, we clean up all those tags
>  				 * we inserted; but make a note that we still
>  				 * found pages pinned.
>  				 */
> -				error = -EBUSY;
> -			}
> -
> -			xa_lock_irq(&mapping->i_pages);
> -			radix_tree_tag_clear(&mapping->i_pages,
> -					     iter.index, SHMEM_TAG_PINNED);
> -			xa_unlock_irq(&mapping->i_pages);
> -continue_resched:
> -			if (need_resched()) {
> -				slot = radix_tree_iter_resume(slot, &iter);
> -				cond_resched_rcu();
> +				if (scan == LAST_SCAN)
> +					error = -EBUSY;
> +				else
> +					clear = false;
>  			}
> +			if (clear)
> +				xas_clear_tag(&xas, SHMEM_TAG_PINNED);
> +			if (++tagged % XA_CHECK_SCHED)
> +				continue;
> +
> +			xas_pause(&xas);
> +			xas_unlock_irq(&xas);
> +			cond_resched();
> +			xas_lock_irq(&xas);
>  		}
> -		rcu_read_unlock();
> +		xas_unlock_irq(&xas);
>  	}
>  
>  	return error;
> 
