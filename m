Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3F56B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 10:37:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e201so5276685wme.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 07:37:13 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id j124si15278063wmg.99.2016.04.28.07.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 07:37:12 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id e201so79337892wme.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 07:37:11 -0700 (PDT)
Date: Thu, 28 Apr 2016 16:37:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
Message-ID: <20160428143710.GC31496@dhcp22.suse.cz>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5720F2A8.6070406@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Wed 27-04-16 10:11:04, Dave Hansen wrote:
> On 04/27/2016 10:01 AM, Odzioba, Lukasz wrote:
[...]
> > 1. We need some statistics on the number and total *SIZES* of all pages
> >    in the lru pagevecs.  It's too opaque now.
> > 2. We need to make darn sure we drain the lru pagevecs before failing
> >    any kind of allocation.

lru_add_drain_all is unfortunatelly too costly (especially on large
machines). You are right that failing an allocation with a lot of cached
pages is less than suboptimal though. So maybe we can do it from the
slow path after the first round of direct reclaim failed to allocate
anything. Something like the following:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dd65d9fb76a..0743c58c2e9d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3559,6 +3559,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum compact_result compact_result;
 	int compaction_retries = 0;
 	int no_progress_loops = 0;
+	bool drained_lru = false;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3667,6 +3668,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto got_pg;
 
+	if (!drained_lru) {
+		drained_lru = true;
+		lru_add_drain_all();
+	}
+
 	/* Do not loop if specifically requested */
 	if (gfp_mask & __GFP_NORETRY)
 		goto noretry;

The downside would be that we really depend on the WQ to make any
progress here. If we are really out of memory then we are screwed so
we would need a flush_work_timeout() or something else that would
guarantee maximum timeout. That something else might be to stop using WQ
and move the flushing into the IRQ context. Not for free too but at
least not dependant on having some memory to make a progress.

> > 3. We need some way to drain the lru pagevecs directly.  Maybe the buddy
> >    pcp lists too.
> > 4. We need to make sure that a zone_reclaim_mode=0 system still drains
> >    too.
> > 5. The VM stats and their updates are now related to how often
> >    drain_zone_pages() gets run.  That might be interacting here too.
> 
> 6. Perhaps don't use the LRU pagevecs for large pages.  It limits the
>    severity of the problem.

7. Hook into vmstat and flush from there? This would drain them
periodically but it would also introduce an undeterministic interference
as well.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
