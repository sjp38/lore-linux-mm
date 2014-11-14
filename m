Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id C2C0E6B00E9
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 03:52:35 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id a1so18877043wgh.34
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 00:52:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z19si2746988wiv.36.2014.11.14.00.52.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 00:52:34 -0800 (PST)
Message-ID: <5465C2CF.4000902@suse.cz>
Date: Fri, 14 Nov 2014 09:52:31 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mm, compaction: pass classzone_idx and alloc_flags
 to watermark checking
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz> <1412696019-21761-2-git-send-email-vbabka@suse.cz> <20141027064651.GA23379@js1304-P5Q-DELUXE> <544E0C43.3030009@suse.cz> <20141028071625.GB27813@js1304-P5Q-DELUXE> <5450F0CF.3030504@suse.cz> <20141031074944.GA14642@js1304-P5Q-DELUXE>
In-Reply-To: <20141031074944.GA14642@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 10/31/2014 08:49 AM, Joonsoo Kim wrote:
> On Wed, Oct 29, 2014 at 02:51:11PM +0100, Vlastimil Babka wrote:
>> On 10/28/2014 08:16 AM, Joonsoo Kim wrote:> On Mon, Oct 27, 2014 at
>> 10:11:31AM +0100, Vlastimil Babka wrote:
>>
>> I thought that the second check in compaction_suitable() makes sure
>> of this, but now I see it's in fact not.
>> But i'm not sure if we should just put the flags in the first check,
>> as IMHO the flags should only affect the final high-order
>> allocation, not also the temporary pages needed for migration?
> 
> I don't think so.
> As mentioned before, if we don't have not enough freepages, compaction
> will fail due to shortage of freepage at final high-order watermark
> check. Maybe it failes due to not enough freepage rather than ordered
> freepage. Proper flags and index make us avoid useless compaction so
> I prefer put the flags in the first check.
> 
>>
>> BTW now I'm not even sure that the 2UL << order part makes sense
>> anymore. The number of pages migrated at once is always restricted
>> by COMPACT_CLUSTER_MAX, so why would we need more than that to cover
>> migration?
> 
> In fact, any values seems to be wrong. We can isolate high order freepage
> for this temporary use. I don't have any idea what the proper value is.
> 
>> Also the order of checks seems wrong. It should return
>> COMPACT_PARTIAL "If the allocation would succeed without compaction"
>> but that only can happen after passing the check if the zone has the
>> extra 1UL << order for migration. Do you agree?
> 
> Yes, agree!
> 
>>> I guess that __isolate_free_page() is also good candidate to need this
>>> information in order to prevent compaction from isolating too many
>>> freepage in low memory condition.
>>
>> I don't see how it would help here. It's temporary allocations for
>> page migration. How would passing classzone_idx and alloc_flags
>> prevent isolating too many?
> 
> It is temporary allocation, but, anyway, it could holds many freepage
> in some duration. As mentioned above, if we isolate high order freepage,
> we can hold 1MB or more freepage at once. I guess that passing flags helps
> system stability.

OK, here's a patch-fix to address everything discussed above. My testing
didn't show much difference, but I know it's limited anyway.

------8<------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Mon, 3 Nov 2014 15:26:40 +0100
Subject: mm-compaction-pass-classzone_idx-and-alloc_flags-to-watermark-checking-fix

This patch-fix changes zone watermark checking in compaction_suitable()
as we discussed with Joonsoo Kim. First, it moves up the watermark check for
answering the question "does the zone need compaction at all?". Before this
change, the check is preceded by a check that answers the question "does the
zone have enough free pages to succeed compaction". So it might happen that
there is already a high-order page available, but not enough pages for
performing the compaction (which assumes extra pages for the migrations).
Before the patch, compaction_suitable() would return COMPACT_SKIPPED which
means "compaction cannot succeed, reclaim more", after this change it returns
COMPACT_PARTIAL which means "compaction not needed, try allocating".

Second, the check for answering "can the compaction succeed?" now also
includes classzone_idx and alloc_flags parameters. This prevents starting
compaction that would not lead to successful allocation due to not having
enough free pages. The addition of extra pages for migration is left in the
check. Although these are temporary allocations and thus should not be
affected by alloc_flags and classzone_idx, it only matters when we are close
to the watermark, where it does not hurt to be a bit pessimistic.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>

---

When squashed, full changelog of the patch+fix should be:

Compaction relies on zone watermark checks for decisions such as if it's
worth to start compacting in compaction_suitable() or whether compaction
should stop in compact_finished().  The watermark checks take
classzone_idx and alloc_flags parameters, which are related to the memory
allocation request.  But from the context of compaction they are currently
passed as 0, including the direct compaction which is invoked to satisfy
the allocation request, and could therefore know the proper values.

The lack of proper values can lead to mismatch between decisions taken
during compaction and decisions related to the allocation request.  Lack
of proper classzone_idx value means that lowmem_reserve is not taken into
account.  This has manifested (during recent changes to deferred
compaction) when DMA zone was used as fallback for preferred Normal zone.
compaction_suitable() without proper classzone_idx would think that the
watermarks are already satisfied, but watermark check in
get_page_from_freelist() would fail.  Because of this problem, deferring
compaction has extra complexity that can be removed in the following
patch.

The issue (not confirmed in practice) with missing alloc_flags is opposite
in nature.  For allocations that include ALLOC_HIGH, ALLOC_HIGHER or
ALLOC_CMA in alloc_flags (the last includes all MOVABLE allocations on
CMA-enabled systems) the watermark checking in compaction with 0 passed
will be stricter than in get_page_from_freelist().  In these cases
compaction might be running for a longer time than is really needed.

Another issue compaction_suitable() is that the check for "does the zone need
compaction at all?" comes only after the check "does the zone have enough free
free pages to succeed compaction". The latter considers extra pages for
migration and can therefore in some situations fail and return COMPACT_SKIPPED,
although the high-order allocation would succeed and we should return
COMPACT_PARTIAL.

This patch fixes these problems by adding alloc_flags and classzone_idx to
struct compact_control and related functions involved in direct compaction
and watermark checking.  Where possible, all other callers of
compaction_suitable() pass proper values where those are known.  This is
currently limited to classzone_idx, which is sometimes known in kswapd
context.  However, the direct reclaim callers should_continue_reclaim()
and compaction_ready() do not currently know the proper values, so the
coordination between reclaim and compaction may still not be as accurate
as it could.  This can be fixed later, if it's shown to be an issue.

Additionaly the checks in compact_suitable() are reordered to address the
second issue described above.

The effect of this patch should be slightly better high-order allocation
success rates and/or less compaction overhead, depending on the type of
allocations and presence of CMA.  It allows simplifying deferred
compaction code in a followup patch.

When testing with stress-highalloc, there was some slight improvement
(which might be just due to variance) in success rates of non-THP-like
allocations.

 mm/compaction.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index ba8bdb9..f15e8e5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1113,21 +1113,30 @@ unsigned long compaction_suitable(struct zone *zone, int order,
 	if (order == -1)
 		return COMPACT_CONTINUE;
 
+	watermark = low_wmark_pages(zone);
+	/*
+	 * If watermarks for high-order allocation are already met, there
+	 * should be no need for compaction at all.
+	 */
+	if (zone_watermark_ok(zone, order, watermark, classzone_idx,
+								alloc_flags))
+		return COMPACT_PARTIAL;
+
 	/*
 	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
 	 * This is because during migration, copies of pages need to be
 	 * allocated and for a short time, the footprint is higher
 	 */
-	watermark = low_wmark_pages(zone) + (2UL << order);
-	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+	watermark += (2UL << order);
+	if (!zone_watermark_ok(zone, 0, watermark, classzone_idx, alloc_flags))
 		return COMPACT_SKIPPED;
 
 	/*
 	 * fragmentation index determines if allocation failures are due to
 	 * low memory or external fragmentation
 	 *
-	 * index of -1000 implies allocations might succeed depending on
-	 * watermarks
+	 * index of -1000 would imply allocations might succeed depending on
+	 * watermarks, but we already failed the high-order watermark check
 	 * index towards 0 implies failure is due to lack of memory
 	 * index towards 1000 implies failure is due to fragmentation
 	 *
@@ -1137,10 +1146,6 @@ unsigned long compaction_suitable(struct zone *zone, int order,
 	if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
 		return COMPACT_SKIPPED;
 
-	if (fragindex == -1000 && zone_watermark_ok(zone, order, watermark,
-	    classzone_idx, alloc_flags))
-		return COMPACT_PARTIAL;
-
 	return COMPACT_CONTINUE;
 }
 
-- 
2.1.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
