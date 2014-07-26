Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3E66B0035
	for <linux-mm@kvack.org>; Sat, 26 Jul 2014 18:45:25 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so5827315wgg.24
        for <linux-mm@kvack.org>; Sat, 26 Jul 2014 15:45:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m3si5205097wix.100.2014.07.26.15.45.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 26 Jul 2014 15:45:23 -0700 (PDT)
Message-ID: <53D42F80.7000000@suse.cz>
Date: Sun, 27 Jul 2014 00:45:20 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix direct reclaim writeback regression
References: <alpine.LSU.2.11.1407261248140.13796@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407261248140.13796@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Jones <davej@redhat.com>, Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/26/2014 09:58 PM, Hugh Dickins wrote:
> Yes, 3.16-rc1's 68711a746345 ("mm, migration: add destination page
> freeing callback") has provided such a way to compaction: if migrating
> a SwapBacked page fails, its newpage may be put back on the list for
> later use with PageSwapBacked still set, and nothing will clear it.

Ugh good catch. So is this the only flag that can become "stray" like
this? It seems so from quick check...

> Whether that can do anything worse than issue WARN_ON_ONCEs, and get
> some statistics wrong, is unclear: easier to fix than to think through
> the consequences.
> 
> Fixing it here, before the put_new_page(), addresses the bug directly,
> but is probably the worst place to fix it.  Page migration is doing too
> many parts of the job on too many levels: fixing it in move_to_new_page()
> to complement its SetPageSwapBacked would be preferable, except why is it
> (and newpage->mapping and newpage->index) done there, rather than down in
> migrate_page_move_mapping(), once we are sure of success?  Not a cleanup
> to get into right now, especially not with memcg cleanups coming in 3.17.
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
>  mm/migrate.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> --- 3.16-rc6/mm/migrate.c	2014-06-29 15:22:10.584003935 -0700
> +++ linux/mm/migrate.c	2014-07-26 11:28:34.488126591 -0700
> @@ -988,9 +988,10 @@ out:
>  	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
>  	 * during isolation.
>  	 */
> -	if (rc != MIGRATEPAGE_SUCCESS && put_new_page)
> +	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
> +		ClearPageSwapBacked(newpage);
>  		put_new_page(newpage, private);
> -	else
> +	} else
>  		putback_lru_page(newpage);
>  
>  	if (result) {

What about unmap_and_move_huge_page()? Seems to me it can also get the
same stray flag. Although compaction, who is the only user so far of
custom put_new_page, wouldn't of course migrate huge pages. But might
bite us in the future, if a new user appears before a cleanup...

Vlastimil


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
