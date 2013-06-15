Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 533786B0033
	for <linux-mm@kvack.org>; Sat, 15 Jun 2013 03:56:27 -0400 (EDT)
Date: Sat, 15 Jun 2013 15:56:23 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [iput] BUG: Bad page state in process rm pfn:0b0ce
Message-ID: <20130615075623.GA2666@localhost>
References: <20130613102549.GD31394@localhost>
 <20130614091655.GD1875@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130614091655.GD1875@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 14, 2013 at 10:16:55AM +0100, Mel Gorman wrote:
> On Thu, Jun 13, 2013 at 06:25:49PM +0800, Fengguang Wu wrote:
> > Greetings,
> > 
> > I got the below dmesg in linux-next and the first bad commit is
> > 
> 
> Thanks Fengguang.
> 
> Can you try the following please? I do not see the same issue
> unfortunately but I am the wrong type of unlucky here.

Mel, this reliably fixes the problem.

Tested-by: Fengguang Wu <fengguang.wu@intel.com>

Thanks,
Fengguang

> ---8<---
> mm: Clear page active before releasing pages
> 
> Active pages should not be freed to the page allocator as it triggers a
> bad page state warning. Fengguang Wu reported the following bug
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
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
