Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id C436A6B006E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 11:44:34 -0400 (EDT)
Received: by wigg3 with SMTP id g3so52930443wig.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 08:44:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb18si10523971wib.69.2015.06.10.08.44.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 08:44:33 -0700 (PDT)
Message-ID: <55785B5E.3000306@suse.cz>
Date: Wed, 10 Jun 2015 17:44:30 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv6 32/36] thp: reintroduce split_huge_page()
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com> <1433351167-125878-33-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-33-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/03/2015 07:06 PM, Kirill A. Shutemov wrote:
> This patch adds implementation of split_huge_page() for new
> refcountings.
>
> Unlike previous implementation, new split_huge_page() can fail if
> somebody holds GUP pin on the page. It also means that pin on page
> would prevent it from bening split under you. It makes situation in
> many places much cleaner.
>
> The basic scheme of split_huge_page():
>
>    - Check that sum of mapcounts of all subpage is equal to page_count()
>      plus one (caller pin). Foll off with -EBUSY. This way we can avoid
>      useless PMD-splits.
>
>    - Freeze the page counters by splitting all PMD and setup migration
>      PTEs.
>
>    - Re-check sum of mapcounts against page_count(). Page's counts are
>      stable now. -EBUSY if page is pinned.
>
>    - Split compound page.
>
>    - Unfreeze the page by removing migration entries.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

[...]

> +
> +static int __split_huge_page_tail(struct page *head, int tail,
> +		struct lruvec *lruvec, struct list_head *list)
> +{
> +	int mapcount;
> +	struct page *page_tail = head + tail;
> +
> +	mapcount = page_mapcount(page_tail);

Isn't page_mapcount() unnecessarily heavyweight here? When you are 
splitting a page, it already should have zero compound_mapcount() and 
shouldn't be PageDoubleMap(), no? So you should care about 
page->_mapcount only? Sure, splitting THP is not a hotpath, but when 
done 512 times per split, it could make some difference in the split's 
latency.

> +	VM_BUG_ON_PAGE(atomic_read(&page_tail->_count) != 0, page_tail);
> +
> +	/*
> +	 * tail_page->_count is zero and not changing from under us. But
> +	 * get_page_unless_zero() may be running from under us on the
> +	 * tail_page. If we used atomic_set() below instead of atomic_add(), we
> +	 * would then run atomic_set() concurrently with
> +	 * get_page_unless_zero(), and atomic_set() is implemented in C not
> +	 * using locked ops. spin_unlock on x86 sometime uses locked ops
> +	 * because of PPro errata 66, 92, so unless somebody can guarantee
> +	 * atomic_set() here would be safe on all archs (and not only on x86),
> +	 * it's safer to use atomic_add().

I would be surprised if this was the first place to use atomic_set() 
with potential concurrent atomic_add(). Shouldn't atomic_*() API 
guarantee that this works?

> +	 */
> +	atomic_add(page_mapcount(page_tail) + 1, &page_tail->_count);

You already have the value in mapcount variable, so why read it again.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
