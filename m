Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 7CEA06B0044
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 03:19:37 -0400 (EDT)
Received: by iajr24 with SMTP id r24so1376341iaj.14
        for <linux-mm@kvack.org>; Wed, 28 Mar 2012 00:19:36 -0700 (PDT)
Date: Wed, 28 Mar 2012 00:19:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/memory_failure: Let the compiler add the function
 name
In-Reply-To: <1332843450-7100-1-git-send-email-bp@amd64.org>
Message-ID: <alpine.DEB.2.00.1203280018390.16201@chino.kir.corp.google.com>
References: <1332843450-7100-1-git-send-email-bp@amd64.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Borislav Petkov <borislav.petkov@amd.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

On Tue, 27 Mar 2012, Borislav Petkov wrote:

> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 56080ea36140..7d78d5ec61a7 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1384,16 +1384,16 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
>  	 */
>  	if (!get_page_unless_zero(compound_head(p))) {
>  		if (PageHuge(p)) {
> -			pr_info("get_any_page: %#lx free huge page\n", pfn);
> +			pr_info("%s: %#lx free huge page\n", __func__, pfn);
>  			ret = dequeue_hwpoisoned_huge_page(compound_head(p));
>  		} else if (is_free_buddy_page(p)) {
> -			pr_info("get_any_page: %#lx free buddy page\n", pfn);
> +			pr_info("%s: %#lx free buddy page\n", __func__, pfn);
>  			/* Set hwpoison bit while page is still isolated */
>  			SetPageHWPoison(p);
>  			ret = 0;
>  		} else {
> -			pr_info("get_any_page: %#lx: unknown zero refcount page type %lx\n",
> -				pfn, p->flags);
> +			pr_info("%s: %#lx: unknown zero refcount page type %lx\n",
> +				__func__, pfn, p->flags);
>  			ret = -EIO;
>  		}
>  	} else {

I agree with your change, but I'm not sure these should be pr_info() to 
start with, these seem more like debugging messages?  I can't see how 
they'd be useful in standard operation so could we just convert them to be 
debug instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
