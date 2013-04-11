Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 252656B0027
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:44:23 -0400 (EDT)
Date: Thu, 11 Apr 2013 16:44:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch]THP: add split tail pages to shrink page list in page
 reclaim
Message-Id: <20130411164421.697ee91f85002f74aea8c4ad@linux-foundation.org>
In-Reply-To: <20130401132605.GA2996@kernel.org>
References: <20130401132605.GA2996@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com, aarcange@redhat.com, minchan@kernel.org

On Mon, 1 Apr 2013 21:26:05 +0800 Shaohua Li <shli@kernel.org> wrote:

> In page reclaim, huge page is split. split_huge_page() adds tail pages to LRU
> list. Since we are reclaiming a huge page, it's better we reclaim all subpages
> of the huge page instead of just the head page. This patch adds split tail
> pages to shrink page list so the tail pages can be reclaimed soon.
> 
> Before this patch, run a swap workload:
> thp_fault_alloc 3492
> thp_fault_fallback 608
> thp_collapse_alloc 6
> thp_collapse_alloc_failed 0
> thp_split 916
> 
> With this patch:
> thp_fault_alloc 4085
> thp_fault_fallback 16
> thp_collapse_alloc 90
> thp_collapse_alloc_failed 0
> thp_split 1272
> 
> fallback allocation is reduced a lot.
> 
> ...
>
> -int split_huge_page(struct page *page)
> +int split_huge_page_to_list(struct page *page, struct list_head *list)

While it's fresh, could you please prepare a covering comment describing
this function?  The meaning of the return value is particularly
cryptic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
