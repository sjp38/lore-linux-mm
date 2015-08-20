Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id AF9AB6B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 19:36:45 -0400 (EDT)
Received: by pdbmi9 with SMTP id mi9so19362713pdb.3
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 16:36:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fa3si9811609pdb.7.2015.08.20.16.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 16:36:44 -0700 (PDT)
Date: Thu, 20 Aug 2015 16:36:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-Id: <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
In-Reply-To: <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 19 Aug 2015 12:21:45 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Hugh has pointed that compound_head() call can be unsafe in some
> context. There's one example:
> 
> 	CPU0					CPU1
> 
> isolate_migratepages_block()
>   page_count()
>     compound_head()
>       !!PageTail() == true
> 					put_page()
> 					  tail->first_page = NULL
>       head = tail->first_page
> 					alloc_pages(__GFP_COMP)
> 					   prep_compound_page()
> 					     tail->first_page = head
> 					     __SetPageTail(p);
>       !!PageTail() == true
>     <head == NULL dereferencing>
> 
> The race is pure theoretical. I don't it's possible to trigger it in
> practice. But who knows.
> 
> We can fix the race by changing how encode PageTail() and compound_head()
> within struct page to be able to update them in one shot.
> 
> The patch introduces page->compound_head into third double word block in
> front of compound_dtor and compound_order. That means it shares storage
> space with:
> 
>  - page->lru.next;
>  - page->next;
>  - page->rcu_head.next;
>  - page->pmd_huge_pte;
> 
> That's too long list to be absolutely sure, but looks like nobody uses
> bit 0 of the word. It can be used to encode PageTail(). And if the bit
> set, rest of the word is pointer to head page.

So nothing else which participates in the union in the "Third double
word block" is allowed to use bit zero of the first word.

Is this really true?  For example if it's a slab page, will that page
ever be inspected by code which is looking for the PageTail bit?


Anyway, this is quite subtle and there's a risk that people will
accidentally break it later on.  I don't think the patch puts
sufficient documentation in place to prevent this.  And even
documentation might not be enough to prevent accidents.

>
> ...
>
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -120,7 +120,12 @@ struct page {
>  		};
>  	};
>  
> -	/* Third double word block */
> +	/*
> +	 * Third double word block
> +	 *
> +	 * WARNING: bit 0 of the first word encode PageTail and *must* be 0
> +	 * for non-tail pages.
> +	 */
>  	union {
>  		struct list_head lru;	/* Pageout list, eg. active_list
>  					 * protected by zone->lru_lock !
> @@ -143,6 +148,7 @@ struct page {
>  						 */
>  		/* First tail page of compound page */
>  		struct {
> +			unsigned long compound_head; /* If bit zero is set */

I think the comments around here should have more details and should
be louder!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
