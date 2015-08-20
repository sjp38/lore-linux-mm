Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id A4AC96B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 05:15:01 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so835697wid.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 02:15:01 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id s6si7260560wjr.193.2015.08.20.02.14.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 02:15:00 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 52864996BD
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 09:14:59 +0000 (UTC)
Date: Thu, 20 Aug 2015 10:14:54 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 06/10] mm: page_alloc: Distinguish between being unable
 to sleep, unwilling to unwilling and avoiding waking kswapd
Message-ID: <20150820091159.GA12432@techsingularity.net>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-7-git-send-email-mgorman@techsingularity.net>
 <55D49658.50802@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55D49658.50802@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 19, 2015 at 04:44:40PM +0200, Vlastimil Babka wrote:
> 
> Unfortunately this is not as simple for all uses of GFP_TRANSHUGE.
> Namely in __alloc_pages_slowpath() the checks could use __GFP_NO_KSWAPD as one
> of the distinguishing flags, but to test for lack of __GFP_KSWAPD_RECLAIM, they
> should be adjusted in order to be functionally equivalent.
> Yes, it would be better if we could get rid of them, but that's out of scope
> here. So, something like this?
> 

Nicely spotted. The only modification I made was to add a helper because
the flags trick is sufficiently complex. That results in this;

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9617e79d6931..0f92d4d42e2e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2774,6 +2774,11 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
 }
 
+static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
+{
+	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
+}
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
@@ -2889,7 +2894,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto got_pg;
 
 	/* Checks for THP-specific high-order allocations */
-	if ((gfp_mask & GFP_TRANSHUGE) == GFP_TRANSHUGE) {
+	if (is_thp_gfp_mask(gfp_mask)) {
 		/*
 		 * If compaction is deferred for high-order allocations, it is
 		 * because sync compaction recently failed. If this is the case
@@ -2924,8 +2929,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * fault, so use asynchronous memory compaction for THP unless it is
 	 * khugepaged trying to collapse.
 	 */
-	if ((gfp_mask & GFP_TRANSHUGE) != GFP_TRANSHUGE ||
-						(current->flags & PF_KTHREAD))
+	if (!is_thp_gfp_mask(gfp_mask) || (current->flags & PF_KTHREAD))
 		migration_mode = MIGRATE_SYNC_LIGHT;
 
 	/* Try direct reclaim and then allocating */
-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
