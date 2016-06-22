Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76AD76B0253
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 17:56:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 143so132750036pfx.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 14:56:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id em6si2174727pac.71.2016.06.22.14.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 14:56:18 -0700 (PDT)
Date: Wed, 22 Jun 2016 14:56:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, compaction: abort free scanner if split fails
Message-Id: <20160622145617.79197acff1a7e617b9d9d393@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1606211820350.97086@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1606211447001.43430@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1606211820350.97086@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Tue, 21 Jun 2016 18:22:49 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> If the memory compaction free scanner cannot successfully split a free
> page (only possible due to per-zone low watermark), terminate the free 
> scanner rather than continuing to scan memory needlessly.  If the 
> watermark is insufficient for a free page of order <= cc->order, then 
> terminate the scanner since all future splits will also likely fail.
> 
> This prevents the compaction freeing scanner from scanning all memory on 
> very large zones (very noticeable for zones > 128GB, for instance) when 
> all splits will likely fail while holding zone->lock.
> 

This collides pretty heavily with Joonsoo's "mm/compaction: split
freepages without holding the zone lock".

I ended up with this, in isolate_freepages_block():

		/* Found a free page, will break it into order-0 pages */
		order = page_order(page);
		isolated = __isolate_free_page(page, page_order(page));
		set_page_private(page, order);

		total_isolated += isolated;
		cc->nr_freepages += isolated;
		list_add_tail(&page->lru, freelist);

		if (!strict && cc->nr_migratepages <= cc->nr_freepages) {
			blockpfn += isolated;
			break;
		}
		/* Advance to the end of split page */
		blockpfn += isolated - 1;
		cursor += isolated - 1;
		continue;

isolate_fail:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
