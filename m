Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 50D166B2864
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 19:36:50 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 89so11807516ple.19
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 16:36:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k11sor38390762pll.39.2018.11.21.16.36.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 16:36:48 -0800 (PST)
Date: Wed, 21 Nov 2018 16:36:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3] mm: use swp_offset as key in shmem_replace_page()
In-Reply-To: <20181121215442.138545-1-yuzhao@google.com>
Message-ID: <alpine.LSU.2.11.1811211634040.5557@eggly.anvils>
References: <20181119010924.177177-1-yuzhao@google.com> <20181121215442.138545-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 21 Nov 2018, Yu Zhao wrote:

> We changed key of swap cache tree from swp_entry_t.val to
> swp_offset. Need to do so in shmem_replace_page() as well.
> 
> Fixes: f6ab1f7f6b2d ("mm, swap: use offset of swap entry as key of swap cache")
> Cc: stable@vger.kernel.org # v4.9+
> Signed-off-by: Yu Zhao <yuzhao@google.com>

Acked-by: Hugh Dickins <hughd@google.com>

Thanks!

> ---
>  mm/shmem.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index d44991ea5ed4..42b70978e814 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1509,11 +1509,13 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
>  {
>  	struct page *oldpage, *newpage;
>  	struct address_space *swap_mapping;
> +	swp_entry_t entry;
>  	pgoff_t swap_index;
>  	int error;
>  
>  	oldpage = *pagep;
> -	swap_index = page_private(oldpage);
> +	entry.val = page_private(oldpage);
> +	swap_index = swp_offset(entry);
>  	swap_mapping = page_mapping(oldpage);
>  
>  	/*
> @@ -1532,7 +1534,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
>  	__SetPageLocked(newpage);
>  	__SetPageSwapBacked(newpage);
>  	SetPageUptodate(newpage);
> -	set_page_private(newpage, swap_index);
> +	set_page_private(newpage, entry.val);
>  	SetPageSwapCache(newpage);
>  
>  	/*
> -- 
> 2.19.1.1215.g8438c0b245-goog
