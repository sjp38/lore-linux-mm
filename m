Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6DA26B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 03:56:21 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q132so732521wmd.22
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 00:56:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l78si6166208wma.227.2017.10.02.00.56.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 00:56:20 -0700 (PDT)
Date: Mon, 2 Oct 2017 09:56:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] writeback: remove unused parameter from
 balance_dirty_pages()
Message-ID: <20171002075616.mro36ci7gk5k6vbc@dhcp22.suse.cz>
References: <20170927221311.23263-1-tahsin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927221311.23263-1-tahsin@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tahsin Erdogan <tahsin@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jeff Layton <jlayton@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Theodore Ts'o <tytso@mit.edu>, Nikolay Borisov <nborisov@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 27-09-17 15:13:11, Tahsin Erdogan wrote:
> "mapping" parameter to balance_dirty_pages() is not used anymore.
> 
> Fixes: dfb8ae567835 ("writeback: let balance_dirty_pages() work on the matching cgroup bdi_writeback")

balance_dirty_pages_ratelimited doesn't really need mapping as well. All
it needs is the inode and we already have it in callers. So would it
make sense to refactor a bit further and make its argument an inode?

> Signed-off-by: Tahsin Erdogan <tahsin@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page-writeback.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 0b9c5cbe8eba..d89663f00e93 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1559,8 +1559,7 @@ static inline void wb_dirty_limits(struct dirty_throttle_control *dtc)
>   * If we're over `background_thresh' then the writeback threads are woken to
>   * perform some writeout.
>   */
> -static void balance_dirty_pages(struct address_space *mapping,
> -				struct bdi_writeback *wb,
> +static void balance_dirty_pages(struct bdi_writeback *wb,
>  				unsigned long pages_dirtied)
>  {
>  	struct dirty_throttle_control gdtc_stor = { GDTC_INIT(wb) };
> @@ -1910,7 +1909,7 @@ void balance_dirty_pages_ratelimited(struct address_space *mapping)
>  	preempt_enable();
>  
>  	if (unlikely(current->nr_dirtied >= ratelimit))
> -		balance_dirty_pages(mapping, wb, current->nr_dirtied);
> +		balance_dirty_pages(wb, current->nr_dirtied);
>  
>  	wb_put(wb);
>  }
> -- 
> 2.14.2.822.g60be5d43e6-goog
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
