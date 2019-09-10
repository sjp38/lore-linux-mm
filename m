Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82183C49ED9
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 20:19:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B5672084D
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 20:19:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B5672084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D20A26B0005; Tue, 10 Sep 2019 16:19:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD0D96B0006; Tue, 10 Sep 2019 16:19:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE7646B0007; Tue, 10 Sep 2019 16:19:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0213.hostedemail.com [216.40.44.213])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD176B0005
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:19:13 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 35F7781D0
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 20:19:13 +0000 (UTC)
X-FDA: 75920125386.19.pest58_6d8917b03423f
X-HE-Tag: pest58_6d8917b03423f
X-Filterd-Recvd-Size: 7752
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 20:19:12 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 94DEDAD31;
	Tue, 10 Sep 2019 20:19:10 +0000 (UTC)
Date: Tue, 10 Sep 2019 22:19:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Nitin Gupta <nigupta@nvidia.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net,
	dan.j.williams@intel.com, khalid.aziz@oracle.com,
	Matthew Wilcox <willy@infradead.org>, Yu Zhao <yuzhao@google.com>,
	Qian Cai <cai@lca.pw>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Allison Randal <allison@lohutok.net>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arun KS <arunks@codeaurora.org>,
	Wei Yang <richard.weiyang@gmail.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm: Add callback for defining compaction completion
Message-ID: <20190910201905.GG4023@dhcp22.suse.cz>
References: <20190910200756.7143-1-nigupta@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190910200756.7143-1-nigupta@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 10-09-19 13:07:32, Nitin Gupta wrote:
> For some applications we need to allocate almost all memory as hugepages.
> However, on a running system, higher order allocations can fail if the
> memory is fragmented. Linux kernel currently does on-demand compaction as
> we request more hugepages but this style of compaction incurs very high
> latency. Experiments with one-time full memory compaction (followed by
> hugepage allocations) shows that kernel is able to restore a highly
> fragmented memory state to a fairly compacted memory state within <1 sec
> for a 32G system. Such data suggests that a more proactive compaction can
> help us allocate a large fraction of memory as hugepages keeping allocation
> latencies low.
> 
> In general, compaction can introduce unexpected latencies for applications
> that don't even have strong requirements for contiguous allocations. It is
> also hard to efficiently determine if the current system state can be
> easily compacted due to mixing of unmovable memory. Due to these reasons,
> automatic background compaction by the kernel itself is hard to get right
> in a way which does not hurt unsuspecting applications or waste CPU cycles.

We do trigger background compaction on a high order pressure from the
page allocator by waking up kcompactd. Why is that not sufficient?

> Even with these caveats, pro-active compaction can still be very useful in
> certain scenarios to reduce hugepage allocation latencies. This callback
> interface allows drivers to drive compaction based on their own policies
> like the current level of external fragmentation for a particular order,
> system load etc.

So we do not trust the core MM to make a reasonable decision while we
give a free ticket to modules. How does this make any sense at all? How
is a random module going to make a more informed decision when it has
less visibility on the overal MM situation.

If you need to control compaction from the userspace you have an
interface for that.  It is also completely unexplained why you need a
completion callback.

That being said, this looks like a terrible idea to me.

> Signed-off-by: Nitin Gupta <nigupta@nvidia.com>
> ---
>  include/linux/compaction.h | 10 ++++++++++
>  mm/compaction.c            | 20 ++++++++++++++------
>  mm/internal.h              |  2 ++
>  3 files changed, 26 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 9569e7c786d3..1ea828450fa2 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -58,6 +58,16 @@ enum compact_result {
>  	COMPACT_SUCCESS,
>  };
>  
> +/* Callback function to determine if compaction is finished. */
> +typedef enum compact_result (*compact_finished_cb)(
> +	struct zone *zone, int order);
> +
> +enum compact_result compact_zone_order(struct zone *zone, int order,
> +		gfp_t gfp_mask, enum compact_priority prio,
> +		unsigned int alloc_flags, int classzone_idx,
> +		struct page **capture,
> +		compact_finished_cb compact_finished_cb);
> +
>  struct alloc_context; /* in mm/internal.h */
>  
>  /*
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 952dc2fb24e5..73e2e9246bc4 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1872,6 +1872,9 @@ static enum compact_result __compact_finished(struct compact_control *cc)
>  			return COMPACT_PARTIAL_SKIPPED;
>  	}
>  
> +	if (cc->compact_finished_cb)
> +		return cc->compact_finished_cb(cc->zone, cc->order);
> +
>  	if (is_via_compact_memory(cc->order))
>  		return COMPACT_CONTINUE;
>  
> @@ -2274,10 +2277,11 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
>  	return ret;
>  }
>  
> -static enum compact_result compact_zone_order(struct zone *zone, int order,
> +enum compact_result compact_zone_order(struct zone *zone, int order,
>  		gfp_t gfp_mask, enum compact_priority prio,
>  		unsigned int alloc_flags, int classzone_idx,
> -		struct page **capture)
> +		struct page **capture,
> +		compact_finished_cb compact_finished_cb)
>  {
>  	enum compact_result ret;
>  	struct compact_control cc = {
> @@ -2293,10 +2297,11 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
>  					MIGRATE_ASYNC :	MIGRATE_SYNC_LIGHT,
>  		.alloc_flags = alloc_flags,
>  		.classzone_idx = classzone_idx,
> -		.direct_compaction = true,
> +		.direct_compaction = !compact_finished_cb,
>  		.whole_zone = (prio == MIN_COMPACT_PRIORITY),
>  		.ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY),
> -		.ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY)
> +		.ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY),
> +		.compact_finished_cb = compact_finished_cb
>  	};
>  	struct capture_control capc = {
>  		.cc = &cc,
> @@ -2313,11 +2318,13 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
>  	VM_BUG_ON(!list_empty(&cc.freepages));
>  	VM_BUG_ON(!list_empty(&cc.migratepages));
>  
> -	*capture = capc.page;
> +	if (capture)
> +		*capture = capc.page;
>  	current->capture_control = NULL;
>  
>  	return ret;
>  }
> +EXPORT_SYMBOL(compact_zone_order);
>  
>  int sysctl_extfrag_threshold = 500;
>  
> @@ -2361,7 +2368,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  		}
>  
>  		status = compact_zone_order(zone, order, gfp_mask, prio,
> -				alloc_flags, ac_classzone_idx(ac), capture);
> +				alloc_flags, ac_classzone_idx(ac), capture,
> +				NULL);
>  		rc = max(status, rc);
>  
>  		/* The allocation should succeed, stop compacting */
> diff --git a/mm/internal.h b/mm/internal.h
> index e32390802fd3..f873f7c2b9dc 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -11,6 +11,7 @@
>  #include <linux/mm.h>
>  #include <linux/pagemap.h>
>  #include <linux/tracepoint-defs.h>
> +#include <linux/compaction.h>
>  
>  /*
>   * The set of flags that only affect watermark checking and reclaim
> @@ -203,6 +204,7 @@ struct compact_control {
>  	bool whole_zone;		/* Whole zone should/has been scanned */
>  	bool contended;			/* Signal lock or sched contention */
>  	bool rescan;			/* Rescanning the same pageblock */
> +	compact_finished_cb compact_finished_cb;
>  };
>  
>  /*
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

