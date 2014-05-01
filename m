Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 64AF96B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 01:09:49 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id k15so2666777qaq.31
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 22:09:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id em3si12166768qcb.11.2014.04.30.22.09.47
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 22:09:48 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [patch 1/2] mm, migration: add destination page freeing callback
Date: Thu,  1 May 2014 01:08:56 -0400
Message-Id: <5361d71c.03c6e50a.23c3.6433SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gthelen@google.com, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi David,

On Wed, Apr 30, 2014 at 05:45:24PM -0700, David Rientjes wrote:
> Memory migration uses a callback defined by the caller to determine how to
> allocate destination pages.  When migration fails for a source page, however, it 
> frees the destination page back to the system.
> 
> This patch adds a memory migration callback defined by the caller to determine 
> how to free destination pages.  If a caller, such as memory compaction, builds 
> its own freelist for migration targets, this can reuse already freed memory 
> instead of scanning additional memory.
> 
> If the caller provides a function to handle freeing of destination pages, it is 
> called when page migration fails.  Otherwise, it may pass NULL and freeing back 
> to the system will be handled as usual.  This patch introduces no functional 
> change.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Looks good to me.
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

I have one comment below ...

[snip]

> @@ -1056,20 +1059,30 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  	if (!page_mapped(hpage))
>  		rc = move_to_new_page(new_hpage, hpage, 1, mode);
>  
> -	if (rc)
> +	if (rc != MIGRATEPAGE_SUCCESS)
>  		remove_migration_ptes(hpage, hpage);
>  
>  	if (anon_vma)
>  		put_anon_vma(anon_vma);
>  
> -	if (!rc)
> +	if (rc == MIGRATEPAGE_SUCCESS)
>  		hugetlb_cgroup_migrate(hpage, new_hpage);
>  
>  	unlock_page(hpage);
>  out:
>  	if (rc != -EAGAIN)
>  		putback_active_hugepage(hpage);
> -	put_page(new_hpage);
> +
> +	/*
> +	 * If migration was not successful and there's a freeing callback, use
> +	 * it.  Otherwise, put_page() will drop the reference grabbed during
> +	 * isolation.
> +	 */

This comment is true both for normal page and huge page, and people more likely
to see unmap_and_move() at first, so this had better be (also) in unmap_and_move().

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
