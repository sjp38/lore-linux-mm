Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A942F6B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 19:53:21 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v69so5007205wrb.3
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 16:53:21 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n2si276168wmc.106.2017.12.07.16.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 16:53:20 -0800 (PST)
Date: Thu, 7 Dec 2017 16:53:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: page_alloc: avoid excessive IRQ disabled times in
 free_unref_page_list
Message-Id: <20171207165317.9ef234b9f83cb62cdad72427@linux-foundation.org>
In-Reply-To: <20171208002537.z6h3v2yojnlcu3ai@techsingularity.net>
References: <20171207170314.4419-1-l.stach@pengutronix.de>
	<20171207195103.dkiqjoeasr35atqj@techsingularity.net>
	<20171207152059.96ebc2f7dfd1a65a91252029@linux-foundation.org>
	<20171208002537.z6h3v2yojnlcu3ai@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Lucas Stach <l.stach@pengutronix.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

On Fri, 8 Dec 2017 00:25:37 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

> Well, it's release_pages. From core VM and the block layer, not very long
> but for drivers and filesystems, it can be arbitrarily long. Even from the
> VM, the function can be called a lot but as it's from pagevec context so
> it's naturally broken into small pieces anyway.

OK.

> > If "significantly" then there may be additional benefit in rearranging
> > free_hot_cold_page_list() so it only walks a small number of list
> > entries at a time.  So the data from the first loop is still in cache
> > during execution of the second loop.  And that way this
> > long-irq-off-time problem gets fixed automagically.
> > 
> 
> I'm not sure it's worthwhile. In too many cases, the list of pages being
> released are either cache cold or are so long that the cache data is
> being thrashed anyway.

Well, whether the incoming data is cache-cold or very-long, doing that
double pass in small bites would reduce thrashing.

> Once the core page allocator is involved, then
> there will be further cache thrashing due to buddy page merging accessing
> data that is potentially very close. I think it's unlikely there would be
> much value in using alternative schemes unless we were willing to have
> very large per-cpu lists -- something I prototyped for fast networking
> but never heard back whether it's worthwhile or not.

I mean something like this....

(strangely indented for clarity)

--- a/mm/page_alloc.c~a
+++ a/mm/page_alloc.c
@@ -2685,12 +2685,17 @@ void free_unref_page_list(struct list_he
 	struct page *page, *next;
 	unsigned long flags, pfn;
 
+while (!list_empty(list)) {
+	unsigned batch = 0;
+
 	/* Prepare pages for freeing */
 	list_for_each_entry_safe(page, next, list, lru) {
 		pfn = page_to_pfn(page);
 		if (!free_unref_page_prepare(page, pfn))
 			list_del(&page->lru);
 		set_page_private(page, pfn);
+		if (batch++ == SWAP_CLUSTER_MAX)
+			break;
 	}
 
 	local_irq_save(flags);
@@ -2699,8 +2704,10 @@ void free_unref_page_list(struct list_he
 
 		set_page_private(page, 0);
 		trace_mm_page_free_batched(page);
+		list_del(&page->lru);	/* now needed, I think? */
 		free_unref_page_commit(page, pfn);
 	}
+}
 	local_irq_restore(flags);
 }
 

But I agree that freeing of a lengthy list is likely to be rare.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
