Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3A92F9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 08:26:01 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so161057868wib.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 05:26:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s20si525736wjw.189.2015.07.22.05.25.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 05:25:59 -0700 (PDT)
Message-ID: <55AF8BD2.6060009@suse.cz>
Date: Wed, 22 Jul 2015 14:25:54 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm, page_isolation: remove bogus tests for isolated
 pages
References: <55969822.9060907@suse.cz> <1437483218-18703-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507211540080.3833@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507211540080.3833@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "minkyung88.kim" <minkyung88.kim@lge.com>, kmk3210@gmail.com, Seungho Park <seungho1.park@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On 07/22/2015 12:43 AM, David Rientjes wrote:
> On Tue, 21 Jul 2015, Vlastimil Babka wrote:
> 
> 
> You may want to consider stating your assumptions explicitly in the code,
> perhaps with VM_BUG_ON(), such as in free_pcppages_bulk() to ensure things
> like get_freepage_migratetype(page) != MIGRATE_ISOLATE.

Hm, OK here's a fixup. I've pondered others but nothing made sense
unless I would have to devise really twisted ways in which somebody
broke the code in the future, and that's not worth BUG_ON().

But the checking made me realize that one more
set_freepage_migratetype() can be removed in the other patch, so I
will resend it.

------8<------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Wed, 22 Jul 2015 14:16:52 +0200
Subject: [PATCH 2/3] fixup! mm, page_isolation: remove bogus tests for
 isolated pages

---
 mm/page_alloc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 41dc650..c61fef8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -789,7 +789,11 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
+
 			mt = get_freepage_migratetype(page);
+			/* MIGRATE_ISOLATE page should not go to pcplists */
+			VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
+			/* Pageblock could have been isolated meanwhile */
 			if (unlikely(has_isolate_pageblock(zone)))
 				mt = get_pageblock_migratetype(page);
 
-- 
2.4.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
