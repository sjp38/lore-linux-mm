Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 987D26B0036
	for <linux-mm@kvack.org>; Sat,  9 Aug 2014 19:12:47 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so9078876pad.21
        for <linux-mm@kvack.org>; Sat, 09 Aug 2014 16:12:47 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id jq1si9303148pbc.49.2014.08.09.16.12.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 09 Aug 2014 16:12:46 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so9118610pab.15
        for <linux-mm@kvack.org>; Sat, 09 Aug 2014 16:12:46 -0700 (PDT)
Date: Sat, 9 Aug 2014 16:11:06 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 2/3] mm/hugetlb: use get_page_unless_zero() in
 hugetlb_fault()
In-Reply-To: <1406914663-8631-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1408091601590.15311@eggly.anvils>
References: <1406914663-8631-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1406914663-8631-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 1 Aug 2014, Naoya Horiguchi wrote:

> After fixing locking in follow_page(FOLL_GET) for hugepages, I start to
> observe the BUG of "get_page() on refcount 0 page" in hugetlb_fault() in
> the same test.
> 
> I'm not exactly sure about how this race is triggered, but hugetlb_fault()
> calls pte_page() and get_page() outside page table lock, so it's not safe.
> This patch checks the refcount of the gotten page, and aborts the page fault
> if the refcount is 0, expecting to retry.
> 

Fixes: 66aebce747ea ("hugetlb: fix race condition in hugetlb_fault()")

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: <stable@vger.kernel.org>  # [3.12+]


I disagree with your 3.12+ annotation there: you may have hit the issue
in testing your hugepage migration work, but it's older than that: the
problematic get_page() was introduced in 3.4, and has been backported
to 3.2-stable: so 3.2+.

I was suspicious of this patch at first, then on the point of giving it
an Ack, and then realized that I had been right to be suspicious of it.

You're not the first the get the sequence wrong here; and it won't be
surprising if there are other instances of subtle get_page_unless_zero()
misuse elsewhere in the tree (I dare not look!  someone else please do).

It's not the use of get_page_unless_zero() itself that is wrong, it's
the unjustified confidence in it: what's wrong is the lock_page() after.

As you have found, and acknowledged with get_page_unless_zero(), is
that the page here may be stale, it might be already freed, it might
be already reused.  If reused, then its page_count will no longer be 0,
but the new user expects to have sole ownership of the page.  The new
owner might be using __set_page_locked() (or one of the other nonatomic
flags operations), or "if (!trylock_page(newpage)) BUG()" like
migration's move_to_new_page().

We are dealing with a recently-hugetlb page here: that might make the
race I'm describing even less likely than with usual order:0 pages,
but I don't think it eliminates it.

What to do instead?  The first answer that occurs to me is to move the
the pte_page,get_page down after the pte_same check inside the spin_lock,
and only then do trylock_page(), backing out to wait_on_page_locked and
retry or refault if not.

Though if doing that, it might be more sensible only to trylock_page
before dropping ptl inside hugetlb_cow().  That would be a bigger,
maybe harder to backport, rearrangement.

What do you think?

Hugh

> ---
>  mm/hugetlb.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git mmotm-2014-07-22-15-58.orig/mm/hugetlb.c mmotm-2014-07-22-15-58/mm/hugetlb.c
> index 4437896cd6ed..863f45f63cd5 100644
> --- mmotm-2014-07-22-15-58.orig/mm/hugetlb.c
> +++ mmotm-2014-07-22-15-58/mm/hugetlb.c
> @@ -3189,7 +3189,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * so no worry about deadlock.
>  	 */
>  	page = pte_page(entry);
> -	get_page(page);
> +	if (!get_page_unless_zero(page))
> +		goto out_put_pagecache;
>  	if (page != pagecache_page)
>  		lock_page(page);
>  
> @@ -3215,15 +3216,14 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  out_ptl:
>  	spin_unlock(ptl);
> -
> +	if (page != pagecache_page)
> +		unlock_page(page);
> +	put_page(page);
> +out_put_pagecache:
>  	if (pagecache_page) {
>  		unlock_page(pagecache_page);
>  		put_page(pagecache_page);
>  	}
> -	if (page != pagecache_page)
> -		unlock_page(page);
> -	put_page(page);
> -
>  out_mutex:
>  	mutex_unlock(&htlb_fault_mutex_table[hash]);
>  	return ret;
> -- 
> 1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
