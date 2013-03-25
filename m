Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 46BBE6B0044
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 09:49:28 -0400 (EDT)
Date: Mon, 25 Mar 2013 14:49:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 07/10] mbind: add hugepage migration code to mbind()
Message-ID: <20130325134926.GZ2154@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-8-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363983835-20184-8-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri 22-03-13 16:23:52, Naoya Horiguchi wrote:
[...]
> --- v3.9-rc3.orig/mm/mempolicy.c
> +++ v3.9-rc3/mm/mempolicy.c
> @@ -1173,6 +1173,8 @@ static struct page *new_vma_page(struct page *page, unsigned long private, int *
>  		vma = vma->vm_next;
>  	}
>  
> +	if (PageHuge(page))
> +		return alloc_huge_page(vma, address, 1);
>  	/*
>  	 * if !vma, alloc_page_vma() will use task or system default policy
>  	 */
[...]
> diff --git v3.9-rc3.orig/mm/migrate.c v3.9-rc3/mm/migrate.c
> index ef8e4e3..e64cd55 100644
> --- v3.9-rc3.orig/mm/migrate.c
> +++ v3.9-rc3/mm/migrate.c
> @@ -951,7 +951,12 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  	struct page *new_hpage = get_new_page(hpage, private, &result);
>  	struct anon_vma *anon_vma = NULL;
>  
> -	if (!new_hpage)
> +	/*
> +	 * Getting a new hugepage with alloc_huge_page() (which can happen
> +	 * when migration is caused by mbind()) can return ERR_PTR value,
> +	 * so we need take care of the case here.
> +	 */
> +	if (!new_hpage || IS_ERR_VALUE(new_hpage))
>  		return -ENOMEM;

Please no. get_new_page returns NULL or a page. You are hooking a wrong
callback here. The error value doesn't make any sense here. IMO you
should just wrap alloc_huge_page by something that returns NULL or page.

>  
>  	rc = -EAGAIN;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
