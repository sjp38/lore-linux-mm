Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 093C244088B
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 03:33:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b189so1700096wmd.3
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 00:33:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 130si737218wmf.221.2017.08.25.00.33.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 00:33:17 -0700 (PDT)
Date: Fri, 25 Aug 2017 09:33:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
Message-ID: <20170825073314.GC25498@dhcp22.suse.cz>
References: <1503553546-27450-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170824093050.GD5943@dhcp22.suse.cz>
 <20170825001543.GC29701@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170825001543.GC29701@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 25-08-17 09:15:43, Joonsoo Kim wrote:
> On Thu, Aug 24, 2017 at 11:30:50AM +0200, Michal Hocko wrote:
> > On Thu 24-08-17 14:45:46, Joonsoo Kim wrote:
> > > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > 
> > > Freepage on ZONE_HIGHMEM doesn't work for kernel memory so it's not that
> > > important to reserve. When ZONE_MOVABLE is used, this problem would
> > > theorectically cause to decrease usable memory for GFP_HIGHUSER_MOVABLE
> > > allocation request which is mainly used for page cache and anon page
> > > allocation. So, fix it.
> > 
> > I do not really understand what is the problem you are trying to fix.
> > Yes the memory is reserved for a higher priority consumer and that is
> > deliberate AFAICT. Just consider that an OOM victim wants to make
> > further progress and rely on memory reserve while doing
> > GFP_HIGHUSER_MOVABLE request.
> > 
> > So what is the real problem you are trying to address here?
> 
> If the system has the both, ZONE_HIGHMEM and ZONE_MOVABLE,
> ZONE_HIGHMEM will reserve the memory for ZONE_MOVABLE request.

Ohh, right. I forgot that __GFP_MOVABLE doesn't really enforce the
movable zone. It does so only if __GFP_HIGHMEM is specified as well when
ZONE_HIGHMEM is enabled. So indeed reserving memory in both is somehow
awkward. So why don't we simply remove reserves from the movable zone
when the highmem zone is enabled?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
