Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2A06A6B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 19:31:25 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id kx10so3672806pab.36
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 16:31:24 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id cz3si10235663pbc.183.2013.12.16.16.31.22
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 16:31:23 -0800 (PST)
Date: Mon, 16 Dec 2013 16:31:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm: munlock: fix deadlock in __munlock_pagevec()
Message-Id: <20131216163120.28218456e2c870c4c1bfce1e@linux-foundation.org>
In-Reply-To: <1387188856-21027-3-git-send-email-vbabka@suse.cz>
References: <52AE07B4.4020203@oracle.com>
	<1387188856-21027-1-git-send-email-vbabka@suse.cz>
	<1387188856-21027-3-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, joern@logfs.org, Michel Lespinasse <walken@google.com>, stable@kernel.org

On Mon, 16 Dec 2013 11:14:15 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> Commit 7225522bb ("mm: munlock: batch non-THP page isolation and
> munlock+putback using pagevec" introduced __munlock_pagevec() to speed up
> munlock by holding lru_lock over multiple isolated pages. Pages that fail to
> be isolated are put_back() immediately, also within the lock.
> 
> This can lead to deadlock when __munlock_pagevec() becomes the holder of the
> last page pin and put_back() leads to __page_cache_release() which also locks
> lru_lock. The deadlock has been observed by Sasha Levin using trinity.
> 
> This patch avoids the deadlock by deferring put_back() operations until
> lru_lock is released. Another pagevec (which is also used by later phases
> of the function is reused to gather the pages for put_back() operation.
> 
> ...
>

Thanks for fixing this one.  I'll cross it off the rather large list of
recent MM regressions :(

> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -295,10 +295,12 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
>  {
>  	int i;
>  	int nr = pagevec_count(pvec);
> -	int delta_munlocked = -nr;
> +	int delta_munlocked;
>  	struct pagevec pvec_putback;
>  	int pgrescued = 0;
>  
> +	pagevec_init(&pvec_putback, 0);
> +
>  	/* Phase 1: page isolation */
>  	spin_lock_irq(&zone->lru_lock);
>  	for (i = 0; i < nr; i++) {
> @@ -327,16 +329,22 @@ skip_munlock:
>  			/*
>  			 * We won't be munlocking this page in the next phase
>  			 * but we still need to release the follow_page_mask()
> -			 * pin.
> +			 * pin. We cannot do it under lru_lock however. If it's
> +			 * the last pin, __page_cache_release would deadlock.
>  			 */
> +			pagevec_add(&pvec_putback, pvec->pages[i]);
>  			pvec->pages[i] = NULL;
> -			put_page(page);
> -			delta_munlocked++;
>  		}
>  	}
> +	delta_munlocked = -nr + pagevec_count(&pvec_putback);
>  	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
>  	spin_unlock_irq(&zone->lru_lock);
>  
> +	/* Now we can release pins of pages that we are not munlocking */
> +	for (i = 0; i < pagevec_count(&pvec_putback); i++) {
> +		put_page(pvec_putback.pages[i]);
> +	}
> +

We could just do

--- a/mm/mlock.c~mm-munlock-fix-deadlock-in-__munlock_pagevec-fix
+++ a/mm/mlock.c
@@ -341,12 +341,9 @@ skip_munlock:
 	spin_unlock_irq(&zone->lru_lock);
 
 	/* Now we can release pins of pages that we are not munlocking */
-	for (i = 0; i < pagevec_count(&pvec_putback); i++) {
-		put_page(pvec_putback.pages[i]);
-	}
+	pagevec_release(&pvec_putback);
 
 	/* Phase 2: page munlock */
-	pagevec_init(&pvec_putback, 0);
 	for (i = 0; i < nr; i++) {
 		struct page *page = pvec->pages[i];
 

The lru_add_drain() is unnecessary overhead here.  What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
