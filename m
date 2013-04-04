Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id E29F86B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 22:45:33 -0400 (EDT)
Received: by mail-da0-f48.google.com with SMTP id p8so923566dan.35
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 19:45:33 -0700 (PDT)
Message-ID: <515CE945.20908@gmail.com>
Date: Thu, 04 Apr 2013 10:45:25 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] THP: Use explicit memory barrier
References: <1364773535-26264-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1364773535-26264-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

Hi Minchan,
On 04/01/2013 07:45 AM, Minchan Kim wrote:
> __do_huge_pmd_anonymous_page depends on page_add_new_anon_rmap's
> spinlock for making sure that clear_huge_page write become visible
> after set set_pmd_at() write.

1. There are no pte modify, why take page_table_lock here?
2. What's the meaning of "clear_huge_page write become visible after set 
set_pmd_at() write"?

>
> But lru_cache_add_lru uses pagevec so it could miss spinlock
> easily so above rule was broken so user may see inconsistent data.
>
> This patch fixes it with using explict barrier rather than depending
> on lru spinlock.
>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>   mm/huge_memory.c | 7 +++----
>   1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index bfa142e..fad800e 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -725,11 +725,10 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>   		pmd_t entry;
>   		entry = mk_huge_pmd(page, vma);
>   		/*
> -		 * The spinlocking to take the lru_lock inside
> -		 * page_add_new_anon_rmap() acts as a full memory
> -		 * barrier to be sure clear_huge_page writes become
> -		 * visible after the set_pmd_at() write.
> +		 * clear_huge_page write become visible after the
> +		 * set_pmd_at() write.
>   		 */
> +		smp_wmb();
>   		page_add_new_anon_rmap(page, vma, haddr);
>   		set_pmd_at(mm, haddr, pmd, entry);
>   		pgtable_trans_huge_deposit(mm, pgtable);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
