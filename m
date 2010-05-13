Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A6FB96B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 02:04:25 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4D64MMc003484
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 13 May 2010 15:04:23 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A850845DE5D
	for <linux-mm@kvack.org>; Thu, 13 May 2010 15:04:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 735C845DE51
	for <linux-mm@kvack.org>; Thu, 13 May 2010 15:04:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 438E3E08003
	for <linux-mm@kvack.org>; Thu, 13 May 2010 15:04:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E122DE08002
	for <linux-mm@kvack.org>; Thu, 13 May 2010 15:04:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Cleanup migrate case in try_to_unmap_one
In-Reply-To: <1272899957-11604-1-git-send-email-ngupta@vflare.org>
References: <1272899957-11604-1-git-send-email-ngupta@vflare.org>
Message-Id: <20100513144336.216D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 13 May 2010 15:04:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Remove duplicate handling of TTU_MIGRATE case for
> anonymous and filesystem pages.
> 
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>

This patch change swap cache case. I think this is not intentional.



> ---
>  mm/rmap.c |   17 ++++-------------
>  1 files changed, 4 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 07fc947..8ccfe4a 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -946,6 +946,10 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			dec_mm_counter(mm, MM_FILEPAGES);
>  		set_pte_at(mm, address, pte,
>  				swp_entry_to_pte(make_hwpoison_entry(page)));
> +	} else if (PAGE_MIGRATION && (TTU_ACTION(flags) == TTU_MIGRATION)) {
> +		swp_entry_t entry;
> +		entry = make_migration_entry(page, pte_write(pteval));
> +		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
>
>  	} else if (PageAnon(page)) {
>  		swp_entry_t entry = { .val = page_private(page) };
>  
> @@ -967,22 +971,9 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			}
>  			dec_mm_counter(mm, MM_ANONPAGES);
>  			inc_mm_counter(mm, MM_SWAPENTS);
> -		} else if (PAGE_MIGRATION) {
> -			/*
> -			 * Store the pfn of the page in a special migration
> -			 * pte. do_swap_page() will wait until the migration
> -			 * pte is removed and then restart fault handling.
> -			 */
> -			BUG_ON(TTU_ACTION(flags) != TTU_MIGRATION);
> -			entry = make_migration_entry(page, pte_write(pteval));
>  		}
>  		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
>  		BUG_ON(pte_file(*pte));
> -	} else if (PAGE_MIGRATION && (TTU_ACTION(flags) == TTU_MIGRATION)) {
> -		/* Establish migration entry for a file page */
> -		swp_entry_t entry;
> -		entry = make_migration_entry(page, pte_write(pteval));
> -		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
>  	} else
>  		dec_mm_counter(mm, MM_FILEPAGES);
>  
> -- 
> 1.6.6.1
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
