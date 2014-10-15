Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id F19006B0070
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 05:14:44 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id m15so844334wgh.2
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 02:14:44 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.197])
        by mx.google.com with ESMTP id mv10si5399289wib.37.2014.10.15.02.14.43
        for <linux-mm@kvack.org>;
        Wed, 15 Oct 2014 02:14:43 -0700 (PDT)
Date: Wed, 15 Oct 2014 12:14:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] mm: verify compound order when freeing a page
Message-ID: <20141015091439.GC12538@node.dhcp.inet.fi>
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

On Tue, Oct 14, 2014 at 01:16:40PM -0700, Yu Zhao wrote:
> This allows us to easily catch the bug fixed in previous patch.
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
> +

Use VM_BUG_ON_PAGE(), please.

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
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
