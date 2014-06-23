Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 55E606B0036
	for <linux-mm@kvack.org>; Sun, 22 Jun 2014 23:04:59 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id rp16so5285151pbb.37
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 20:04:59 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id qs8si19758130pbb.206.2014.06.22.20.04.57
        for <linux-mm@kvack.org>;
        Sun, 22 Jun 2014 20:04:58 -0700 (PDT)
Date: Mon, 23 Jun 2014 12:05:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 09/13] mm, compaction: skip buddy pages by their order
 in the migrate scanner
Message-ID: <20140623030541.GE12413@bbox>
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
 <1403279383-5862-10-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1403279383-5862-10-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On Fri, Jun 20, 2014 at 05:49:39PM +0200, Vlastimil Babka wrote:
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
> pages scanned by migration scanner. This change is also a prerequisite for a
> later patch which is detecting when a cc->order block of pages contains
> non-buddy pages that cannot be isolated, and the scanner should thus skip to
> the next block immediately.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
