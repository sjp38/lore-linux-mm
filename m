Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id C09736B0039
	for <linux-mm@kvack.org>; Mon, 12 May 2014 05:51:40 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d49so4501065eek.1
        for <linux-mm@kvack.org>; Mon, 12 May 2014 02:51:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si10097347eef.142.2014.05.12.02.51.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 02:51:39 -0700 (PDT)
Message-ID: <537099A7.4060501@suse.cz>
Date: Mon, 12 May 2014 11:51:35 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/2] mm/compaction: do not count migratepages when
 unnecessary
References: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com> <1399464550-26447-1-git-send-email-vbabka@suse.cz> <xa1ty4ybvtq4.fsf@mina86.com>
In-Reply-To: <xa1ty4ybvtq4.fsf@mina86.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 05/09/2014 05:48 PM, Michal Nazarewicz wrote:
> On Wed, May 07 2014, Vlastimil Babka wrote:
>> During compaction, update_nr_listpages() has been used to count remaining
>> non-migrated and free pages after a call to migrage_pages(). The freepages
>> counting has become unneccessary, and it turns out that migratepages counting
>> is also unnecessary in most cases.
>>
>> The only situation when it's needed to count cc->migratepages is when
>> migrate_pages() returns with a negative error code. Otherwise, the non-negative
>> return value is the number of pages that were not migrated, which is exactly
>> the count of remaining pages in the cc->migratepages list.
>>
>> Furthermore, any non-zero count is only interesting for the tracepoint of
>> mm_compaction_migratepages events, because after that all remaining unmigrated
>> pages are put back and their count is set to 0.
>>
>> This patch therefore removes update_nr_listpages() completely, and changes the
>> tracepoint definition so that the manual counting is done only when the
>> tracepoint is enabled, and only when migrate_pages() returns a negative error
>> code.
>>
>> Furthermore, migrate_pages() and the tracepoints won't be called when there's
>> nothing to migrate. This potentially avoids some wasted cycles and reduces the
>> volume of uninteresting mm_compaction_migratepages events where "nr_migrated=0
>> nr_failed=0". In the stress-highalloc mmtest, this was about 75% of the events.
>> The mm_compaction_isolate_migratepages event is better for determining that
>> nothing was isolated for migration, and this one was just duplicating the info.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
>> Cc: Michal Nazarewicz <mina86@mina86.com>
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> 
> One tiny comment below:
> 
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> ---
>>   v2: checkpack and other non-functional fixes suggested by Naoya Horiguchi
>>
>>   include/trace/events/compaction.h | 26 ++++++++++++++++++++++----
>>   mm/compaction.c                   | 31 +++++++------------------------
>>   2 files changed, 29 insertions(+), 28 deletions(-)
>>
>> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
>> index 06f544e..aacaf0f 100644
>> --- a/include/trace/events/compaction.h
>> +++ b/include/trace/events/compaction.h
>> @@ -58,7 +61,22 @@ TRACE_EVENT(mm_compaction_migratepages,
>>   	),
>>   
>>   	TP_fast_assign(
>> -		__entry->nr_migrated = nr_migrated;
>> +		unsigned long nr_failed = 0;
>> +		struct page *page;
>> +
>> +		/*
>> +		 * migrate_pages() returns either a non-negative number
>> +		 * with the number of pages that failed migration, or an
>> +		 * error code, in which case we need to count the remaining
>> +		 * pages manually
>> +		 */
>> +		if (migrate_rc >= 0)
>> +			nr_failed = migrate_rc;
>> +		else
>> +			list_for_each_entry(page, migratepages, lru)
>> +				nr_failed++;
> 
> list_for_each would suffice here.
> 
>> +
>> +		__entry->nr_migrated = nr_all - nr_failed;
>>   		__entry->nr_failed = nr_failed;
>>   	),
>>   

Right, thanks!

-----8<-----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Mon, 12 May 2014 10:56:11 +0200
Subject: [PATCH] mm-compaction-do-not-count-migratepages-when-unnecessary-fix

list_for_each is enough for counting the list length. We also avoid including
struct page definition this way.

Suggested-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/trace/events/compaction.h | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index aacaf0f..c6814b9 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -7,7 +7,6 @@
 #include <linux/types.h>
 #include <linux/list.h>
 #include <linux/tracepoint.h>
-#include <linux/mm_types.h>
 #include <trace/events/gfpflags.h>
 
 DECLARE_EVENT_CLASS(mm_compaction_isolate_template,
@@ -62,7 +61,7 @@ TRACE_EVENT(mm_compaction_migratepages,
 
 	TP_fast_assign(
 		unsigned long nr_failed = 0;
-		struct page *page;
+		struct list_head *page_lru;
 
 		/*
 		 * migrate_pages() returns either a non-negative number
@@ -73,7 +72,7 @@ TRACE_EVENT(mm_compaction_migratepages,
 		if (migrate_rc >= 0)
 			nr_failed = migrate_rc;
 		else
-			list_for_each_entry(page, migratepages, lru)
+			list_for_each(page_lru, migratepages)
 				nr_failed++;
 
 		__entry->nr_migrated = nr_all - nr_failed;
-- 
1.8.4.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
