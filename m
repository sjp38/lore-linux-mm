Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B30B16B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 04:47:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e201so42172648wme.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:47:40 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id wb6si3551320wjc.99.2016.05.04.01.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 01:47:39 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r12so9008335wme.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:47:39 -0700 (PDT)
Date: Wed, 4 May 2016 10:47:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0.14] oom detection rework v6
Message-ID: <20160504084737.GB29978@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <20160504054502.GA10899@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160504054502.GA10899@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 04-05-16 14:45:02, Joonsoo Kim wrote:
> On Wed, Apr 20, 2016 at 03:47:13PM -0400, Michal Hocko wrote:
> > Hi,
> > 
> > This is v6 of the series. The previous version was posted [1]. The
> > code hasn't changed much since then. I have found one old standing
> > bug (patch 1) which just got much more severe and visible with this
> > series. Other than that I have reorganized the series and put the
> > compaction feedback abstraction to the front just in case we find out
> > that parts of the series would have to be reverted later on for some
> > reason. The premature oom killer invocation reported by Hugh [2] seems
> > to be addressed.
> > 
> > We have discussed this series at LSF/MM summit in Raleigh and there
> > didn't seem to be any concerns/objections to go on with the patch set
> > and target it for the next merge window. 
> 
> I still don't agree with some part of this patchset that deal with
> !costly order. As you know, there was two regression reports from Hugh
> and Aaron and you fixed them by ensuring to trigger compaction. I
> think that these show the problem of this patchset. Previous kernel
> doesn't need to ensure to trigger compaction and just works fine in
> any case. Your series make compaction necessary for all. OOM handling
> is essential part in MM but compaction isn't. OOM handling should not
> depend on compaction. I tested my own benchmark without
> CONFIG_COMPACTION and found that premature OOM happens.

High order allocations without compaction are basically a lost game. You
can wait unbounded amount of time and still have no guarantee of any
progress. What is the usual reason to disable compaction in the first
place?

Anyway if this is _really_ a big issue then we can do something like the
following to emulate the previous behavior. We are losing the
determinism but if you really thing that the !COMPACTION workloads
already reconcile with it I can live with that.
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2e7e26c5d3ba..f48b9e9b1869 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3319,6 +3319,24 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
 		     enum migrate_mode *migrate_mode,
 		     int compaction_retries)
 {
+	struct zone *zone;
+	struct zoneref *z;
+
+	if (order > PAGE_ALLOC_COSTLY_ORDER)
+		return false;
+
+	/*
+	 * There are setups with compaction disabled which would prefer to loop
+	 * inside the allocator rather than hit the oom killer prematurely. Let's
+	 * give them a good hope and keep retrying while the order-0 watermarks
+	 * are OK.
+	 */
+	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
+					ac->nodemask) {
+		if(zone_watermark_ok(zone, 0, min_wmark_pages(zone),
+					ac->high_zoneidx, alloc_flags))
+			return true;
+	}
 	return false;
 }
 #endif /* CONFIG_COMPACTION */
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
