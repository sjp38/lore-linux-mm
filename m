Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 75B599003C7
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 04:59:27 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so22855262pac.3
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 01:59:27 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sk5si10406739pac.9.2015.08.06.01.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 01:59:26 -0700 (PDT)
Date: Thu, 6 Aug 2015 11:59:11 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/3] Make workingset detection logic memcg aware
Message-ID: <20150806085911.GL11971@esperanza>
References: <cover.1438599199.git.vdavydov@parallels.com>
 <55C16842.9040505@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <55C16842.9040505@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 05, 2015 at 10:34:58AM +0900, Kamezawa Hiroyuki wrote:

> Reading discussion, I feel storing more data is difficult, too.

Yep, even with the current 16-bit memcg id. Things would get even worse
if we wanted to extend it one day (will we?)

> 
> I wonder, rather than collecting more data, rough calculation can help the situation.
> for example,
> 
>    (refault_disatance calculated in zone) * memcg_reclaim_ratio < memcg's active list
> 
> If one of per-zone calc or per-memcg calc returns true, refault should be true.
> 
> memcg_reclaim_ratio is the percentage of scan in a memcg against in a zone.

This particular formula wouldn't work I'm afraid. If there are two
isolated cgroups issuing local reclaim on the same zone, the refault
distance needed for activation would be reduced by half for no apparent
reason.

The thing is that there is no need in inventing anything if refaults
from different cgroups are infrequent - it is enough to store only
zone/node ids in shadow entries then, as this patch set does. The
question remains, can we disregard them? Sometimes we need to sacrifice
accuracy for the sake of performance and/or code simplicity. E.g.
inter-cgroup concurrent file writes are not supported in the
implementation of the blkio writeback accounting AFAIK. May be, we could
neglect inter-cgroup refaults too? My point is that even if two cgroups
are actively sharing the same file, its pages will end up in the cgroup
which experiences less memory pressure (most likely, the one with the
greater limit), so inter-cgroup refaults should be rare. Am I wrong?

Anyway, workingset detection is broken for local reclaim (activations
are random) and needs to be fixed. What is worse, shadow entries are
accounted per memcg, but reclaimed only on global memory pressure, so
that they can eat all RAM available to a container w/o giving it a
chance to reclaim it. That said, even this patch set is a huge step
forward, because it makes activations much more deterministic and fixes
per memcg shadow nodes reclaim.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
