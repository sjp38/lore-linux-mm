Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 41A0C6B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 14:57:21 -0500 (EST)
Received: by wmec201 with SMTP id c201so225945651wme.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 11:57:20 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id et14si22046386wjc.67.2015.11.24.11.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 11:57:19 -0800 (PST)
Date: Tue, 24 Nov 2015 14:57:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
Message-ID: <20151124195710.GA12923@cmpxchg.org>
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
 <5651BB43.8030102@suse.cz>
 <20151123092925.GB21050@dhcp22.suse.cz>
 <5652DFCE.3010201@suse.cz>
 <20151123101345.GF21050@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511231320160.30886@chino.kir.corp.google.com>
 <20151124094708.GA29472@dhcp22.suse.cz>
 <20151124162604.GB9598@cmpxchg.org>
 <20151124170239.GA13492@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124170239.GA13492@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 24, 2015 at 06:02:39PM +0100, Michal Hocko wrote:
> On Tue 24-11-15 11:26:04, Johannes Weiner wrote:
> > On Tue, Nov 24, 2015 at 10:47:09AM +0100, Michal Hocko wrote:
> > > Besides that there is no other reliable warning that we are getting
> > > _really_ short on memory unlike when the allocation failure is
> > > allowed. OOM killer report might be missing because there was no actual
> > > killing happening.
> > 
> > This is why I would like to see that warning generalized, and not just
> > for __GFP_NOFAIL. We have allocations other than explicit __GFP_NOFAIL
> > that will loop forever in the allocator,
> 
> Yes but does it make sense to warn for all of them? Wouldn't it be
> sufficient to warn about those which cannot allocate anything even
> though they are doing ALLOC_NO_WATERMARKS?

Why is it important whether they can do ALLOC_NO_WATERMARKS or not?

I'm worried about all those that can loop forever with locks held.

> > and when this deadlocks the
> > machine all we see is other tasks hanging, but not the culprit. If we
> > were to get a backtrace of some task in the allocator that is known to
> > hold locks, suddenly all the other hung tasks will make sense, and it
> > will clearly distinguish such an allocator deadlock from other issues.
> 
> Tetsuo was suggesting a more sophisticated infrastructure for tracking
> allocations [1] which take too long without making progress. I haven't
> seen his patch because I was too busy with other stuff but maybe this is
> what you would like to see?

That seems a bit excessive. I was thinking something more like this:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 05ef7fb..fbfc581 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3004,6 +3004,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	unsigned int nr_tries = 0;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3033,6 +3034,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 retry:
+	if (++nr_retries % 100 == 0)
+		warn_alloc_failed(gfp_mask, order, "Potential GFP deadlock\n");
+
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
> Anyway I would like to make some progress on this patch. Do you think
> that it would be acceptable in the current form without the warning or
> you preffer a different way?

Oh, I have nothing against your patch, please go ahead with it. I just
wondered out loud when you proposed a warning about deadlocking NOFAIL
allocations but limited it to explicit __GFP_NOFAIL allocations, when
those obviously aren't the only ones that can deadlock in that way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
