Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 19EB76B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 04:00:59 -0400 (EDT)
Message-ID: <4FF3F864.3000204@kernel.org>
Date: Wed, 04 Jul 2012 17:01:40 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off where
 it left
References: <20120628135520.0c48b066@annuminas.surriel.com> <20120628135940.2c26ada9.akpm@linux-foundation.org> <4FECCB89.2050400@redhat.com> <20120628143546.d02d13f9.akpm@linux-foundation.org> <1341250950.16969.6.camel@lappy> <4FF2435F.2070302@redhat.com> <20120703101024.GG13141@csn.ul.ie> <20120703144808.4daa4244.akpm@linux-foundation.org> <4FF3ABA1.3070808@kernel.org> <20120704004219.47d0508d.akpm@linux-foundation.org>
In-Reply-To: <20120704004219.47d0508d.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Sasha Levin <levinsasha928@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaschut@sandia.gov, kamezawa.hiroyu@jp.fujitsu.com, Dave Jones <davej@redhat.com>

On 07/04/2012 04:42 PM, Andrew Morton wrote:

> On Wed, 04 Jul 2012 11:34:09 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
>>> The rest of this patch takes care to ensure that
>>> ->compact_cached_free_pfn is aligned to pageblock_nr_pages.  But it now
>>> appears that this particular site will violate that.
>>>
>>> What's up?  Do we need to fix this site, or do we remove all that
>>> make-compact_cached_free_pfn-aligned code?
>>
>>
>> I vote removing the warning because it doesn't related to Rik's incremental compaction.
>> Let's see. 
>>
>> high_pfn = min(low_pfn, pfn) = cc->migrate_pfn + pageblock_nr_pages.
>> In here, cc->migrate_pfn isn't necessarily pageblock aligined.
>> So if we don't consider compact_cached_free_pfn, it can hit.
>>
>> static void isolate_freepages()
>> {
>> 	high_pfn = min(low_pfn, pfn) = cc->migrate_pfn + pageblock_nr_pages;
>> 	for (..) {
>> 		...
>> 		 WARN_ON_ONCE(high_pfn & (pageblock_nr_pages - 1));
>> 		
>> 	}
>> }
> 
> Please, look at the patch.  In numerous places it is aligning

> compact_cached_free_pfn to a multiple of pageblock_nr_pages.  But in

> one place it doesn't do that.  So are all those alignment operations
> necessary?


I mean if you *really* want to check the align, you should do following as

barrios@bbox:~/linux-memcg$ git diff
diff --git a/mm/compaction.c b/mm/compaction.c
index 6bb3e9f..12416d4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -467,16 +467,18 @@ static void isolate_freepages(struct zone *zone,
                }
                spin_unlock_irqrestore(&zone->lock, flags);
 
-               WARN_ON_ONCE(high_pfn & (pageblock_nr_pages - 1));
                /*
                 * Record the highest PFN we isolated pages from. When next
                 * looking for free pages, the search will restart here as
                 * page migration may have returned some pages to the allocator
                 */
-               if (isolated)
+               if (isolated) {
                        high_pfn = max(high_pfn, pfn);
-               if (cc->order > 0)
-                       zone->compact_cached_free_pfn = high_pfn;
+                       if (cc->order > 0) {
+                               WARN_ON_ONCE(high_pfn & (pageblock_nr_pages - 1));
+                               zone->compact_cached_free_pfn = high_pfn;
+                       }
+               }
        }
 
        /* split_free_page does not map the pages */


Because high_pfn could be not aligned in loop if it doesn't reset by max(high_pfn, pfn).
and it's legal. So regardless of Rik's patch, if you add such warning in that code,
it could emit WARNING, too. Rik already sent a patch which was similar to above
but he wanted to solve WARN_ON_ONCE problem by someone else.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
