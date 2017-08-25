Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9F4244088B
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 20:15:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b8so3691172pgn.3
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 17:15:17 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id q72si1998756pfd.574.2017.08.24.17.15.16
        for <linux-mm@kvack.org>;
        Thu, 24 Aug 2017 17:15:17 -0700 (PDT)
Date: Fri, 25 Aug 2017 09:15:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
Message-ID: <20170825001543.GC29701@js1304-P5Q-DELUXE>
References: <1503553546-27450-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170824093050.GD5943@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170824093050.GD5943@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 24, 2017 at 11:30:50AM +0200, Michal Hocko wrote:
> On Thu 24-08-17 14:45:46, Joonsoo Kim wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Freepage on ZONE_HIGHMEM doesn't work for kernel memory so it's not that
> > important to reserve. When ZONE_MOVABLE is used, this problem would
> > theorectically cause to decrease usable memory for GFP_HIGHUSER_MOVABLE
> > allocation request which is mainly used for page cache and anon page
> > allocation. So, fix it.
> 
> I do not really understand what is the problem you are trying to fix.
> Yes the memory is reserved for a higher priority consumer and that is
> deliberate AFAICT. Just consider that an OOM victim wants to make
> further progress and rely on memory reserve while doing
> GFP_HIGHUSER_MOVABLE request.
> 
> So what is the real problem you are trying to address here?

If the system has the both, ZONE_HIGHMEM and ZONE_MOVABLE,
ZONE_HIGHMEM will reserve the memory for ZONE_MOVABLE request.
However, they are consumed by nearly equivalent priority consumer who
uses GFP_HIGHMEM + GFP_MOVABLE. In that case, reserved memory in
ZONE_HIGHMEM would not be used and it means just waste of the memory.
This patch try to fix it to nullify reserving memory in ZONE_HIGHMEM.

And, I think that all this problem is caused by the complex code in
lowmem reserve calculation. So, did some clean-up.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
