Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id E9F106B0253
	for <linux-mm@kvack.org>; Sat,  8 Aug 2015 09:05:18 -0400 (EDT)
Received: by iodd187 with SMTP id d187so134299018iod.2
        for <linux-mm@kvack.org>; Sat, 08 Aug 2015 06:05:18 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id il7si23825334pac.156.2015.08.08.06.05.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Aug 2015 06:05:17 -0700 (PDT)
Date: Sat, 8 Aug 2015 16:05:01 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/3] Make workingset detection logic memcg aware
Message-ID: <20150808130501.GA16760@esperanza>
References: <cover.1438599199.git.vdavydov@parallels.com>
 <55C16842.9040505@jp.fujitsu.com>
 <20150806085911.GL11971@esperanza>
 <55C40C08.8010706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <55C40C08.8010706@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 07, 2015 at 10:38:16AM +0900, Kamezawa Hiroyuki wrote:
> On 2015/08/06 17:59, Vladimir Davydov wrote:
> >On Wed, Aug 05, 2015 at 10:34:58AM +0900, Kamezawa Hiroyuki wrote:
> >>I wonder, rather than collecting more data, rough calculation can help the situation.
> >>for example,
> >>
> >>    (refault_disatance calculated in zone) * memcg_reclaim_ratio < memcg's active list
> >>
> >>If one of per-zone calc or per-memcg calc returns true, refault should be true.
> >>
> >>memcg_reclaim_ratio is the percentage of scan in a memcg against in a zone.
> >
> >This particular formula wouldn't work I'm afraid. If there are two
> >isolated cgroups issuing local reclaim on the same zone, the refault
> >distance needed for activation would be reduced by half for no apparent
> >reason.
> 
> Hmm, you mean activation in memcg means activation in global LRU, and it's not a
> valid reason. Current implementation does have the same issue, right ?
> 
> i.e. when a container has been hitting its limit for a while, and then, a file cache is
> pushed out but came back soon, it can be easily activated.
> 
> I'd like to confirm what you want to do.
> 
>  1) avoid activating a file cache when it was kicked out because of memcg's local limit.

No, that's not what I want. I want pages of the workingset to get
activated on refault no matter if they were evicted on global memory
pressure or due to hitting a memory cgroup limit.

>  2) maintain acitve/inactive ratio in memcg properly as global LRU does.
>  3) reclaim shadow entry at proper timing.
> 
> All ? hmm. It seems that mixture of record of global memory pressure and of local memory
> pressure is just wrong.

What makes you think so? An example of misbehavior caused by this would
be nice to have.

> 
> Now, the record is
> a??a??a??a??
> a??a??a??a??eviction | node | zone | 2bit.
> 
> How about changing this as
> 
>         0 |eviction | node | zone | 2bit
>         1 |eviction |  memcgid    | 2bit
> 
> Assume each memcg has an eviction counter, which ignoring node/zone.
> i.e. memcg local reclaim happens against memcg not against zone.
> 
> At page-in,
>         if (the 1st bit is 0)
>                 compare eviction counter with zone's counter and activate the page if needed.
>         else if (the 1st bit is 1)
>                 compare eviction counter with the memcg (if exists)

Having a single counter per memcg won't scale with the number of NUMA
nodes.

>                 if (current memcg == recorded memcg && eviction distance is okay)
>                      activate page.
>                 else
>                      inactivate
> At page-out
>         if (global memory pressure)
>                 record eviction id with using zone's counter.
>         else if (memcg local memory pressure)
>                 record eviction id with memcg's counter.
> 

I don't understand how this is supposed to work when a memory cgroup
experiences both local and global pressure simultaneously.

Also, what if a memory cgroup is protected by memory.low? Such a cgroup
may have all its pages in the active list, because it is never scanned.
This will affect the refault distance of other cgroups, making
activations unpredictable.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
