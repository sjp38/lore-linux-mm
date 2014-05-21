Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 784C66B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 10:13:45 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so1638275eek.16
        for <linux-mm@kvack.org>; Wed, 21 May 2014 07:13:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 45si9060987eeq.4.2014.05.21.07.13.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 07:13:43 -0700 (PDT)
Message-ID: <537CB493.9090706@suse.cz>
Date: Wed, 21 May 2014 16:13:39 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm, compaction: properly signal and act upon lock
 and need_sched() contention
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz>	<1400233673-11477-1-git-send-email-vbabka@suse.cz> <20140519163741.55998ce65534ed73d913ee2c@linux-foundation.org>
In-Reply-To: <20140519163741.55998ce65534ed73d913ee2c@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 05/20/2014 01:37 AM, Andrew Morton wrote:
> On Fri, 16 May 2014 11:47:53 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> Compaction uses compact_checklock_irqsave() function to periodically check for
>> lock contention and need_resched() to either abort async compaction, or to
>> free the lock, schedule and retake the lock. When aborting, cc->contended is
>> set to signal the contended state to the caller. Two problems have been
>> identified in this mechanism.
>>
>> First, compaction also calls directly cond_resched() in both scanners when no
>> lock is yet taken. This call either does not abort async compaction, or set
>> cc->contended appropriately. This patch introduces a new compact_should_abort()
>> function to achieve both. In isolate_freepages(), the check frequency is
>> reduced to once by SWAP_CLUSTER_MAX pageblocks to match what the migration
>> scanner does in the preliminary page checks. In case a pageblock is found
>> suitable for calling isolate_freepages_block(), the checks within there are
>> done on higher frequency.
>>
>> Second, isolate_freepages() does not check if isolate_freepages_block()
>> aborted due to contention, and advances to the next pageblock. This violates
>> the principle of aborting on contention, and might result in pageblocks not
>> being scanned completely, since the scanning cursor is advanced. This patch
>> makes isolate_freepages_block() check the cc->contended flag and abort.
>>
>> In case isolate_freepages() has already isolated some pages before aborting
>> due to contention, page migration will proceed, which is OK since we do not
>> want to waste the work that has been done, and page migration has own checks
>> for contention. However, we do not want another isolation attempt by either
>> of the scanners, so cc->contended flag check is added also to
>> compaction_alloc() and compact_finished() to make sure compaction is aborted
>> right after the migration.
> 
> What are the runtime effect of this change?
> 
>> Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> What did Joonsoo report?  Perhaps this is the same thing..

Updated log message:

Compaction uses compact_checklock_irqsave() function to periodically check for
lock contention and need_resched() to either abort async compaction, or to
free the lock, schedule and retake the lock. When aborting, cc->contended is
set to signal the contended state to the caller. Two problems have been
identified in this mechanism.

First, compaction also calls directly cond_resched() in both scanners when no
lock is yet taken. This call either does not abort async compaction, or set
cc->contended appropriately. This patch introduces a new compact_should_abort()
function to achieve both. In isolate_freepages(), the check frequency is
reduced to once by SWAP_CLUSTER_MAX pageblocks to match what the migration
scanner does in the preliminary page checks. In case a pageblock is found
suitable for calling isolate_freepages_block(), the checks within there are
done on higher frequency.

Second, isolate_freepages() does not check if isolate_freepages_block()
aborted due to contention, and advances to the next pageblock. This violates
the principle of aborting on contention, and might result in pageblocks not
being scanned completely, since the scanning cursor is advanced. This problem
has been noticed in the code by Joonsoo Kim when reviewing related patches.
This patch makes isolate_freepages_block() check the cc->contended flag and
abort.

In case isolate_freepages() has already isolated some pages before aborting
due to contention, page migration will proceed, which is OK since we do not
want to waste the work that has been done, and page migration has own checks
for contention. However, we do not want another isolation attempt by either
of the scanners, so cc->contended flag check is added also to
compaction_alloc() and compact_finished() to make sure compaction is aborted
right after the migration.

The outcome of the patch should be reduced lock contention by async compaction
and lower latencies for higher-order allocations where direct compaction is
involved.

>>
>> ...
>>
>> @@ -718,9 +739,11 @@ static void isolate_freepages(struct zone *zone,
>>   		/*
>>   		 * This can iterate a massively long zone without finding any
>>   		 * suitable migration targets, so periodically check if we need
>> -		 * to schedule.
>> +		 * to schedule, or even abort async compaction.
>>   		 */
>> -		cond_resched();
>> +		if (!(block_start_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages))
>> +						&& compact_should_abort(cc))
> 
> This seems rather gratuitously inefficient and isn't terribly clear.
> What's wrong with
> 
> 	if ((++foo % SWAP_CLUSTER_MAX) == 0 && compact_should_abort(cc))

It's a new variable and it differs from how isolate_migratepages_range() does this.
But yeah, I might change it later there as well. There it makes even more sense.
E.g. when skipping whole pageblock there, pfn % SWAP_CLUSTER_MAX will be always zero
so the periodicity varies.
 
> ?
> 
> (Assumes that SWAP_CLUSTER_MAX is power-of-2 and that the compiler will
> use &)
 
I hoped that compiler would be smart enough about SWAP_CLUSTER_MAX * pageblock_nr_pages
as well, as those are constants and also power-of-2. But I didn't check the assembly.

-----8<-----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Wed, 21 May 2014 16:07:21 +0200
Subject: [PATCH] 
 mm-compaction-properly-signal-and-act-upon-lock-and-need_sched-contention-fix

Use a separate counter variable (not pfn) to trigger abort checks.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index bbe6a26..23c7439 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -779,6 +779,7 @@ static void isolate_freepages(struct zone *zone,
 	unsigned long block_start_pfn;	/* start of current pageblock */
 	unsigned long block_end_pfn;	/* end of current pageblock */
 	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
+	unsigned long nr_blocks_scanned = 0; /* for periodical abort checks */
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
@@ -813,7 +814,7 @@ static void isolate_freepages(struct zone *zone,
 		 * suitable migration targets, so periodically check if we need
 		 * to schedule, or even abort async compaction.
 		 */
-		if (!(block_start_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages))
+		if ((++nr_blocks_scanned % SWAP_CLUSTER_MAX) == 0
 						&& compact_should_abort(cc))
 			break;
 
-- 
1.8.4.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
