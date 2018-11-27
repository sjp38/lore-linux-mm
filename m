Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D6B986B46A9
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:59:52 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id l9so22598904plt.7
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:59:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x69sor3782024pgx.20.2018.11.26.23.59.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 23:59:51 -0800 (PST)
Date: Tue, 27 Nov 2018 10:59:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 07/10] mm/khugepaged: minor reorderings in
 collapse_shmem()
Message-ID: <20181127075945.m5nbflc6nqto6f2i@kshutemo-mobl1>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
 <alpine.LSU.2.11.1811261526400.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811261526400.2275@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 03:27:52PM -0800, Hugh Dickins wrote:
> Several cleanups in collapse_shmem(): most of which probably do not
> really matter, beyond doing things in a more familiar and reassuring
> order.  Simplify the failure gotos in the main loop, and on success
> update stats while interrupts still disabled from the last iteration.
> 
> Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: stable@vger.kernel.org # 4.8+
> ---
>  mm/khugepaged.c | 72 ++++++++++++++++++++++---------------------------
>  1 file changed, 32 insertions(+), 40 deletions(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 1c402d33547e..9d4e9ff1af95 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1329,10 +1329,10 @@ static void collapse_shmem(struct mm_struct *mm,
>  		goto out;
>  	}
>  
> +	__SetPageLocked(new_page);
> +	__SetPageSwapBacked(new_page);
>  	new_page->index = start;
>  	new_page->mapping = mapping;
> -	__SetPageSwapBacked(new_page);
> -	__SetPageLocked(new_page);
>  	BUG_ON(!page_ref_freeze(new_page, 1));
>  
>  	/*
> @@ -1366,13 +1366,13 @@ static void collapse_shmem(struct mm_struct *mm,
>  			if (index == start) {
>  				if (!xas_next_entry(&xas, end - 1)) {
>  					result = SCAN_TRUNCATED;
> -					break;
> +					goto xa_locked;
>  				}
>  				xas_set(&xas, index);
>  			}
>  			if (!shmem_charge(mapping->host, 1)) {
>  				result = SCAN_FAIL;
> -				break;
> +				goto xa_locked;
>  			}
>  			xas_store(&xas, new_page + (index % HPAGE_PMD_NR));
>  			nr_none++;
> @@ -1387,13 +1387,12 @@ static void collapse_shmem(struct mm_struct *mm,
>  				result = SCAN_FAIL;
>  				goto xa_unlocked;
>  			}
> -			xas_lock_irq(&xas);
> -			xas_set(&xas, index);
>  		} else if (trylock_page(page)) {
>  			get_page(page);
> +			xas_unlock_irq(&xas);
>  		} else {
>  			result = SCAN_PAGE_LOCK;
> -			break;
> +			goto xa_locked;
>  		}
>  
>  		/*

I'm puzzled by locking change here.

Isn't the change responsible for the bug you are fixing in 09/10?

IIRC, my intend for the locking scheme was to protect against
truncate-repopulate race.

What do I miss?

The rest of the patch *looks* okay, but I found it hard to follow.
Splitting it up would make it easier.

-- 
 Kirill A. Shutemov
