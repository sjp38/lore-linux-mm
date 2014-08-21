Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E8FE06B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 18:11:18 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so15070376pac.3
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 15:11:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id km10si38098426pbd.132.2014.08.21.15.11.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Aug 2014 15:11:17 -0700 (PDT)
Date: Thu, 21 Aug 2014 15:11:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 11/13] mm, compaction: skip buddy pages by their
 order in the migrate scanner
Message-Id: <20140821151115.bcc66c15d53f7dc89d1b9b73@linux-foundation.org>
In-Reply-To: <1407142524-2025-12-git-send-email-vbabka@suse.cz>
References: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
	<1407142524-2025-12-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon,  4 Aug 2014 10:55:22 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> The migration scanner skips PageBuddy pages, but does not consider their order
> as checking page_order() is generally unsafe without holding the zone->lock,
> and acquiring the lock just for the check wouldn't be a good tradeoff.
> 
> Still, this could avoid some iterations over the rest of the buddy page, and
> if we are careful, the race window between PageBuddy() check and page_order()
> is small, and the worst thing that can happen is that we skip too much and miss
> some isolation candidates. This is not that bad, as compaction can already fail
> for many other reasons like parallel allocations, and those have much larger
> race window.
> 
> This patch therefore makes the migration scanner obtain the buddy page order
> and use it to skip the whole buddy page, if the order appears to be in the
> valid range.
> 
> It's important that the page_order() is read only once, so that the value used
> in the checks and in the pfn calculation is the same. But in theory the
> compiler can replace the local variable by multiple inlines of page_order().
> Therefore, the patch introduces page_order_unsafe() that uses ACCESS_ONCE to
> prevent this.
> 
> Testing with stress-highalloc from mmtests shows a 15% reduction in number of
> pages scanned by migration scanner. The reduction is >60% with __GFP_NO_KSWAPD
> allocations, along with success rates better by few percent.
> This change is also a prerequisite for a later patch which is detecting when
> a cc->order block of pages contains non-buddy pages that cannot be isolated,
> and the scanner should thus skip to the next block immediately.

What is this "later patch"?  Or is the changelog stale?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
