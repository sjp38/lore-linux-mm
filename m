Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 45E826B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 21:57:57 -0400 (EDT)
Date: Thu, 19 Aug 2010 09:57:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 9/9] hugetlb: add corrupted hugepage counter
Message-ID: <20100819015752.GB5762@localhost>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1281432464-14833-10-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1281432464-14833-10-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> +void increment_corrupted_huge_page(struct page *page);
> +void decrement_corrupted_huge_page(struct page *page);

nitpick: increment/decrement are not verbs.

> +void increment_corrupted_huge_page(struct page *hpage)
> +{
> +	struct hstate *h = page_hstate(hpage);
> +	spin_lock(&hugetlb_lock);
> +	h->corrupted_huge_pages++;
> +	spin_unlock(&hugetlb_lock);
> +}
> +
> +void decrement_corrupted_huge_page(struct page *hpage)
> +{
> +	struct hstate *h = page_hstate(hpage);
> +	spin_lock(&hugetlb_lock);
> +	BUG_ON(!h->corrupted_huge_pages);

There is no point to have BUG_ON() here:

/*
 * Don't use BUG() or BUG_ON() unless there's really no way out; one
 * example might be detecting data structure corruption in the middle
 * of an operation that can't be backed out of.  If the (sub)system
 * can somehow continue operating, perhaps with reduced functionality,
 * it's probably not BUG-worthy.
 *
 * If you're tempted to BUG(), think again:  is completely giving up
 * really the *only* solution?  There are usually better options, where
 * users don't need to reboot ASAP and can mostly shut down cleanly.
 */


And there is a race case that (corrupted_huge_pages==0)!
Suppose the user space calls unpoison_memory() on a good pfn, and the page
happen to be hwpoisoned between lock_page() and TestClearPageHWPoison(),
corrupted_huge_pages will go negative.

Thanks,
Fengguang

> +	h->corrupted_huge_pages--;
> +	spin_unlock(&hugetlb_lock);
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
