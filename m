Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0A1C06B004F
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 00:35:55 -0400 (EDT)
Date: Thu, 4 Jun 2009 12:35:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [9/16] HWPOISON: Handle hardware poisoned pages in
	try_to_unmap
Message-ID: <20090604043541.GC15682@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184642.BD4B91D0291@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090603184642.BD4B91D0291@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 02:46:42AM +0800, Andi Kleen wrote:
> 
> When a page has the poison bit set replace the PTE with a poison entry. 
> This causes the right error handling to be done later when a process runs 
> into it.
> 
> Also add a new flag to not do that (needed for the memory-failure handler
> later)
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> ---
>  include/linux/rmap.h |    1 +
>  mm/rmap.c            |    9 ++++++++-
>  2 files changed, 9 insertions(+), 1 deletion(-)
> 
> Index: linux/mm/rmap.c
> ===================================================================
> --- linux.orig/mm/rmap.c	2009-06-03 19:36:23.000000000 +0200
> +++ linux/mm/rmap.c	2009-06-03 20:39:49.000000000 +0200
> @@ -943,7 +943,14 @@
>  	/* Update high watermark before we lower rss */
>  	update_hiwater_rss(mm);
>  
> -	if (PageAnon(page)) {
> +	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> +		if (PageAnon(page))
> +			dec_mm_counter(mm, anon_rss);
> +		else if (!is_migration_entry(pte_to_swp_entry(*pte)))
> +			dec_mm_counter(mm, file_rss);
> +		set_pte_at(mm, address, pte,
> +				swp_entry_to_pte(make_hwpoison_entry(page)));
> +	} else if (PageAnon(page)) {
>  		swp_entry_t entry = { .val = page_private(page) };
>  
>  		if (PageSwapCache(page)) {
> Index: linux/include/linux/rmap.h
> ===================================================================
> --- linux.orig/include/linux/rmap.h	2009-06-03 19:36:23.000000000 +0200
> +++ linux/include/linux/rmap.h	2009-06-03 19:36:23.000000000 +0200
> @@ -93,6 +93,7 @@
>  
>  	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
>  	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
> +	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */

Or more precisely comment it as "corrupted data is recoverable"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
