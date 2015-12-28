Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F18686B027B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 18:30:27 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id cy9so115863715pac.0
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 15:30:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y20si20845455pfi.247.2015.12.28.15.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Dec 2015 15:30:27 -0800 (PST)
Date: Mon, 28 Dec 2015 15:30:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] thp: increase split_huge_page() success rate
Message-Id: <20151228153026.628d44126a848e14bcbbce68@linux-foundation.org>
In-Reply-To: <1450957883-96356-5-git-send-email-kirill.shutemov@linux.intel.com>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1450957883-96356-5-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Thu, 24 Dec 2015 14:51:23 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> During freeze_page(), we remove the page from rmap. It munlocks the page
> if it was mlocked. clear_page_mlock() uses of lru cache, which temporary
> pins page.
> 
> Let's drain the lru cache before checking page's count vs. mapcount.
> The change makes mlocked page split on first attempt, if it was not
> pinned by somebody else.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/huge_memory.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 1a988d9b86ef..4c1c292b7ddd 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -3417,6 +3417,9 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  	freeze_page(anon_vma, head);
>  	VM_BUG_ON_PAGE(compound_mapcount(head), head);
>  
> +	/* Make sure the page is not on per-CPU pagevec as it takes pin */
> +	lru_add_drain();
> +
>  	/* Prevent deferred_split_scan() touching ->_count */
>  	spin_lock(&split_queue_lock);
>  	count = page_count(head);

Fair enough.

mlocked pages are rare and lru_add_drain() isn't free.  We could easily
and cheaply make page_remove_rmap() return "bool was_mlocked" (or,
better, "bool might_be_in_lru_cache") to skip this overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
