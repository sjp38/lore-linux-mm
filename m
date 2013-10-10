Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id B5CC36B0044
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 16:00:20 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so3081857pbb.19
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 13:00:20 -0700 (PDT)
Date: Thu, 10 Oct 2013 20:00:14 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 34/34] mm: dynamically allocate page->ptl if it cannot
 be embedded to struct page
In-Reply-To: <1381428359-14843-35-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <00000141a3f48ada-37ee9c14-2f2b-40a2-93f4-70258363351b-000000@email.amazonses.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com> <1381428359-14843-35-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Thu, 10 Oct 2013, Kirill A. Shutemov wrote:

> +static inline bool ptlock_alloc(struct page *page)
> +{
> +	if (sizeof(spinlock_t) > sizeof(page->ptl))
> +		return __ptlock_alloc(page);
> +	return true;
> +}

Could you make the check a CONFIG option? CONFIG_PTLOCK_DOES_NOT_FIT_IN_PAGE_STRUCT or
so?

> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -147,7 +147,10 @@ struct page {
>  						 * system if PG_buddy is set.
>  						 */
>  #if USE_SPLIT_PTE_PTLOCKS
> -		spinlock_t ptl;
> +		unsigned long ptl; /* It's spinlock_t if it fits to long,
> +				    * otherwise it's pointer to dynamicaly
> +				    * allocated spinlock_t.
> +				    */

If you had such a CONFIG option then you could use the proper type here.

#ifdef CONFIG_PTLOCK_NOT_FITTING
	spinlock_t *ptl;
#else
	spinlock_t ptl;
#endif

Or some such thing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
