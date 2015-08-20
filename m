Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id DB11B6B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 10:17:23 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so7921705wid.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 07:17:23 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id ft15si9362390wic.93.2015.08.20.07.17.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 07:17:22 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id C5461F408E
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 14:17:21 +0000 (UTC)
Date: Thu, 20 Aug 2015 15:17:20 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 01/10] mm, page_alloc: Delete the zonelist_cache
Message-ID: <20150820141720.GE12432@techsingularity.net>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-2-git-send-email-mgorman@techsingularity.net>
 <55D5D68E.6040206@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55D5D68E.6040206@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 20, 2015 at 03:30:54PM +0200, Vlastimil Babka wrote:
> >Note the maximum stall latency which was 6 seconds and becomes 67ms with
> >this patch applied. However, also note that it is not guaranteed this
> >benchmark always hits pathelogical cases and the milage varies. There is
> >a secondary impact with more direct reclaim because zones are now being
> >considered instead of being skipped by zlc.
> >
> >                                  4.1.0       4.1.0
> >                                vanilla  nozlc-v1r4
> >Swap Ins                           838         502
> >Swap Outs                      1149395     2622895
> >DMA32 allocs                  17839113    15863747
> >Normal allocs                129045707   137847920
> >Direct pages scanned           4070089    29046893
> >Kswapd pages scanned          17147837    17140694
> >Kswapd pages reclaimed        17146691    17139601
> >Direct pages reclaimed         1888879     4886630
> >Kswapd efficiency                  99%         99%
> >Kswapd velocity              17523.721   17518.928
> >Direct efficiency                  46%         16%
> >Direct velocity               4159.306   29687.854
> >Percentage direct scans            19%         62%
> >Page writes by reclaim     1149395.000 2622895.000
> >Page writes file                     0           0
> >Page writes anon               1149395     2622895
> 
> Interesting, kswapd has no decrease that would counter the increase in
> direct reclaim. So there's more reclaim overall. Does it mean that stutter
> doesn't like LRU and zlc was disrupting LRU?
> 

The LRU is being heavily disrupted by both reclaim and compaction
activity. The test is not a reliable means of evaluating reclaim decisions
because of the compaction activity. The main purpose of stutter was as a
proxy measure of desktop interactivity during IO.

As the test does THP allocations, it can trigger the case where zlc can
disable a zone for no reason and instead busy loop which is just wrong.

> >The direct page scan and reclaim rates are noticeable. It is possible
> >this will not be a universal win on all workloads but cycling through
> >zonelists waiting for zlc->last_full_zap to expire is not the right
> >decision.
> >
> >Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> >Acked-by: David Rientjes <rientjes@google.com>
> 
> It doesn't seem that removal of zlc would increase overhead due to
> "expensive operations no longer being avoided". Making some corner-case
> benchmark(s) worse as a side-effect of different LRU approximation shouldn't
> be a show-stopper. Hence
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

Thanks.

> just git grep found some lines that should be also deleted:
> 
> include/linux/mmzone.h: * If zlcache_ptr is not NULL, then it is just the
> address of zlcache,
> include/linux/mmzone.h: * as explained above.  If zlcache_ptr is NULL, there
> is no zlcache.
> 

Thanks

> And:
> 
> >@@ -3157,7 +2967,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> >  	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
> >  	struct alloc_context ac = {
> >  		.high_zoneidx = gfp_zone(gfp_mask),
> >-		.nodemask = nodemask,
> >+		.nodemask = nodemask ? : &cpuset_current_mems_allowed,
> >  		.migratetype = gfpflags_to_migratetype(gfp_mask),
> >  	};
> >
> >@@ -3188,8 +2998,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> >  	ac.zonelist = zonelist;
> >  	/* The preferred zone is used for statistics later */
> >  	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
> >-				ac.nodemask ? : &cpuset_current_mems_allowed,
> >-				&ac.preferred_zone);
> >+				ac.nodemask, &ac.preferred_zone);
> >  	if (!ac.preferred_zone)
> >  		goto out;
> >  	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
> 
> These hunks appear unrelated to zonelist cache? Also they move the
> evaluation of cpuset_current_mems_allowed

They are rebase-related brain damage :(. I'll fix it and retest.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
