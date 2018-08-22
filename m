Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8F46B2404
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 07:07:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h40-v6so799531edb.2
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 04:07:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n21-v6si1511888edr.216.2018.08.22.04.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 04:07:38 -0700 (PDT)
Date: Wed, 22 Aug 2018 13:07:37 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180822110737.GK29735@dhcp22.suse.cz>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz>
 <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822090214.GF29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed 22-08-18 11:02:14, Michal Hocko wrote:
> On Tue 21-08-18 17:40:49, Andrea Arcangeli wrote:
> > On Tue, Aug 21, 2018 at 01:50:57PM +0200, Michal Hocko wrote:
> [...]
> > > I really detest a new gfp flag for one time semantic that is muddy as
> > > hell.
> > 
> > Well there's no way to fix this other than to prevent reclaim to run,
> > if you still want to give a chance to page faults to obtain THP under
> > MADV_HUGEPAGE in the page fault without waiting minutes or hours for
> > khugpaged to catch up with it.
> 
> I do not get that part. Why should caller even care about reclaim vs.
> compaction. How can you even make an educated guess what makes more
> sense? This should be fully controlled by the allocator path. The caller
> should only care about how hard to try. It's been some time since I've
> looked but we used to have a gfp flags to tell that for THP allocations
> as well.

In other words, why do we even try to swap out when allocating costly
high order page for requests which do not insist to try really hard?

I mean why don't we do something like this?
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 03822f86f288..41005d3d4c2d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3071,6 +3071,14 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
 		return 1;
 
+	/*
+	 * If we are allocating a costly order and do not insist on trying really
+	 * hard then we should keep the reclaim impact at minimum. So only
+	 * focus on easily reclaimable memory.
+	 */
+	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_RETRY_MAYFAIL))
+		sc.may_swap = sc.may_unmap = 0;
+
 	trace_mm_vmscan_direct_reclaim_begin(order,
 				sc.may_writepage,
 				sc.gfp_mask,
-- 
Michal Hocko
SUSE Labs
