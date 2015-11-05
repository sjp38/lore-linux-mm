Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA8082F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 13:31:38 -0500 (EST)
Received: by wmnn186 with SMTP id n186so22140233wmn.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 10:31:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j6si9594023wjf.167.2015.11.05.10.31.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 10:31:37 -0800 (PST)
Subject: Re: [PATCH 6/12] mm: page migration use the put_new_page whenever
 necessary
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182156010.2481@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <563BA087.1090402@suse.cz>
Date: Thu, 5 Nov 2015 19:31:35 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510182156010.2481@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On 10/19/2015 06:57 AM, Hugh Dickins wrote:
> I don't know of any problem from the way it's used in our current tree,
> but there is one defect in page migration's custom put_new_page feature.
> 
> An unused newpage is expected to be released with the put_new_page(),
> but there was one MIGRATEPAGE_SUCCESS (0) path which released it with
> putback_lru_page(): which can be very wrong for a custom pool.

I'm a bit confused. So there's no immediate bug to be fixed but there was one in
the mainline in the past? Or elsewhere?

> Fixed more easily by resetting put_new_page once it won't be needed,
> than by adding a further flag to modify the rc test.

What is "fixed" if there is no bug? :) Maybe "Further bugs would be
prevented..." or something?

> Signed-off-by: Hugh Dickins <hughd@google.com>

I agree it's less error-prone after you patch, so:

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/migrate.c |   19 +++++++++++--------
>  1 file changed, 11 insertions(+), 8 deletions(-)
> 
> --- migrat.orig/mm/migrate.c	2015-10-18 17:53:17.579329434 -0700
> +++ migrat/mm/migrate.c	2015-10-18 17:53:20.159332371 -0700
> @@ -938,10 +938,11 @@ static ICE_noinline int unmap_and_move(n
>  				   int force, enum migrate_mode mode,
>  				   enum migrate_reason reason)
>  {
> -	int rc = 0;
> +	int rc = MIGRATEPAGE_SUCCESS;
>  	int *result = NULL;
> -	struct page *newpage = get_new_page(page, private, &result);
> +	struct page *newpage;
>  
> +	newpage = get_new_page(page, private, &result);
>  	if (!newpage)
>  		return -ENOMEM;
>  
> @@ -955,6 +956,8 @@ static ICE_noinline int unmap_and_move(n
>  			goto out;
>  
>  	rc = __unmap_and_move(page, newpage, force, mode);
> +	if (rc == MIGRATEPAGE_SUCCESS)
> +		put_new_page = NULL;
>  
>  out:
>  	if (rc != -EAGAIN) {
> @@ -981,7 +984,7 @@ out:
>  	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
>  	 * during isolation.
>  	 */
> -	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
> +	if (put_new_page) {
>  		ClearPageSwapBacked(newpage);
>  		put_new_page(newpage, private);
>  	} else if (unlikely(__is_movable_balloon_page(newpage))) {
> @@ -1022,7 +1025,7 @@ static int unmap_and_move_huge_page(new_
>  				struct page *hpage, int force,
>  				enum migrate_mode mode)
>  {
> -	int rc = 0;
> +	int rc = -EAGAIN;
>  	int *result = NULL;
>  	int page_was_mapped = 0;
>  	struct page *new_hpage;
> @@ -1044,8 +1047,6 @@ static int unmap_and_move_huge_page(new_
>  	if (!new_hpage)
>  		return -ENOMEM;
>  
> -	rc = -EAGAIN;
> -
>  	if (!trylock_page(hpage)) {
>  		if (!force || mode != MIGRATE_SYNC)
>  			goto out;
> @@ -1070,8 +1071,10 @@ static int unmap_and_move_huge_page(new_
>  	if (anon_vma)
>  		put_anon_vma(anon_vma);
>  
> -	if (rc == MIGRATEPAGE_SUCCESS)
> +	if (rc == MIGRATEPAGE_SUCCESS) {
>  		hugetlb_cgroup_migrate(hpage, new_hpage);
> +		put_new_page = NULL;
> +	}
>  
>  	unlock_page(hpage);
>  out:
> @@ -1083,7 +1086,7 @@ out:
>  	 * it.  Otherwise, put_page() will drop the reference grabbed during
>  	 * isolation.
>  	 */
> -	if (rc != MIGRATEPAGE_SUCCESS && put_new_page)
> +	if (put_new_page)
>  		put_new_page(new_hpage, private);
>  	else
>  		putback_active_hugepage(new_hpage);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
