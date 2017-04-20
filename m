Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85ED22806EA
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 08:32:42 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l132so28711665oia.10
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 05:32:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31si6363746plz.70.2017.04.20.05.32.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 05:32:41 -0700 (PDT)
Date: Thu, 20 Apr 2017 14:32:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: prevent NR_ISOLATE_* stats from going negative
Message-ID: <20170420123234.GF15781@dhcp22.suse.cz>
References: <1492683865-27549-1-git-send-email-rabin.vincent@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1492683865-27549-1-git-send-email-rabin.vincent@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rabin Vincent <rabin.vincent@axis.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>, Ming Ling <ming.ling@spreadtrum.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org

On Thu 20-04-17 12:24:25, Rabin Vincent wrote:
> From: Rabin Vincent <rabinv@axis.com>
> 
> Commit 6afcf8ef0ca0 ("mm, compaction: fix NR_ISOLATED_* stats for pfn
> based migration") moved the dec_node_page_state() call (along with the
> page_is_file_cache() call) to after putback_lru_page().  But
> page_is_file_cache() can change after putback_lru_page() is called, so
> it should be called before putback_lru_page(), as it was before that
> patch, to prevent NR_ISOLATE_* stats from going negative.
> 
> Without this fix, non-CONFIG_SMP kernels end up hanging in the
> while(too_many_isolated()) { congestion_wait() } loop in
> shrink_active_list() due to the negative stats.
> 
>  Mem-Info:
>   active_anon:32567 inactive_anon:121 isolated_anon:1
>   active_file:6066 inactive_file:6639 isolated_file:4294967295
>                                                     ^^^^^^^^^^
>   unevictable:0 dirty:115 writeback:0 unstable:0
>   slab_reclaimable:2086 slab_unreclaimable:3167
>   mapped:3398 shmem:18366 pagetables:1145 bounce:0
>   free:1798 free_pcp:13 free_cma:0
> 
> Fixes: 6afcf8ef0ca0 ("mm, compaction: fix NR_ISOLATED_* stats for pfn based migration")
> Cc: Ming Ling <ming.ling@spreadtrum.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Rabin Vincent <rabinv@axis.com>

Thanks for catching and fixing this. This is definitely my fault whe
reworking Ming's original patch

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/migrate.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index ed97c2c..738f1d5 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -184,9 +184,9 @@ void putback_movable_pages(struct list_head *l)
>  			unlock_page(page);
>  			put_page(page);
>  		} else {
> -			putback_lru_page(page);
>  			dec_node_page_state(page, NR_ISOLATED_ANON +
>  					page_is_file_cache(page));
> +			putback_lru_page(page);
>  		}
>  	}
>  }
> -- 
> 2.7.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
