Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id A976B6B06EC
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 06:33:12 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id t194-v6so779861oie.16
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 03:33:12 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k184-v6si2821554oif.155.2018.11.09.03.33.11
        for <linux-mm@kvack.org>;
        Fri, 09 Nov 2018 03:33:11 -0800 (PST)
Subject: Re: [RFC][PATCH v1 11/11] mm: hwpoison: introduce
 clear_hwpoison_free_buddy_page()
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-12-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <d37c1be2-2069-a147-9ba8-4749cd386d0b@arm.com>
Date: Fri, 9 Nov 2018 17:03:06 +0530
MIME-Version: 1.0
In-Reply-To: <1541746035-13408-12-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>



On 11/09/2018 12:17 PM, Naoya Horiguchi wrote:
> The new function is a reverse operation of set_hwpoison_free_buddy_page()
> to adjust unpoison_memory() to the new semantics.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

snip

> +
> +/*
> + * Reverse operation of set_hwpoison_free_buddy_page(), which is expected
> + * to work only on error pages isolated from buddy allocator.
> + */
> +bool clear_hwpoison_free_buddy_page(struct page *page)
> +{
> +	struct zone *zone = page_zone(page);
> +	bool unpoisoned = false;
> +
> +	spin_lock(&zone->lock);
> +	if (TestClearPageHWPoison(page)) {
> +		unsigned long pfn = page_to_pfn(page);
> +		int migratetype = get_pfnblock_migratetype(page, pfn);
> +
> +		__free_one_page(page, pfn, zone, 0, migratetype);
> +		unpoisoned = true;
> +	}
> +	spin_unlock(&zone->lock);
> +	return unpoisoned;
> +}
>  #endif
> 

Though there are multiple page state checks in unpoison_memory() leading
upto clearing HWPoison flag, the page must not be in buddy already if
__free_one_page() would be called on it.
