Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF166B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 14:47:28 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id 10so1290301ykt.2
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 11:47:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f3si3281004qci.15.2015.01.23.11.47.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 11:47:27 -0800 (PST)
Message-ID: <54C29B2B.4070800@redhat.com>
Date: Fri, 23 Jan 2015 14:04:11 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: incorporate read-only pages into transparent huge
 pages
References: <1421999256-3881-1-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1421999256-3881-1-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, aarcange@redhat.com

On 01/23/2015 02:47 AM, Ebru Akagunduz wrote:

> @@ -2169,7 +2169,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
>  
>  		/* cannot use mapcount: can't collapse if there's a gup pin */
> -		if (page_count(page) != 1)
> +		if (page_count(page) != 1 + !!PageSwapCache(page))
>  			goto out;
>  		/*
>  		 * We can do it before isolate_lru_page because the
> @@ -2179,6 +2179,17 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  		 */
>  		if (!trylock_page(page))
>  			goto out;
> +		if (!pte_write(pteval)) {
> +			if (PageSwapCache(page) && !reuse_swap_page(page)) {
> +					unlock_page(page);
> +					goto out;
> +			}
> +			/*
> +			 * Page is not in the swap cache, and page count is
> +			 * one (see above). It can be collapsed into a THP.
> +			 */
> +		}

Andrea pointed out a bug between the above two parts of
the patch.

In-between where we check page_count(page), and where we
check whether the page got added to the swap cache, the
page count may change, causing us to get into a race
condition with get_user_pages_fast, the pageout code, etc.

It is necessary to check the page count again right after
the trylock_page(page) above, to make sure it was not changed
while the page was not yet locked.

That second check should have a comment explaining that
the first "page_count(page) != 1 + !!PageSwapCache(page)"
check could be unsafe due to the page not yet locked,
so the check needs to be repeated. Maybe something along
the lines of:

     /* Re-check the page count with the page locked */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
