Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id E42056B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 02:17:17 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id w7so15779372qcr.0
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 23:17:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z5si5084624qar.13.2015.01.15.23.17.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 23:17:16 -0800 (PST)
Date: Fri, 16 Jan 2015 09:07:44 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] mm/vmscan: fix highidx argument type
Message-ID: <20150116070744.GA12190@redhat.com>
References: <1421360175-18899-1-git-send-email-mst@redhat.com>
 <20150115144920.33c446af388ed74c11dc573e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150115144920.33c446af388ed74c11dc573e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org

On Thu, Jan 15, 2015 at 02:49:20PM -0800, Andrew Morton wrote:
> On Fri, 16 Jan 2015 00:18:12 +0200 "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > for_each_zone_zonelist_nodemask wants an enum zone_type
> > argument, but is passed gfp_t:
> > 
> > mm/vmscan.c:2658:9:    expected int enum zone_type [signed] highest_zoneidx
> > mm/vmscan.c:2658:9:    got restricted gfp_t [usertype] gfp_mask
> > mm/vmscan.c:2658:9: warning: incorrect type in argument 2 (different base types)
> > mm/vmscan.c:2658:9:    expected int enum zone_type [signed] highest_zoneidx
> > mm/vmscan.c:2658:9:    got restricted gfp_t [usertype] gfp_mask
> 
> Which tool emitted these warnings?

Oh, sorry.
It's sparce.

> > convert argument to the correct type.
> > 
> > ...
> >
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2656,7 +2656,7 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
> >  	 * should make reasonable progress.
> >  	 */
> >  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > -					gfp_mask, nodemask) {
> > +					gfp_zone(gfp_mask), nodemask) {
> >  		if (zone_idx(zone) > ZONE_NORMAL)
> >  			continue;
> 
> hm, I wonder what the runtime effects are.
> 
> The throttle_direct_reclaim() comment isn't really accurate, is it? 
> "Throttle direct reclaimers if backing storage is backed by the
> network".  The code is applicable to all types of backing, but was
> added to address problems which are mainly observed with network
> backing?


As far as I can tell, yes. It would seem that it can cause
deadlocks in theory.  Cc stable on the grounds that it's obvious?

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
