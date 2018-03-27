Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7276B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 20:29:06 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c42-v6so10000143itf.2
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 17:29:06 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q63si12327099ioi.240.2018.03.26.17.29.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 17:29:04 -0700 (PDT)
Date: Mon, 26 Mar 2018 17:28:41 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v9 05/61] Export __set_page_dirty
Message-ID: <20180327002841.GI4807@magnolia>
References: <20180313132639.17387-1-willy@infradead.org>
 <20180313132639.17387-6-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313132639.17387-6-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Tue, Mar 13, 2018 at 06:25:43AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> XFS currently contains a copy-and-paste of __set_page_dirty().  Export
> it from buffer.c instead.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Acked-by: Jeff Layton <jlayton@kernel.org>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/buffer.c        |  3 ++-
>  fs/xfs/xfs_aops.c  | 15 ++-------------
>  include/linux/mm.h |  1 +
>  3 files changed, 5 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 17f13191a552..62bf5445c921 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -594,7 +594,7 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
>   *
>   * The caller must hold lock_page_memcg().
>   */
> -static void __set_page_dirty(struct page *page, struct address_space *mapping,
> +void __set_page_dirty(struct page *page, struct address_space *mapping,
>  			     int warn)
>  {
>  	unsigned long flags;
> @@ -608,6 +608,7 @@ static void __set_page_dirty(struct page *page, struct address_space *mapping,
>  	}
>  	spin_unlock_irqrestore(&mapping->tree_lock, flags);
>  }
> +EXPORT_SYMBOL_GPL(__set_page_dirty);
>  
>  /*
>   * Add a page to the dirty page list.
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index a0afb6411417..f51350cb98a7 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -1473,19 +1473,8 @@ xfs_vm_set_page_dirty(
>  	newly_dirty = !TestSetPageDirty(page);
>  	spin_unlock(&mapping->private_lock);
>  
> -	if (newly_dirty) {
> -		/* sigh - __set_page_dirty() is static, so copy it here, too */
> -		unsigned long flags;
> -
> -		spin_lock_irqsave(&mapping->tree_lock, flags);
> -		if (page->mapping) {	/* Race with truncate? */
> -			WARN_ON_ONCE(!PageUptodate(page));
> -			account_page_dirtied(page, mapping);
> -			radix_tree_tag_set(&mapping->page_tree,
> -					page_index(page), PAGECACHE_TAG_DIRTY);
> -		}
> -		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> -	}
> +	if (newly_dirty)
> +		__set_page_dirty(page, mapping, 1);
>  	unlock_page_memcg(page);
>  	if (newly_dirty)
>  		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4d02524a7998..7f7bb4c28497 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1456,6 +1456,7 @@ extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
>  extern void do_invalidatepage(struct page *page, unsigned int offset,
>  			      unsigned int length);
>  
> +void __set_page_dirty(struct page *, struct address_space *, int warn);
>  int __set_page_dirty_nobuffers(struct page *page);
>  int __set_page_dirty_no_writeback(struct page *page);
>  int redirty_page_for_writepage(struct writeback_control *wbc,
> -- 
> 2.16.1
> 
