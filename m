Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BAED6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 06:27:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a66so15142714wme.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 03:27:29 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id y4si2236998wjh.3.2016.07.07.03.27.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 03:27:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 2C0C11C1ADA
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 11:27:28 +0100 (IST)
Date: Thu, 7 Jul 2016 11:27:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 09/31] mm, vmscan: by default have direct reclaim only
 shrink once per node
Message-ID: <20160707102726.GS11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-10-git-send-email-mgorman@techsingularity.net>
 <20160707014321.GD27987@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707014321.GD27987@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 07, 2016 at 10:43:22AM +0900, Joonsoo Kim wrote:
> > @@ -2600,6 +2593,16 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >  			classzone_idx--;
> >  
> >  		/*
> > +		 * Shrink each node in the zonelist once. If the zonelist is
> > +		 * ordered by zone (not the default) then a node may be
> > +		 * shrunk multiple times but in that case the user prefers
> > +		 * lower zones being preserved
> > +		 */
> > +		if (zone->zone_pgdat == last_pgdat)
> > +			continue;
> > +		last_pgdat = zone->zone_pgdat;
> > +
> > +		/*
> 
> After this change, compaction_ready() which uses zone information
> would be called with highest zone in node. So, if some lower zone in
> that node is compaction-ready, we cannot stop the reclaim.
> 

Yes. It only impacts direct reclaim but potentially it's an issue. I'll
fix it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
