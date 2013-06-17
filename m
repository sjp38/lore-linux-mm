Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 832006B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 08:56:01 -0400 (EDT)
Date: Mon, 17 Jun 2013 14:55:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Clear page active before releasing pages
Message-ID: <20130617125559.GA8853@dhcp22.suse.cz>
References: <20130617085439.GF1875@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130617085439.GF1875@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 17-06-13 09:54:39, Mel Gorman wrote:
> Active pages should not be freed to the page allocator as it triggers
> a bad page state warning. Fengguang Wu reported the following
> bug and bisected it to the patch "mm: remove lru parameter from
> __lru_cache_add and lru_cache_add_lru" which is currently in mmotm as
> mm-remove-lru-parameter-from-__lru_cache_add-and-lru_cache_add_lru.patch
> 
> [   84.212960] BUG: Bad page state in process rm  pfn:0b0c9
> [   84.214682] page:ffff88000d646240 count:0 mapcount:0 mapping:          (null) index:0x0
> [   84.216883] page flags: 0x20000000004c(referenced|uptodate|active)
> [   84.218697] CPU: 1 PID: 283 Comm: rm Not tainted 3.10.0-rc4-04361-geeb9bfc #49
> [   84.220729]  ffff88000d646240 ffff88000d179bb8 ffffffff82562956 ffff88000d179bd8
> [   84.223242]  ffffffff811333f1 000020000000004c ffff88000d646240 ffff88000d179c28
> [   84.225387]  ffffffff811346a4 ffff880000270000 0000000000000000 0000000000000006
> [   84.227294] Call Trace:
> [   84.227867]  [<ffffffff82562956>] dump_stack+0x27/0x30
> [   84.229045]  [<ffffffff811333f1>] bad_page+0x130/0x158
> [   84.230261]  [<ffffffff811346a4>] free_pages_prepare+0x8b/0x1e3
> [   84.231765]  [<ffffffff8113542a>] free_hot_cold_page+0x28/0x1cf
> [   84.233171]  [<ffffffff82585830>] ? _raw_spin_unlock_irqrestore+0x6b/0xc6
> [   84.234822]  [<ffffffff81135b59>] free_hot_cold_page_list+0x30/0x5a
> [   84.236311]  [<ffffffff8113a4ed>] release_pages+0x251/0x267
> [   84.237653]  [<ffffffff8112a88d>] ? delete_from_page_cache+0x48/0x9e
> [   84.239142]  [<ffffffff8113ad93>] __pagevec_release+0x2b/0x3d
> [   84.240473]  [<ffffffff8113b45a>] truncate_inode_pages_range+0x1b0/0x7ce
> [   84.242032]  [<ffffffff810e76ab>] ? put_lock_stats.isra.20+0x1c/0x53
> [   84.243480]  [<ffffffff810e77f5>] ? lock_release_holdtime+0x113/0x11f
> [   84.244935]  [<ffffffff8113ba8c>] truncate_inode_pages+0x14/0x1d
> [   84.246337]  [<ffffffff8119b3ef>] evict+0x11f/0x232
> [   84.247501]  [<ffffffff8119c527>] iput+0x1a5/0x218
> [   84.248607]  [<ffffffff8118f015>] do_unlinkat+0x19b/0x25a
> [   84.249828]  [<ffffffff810ea993>] ? trace_hardirqs_on_caller+0x210/0x2ce
> [   84.251382]  [<ffffffff8144372e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [   84.252879]  [<ffffffff8118f10d>] SyS_unlinkat+0x39/0x4c
> [   84.254174]  [<ffffffff825874d6>] system_call_fastpath+0x1a/0x1f
> [   84.255596] Disabling lock debugging due to kernel taint
> 
> The problem was that a page marked for activation was released via
> pagevec. This patch clears the active bit before freeing in this case.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reported-and-Tested-by: Fengguang Wu <fengguang.wu@intel.com>

Yes it fixes a flood of "Bad page state" messages I was seeing during
boot while testing my patches on top of mm tree. I just didn't get to
reporting the issue as there seem to be more of them. I will report
others after I have some more specifics.

That being said feel free to add my
Tested-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/swap.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index ac23602..4a1d0d2 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -739,6 +739,9 @@ void release_pages(struct page **pages, int nr, int cold)
>  			del_page_from_lru_list(page, lruvec, page_off_lru(page));
>  		}
>  
> +		/* Clear Active bit in case of parallel mark_page_accessed */
> +		ClearPageActive(page);
> +
>  		list_add(&page->lru, &pages_to_free);
>  	}
>  	if (zone)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
