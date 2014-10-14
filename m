Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 90A546B0069
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 16:30:00 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so8318708pad.8
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 13:30:00 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id uy3si9385129pab.42.2014.10.14.13.29.59
        for <linux-mm@kvack.org>;
        Tue, 14 Oct 2014 13:29:59 -0700 (PDT)
Date: Tue, 14 Oct 2014 13:29:55 -0700
From: David Cohen <david.a.cohen@linux.intel.com>
Subject: Re: [PATCH 2/2] mm: verify compound order when freeing a page
Message-ID: <20141014202955.GA2889@psi-dev26.jf.intel.com>
References: <1413317800-25450-1-git-send-email-yuzhao@google.com>
 <1413317800-25450-2-git-send-email-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413317800-25450-2-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Yu,

On Tue, Oct 14, 2014 at 01:16:40PM -0700, Yu Zhao wrote:
> This allows us to easily catch the bug fixed in previous patch.

Is the word "previous" a good way to relate patches after merged?
Maybe you could either detail the bug here or be more verbose about the
patch you're referring.

> 
> Here we also verify whether a page is tail page or not -- tail
> pages are supposed to be freed along with their head, not by
> themselves.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  mm/page_alloc.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 736d8e1..2bcc770 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -750,6 +750,9 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>  	int i;
>  	int bad = 0;
>  
> +	VM_BUG_ON(PageTail(page));
> +	VM_BUG_ON(PageHead(page) && compound_order(page) != order);

It may be too severe. AFAIU we're not talking about a fatal error.
How about VM_WARN_ON()?

Br, David Cohen

> +
>  	trace_mm_page_free(page, order);
>  	kmemcheck_free_shadow(page, order);
>  
> -- 
> 2.1.0.rc2.206.gedb03e5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
