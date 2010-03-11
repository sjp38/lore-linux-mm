Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A92366B00DE
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 11:00:20 -0500 (EST)
Date: Thu, 11 Mar 2010 18:01:59 +0200
From: Izik Eidus <ieidus@redhat.com>
Subject: Re: [Patch] mm/ksm.c is doing an unneeded _notify in
 write_protect_page.
Message-ID: <20100311180159.124ffecd@redhat.com>
In-Reply-To: <20100311155422.GB5685@sgi.com>
References: <20100310191842.GL5677@sgi.com>
	<4B97FED5.2030007@redhat.com>
	<20100310221903.GC5967@random.random>
	<alpine.LSU.2.00.1003110617540.29040@sister.anvils>
	<4B98EE31.80502@redhat.com>
	<20100311155422.GB5685@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010 09:54:22 -0600
Robin Holt <holt@sgi.com> wrote:

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
> Signed-off-by: Robin Holt <holt@sgi.com>
> To: Izik Eidus <ieidus@redhat.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: Chris Wright <chrisw@redhat.com>
> Cc: linux-mm@kvack.org

Acked-by: Izik Eidus <ieidus@redhat.com>

> 
> ---
> 
>  mm/ksm.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: ksm_remove_notify/mm/ksm.c
> ===================================================================
> --- ksm_remove_notify.orig/mm/ksm.c	2010-03-11 09:24:30.000000000 -0600
> +++ ksm_remove_notify/mm/ksm.c	2010-03-11 09:35:18.000000000 -0600
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
