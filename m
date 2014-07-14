Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E70D36B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 15:59:26 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so2986123pab.26
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 12:59:26 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id ss10si9902999pab.209.2014.07.14.12.59.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 12:59:26 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so1415685pdj.14
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 12:59:25 -0700 (PDT)
Date: Mon, 14 Jul 2014 12:57:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 2/3] mm: memcontrol: rewrite uncharge API fix - double
 migration
In-Reply-To: <1404759133-29218-3-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1407141246340.17669@eggly.anvils>
References: <1404759133-29218-1-git-send-email-hannes@cmpxchg.org> <1404759133-29218-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 7 Jul 2014, Johannes Weiner wrote:

> Hugh reports:
> 
> VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM))
> mm/memcontrol.c:6680!
> page had count 1 mapcount 0 mapping anon index 0x196
> flags locked uptodate reclaim swapbacked, pcflags 1, memcg not root
> mem_cgroup_migrate < move_to_new_page < migrate_pages < compact_zone <
> compact_zone_order < try_to_compact_pages < __alloc_pages_direct_compact <
> __alloc_pages_nodemask < alloc_pages_vma < do_huge_pmd_anonymous_page <
> handle_mm_fault < __do_page_fault
> 
> mem_cgroup_migrate() assumes that a page is only migrated once and
> then freed immediately after.
> 
> However, putting the page back on the LRU list and dropping the
> isolation refcount is not done atomically.  This allows a PFN-based
> migrator like compaction to isolate the page, see the expected
> anonymous page refcount of 1, and migrate the page once more.
> 
> Catch pages that have already been migrated and abort migration
> gracefully.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1e3b27f8dc2f..e4afdbdda0a7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6653,7 +6653,10 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  	if (!PageCgroupUsed(pc))
>  		return;
>  
> -	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
> +	/* Already migrated */
> +	if (!(pc->flags & PCG_MEM))
> +		return;
> +

I am curious why you chose to fix the BUG in this way, instead of
-	pc->flags &= ~(PCG_MEM | PCG_MEMSW);
+	pc->flags = 0;
a few lines further down.

The page that gets left behind with just PCG_USED is anomalous (for an
LRU page, maybe not for a kmem page), isn'it it?  And liable to cause
other problems.

For example, won't it go the wrong way in the "Surreptitiously" test
in mem_cgroup_page_lruvec(): the page no longer has a hold on any
memcg, so is in a danger of being placed on a gone-memcg's LRU?

Hugh

>  	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
>  	pc->flags &= ~(PCG_MEM | PCG_MEMSW);
>  
> -- 
> 2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
