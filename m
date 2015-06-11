Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4606B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 05:49:53 -0400 (EDT)
Received: by wiga1 with SMTP id a1so70745229wig.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 02:49:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jt5si273718wjc.48.2015.06.11.02.49.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 02:49:51 -0700 (PDT)
Message-ID: <557959BC.5000303@suse.cz>
Date: Thu, 11 Jun 2015 11:49:48 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv6 29/36] thp: implement split_huge_pmd()
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com> <1433351167-125878-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-30-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/03/2015 07:06 PM, Kirill A. Shutemov wrote:
> Original split_huge_page() combined two operations: splitting PMDs into
> tables of PTEs and splitting underlying compound page. This patch
> implements split_huge_pmd() which split given PMD without splitting
> other PMDs this page mapped with or underlying compound page.
>
> Without tail page refcounting, implementation of split_huge_pmd() is
> pretty straight-forward.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

[...]

> +
> +	if (atomic_add_negative(-1, compound_mapcount_ptr(page))) {
> +		/* Last compound_mapcount is gone. */
> +		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
> +		if (PageDoubleMap(page)) {
> +			/* No need in mapcount reference anymore */
> +			ClearPageDoubleMap(page);
> +			for (i = 0; i < HPAGE_PMD_NR; i++)
> +				atomic_dec(&page[i]._mapcount);
> +		}
> +	} else if (!TestSetPageDoubleMap(page)) {
> +		/*
> +		 * The first PMD split for the compound page and we still
> +		 * have other PMD mapping of the page: bump _mapcount in
> +		 * every small page.
> +		 * This reference will go away with last compound_mapcount.
> +		 */
> +		for (i = 0; i < HPAGE_PMD_NR; i++)
> +			atomic_inc(&page[i]._mapcount);

The order of actions here means that between TestSetPageDoubleMap() and 
the atomic incs, anyone calling page_mapcount() on one of the pages not 
processed by the for loop yet, will see a value lower by 1 from what he 
should see. I wonder if that can cause any trouble somewhere, especially 
if there's only one other compound mapping and page_mapcount() will 
return 0 instead of 1?

Conversely, when clearing PageDoubleMap() above (or in one of those rmap 
functions IIRC), one could see mapcount inflated by one. But I guess 
that's less dangerous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
