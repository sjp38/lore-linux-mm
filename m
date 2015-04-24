Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 791F46B006C
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 20:43:00 -0400 (EDT)
Received: by wizk4 with SMTP id k4so3618562wiz.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:43:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a9si1521541wie.64.2015.04.23.17.42.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 17:42:59 -0700 (PDT)
Message-ID: <55399189.5030608@redhat.com>
Date: Thu, 23 Apr 2015 19:42:49 -0500
From: Dean Nelson <dnelson@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: soft-offline: fix num_poisoned_pages counting on
 concurrent events
References: <1429589902-2765-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1429589902-2765-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 04/20/2015 11:18 PM, Naoya Horiguchi wrote:
> If multiple soft offline events hit one free page/hugepage concurrently,
> soft_offline_page() can handle the free page/hugepage multiple times,
> which makes num_poisoned_pages counter increased more than once.
> This patch fixes this wrong counting by checking TestSetPageHWPoison for
> normal papes and by checking the return value of dequeue_hwpoisoned_huge_page()
> for hugepages.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Dean Nelson <dnelson@redhat.com>


> Cc: stable@vger.kernel.org  # v3.14+
> ---
> # This problem might happen before 3.14, but it's rare and non-critical,
> # so I want this patch to be backported to stable trees only if the patch
> # cleanly applies (i.e. v3.14+).
> ---
>   mm/memory-failure.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git v4.0.orig/mm/memory-failure.c v4.0/mm/memory-failure.c
> index 2cc1d578144b..72a5224c8084 100644
> --- v4.0.orig/mm/memory-failure.c
> +++ v4.0/mm/memory-failure.c
> @@ -1721,12 +1721,12 @@ int soft_offline_page(struct page *page, int flags)
>   	} else if (ret == 0) { /* for free pages */
>   		if (PageHuge(page)) {
>   			set_page_hwpoison_huge_page(hpage);
> -			dequeue_hwpoisoned_huge_page(hpage);
> -			atomic_long_add(1 << compound_order(hpage),
> +			if (!dequeue_hwpoisoned_huge_page(hpage))
> +				atomic_long_add(1 << compound_order(hpage),
>   					&num_poisoned_pages);
>   		} else {
> -			SetPageHWPoison(page);
> -			atomic_long_inc(&num_poisoned_pages);
> +			if (!TestSetPageHWPoison(page))
> +				atomic_long_inc(&num_poisoned_pages);
>   		}
>   	}
>   	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
