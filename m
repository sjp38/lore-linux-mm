Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6EAAC6B00EC
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 13:44:54 -0500 (EST)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id o2BIipbY023715
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 18:44:51 GMT
Received: from fxm27 (fxm27.prod.google.com [10.184.13.27])
	by spaceape13.eur.corp.google.com with ESMTP id o2BIio1k017863
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 10:44:50 -0800
Received: by fxm27 with SMTP id 27so414257fxm.28
        for <linux-mm@kvack.org>; Thu, 11 Mar 2010 10:44:50 -0800 (PST)
Date: Thu, 11 Mar 2010 18:44:43 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [Patch] mm/ksm.c is doing an unneeded _notify in
 write_protect_page.
In-Reply-To: <20100311172340.GD5685@sgi.com>
Message-ID: <alpine.LSU.2.00.1003111843560.5991@sister.anvils>
References: <20100311172340.GD5685@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010, Robin Holt wrote:
> 
> ksm.c's write_protect_page implements a lockless means of verifying a
> page does not have any users of the page which are not accounted for via
> other kernel tracking means.  It does this by removing the writable pte
> with TLB flushes, checking the page_count against the total known users,
> and then using set_pte_at_notify to make it a read-only entry.
> 
> An unneeded mmu_notifier callout is made in the case where the known
> users does not match the page_count.  In that event, we are inserting
> the identical pte and there is no need for the set_pte_at_notify, but
> rather the simpler set_pte_at suffices.
> 
> To: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Robin Holt <holt@sgi.com>
> Acked-by: Izik Eidus <ieidus@redhat.com>
> Acked-by: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> Cc: Chris Wright <chrisw@redhat.com>
> Cc: linux-mm@kvack.org
> 
> ---
> 
>  mm/ksm.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: ksm_remove_notify/mm/ksm.c
> ===================================================================
> --- ksm_remove_notify.orig/mm/ksm.c	2010-03-11 11:21:57.000000000 -0600
> +++ ksm_remove_notify/mm/ksm.c	2010-03-11 11:21:59.000000000 -0600
> @@ -751,7 +751,7 @@ static int write_protect_page(struct vm_
>  		 * page
>  		 */
>  		if (page_mapcount(page) + 1 + swapped != page_count(page)) {
> -			set_pte_at_notify(mm, addr, ptep, entry);
> +			set_pte_at(mm, addr, ptep, entry);
>  			goto out_unlock;
>  		}
>  		entry = pte_wrprotect(entry);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
