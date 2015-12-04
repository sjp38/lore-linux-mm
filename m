Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0C26B6B0259
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 10:17:08 -0500 (EST)
Received: by wmvv187 with SMTP id v187so79142030wmv.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 07:17:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bt17si7664467wjb.137.2015.12.04.07.17.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Dec 2015 07:17:05 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/3] mm, page_owner: provide symbolic page flags and gfp_flags
Date: Fri,  4 Dec 2015 16:16:34 +0100
Message-Id: <1449242195-16374-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1449242195-16374-1-git-send-email-vbabka@suse.cz>
References: <87io4hi06n.fsf@rasmusvillemoes.dk>
 <1449242195-16374-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

With the new format strings for flags, we can now provide symbolic page and gfp
flags in the /sys/kernel/debug/page_owner file. This replaces the positional
printing of page flags as single letters, which might have looked nicer, but
was limited to a subset of flags, and required the user to remember the
letters.

Example of the adjusted format:

Page allocated via order 0, mask 0x24213ca(GFP_HIGHUSER_MOVABLE|GFP_COLD|GFP_NOWARN|GFP_NORETRY)
PFN 674308 type Movable Block 1317 type Movable Flags 0x1fffff80010068(uptodate|lru|active|mappedtodisk)
 [<ffffffff81164e9a>] __alloc_pages_nodemask+0x15a/0xa30
 [<ffffffff811ab938>] alloc_pages_current+0x88/0x120
 [<ffffffff8115bc46>] __page_cache_alloc+0xe6/0x120
 [<ffffffff81168b9b>] __do_page_cache_readahead+0xdb/0x200
 [<ffffffff81168df5>] ondemand_readahead+0x135/0x260
 [<ffffffff81168f8c>] page_cache_async_readahead+0x6c/0x70
 [<ffffffff8115d5f8>] generic_file_read_iter+0x378/0x590
 [<ffffffff811d12a7>] __vfs_read+0xa7/0xd0
Page has been migrated, last migrate reason: compaction

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
---
 mm/page_owner.c | 20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 313251f36d86..011377548b4f 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -135,8 +135,9 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		return -ENOMEM;
 
 	ret = snprintf(kbuf, count,
-			"Page allocated via order %u, mask 0x%x\n",
-			page_ext->order, page_ext->gfp_mask);
+			"Page allocated via order %u, mask %#x(%pgg)\n",
+			page_ext->order, page_ext->gfp_mask,
+			&page_ext->gfp_mask);
 
 	if (ret >= count)
 		goto err;
@@ -145,23 +146,12 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	pageblock_mt = get_pfnblock_migratetype(page, pfn);
 	page_mt  = gfpflags_to_migratetype(page_ext->gfp_mask);
 	ret += snprintf(kbuf + ret, count - ret,
-			"PFN %lu type %s Block %lu type %s Flags %s%s%s%s%s%s%s%s%s%s%s%s\n",
+			"PFN %lu type %s Block %lu type %s Flags %#lx(%pgp)\n",
 			pfn,
 			migratetype_names[page_mt],
 			pfn >> pageblock_order,
 			migratetype_names[pageblock_mt],
-			PageLocked(page)	? "K" : " ",
-			PageError(page)		? "E" : " ",
-			PageReferenced(page)	? "R" : " ",
-			PageUptodate(page)	? "U" : " ",
-			PageDirty(page)		? "D" : " ",
-			PageLRU(page)		? "L" : " ",
-			PageActive(page)	? "A" : " ",
-			PageSlab(page)		? "S" : " ",
-			PageWriteback(page)	? "W" : " ",
-			PageCompound(page)	? "C" : " ",
-			PageSwapCache(page)	? "B" : " ",
-			PageMappedToDisk(page)	? "M" : " ");
+			page->flags, &page->flags);
 
 	if (ret >= count)
 		goto err;
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
