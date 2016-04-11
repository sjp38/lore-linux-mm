Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9331C6B0261
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:46:56 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id v188so84845904wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:46:56 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id n9si27678769wjz.199.2016.04.11.05.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 05:46:55 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a140so21033934wma.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:46:55 -0700 (PDT)
Date: Mon, 11 Apr 2016 14:46:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 06/11] mm, compaction: distinguish between full and
 partial COMPACT_COMPLETE
Message-ID: <20160411124653.GG23157@dhcp22.suse.cz>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-7-git-send-email-mhocko@kernel.org>
 <570B9432.9090600@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <570B9432.9090600@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 11-04-16 14:10:26, Vlastimil Babka wrote:
> On 04/05/2016 01:25 PM, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> >COMPACT_COMPLETE now means that compaction and free scanner met. This is
> >not very useful information if somebody just wants to use this feedback
> >and make any decisions based on that. The current caller might be a poor
> >guy who just happened to scan tiny portion of the zone and that could be
> >the reason no suitable pages were compacted. Make sure we distinguish
> >the full and partial zone walks.
> >
> >Consumers should treat COMPACT_PARTIAL_SKIPPED as a potential success
> >and be optimistic in retrying.
> >
> >The existing users of COMPACT_COMPLETE are conservatively changed to
> >use COMPACT_PARTIAL_SKIPPED as well but some of them should be probably
> >reconsidered and only defer the compaction only for COMPACT_COMPLETE
> >with the new semantic.
> >
> >This patch shouldn't introduce any functional changes.
> >
> >Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> With some notes:
> 
> >@@ -1463,6 +1466,10 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
> >  		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
> >  		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
> >  	}
> >+
> >+	if (cc->migrate_pfn == start_pfn)
> >+		cc->whole_zone = true;
> >+
> 
> This assumes that migrate scanner at initial position implies also free
> scanner at the initial position. That should be true, because migration
> scanner is the first to run. But getting the zone->compact_cached_*_pfn is
> racy. Worse, zone->compact_cached_migrate_pfn is array distinguishing sync
> and async compaction, so it's possible that async compaction has advanced
> both its own migrate scanner cached position, and the shared free scanner
> cached position, and then sync compaction starts migrate scanner at
> start_pfn, but free scanner has already advanced.

OK, I see. The whole thing smelled racy but I thought it wouldn't be
such a big deal. Even if we raced then only a marginal part of the zone
wouldn't be scanned, right? Or is it possible that free_pfn would appear
in the middle of the zone because of the race?

> So you might still see a false positive COMPACT_COMPLETE, just less
> frequently and probably with much lower impact.
> But if you need to be truly reliable, check also that cc->free_pfn ==
> round_down(end_pfn - 1, pageblock_nr_pages)

I do not think we need the precise check if the race window (in the
skipped zone range) is always small.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
