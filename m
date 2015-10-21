Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id E28C06B0253
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:54:23 -0400 (EDT)
Received: by qgeo38 with SMTP id o38so34510164qge.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:54:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 69si9109448qht.87.2015.10.21.10.54.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 10:54:23 -0700 (PDT)
Date: Wed, 21 Oct 2015 13:54:18 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 7/12] mm: page migration trylock newpage at same level as
 oldpage
Message-ID: <20151021175417.GB14968@t510.redhat.com>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182157230.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510182157230.2481@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On Sun, Oct 18, 2015 at 09:59:11PM -0700, Hugh Dickins wrote:
> Clean up page migration a little by moving the trylock of newpage from
> move_to_new_page() into __unmap_and_move(), where the old page has been
> locked.  Adjust unmap_and_move_huge_page() and balloon_page_migrate()
> accordingly.
> 
> But make one kind-of-functional change on the way: whereas trylock of
> newpage used to BUG() if it failed, now simply return -EAGAIN if so.
> Cutting out BUG()s is good, right?  But, to be honest, this is really
> to extend the usefulness of the custom put_new_page feature, allowing
> a pool of new pages to be shared perhaps with racing uses.
> 
> Use an "else" instead of that "skip_unmap" label.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  mm/balloon_compaction.c |   10 +-------
>  mm/migrate.c            |   46 +++++++++++++++++++++-----------------
>  2 files changed, 28 insertions(+), 28 deletions(-)
> 
> --- migrat.orig/mm/balloon_compaction.c	2014-12-07 14:21:05.000000000 -0800
> +++ migrat/mm/balloon_compaction.c	2015-10-18 17:53:22.486335020 -0700
> @@ -199,23 +199,17 @@ int balloon_page_migrate(struct page *ne
>  	struct balloon_dev_info *balloon = balloon_page_device(page);
>  	int rc = -EAGAIN;
>  
> -	/*
> -	 * Block others from accessing the 'newpage' when we get around to
> -	 * establishing additional references. We should be the only one
> -	 * holding a reference to the 'newpage' at this point.
> -	 */
> -	BUG_ON(!trylock_page(newpage));
> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
>  
>  	if (WARN_ON(!__is_movable_balloon_page(page))) {
>  		dump_page(page, "not movable balloon page");
> -		unlock_page(newpage);
>  		return rc;
>  	}
>  
>  	if (balloon && balloon->migratepage)
>  		rc = balloon->migratepage(balloon, newpage, page, mode);
>  
> -	unlock_page(newpage);
>  	return rc;
>  }
>  #endif /* CONFIG_BALLOON_COMPACTION */
> --- migrat.orig/mm/migrate.c	2015-10-18 17:53:20.159332371 -0700
> +++ migrat/mm/migrate.c	2015-10-18 17:53:22.487335021 -0700
> @@ -727,13 +727,8 @@ static int move_to_new_page(struct page
>  	struct address_space *mapping;
>  	int rc;
>  
> -	/*
> -	 * Block others from accessing the page when we get around to
> -	 * establishing additional references. We are the only one
> -	 * holding a reference to the new page at this point.
> -	 */
> -	if (!trylock_page(newpage))
> -		BUG();
> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
>  
>  	/* Prepare mapping for the new page.*/
>  	newpage->index = page->index;
> @@ -774,9 +769,6 @@ static int move_to_new_page(struct page
>  			remove_migration_ptes(page, newpage);
>  		page->mapping = NULL;
>  	}
> -
> -	unlock_page(newpage);
> -
>  	return rc;
>  }
>  
> @@ -861,6 +853,17 @@ static int __unmap_and_move(struct page
>  		}
>  	}
>  
> +	/*
> +	 * Block others from accessing the new page when we get around to
> +	 * establishing additional references. We are usually the only one
> +	 * holding a reference to newpage at this point. We used to have a BUG
> +	 * here if trylock_page(newpage) fails, but would like to allow for
> +	 * cases where there might be a race with the previous use of newpage.
> +	 * This is much like races on refcount of oldpage: just don't BUG().
> +	 */
> +	if (unlikely(!trylock_page(newpage)))
> +		goto out_unlock;
> +
>  	if (unlikely(isolated_balloon_page(page))) {
>  		/*
>  		 * A ballooned page does not need any special attention from
> @@ -870,7 +873,7 @@ static int __unmap_and_move(struct page
>  		 * the page migration right away (proteced by page lock).
>  		 */
>  		rc = balloon_page_migrate(newpage, page, mode);
> -		goto out_unlock;
> +		goto out_unlock_both;
>  	}
>  
>  	/*
> @@ -889,30 +892,27 @@ static int __unmap_and_move(struct page
>  		VM_BUG_ON_PAGE(PageAnon(page), page);
>  		if (page_has_private(page)) {
>  			try_to_free_buffers(page);
> -			goto out_unlock;
> +			goto out_unlock_both;
>  		}
> -		goto skip_unmap;
> -	}
> -
> -	/* Establish migration ptes or remove ptes */
> -	if (page_mapped(page)) {
> +	} else if (page_mapped(page)) {
> +		/* Establish migration ptes */
>  		try_to_unmap(page,
>  			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
>  		page_was_mapped = 1;
>  	}
>  
> -skip_unmap:
>  	if (!page_mapped(page))
>  		rc = move_to_new_page(newpage, page, page_was_mapped, mode);
>  
>  	if (rc && page_was_mapped)
>  		remove_migration_ptes(page, page);
>  
> +out_unlock_both:
> +	unlock_page(newpage);
> +out_unlock:
>  	/* Drop an anon_vma reference if we took one */
>  	if (anon_vma)
>  		put_anon_vma(anon_vma);
> -
> -out_unlock:
>  	unlock_page(page);
>  out:
>  	return rc;
> @@ -1056,6 +1056,9 @@ static int unmap_and_move_huge_page(new_
>  	if (PageAnon(hpage))
>  		anon_vma = page_get_anon_vma(hpage);
>  
> +	if (unlikely(!trylock_page(new_hpage)))
> +		goto put_anon;
> +
>  	if (page_mapped(hpage)) {
>  		try_to_unmap(hpage,
>  			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> @@ -1068,6 +1071,9 @@ static int unmap_and_move_huge_page(new_
>  	if (rc != MIGRATEPAGE_SUCCESS && page_was_mapped)
>  		remove_migration_ptes(hpage, hpage);
>  
> +	unlock_page(new_hpage);
> +
> +put_anon:
>  	if (anon_vma)
>  		put_anon_vma(anon_vma);
>  
Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
