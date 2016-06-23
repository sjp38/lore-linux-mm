Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2EF2828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 07:07:31 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so51043663lfe.0
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 04:07:31 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id dc5si6608264wjb.110.2016.06.23.04.07.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 04:07:30 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 6E1FD98753
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 11:07:30 +0000 (UTC)
Date: Thu, 23 Jun 2016 12:07:28 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/27] mm, vmscan: Begin reclaiming pages on a per-node
 basis
Message-ID: <20160623110728.GT1868@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-5-git-send-email-mgorman@techsingularity.net>
 <6eecdf50-7880-2bfe-5519-004a4beeece6@suse.cz>
 <efa724ae-63fb-c09f-13a3-ca9a09849ae2@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <efa724ae-63fb-c09f-13a3-ca9a09849ae2@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On Wed, Jun 22, 2016 at 06:00:12PM +0200, Vlastimil Babka wrote:
> >>-		enum zone_type classzone_idx;
> >>-
> >> 		if (!populated_zone(zone))
> >> 			continue;
> >>
> >>-		classzone_idx = requested_highidx;
> >>+		/*
> >>+		 * Note that reclaim_idx does not change as it is the highest
> >>+		 * zone reclaimed from which for empty zones is a no-op but
> >>+		 * classzone_idx is used by shrink_node to test if the slabs
> >>+		 * should be shrunk on a given node.
> >>+		 */
> >> 		while (!populated_zone(zone->zone_pgdat->node_zones +
> >>-							classzone_idx))
> >>+							classzone_idx)) {
> >> 			classzone_idx--;
> >>+			continue;
> 
> Oh and Michal's comment on Patch 20 made me realize that my objection to v6
> about possible underflow of sc->reclaim_idx and classzone_idx seems to still
> apply here for classzone_idx?

Potentially. The relevant code now looks like this

                classzone_idx = sc->reclaim_idx;
                while (!populated_zone(zone->zone_pgdat->node_zones +
                                                        classzone_idx))
                        classzone_idx--;

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
