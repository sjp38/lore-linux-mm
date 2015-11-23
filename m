Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 208776B0254
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:41:11 -0500 (EST)
Received: by wmec201 with SMTP id c201so151340529wme.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:41:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si18079679wjq.6.2015.11.23.01.41.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 01:41:09 -0800 (PST)
Date: Mon, 23 Nov 2015 10:41:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Message-ID: <20151123094106.GD21050@dhcp22.suse.cz>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
 <1447851840-15640-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511191455310.17510@chino.kir.corp.google.com>
 <20151120090626.GB16698@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511201523520.10092@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511201523520.10092@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri 20-11-15 15:27:39, David Rientjes wrote:
> On Fri, 20 Nov 2015, Michal Hocko wrote:
> 
> > > > +		unsigned long reclaimable;
> > > > +		unsigned long target;
> > > > +
> > > > +		reclaimable = zone_reclaimable_pages(zone) +
> > > > +			      zone_page_state(zone, NR_ISOLATED_FILE) +
> > > > +			      zone_page_state(zone, NR_ISOLATED_ANON);
> > > 
> > > Does NR_ISOLATED_ANON mean anything relevant here in swapless 
> > > environments?
> > 
> > It should be 0 so I didn't bother to check for swapless configuration.
> > 
> 
> I'm not sure I understand your point, memory compaction certainly 
> increments NR_ISOLATED_ANON and that would be considered unreclaimable in 
> a swapless environment, correct?

My bad. I have completely missed that compaction/migration is updating
the counter as well. I would expect that the number shouldn't too large
to matter but I guess it will be better to simply exclude it. I will
fold this to the first patch.

Thanks
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 54476e71b572..7d885d7fae86 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3197,8 +3197,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		unsigned long target;
 
 		reclaimable = zone_reclaimable_pages(zone) +
-			      zone_page_state(zone, NR_ISOLATED_FILE) +
-			      zone_page_state(zone, NR_ISOLATED_ANON);
+			      zone_page_state(zone, NR_ISOLATED_FILE);
+		if (get_nr_swap_pages() > 0)
+			reclaimable += zone_page_state(zone, NR_ISOLATED_ANON);
+
 		target = reclaimable;
 		target -= DIV_ROUND_UP(stall_backoff * target, MAX_STALL_BACKOFF);
 		target += free;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
