Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 10F206B024F
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 12:00:59 -0400 (EDT)
Date: Tue, 6 Jul 2010 11:00:27 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 6/7] hugetlb: hugepage migration core
In-Reply-To: <1278049646-29769-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.00.1007061057230.4938@router.home>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1278049646-29769-7-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2 Jul 2010, Naoya Horiguchi wrote:

> --- v2.6.35-rc3-hwpoison/mm/migrate.c
> +++ v2.6.35-rc3-hwpoison/mm/migrate.c
> @@ -32,6 +32,7 @@
>  #include <linux/security.h>
>  #include <linux/memcontrol.h>
>  #include <linux/syscalls.h>
> +#include <linux/hugetlb.h>
>  #include <linux/gfp.h>
>
>  #include "internal.h"
> @@ -74,6 +75,8 @@ void putback_lru_pages(struct list_head *l)
>  	struct page *page2;
>
>  	list_for_each_entry_safe(page, page2, l, lru) {
> +		if (PageHuge(page))
> +			break;
>  		list_del(&page->lru);

Argh. Hugepages in putpack_lru_pages()? Huge pages are not on the lru.
Come up with something cleaner here.

> @@ -267,7 +284,14 @@ static int migrate_page_move_mapping(struct address_space *mapping,
>  	 * Note that anonymous pages are accounted for
>  	 * via NR_FILE_PAGES and NR_ANON_PAGES if they
>  	 * are mapped to swap space.
> +	 *
> +	 * Not account hugepage here for now because hugepage has
> +	 * separate accounting rule.
>  	 */
> +	if (PageHuge(newpage)) {
> +		spin_unlock_irq(&mapping->tree_lock);
> +		return 0;
> +	}
>  	__dec_zone_page_state(page, NR_FILE_PAGES);
>  	__inc_zone_page_state(newpage, NR_FILE_PAGES);
>  	if (PageSwapBacked(page)) {

This looks wrong here. Too many special casing added to basic migration
functionality.

> @@ -284,7 +308,17 @@ static int migrate_page_move_mapping(struct address_space *mapping,
>   */
>  static void migrate_page_copy(struct page *newpage, struct page *page)
>  {
> -	copy_highpage(newpage, page);
> +	int i;
> +	struct hstate *h;
> +	if (!PageHuge(newpage))
> +		copy_highpage(newpage, page);
> +	else {
> +		h = page_hstate(newpage);
> +		for (i = 0; i < pages_per_huge_page(h); i++) {
> +			cond_resched();
> +			copy_highpage(newpage + i, page + i);
> +		}
> +	}
>
>  	if (PageError(page))
>  		SetPageError(newpage);

Could you generalize this for migrating an order N page?

> @@ -718,6 +752,11 @@ unlock:
>  	put_page(page);
>
>  	if (rc != -EAGAIN) {
> +		if (PageHuge(newpage)) {
> +			put_page(newpage);
> +			goto out;
> +		}
> +

I dont like this kind of inconsistency with the refcounting. Page
migration is complicated enough already.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
