Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3866282F65
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 05:58:51 -0400 (EDT)
Received: by iofz202 with SMTP id z202so39639128iof.2
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 02:58:51 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id qf9si12897491igb.61.2015.10.19.02.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 02:58:50 -0700 (PDT)
Received: by pabrc13 with SMTP id rc13so186979113pab.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 02:58:50 -0700 (PDT)
Date: Mon, 19 Oct 2015 19:01:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/5] MADV_FREE refactoring and fix KSM page
Message-ID: <20151019100150.GA5194@bbox>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445236307-895-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Oct 19, 2015 at 03:31:42PM +0900, Minchan Kim wrote:
> Hello, it's too late since I sent previos patch.
> https://lkml.org/lkml/2015/6/3/37
> 
> This patch is alomost new compared to previos approach.
> I think this is more simple, clear and easy to review.
> 
> One thing I should notice is that I have tested this patch
> and couldn't find any critical problem so I rebased patchset
> onto recent mmotm(ie, mmotm-2015-10-15-15-20) to send formal
> patchset. Unfortunately, I start to see sudden discarding of
> the page we shouldn't do. IOW, application's valid anonymous page
> was disappeared suddenly.
> 
> When I look through THP changes, I think we could lose
> dirty bit of pte between freeze_page and unfreeze_page
> when we mark it as migration entry and restore it.
> So, I added below simple code without enough considering
> and cannot see the problem any more.
> I hope it's good hint to find right fix this problem.
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index d5ea516ffb54..e881c04f5950 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -3138,6 +3138,9 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
>  		if (is_write_migration_entry(swp_entry))
>  			entry = maybe_mkwrite(entry, vma);
>  
> +		if (PageDirty(page))
> +			SetPageDirty(page);

The condition of PageDirty was typo. I didn't add the condition.
Just added.

                SetPageDirty(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
