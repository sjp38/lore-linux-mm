Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 598606B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 15:50:23 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so2311804pbc.24
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 12:50:23 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id bs8si3299896pad.53.2014.04.24.12.50.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 12:50:22 -0700 (PDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so2274504pde.15
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 12:50:22 -0700 (PDT)
Date: Thu, 24 Apr 2014 12:48:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: numa: Add migrated transhuge pages to LRU the same
 way as base pages
In-Reply-To: <20140424153914.GW23991@suse.de>
Message-ID: <alpine.LSU.2.11.1404241238180.3362@eggly.anvils>
References: <1396235259-2394-1-git-send-email-bob.liu@oracle.com> <alpine.LSU.2.11.1404042358030.12542@eggly.anvils> <20140424153914.GW23991@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, sasha.levin@oracle.com, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>, LKML <lkml@vger.kernel.org>

On Thu, 24 Apr 2014, Mel Gorman wrote:

> Migration of misplaced transhuge pages uses page_add_new_anon_rmap() when
> putting the page back as it avoided an atomic operations and added the
> new page to the correct LRU. A side-effect is that the page gets marked
> activated as part of the migration meaning that transhuge and base pages
> are treated differently from an aging perspective than base page migration.
> 
> This patch uses page_add_anon_rmap() and putback_lru_page() on completion of
> a transhuge migration similar to base page migration. It would fewer atomic
> operations to use lru_cache_add without taking an additional reference to the
> page. The downside would be that it's still different to base page migration
> and unevictable pages may be added to the wrong LRU for cleaning up later.
> Testing of the usual workloads did not show any adverse impact to the
> change.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Hugh Dickins <hughd@google.com>

Thanks, Mel: I do feel more comfortable doing it this way, as elsewhere
in migrate.c, whatever the slight drawbacks (I hadn't realized that I
was asking for another get_page, but it's far from the only place where
isolate/putback forces us into that additional superfluous reference:
something to sort out "some other day").  I worried for a bit that you
are doing the putback while holding page lock; but this is not the only
place where that's done (page_remove_rmap may clear_page_mlock though
called under page lock), so no good reason to ask for a change there.

> ---
>  mm/migrate.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index bed4880..6247be7 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1852,7 +1852,7 @@ fail_putback:
>  	 * guarantee the copy is visible before the pagetable update.
>  	 */
>  	flush_cache_range(vma, mmun_start, mmun_end);
> -	page_add_new_anon_rmap(new_page, vma, mmun_start);
> +	page_add_anon_rmap(new_page, vma, mmun_start);
>  	pmdp_clear_flush(vma, mmun_start, pmd);
>  	set_pmd_at(mm, mmun_start, pmd, entry);
>  	flush_tlb_range(vma, mmun_start, mmun_end);
> @@ -1877,6 +1877,10 @@ fail_putback:
>  	spin_unlock(ptl);
>  	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>  
> +	/* Take an "isolate" reference and put new page on the LRU. */
> +	get_page(new_page);
> +	putback_lru_page(new_page);
> +
>  	unlock_page(new_page);
>  	unlock_page(page);
>  	put_page(page);			/* Drop the rmap reference */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
