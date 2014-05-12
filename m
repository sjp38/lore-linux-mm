Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 10C3A6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 11:45:36 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so4855128eei.14
        for <linux-mm@kvack.org>; Mon, 12 May 2014 08:45:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d1si6083410eem.115.2014.05.12.08.45.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 08:45:35 -0700 (PDT)
Message-ID: <5370EC9B.5020106@suse.cz>
Date: Mon, 12 May 2014 17:45:31 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, compaction: properly signal and act upon lock and
 need_sched() contention
References: <20140508051747.GA9161@js1304-P5Q-DELUXE> <1399904111-23520-1-git-send-email-vbabka@suse.cz> <1399908847-ouuxeneo@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1399908847-ouuxeneo@n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, Mel Gorman <mgorman@suse.de>, b.zolnierkie@samsung.com, mina86@mina86.com, cl@linux.com, Rik van Riel <riel@redhat.com>

On 05/12/2014 05:34 PM, Naoya Horiguchi wrote:
> On Mon, May 12, 2014 at 04:15:11PM +0200, Vlastimil Babka wrote:
>> Compaction uses compact_checklock_irqsave() function to periodically check for
>> lock contention and need_resched() to either abort async compaction, or to
>> free the lock, schedule and retake the lock. When aborting, cc->contended is
>> set to signal the contended state to the caller. Two problems have been
>> identified in this mechanism.
>>
>> First, compaction also calls directly cond_resched() in both scanners when no
>> lock is yet taken. This call either does not abort async compaction, or set
>> cc->contended appropriately. This patch introduces a new
>> compact_check_resched() function to achieve both.
>>
>> Second, isolate_freepages() does not check if isolate_freepages_block()
>> aborted due to contention, and advances to the next pageblock. This violates
>> the principle of aborting on contention, and might result in pageblocks not
>> being scanned completely, since the scanning cursor is advanced. This patch
>> makes isolate_freepages_block() check the cc->contended flag and abort.
>>
>> Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
>> Cc: Michal Nazarewicz <mina86@mina86.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> ---
>>   mm/compaction.c | 40 +++++++++++++++++++++++++++++++++-------
>>   1 file changed, 33 insertions(+), 7 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 83ca6f9..b34ab7c 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -222,6 +222,27 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>>   	return true;
>>   }
>>
>> +/*
>> + * Similar to compact_checklock_irqsave() (see its comment) for places where
>> + * a zone lock is not concerned.
>> + *
>> + * Returns false when compaction should abort.
>> + */
>> +static inline bool compact_check_resched(struct compact_control *cc)
>> +{
>> +	/* async compaction aborts if contended */
>> +	if (need_resched()) {
>> +		if (cc->mode == MIGRATE_ASYNC) {
>> +			cc->contended = true;
>
> This changes the meaning of contended in struct compact_control (not just
> indicating lock contention,) so please update the comment in mm/internal.h too.

It doesn't change it, since compact_checklock_irqsave() already has this 
semantic:
if (should_release_lock(lock) && cc->mode == MIGRATE_ASYNC)
	cc->contended = true;

and should_release_lock() is:
	need_resched() || spin_is_contended(lock)

So the comment was already outdated, I will update it in v2.

> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks.

> Thanks,
> Naoya Horiguchi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
