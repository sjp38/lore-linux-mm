Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9AC82F65
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 17:36:53 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so32519817pad.1
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 14:36:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xp4si7941735pbc.180.2015.10.20.14.36.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 14:36:52 -0700 (PDT)
Date: Tue, 20 Oct 2015 14:36:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] MADV_FREE refactoring and fix KSM page
Message-Id: <20151020143651.64ce2c459cda168c714caf93@linux-foundation.org>
In-Reply-To: <20151020072109.GD2941@bbox>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
	<20151019100150.GA5194@bbox>
	<20151020072109.GD2941@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Tue, 20 Oct 2015 16:21:09 +0900 Minchan Kim <minchan@kernel.org> wrote:

> 
> I reviewed THP refcount redesign patch and It seems below patch fixes
> MADV_FREE problem. It works well for hours.
> 
> >From 104a0940b4c0f97e61de9fee0fd602926ff28312 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Tue, 20 Oct 2015 16:00:52 +0900
> Subject: [PATCH] mm: mark head page dirty in split_huge_page
> 
> In thp split in old THP refcount, we mappped all of pages
> (ie, head + tails) to pte_mkdirty and mark PG_flags to every
> tail pages.
> 
> But with THP refcount redesign, we can lose dirty bit in page table
> and PG_dirty for head page if we want to free the THP page using
> migration_entry.
> 
> It ends up discarding head page by madvise_free suddenly.
> This patch fixes it by mark the head page PG_dirty when VM splits
> the THP page.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/huge_memory.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index adccfb48ce57..7fbbd42554a1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -3258,6 +3258,7 @@ static void __split_huge_page(struct page *page, struct list_head *list)
>  	atomic_sub(tail_mapcount, &head->_count);
>  
>  	ClearPageCompound(head);
> +	SetPageDirty(head);
>  	spin_unlock_irq(&zone->lru_lock);
>  
>  	unfreeze_page(page_anon_vma(head), head);

This appears to be a bugfix against Kirill's "thp: reintroduce
split_huge_page()"?

Yes, __split_huge_page() is marking the tail pages dirty but forgot
about the head page

You say "we can lose dirty bit in page table" but I don't see how the
above patch fixes that?


Why does __split_huge_page() unconditionally mark the pages dirty, btw?
Is it because the THP page was known to be dirty?  If so, the head
page already had PG_dirty, so this patch doesn't do anything.

freeze_page(), unfreeze_page() and their callees desperately need some
description of what they're doing.  Kirill, could you cook somethnig up
please?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
