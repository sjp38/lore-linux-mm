Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id EC4C56B025A
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 01:18:50 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so150884323pdr.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 22:18:50 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id vf13si9006371pac.178.2015.07.22.22.18.49
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 22:18:50 -0700 (PDT)
Date: Thu, 23 Jul 2015 14:23:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mm, page_isolation: remove bogus tests for isolated
 pages
Message-ID: <20150723052314.GC4449@js1304-P5Q-DELUXE>
References: <55969822.9060907@suse.cz>
 <1437483218-18703-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437483218-18703-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "minkyung88.kim" <minkyung88.kim@lge.com>, kmk3210@gmail.com, Seungho Park <seungho1.park@lge.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Tue, Jul 21, 2015 at 02:53:37PM +0200, Vlastimil Babka wrote:
> The __test_page_isolated_in_pageblock() is used to verify whether all pages
> in pageblock were either successfully isolated, or are hwpoisoned. Two of the
> possible state of pages, that are tested, are however bogus and misleading.
> 
> Both tests rely on get_freepage_migratetype(page), which however has no
> guarantees about pages on freelists. Specifically, it doesn't guarantee that
> the migratetype returned by the function actually matches the migratetype of
> the freelist that the page is on. Such guarantee is not its purpose and would
> have negative impact on allocator performance.
> 
> The first test checks whether the freepage_migratetype equals MIGRATE_ISOLATE,
> supposedly to catch races between page isolation and allocator activity. These
> races should be fixed nowadays with 51bb1a4093 ("mm/page_alloc: add freepage
> on isolate pageblock to correct buddy list") and related patches. As explained
> above, the check wouldn't be able to catch them reliably anyway. For the same
> reason false positives can happen, although they are harmless, as the
> move_freepages() call would just move the page to the same freelist it's
> already on. So removing the test is not a bug fix, just cleanup. After this
> patch, we assume that all PageBuddy pages are on the correct freelist and that
> the races were really fixed. A truly reliable verification in the form of e.g.
> VM_BUG_ON() would be complicated and is arguably not needed.
> 
> The second test (page_count(page) == 0 && get_freepage_migratetype(page)
> == MIGRATE_ISOLATE) is probably supposed (the code comes from a big memory
> isolation patch from 2007) to catch pages on MIGRATE_ISOLATE pcplists.
> However, pcplists don't contain MIGRATE_ISOLATE freepages nowadays, those are
> freed directly to free lists, so the check is obsolete. Remove it as well.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks for taking care of this.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
