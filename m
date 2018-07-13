Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6439C6B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:40:06 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d22-v6so2604236pls.4
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 13:40:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m13-v6si24327012pls.70.2018.07.13.13.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 13:40:05 -0700 (PDT)
Date: Fri, 13 Jul 2018 13:40:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1 2/2] mm: soft-offline: close the race against page
 allocation
Message-Id: <20180713134002.a365049a79d41be3c28916cc@linux-foundation.org>
In-Reply-To: <1531452366-11661-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1531452366-11661-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1531452366-11661-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, xishi.qiuxishi@alibaba-inc.com, zy.zhengyi@alibaba-inc.com, linux-kernel@vger.kernel.org

On Fri, 13 Jul 2018 12:26:06 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> A process can be killed with SIGBUS(BUS_MCEERR_AR) when it tries to
> allocate a page that was just freed on the way of soft-offline.
> This is undesirable because soft-offline (which is about corrected error)
> is less aggressive than hard-offline (which is about uncorrected error),
> and we can make soft-offline fail and keep using the page for good reason
> like "system is busy."
> 
> Two main changes of this patch are:
> 
> - setting migrate type of the target page to MIGRATE_ISOLATE. As done
>   in free_unref_page_commit(), this makes kernel bypass pcplist when
>   freeing the page. So we can assume that the page is in freelist just
>   after put_page() returns,
> 
> - setting PG_hwpoison on free page under zone->lock which protects
>   freelists, so this allows us to avoid setting PG_hwpoison on a page
>   that is decided to be allocated soon.
> 
>
> ...
>
> +
> +#ifdef CONFIG_MEMORY_FAILURE
> +/*
> + * Set PG_hwpoison flag if a given page is confirmed to be a free page
> + * within zone lock, which prevents the race against page allocation.
> + */

I think this is clearer?

--- a/mm/page_alloc.c~mm-soft-offline-close-the-race-against-page-allocation-fix
+++ a/mm/page_alloc.c
@@ -8039,8 +8039,9 @@ bool is_free_buddy_page(struct page *pag
 
 #ifdef CONFIG_MEMORY_FAILURE
 /*
- * Set PG_hwpoison flag if a given page is confirmed to be a free page
- * within zone lock, which prevents the race against page allocation.
+ * Set PG_hwpoison flag if a given page is confirmed to be a free page.  This
+ * test is performed under the zone lock to prevent a race against page
+ * allocation.
  */
 bool set_hwpoison_free_buddy_page(struct page *page)
 {

> +bool set_hwpoison_free_buddy_page(struct page *page)
> +{
> +	struct zone *zone = page_zone(page);
> +	unsigned long pfn = page_to_pfn(page);
> +	unsigned long flags;
> +	unsigned int order;
> +	bool hwpoisoned = false;
> +
> +	spin_lock_irqsave(&zone->lock, flags);
> +	for (order = 0; order < MAX_ORDER; order++) {
> +		struct page *page_head = page - (pfn & ((1 << order) - 1));
> +
> +		if (PageBuddy(page_head) && page_order(page_head) >= order) {
> +			if (!TestSetPageHWPoison(page))
> +				hwpoisoned = true;
> +			break;
> +		}
> +	}
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +
> +	return hwpoisoned;
> +}
> +#endif
