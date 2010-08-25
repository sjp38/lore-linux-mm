Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E70C26B01F6
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 22:58:15 -0400 (EDT)
Date: Wed, 25 Aug 2010 11:02:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/8] HWPOISON, hugetlb: soft offlining for hugepage
Message-ID: <20100825030202.GB15129@localhost>
References: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1282694127-14609-7-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282694127-14609-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> +static int is_hugepage_on_freelist(struct page *hpage)
> +{
> +	struct page *page;
> +	struct page *tmp;
> +	struct hstate *h = page_hstate(hpage);
> +	int nid = page_to_nid(hpage);
> +
> +	spin_lock(&hugetlb_lock);
> +	list_for_each_entry_safe(page, tmp, &h->hugepage_freelists[nid], lru) {
> +		if (page == hpage) {
> +			spin_unlock(&hugetlb_lock);
> +			return 1;
> +		}
> +	}
> +	spin_unlock(&hugetlb_lock);
> +	return 0;
> +}

Ha! That looks better than the page_count test in my previous email.

> +void isolate_hwpoisoned_huge_page(struct page *hpage)
> +{
> +	lock_page(hpage);
> +	if (is_hugepage_on_freelist(hpage))
> +		__isolate_hwpoisoned_huge_page(hpage);
> +	unlock_page(hpage);
> +}

However it should still be racy if the test/isolate actions are
not performed in the same hugetlb_lock.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
