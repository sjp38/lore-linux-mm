Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03CD883090
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 02:57:35 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id y69so112143163oif.0
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 23:57:34 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id e7si1915855igg.93.2016.04.20.23.57.32
        for <linux-mm@kvack.org>;
        Wed, 20 Apr 2016 23:57:34 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org> <1461181647-8039-9-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461181647-8039-9-git-send-email-mhocko@kernel.org>
Subject: Re: [PATCH 08/14] mm, compaction: Abstract compaction feedback to helpers
Date: Thu, 21 Apr 2016 14:57:13 +0800
Message-ID: <02d001d19b9b$092f8380$1b8e8a80$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'Joonsoo Kim' <js1304@gmail.com>, 'Vlastimil Babka' <vbabka@suse.cz>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

> 
> From: Michal Hocko <mhocko@suse.com>
> 
> Compaction can provide a wild variation of feedback to the caller. Many
> of them are implementation specific and the caller of the compaction
> (especially the page allocator) shouldn't be bound to specifics of the
> current implementation.
> 
> This patch abstracts the feedback into three basic types:
> 	- compaction_made_progress - compaction was active and made some
> 	  progress.
> 	- compaction_failed - compaction failed and further attempts to
> 	  invoke it would most probably fail and therefore it is not
> 	  worth retrying
> 	- compaction_withdrawn - compaction wasn't invoked for an
>           implementation specific reasons. In the current implementation
>           it means that the compaction was deferred, contended or the
>           page scanners met too early without any progress. Retrying is
>           still worthwhile.
> 
> [vbabka@suse.cz: do not change thp back off behavior]
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  include/linux/compaction.h | 79 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 79 insertions(+)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index a7b9091ff349..a002ca55c513 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -78,6 +78,70 @@ extern void compaction_defer_reset(struct zone *zone, int order,
>  				bool alloc_success);
>  extern bool compaction_restarting(struct zone *zone, int order);
> 
> +/* Compaction has made some progress and retrying makes sense */
> +static inline bool compaction_made_progress(enum compact_result result)
> +{
> +	/*
> +	 * Even though this might sound confusing this in fact tells us
> +	 * that the compaction successfully isolated and migrated some
> +	 * pageblocks.
> +	 */
> +	if (result == COMPACT_PARTIAL)
> +		return true;
> +
> +	return false;
> +}
> +
> +/* Compaction has failed and it doesn't make much sense to keep retrying. */
> +static inline bool compaction_failed(enum compact_result result)
> +{
> +	/* All zones where scanned completely and still not result. */

s/where/were/

> +	if (result == COMPACT_COMPLETE)
> +		return true;
> +
> +	return false;
> +}
> +
> +/*
> + * Compaction  has backed off for some reason. It might be throttling or
> + * lock contention. Retrying is still worthwhile.
> + */
> +static inline bool compaction_withdrawn(enum compact_result result)
> +{
> +	/*
> +	 * Compaction backed off due to watermark checks for order-0
> +	 * so the regular reclaim has to try harder and reclaim something.
> +	 */
> +	if (result == COMPACT_SKIPPED)
> +		return true;
> +
> +	/*
> +	 * If compaction is deferred for high-order allocations, it is
> +	 * because sync compaction recently failed. If this is the case
> +	 * and the caller requested a THP allocation, we do not want
> +	 * to heavily disrupt the system, so we fail the allocation
> +	 * instead of entering direct reclaim.
> +	 */
> +	if (result == COMPACT_DEFERRED)
> +		return true;
> +
> +	/*
> +	 * If compaction in async mode encounters contention or blocks higher
> +	 * priority task we back off early rather than cause stalls.
> +	 */
> +	if (result == COMPACT_CONTENDED)
> +		return true;
> +
> +	/*
> +	 * Page scanners have met but we haven't scanned full zones so this
> +	 * is a back off in fact.
> +	 */
> +	if (result == COMPACT_PARTIAL_SKIPPED)
> +		return true;
> +
> +	return false;
> +}
> +
>  extern int kcompactd_run(int nid);
>  extern void kcompactd_stop(int nid);
>  extern void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx);
> @@ -114,6 +178,21 @@ static inline bool compaction_deferred(struct zone *zone, int order)
>  	return true;
>  }
> 
> +static inline bool compaction_made_progress(enum compact_result result)
> +{
> +	return false;
> +}
> +
> +static inline bool compaction_failed(enum compact_result result)
> +{
> +	return false;
> +}
> +
> +static inline bool compaction_withdrawn(enum compact_result result)
> +{
> +	return true;
> +}
> +
>  static inline int kcompactd_run(int nid)
>  {
>  	return 0;
> --
> 2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
