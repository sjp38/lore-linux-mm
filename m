Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 59EA0900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 05:14:09 -0400 (EDT)
Received: by wibdt2 with SMTP id dt2so4737353wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 02:14:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dt1si29560603wib.46.2015.06.03.02.14.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Jun 2015 02:14:07 -0700 (PDT)
Message-ID: <556EC55D.40105@suse.cz>
Date: Wed, 03 Jun 2015 11:14:05 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] compaction: fix isolate_migratepages_block() for THP=n
References: <1430134006-215317-1-git-send-email-kirill.shutemov@linux.intel.com> <20150428151420.227e7ac34745e9fe8e9bc145@linux-foundation.org> <20150428222828.GA6072@node.dhcp.inet.fi> <20150428153724.cbe99bef1e7c2f073755539a@linux-foundation.org> <20150428224442.GA6188@node.dhcp.inet.fi>
In-Reply-To: <20150428224442.GA6188@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

On 04/29/2015 12:44 AM, Kirill A. Shutemov wrote:
>>>
>>> I wrote this to fix bug I originally attributed to refcounting patchset,
>>> but Sasha triggered the same bug on -next without the patchset applied:
>>>
>>> http://lkml.kernel.org/g/553EB993.7030401@oracle.com
>>
>> Well why the heck didn't the changelog tell us this?!?!?
> 
> Sasha reported bug in -next after I sent the patch.
> 
>>
>>> Now I think it's related to changing of PageLRU() behaviour on tail page
>>> by my page flags patchset.
>>
>> So this patch is a bugfix against one of
>>
>> page-flags-trivial-cleanup-for-pagetrans-helpers.patch
>> page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
>> page-flags-define-pg_locked-behavior-on-compound-pages.patch
>> page-flags-define-behavior-of-fs-io-related-flags-on-compound-pages.patch
>> page-flags-define-behavior-of-lru-related-flags-on-compound-pages.patch
> 
> ^^^ this one is fault, I think.

So this patch is now:
http://www.ozlabs.org/~akpm/mmotm/broken-out/page-flags-define-behavior-of-lru-related-flags-on-compound-pages-fix.patch

I've found a non-fatal but misleading issues.

First, the "will fail to detect hugetlb pages in this case" part of the
changelog, and mention of hugetlbfs in the comment is AFAIK moot.
There's a PageLRU() check preceding the compound check, so hugetlbfs
pages (which are not PageLRU() AFAIK) are already skipped at that point.
I want to improve that in another series, but that's out of scope here.

Second, compound_order(page) returns 0 for a tail page, so the ALIGN()
trick that's supposed to properly advance pfn from a tail page is
useless. We could grab a head page, but stumbling on a THP tail page
should be very rare so it's not worth the trouble - just remove the ALIGN.

From: Vlastimil Babka <vbabka@suse.cz>
Date: Wed, 3 Jun 2015 11:03:37 +0200
Subject: [PATCH] page-flags-define-behavior-of-lru-related-flags-on-compound-pages-fix-fix

Mentioning hugetlbfs is misleading, because PageLRU() checks skip over hugetlb pages.
The ALIGN() parts are useless, because compound_order(page) returns 0 for tail pages.

---
 mm/compaction.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 6ef2fdf..16e1b57 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -733,9 +733,12 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 * if PageLRU is set) but the lock is not necessarily taken
 		 * here and it is wasteful to take it just to check transhuge.
 		 * Check PageCompound without lock and skip the whole pageblock
-		 * if it's either a transhuge or hugetlbfs page, as calling
-		 * compound_order() without preventing THP from splitting the
-		 * page underneath us may return surprising results.
+		 * if it's a transhuge page, as calling compound_order()
+		 * without preventing THP from splitting the page underneath us
+		 * may return surprising results.
+		 * If we happen to check a THP tail page, compound_order()
+		 * returns 0. It should be rare enough to not bother with
+		 * using compound_head() in that case.
 		 */
 		if (PageCompound(page)) {
 			int nr;
@@ -743,7 +746,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 				nr = 1 << compound_order(page);
 			else
 				nr = pageblock_nr_pages;
-			low_pfn = ALIGN(low_pfn + 1, nr) - 1;
+			low_pfn += nr - 1;
 			continue;
 		}
 
@@ -768,7 +771,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 				continue;
 			if (PageCompound(page)) {
 				int nr = 1 << compound_order(page);
-				low_pfn = ALIGN(low_pfn + 1, nr) - 1;
+				low_pfn += nr - 1;
 				continue;
 			}
 		}
-- 
2.1.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
