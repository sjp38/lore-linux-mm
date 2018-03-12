Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 413206B0006
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 17:22:15 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r29so10002000wra.13
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 14:22:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a9si5749519wrd.185.2018.03.12.14.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 14:22:13 -0700 (PDT)
Date: Mon, 12 Mar 2018 14:22:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1 1/1] mm/ksm: fix interaction with THP
Message-Id: <20180312142210.4e664519118369d5d129e6dc@linux-foundation.org>
In-Reply-To: <1520872937-15351-1-git-send-email-imbrenda@linux.vnet.ibm.com>
References: <1520872937-15351-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, minchan@kernel.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, hughd@google.com, pholasek@redhat.com, borntraeger@de.ibm.com, gerald.schaefer@de.ibm.com

On Mon, 12 Mar 2018 17:42:17 +0100 Claudio Imbrenda <imbrenda@linux.vnet.ibm.com> wrote:

> This patch fixes a corner case for KSM. When two pages belong or
> belonged to the same transparent hugepage, and they should be merged,
> KSM fails to split the page, and therefore no merging happens.
> 
> This bug can be reproduced by:
> * making sure ksm is running (in case disabling ksmtuned)
> * enabling transparent hugepages
> * allocating a THP-aligned 1-THP-sized buffer
>   e.g. on amd64: posix_memalign(&p, 1<<21, 1<<21)
> * filling it with the same values
>   e.g. memset(p, 42, 1<<21)
> * performing madvise to make it mergeable
>   e.g. madvise(p, 1<<21, MADV_MERGEABLE)
> * waiting for KSM to perform a few scans
> 
> The expected outcome is that the all the pages get merged (1 shared and
> the rest sharing); the actual outcome is that no pages get merged (1
> unshared and the rest volatile)
> 
> The reason of this behaviour is that we increase the reference count
> once for both pages we want to merge, but if they belong to the same
> hugepage (or compound page), the reference counter used in both cases
> is the one of the head of the compound page.
> This means that split_huge_page will find a value of the reference
> counter too high and will fail.
> 
> This patch solves this problem by testing if the two pages to merge
> belong to the same hugepage when attempting to merge them. If so, the
> hugepage is split safely. This means that the hugepage is not split if
> not necessary.
> 
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>

Signoff trail is confusing.  Usually people put the primary author's
signoff first, which makes me wonder whether you or Gerald was the
primary author?


> diff --git a/mm/ksm.c b/mm/ksm.c
> index 293721f..7a826fa 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -2001,7 +2001,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  	struct page *kpage;
>  	unsigned int checksum;
>  	int err;
> -	bool max_page_sharing_bypass = false;
> +	bool split, max_page_sharing_bypass = false;

`split' could be made local to the `if' block where it is used, which
improves readability and maintainability somewhat.

>  	stable_node = page_stable_node(page);
>  	if (stable_node) {
> @@ -2084,6 +2084,8 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  	if (tree_rmap_item) {
>  		kpage = try_to_merge_two_pages(rmap_item, page,
>  						tree_rmap_item, tree_page);
> +		split = PageTransCompound(page) && PageTransCompound(tree_page)
> +			&& compound_head(page) == compound_head(tree_page);

I think a comment explainig what's going on would be useful here.

>  		put_page(tree_page);
>  		if (kpage) {
>  			/*
> @@ -2110,6 +2112,11 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  				break_cow(tree_rmap_item);
>  				break_cow(rmap_item);
>  			}
> +		} else if (split) {
> +			if (!trylock_page(page))
> +				return;
> +			split_huge_page(page);
> +			unlock_page(page);

Why did we use trylock_page()?  Perhaps for the same reasons which were
explained in try_to_merge_one_page(), perhaps for other reasons. 
cmp_and_merge_page() already does lock_page() and down_read(), so I
wonder if those reasons are legitimate.

Again, a comment here is needed - otherwise it will be hard for readers
to understand your intent.

>  		}
>  	}
>  }
