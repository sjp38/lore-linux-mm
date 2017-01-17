Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8166B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 15:20:12 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id an2so18917331wjc.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 12:20:12 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id k2si17145196wmg.135.2017.01.17.12.20.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 12:20:11 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id B3E6598F76
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 20:20:10 +0000 (UTC)
Date: Tue, 17 Jan 2017 20:20:08 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/4] mm, page_alloc: Split buffered_rmqueue
Message-ID: <20170117202008.pcufk5qencdgkgpj@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-2-mgorman@techsingularity.net>
 <20170117190732.0fc733ec@redhat.com>
 <2df88f73-a32d-4b71-d4de-3a0ad8831d9a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2df88f73-a32d-4b71-d4de-3a0ad8831d9a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>

On Tue, Jan 17, 2017 at 07:17:22PM +0100, Vlastimil Babka wrote:
> On 01/17/2017 07:07 PM, Jesper Dangaard Brouer wrote:
> > 
> > On Tue, 17 Jan 2017 09:29:51 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> > 
> >> +/* Lock and remove page from the per-cpu list */
> >> +static struct page *rmqueue_pcplist(struct zone *preferred_zone,
> >> +			struct zone *zone, unsigned int order,
> >> +			gfp_t gfp_flags, int migratetype)
> >> +{
> >> +	struct per_cpu_pages *pcp;
> >> +	struct list_head *list;
> >> +	bool cold = ((gfp_flags & __GFP_COLD) != 0);
> >> +	struct page *page;
> >> +	unsigned long flags;
> >> +
> >> +	local_irq_save(flags);
> >> +	pcp = &this_cpu_ptr(zone->pageset)->pcp;
> >> +	list = &pcp->lists[migratetype];
> >> +	page = __rmqueue_pcplist(zone,  migratetype, cold, pcp, list);
> >> +	if (page) {
> >> +		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
> >> +		zone_statistics(preferred_zone, zone, gfp_flags);
> > 
> > Word-of-warning: The zone_statistics() call changed number of
> > parameters in commit 41b6167e8f74 ("mm: get rid of __GFP_OTHER_NODE").
> > (Not sure what tree you are based on)
> 

Yes, there's a conflict. The fix is trivial and shouldn't affect the
overall series. Not that it matters because of ths next part

> Yeah and there will likely be more conflicts with fixes wrt the "getting
> oom/stalls for ltp test cpuset01 with latest/4.9 kernel???" thread,
> hopefully tomorrow.
> 

It's was on my list to look closer at that thread tomorrow. I only took a
quick look for the first time a few minutes ago and it looks bad. There
is at least a flaw in the retry sequence if cpusets are disabled during
an allocation that fails as it won't retry. That leaves a small window if
the last cpuset disappeared during which an allocation could artifically
fail but that can't be what's going on here.

It could still be the retry logic because the nodemask is not necessarily
synced up with cpuset_current_mems_allowed. I'll try reproducing this
in the morning. The fix is almost certainly going to conflict with this
series but this series can wait until after that gets resolved and I'll
rebase on top of mmotm.

It's late so I'm fairly tired but assuming I can reproduce this in the
morning, the first thing I'll try is something like this to force a reread
of mems_allowed;

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebea51cc0135..3fc2b3a8d301 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3774,13 +3774,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		.migratetype = gfpflags_to_migratetype(gfp_mask),
 	};
 
-	if (cpusets_enabled()) {
-		alloc_mask |= __GFP_HARDWALL;
-		alloc_flags |= ALLOC_CPUSET;
-		if (!ac.nodemask)
-			ac.nodemask = &cpuset_current_mems_allowed;
-	}
-
 	gfp_mask &= gfp_allowed_mask;
 
 	lockdep_trace_alloc(gfp_mask);
@@ -3802,6 +3795,13 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		alloc_flags |= ALLOC_CMA;
 
 retry_cpuset:
+	if (cpusets_enabled()) {
+		alloc_mask |= __GFP_HARDWALL;
+		alloc_flags |= ALLOC_CPUSET;
+		if (!nodemask)
+			ac.nodemask = &cpuset_current_mems_allowed;
+	}
+
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
 	/* Dirty zone balancing only done in the fast path */

If that doesn't work out then I'll start kicking the problem properly
unless you've beaten me to the correct solution already :)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
