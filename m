Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id F0CDE6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 15:30:46 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kx10so1901257pab.9
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 12:30:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c3si16950893pat.15.2014.10.15.12.30.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Oct 2014 12:30:45 -0700 (PDT)
Date: Wed, 15 Oct 2014 12:30:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] mm: free compound page with correct order
Message-Id: <20141015123044.03f38a520b01c5d332e3d9a5@linux-foundation.org>
In-Reply-To: <1413400805-15547-1-git-send-email-yuzhao@google.com>
References: <1413400805-15547-1-git-send-email-yuzhao@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Wed, 15 Oct 2014 12:20:04 -0700 Yu Zhao <yuzhao@google.com> wrote:

> Compound page should be freed by put_page() or free_pages() with
> correct order. Not doing so will cause tail pages leaked.
> 
> The compound order can be obtained by compound_order() or use
> HPAGE_PMD_ORDER in our case. Some people would argue the latter
> is faster but I prefer the former which is more general.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: 97ae17497e99 ("thp: implement refcounting for huge zero page")
> Cc: stable@vger.kernel.org (v3.8+)

It's two years old and nobody noticed the memory leak, so presumably it
happens rarely.

> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  mm/huge_memory.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 74c78aa..780d12c 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -200,7 +200,7 @@ retry:
>  	preempt_disable();
>  	if (cmpxchg(&huge_zero_page, NULL, zero_page)) {
>  		preempt_enable();
> -		__free_page(zero_page);
> +		__free_pages(zero_page, compound_order(zero_page));

This is rare.

>  		goto retry;
>  	}
>  
> @@ -232,7 +232,7 @@ static unsigned long shrink_huge_zero_page_scan(struct shrinker *shrink,
>  	if (atomic_cmpxchg(&huge_zero_refcount, 1, 0) == 1) {
>  		struct page *zero_page = xchg(&huge_zero_page, NULL);
>  		BUG_ON(zero_page == NULL);
> -		__free_page(zero_page);
> +		__free_pages(zero_page, compound_order(zero_page));

But I'm surprised that this is also rare.  It makes me wonder if this
code is working correctly.

>  		return HPAGE_PMD_NR;
>  	}

Were you able to observe the leakage in practice?  If so, under what
circumstances?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
