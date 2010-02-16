Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 996A36B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 06:34:19 -0500 (EST)
Subject: Re: [PATCH 04 of 32] update futex compound knowledge
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <57877975a9a72d2fad7e.1264969635@v2.random>
References: <patchbomb.1264969631@v2.random>
	 <57877975a9a72d2fad7e.1264969635@v2.random>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 16 Feb 2010 12:33:18 +0100
Message-ID: <1266319998.8404.48.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-01-31 at 21:27 +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Futex code is smarter than most other gup_fast O_DIRECT code and knows about
> the compound internals. However now doing a put_page(head_page) will not
> release the pin on the tail page taken by gup-fast, leading to all sort of
> refcounting bugchecks. Getting a stable head_page is a little tricky.
> 
> page_head = page is there because if this is not a tail page it's also the
> page_head. Only in case this is a tail page, compound_head is called, otherwise
> it's guaranteed unnecessary. And if it's a tail page compound_head has to run
> atomically inside irq disabled section __get_user_pages_fast before returning.
> Otherwise ->first_page won't be a stable pointer.
> 
> Disableing irq before __get_user_page_fast and releasing irq after running
> compound_head is needed because if __get_user_page_fast returns == 1, it means
> the huge pmd is established and cannot go away from under us.
> pmdp_splitting_flush_notify in __split_huge_page_splitting will have to wait
> for local_irq_enable before the IPI delivery can return. This means
> __split_huge_page_refcount can't be running from under us, and in turn when we
> run compound_head(page) we're not reading a dangling pointer from
> tailpage->first_page. Then after we get to stable head page, we are always safe
> to call compound_lock and after taking the compound lock on head page we can
> finally re-check if the page returned by gup-fast is still a tail page. in
> which case we're set and we didn't need to split the hugepage in order to take
> a futex on it.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> 
> diff --git a/kernel/futex.c b/kernel/futex.c
> --- a/kernel/futex.c
> +++ b/kernel/futex.c
> @@ -218,7 +218,7 @@ get_futex_key(u32 __user *uaddr, int fsh
>  {
>  	unsigned long address = (unsigned long)uaddr;
>  	struct mm_struct *mm = current->mm;
> -	struct page *page;
> +	struct page *page, *page_head;
>  	int err;
>  
>  	/*
> @@ -250,10 +250,36 @@ again:
>  	if (err < 0)
>  		return err;
>  
> -	page = compound_head(page);
> -	lock_page(page);
> -	if (!page->mapping) {
> -		unlock_page(page);
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	page_head = page;
> +	if (unlikely(PageTail(page))) {
> +		put_page(page);
> +		/* serialize against __split_huge_page_splitting() */
> +		local_irq_disable();
> +		if (likely(__get_user_pages_fast(address, 1, 1, &page) == 1)) {
> +			page_head = compound_head(page);
> +			local_irq_enable();
> +		} else {
> +			local_irq_enable();
> +			goto again;
> +		}
> +	}
> +#else
> +	page_head = compound_head(page);
> +#endif
> +
> +	lock_page(page_head);
> +	if (unlikely(page_head != page)) {
> +		compound_lock(page_head);
> +		if (unlikely(!PageTail(page))) {
> +			compound_unlock(page_head);
> +			unlock_page(page_head);
> +			put_page(page);
> +			goto again;
> +		}
> +	}
> +	if (!page_head->mapping) {
> +		unlock_page(page_head);
>  		put_page(page);
>  		goto again;
>  	}

OK, so I really don't like this, the futex code is pain enough without
having all this open-coded gunk in. Is there really no sensible
vm-helper you can use here?

Also, that whole local_irq_disable(); __gup_fast(); dance is terribly
x86 specific, and this is generic core kernel code.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
