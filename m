Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C87AF6B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 21:26:21 -0400 (EDT)
Date: Wed, 25 Aug 2010 09:29:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/8] hugetlb: add allocate function for hugepage
 migration
Message-ID: <20100825012941.GD7283@localhost>
References: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1282694127-14609-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282694127-14609-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> +static struct page *alloc_buddy_huge_page_node(struct hstate *h, int nid)
> +{
> +	struct page *page = __alloc_huge_page_node(h, nid);
>  	if (page) {
> -		if (arch_prepare_hugepage(page)) {
> -			__free_pages(page, huge_page_order(h));
> +		set_compound_page_dtor(page, free_huge_page);
> +		spin_lock(&hugetlb_lock);
> +		h->nr_huge_pages++;
> +		h->nr_huge_pages_node[nid]++;
> +		spin_unlock(&hugetlb_lock);
> +		put_page_testzero(page);
> +	}
> +	return page;
> +}

One would expect the alloc_buddy_huge_page_node() to only differ with
alloc_buddy_huge_page() in the alloc_pages/alloc_pages_exact_node
calls. However you implement alloc_buddy_huge_page_node() in a quite
different way. Can the two functions be unified at all?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
