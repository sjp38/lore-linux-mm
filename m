Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68052800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 01:13:46 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id n19so12139072iob.7
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 22:13:46 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t193sor2512745iof.284.2018.01.22.22.13.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 22:13:45 -0800 (PST)
Date: Tue, 23 Jan 2018 15:13:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Pin address_space before dereferencing it while
 isolating an LRU page
Message-ID: <20180123061338.cpsmhih2cvbo4gr6@bbox-2.seo.corp.google.com>
References: <20180104102512.2qos3h5vqzeisrek@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180104102512.2qos3h5vqzeisrek@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Huang, Ying" <ying.huang@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 04, 2018 at 10:25:12AM +0000, Mel Gorman wrote:
> Minchan Kim asked the following question -- what locks protects
> address_space destroying when race happens between inode trauncation and
> __isolate_lru_page? Jan Kara clarified by describing the race as follows
> 
> CPU1                                            CPU2
> 
> truncate(inode)                                 __isolate_lru_page()
>   ...
>   truncate_inode_page(mapping, page);
>     delete_from_page_cache(page)
>       spin_lock_irqsave(&mapping->tree_lock, flags);
>         __delete_from_page_cache(page, NULL)
>           page_cache_tree_delete(..)
>             ...                                   mapping = page_mapping(page);
>             page->mapping = NULL;
>             ...
>       spin_unlock_irqrestore(&mapping->tree_lock, flags);
>       page_cache_free_page(mapping, page)
>         put_page(page)
>           if (put_page_testzero(page)) -> false
> - inode now has no pages and can be freed including embedded address_space
> 
>                                                   if (mapping && !mapping->a_ops->migratepage)
> - we've dereferenced mapping which is potentially already free.
> 
> The race is theoritically possible but unlikely. Before the
> delete_from_page_cache, truncate_cleanup_page is called so the page is
> likely to be !PageDirty or PageWriteback which gets skipped by the only
> caller that checks the mappping in __isolate_lru_page. Even if the race
> occurs, a substantial amount of work has to happen during a tiny window
> with no preemption but it could potentially be done using a virtual machine
> to artifically slow one CPU or halt it during the critical window.
> 
> This patch should eliminate the race with truncation by try-locking the page
> before derefencing mapping and aborting if the lock was not acquired. There
> was a suggestion from Huang Ying to use RCU as a side-effect to prevent
> mapping being freed. However, I do not like the solution as it's an
> unconventional means of preserving a mapping and it's not a context where
> rcu_read_lock is obviously protecting rcu data.
> 
> Fixes: c82449352854 ("mm: compaction: make isolate_lru_page() filter-aware again")
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks for the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
