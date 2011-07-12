Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D08B56B004A
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 13:48:12 -0400 (EDT)
Received: by yxj17 with SMTP id 17so569779yxj.14
        for <linux-mm@kvack.org>; Tue, 12 Jul 2011 10:48:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110712165003.GP23227@redhat.com>
References: <20110712165003.GP23227@redhat.com>
Date: Wed, 13 Jul 2011 01:48:10 +0800
Message-ID: <CAPQyPG5asX4t_hhzmCeXLRnerXxuD2v8CRfQ2_RZqUcqdToskQ@mail.gmail.com>
Subject: Re: mm: do_wp_page recheck PageKsm after obtaining the page_lock,
 pte_same not enough
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Johannes Weiner <jweiner@redhat.com>

On 7/13/11, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hi Hugh,
>
> what do you think about this?
>
> ===
> Subject: mm: do_wp_page recheck PageKsm after obtaining the page_lock,
> pte_same not enough
>
> From: Andrea Arcangeli <aarcange@redhat.com>
>
> There seems to be a bug in do_wp_page that if not fixed, it would
> lead to a Ksm shared page to be mapped read-write into some process pte
> leading
> to random memory corruption in userland MADV_MEARGEABLE vmas.
>
> If the orig_pte value was read by do_wp_page after
> write_protect_page() (likely as if the pte wasn't originally read as
> readonly by handle_pte_fault, do_wp_page wouldn't be called in the
> first place), but if we reach lock_page() in the !PageKsm path (before
> reuse_swap_page is called), but before set_page_stable_node() run (the
> kpage == NULL case), the orig_pte wouldn't have changed (after
> write_protect_page returned the pte doesn't change anymore and then we
> release the page lock), and the pte_same() check would succeed, but
> the old_page would have become a PageKsm already before releasing the
> page lock in try_to_merge_one_page, so we shouldn't go ahead with
> reuse_swap_page in do_wp_page in that case. But we do, and then we
> reuse the wrprotected PageKsm in the stable tree allowing userland to
> map it read-write. The PageKsm check I introduced below in memory.c
> should close this race, it is enough to check the page is not Ksm to
> know if we can takeover it or not after we obtain the page lock.
>
> To say it in another way, the current and only PageKsm check in
> do_wp_page in short is racy because it's run before trying to obtain
> the page lock, so it could run before set_page_stable_node() had a
> chance to run yet.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2454,7 +2454,8 @@ static int do_wp_page(struct mm_struct *
>  			lock_page(old_page);
>  			page_table = pte_offset_map_lock(mm, pmd, address,
>  							 &ptl);
> -			if (!pte_same(*page_table, orig_pte)) {
> +			if (!pte_same(*page_table, orig_pte) ||
> +			    PageKsm(old_page)) {

I think in this case we should copy the page instead of going to unlock.

And I think reuse_swap_page() has checked the PageKsm(page) inside and
in this case it will go to the copy path already?

>  				unlock_page(old_page);
>  				goto unlock;
>  			}
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
