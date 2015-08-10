Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 12B3B6B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:14:34 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so21855291pac.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 01:14:33 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pr10si31875317pbb.122.2015.08.10.01.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 01:14:32 -0700 (PDT)
Date: Mon, 10 Aug 2015 11:14:14 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/3] Make workingset detection logic memcg aware
Message-ID: <20150810081414.GB16760@esperanza>
References: <cover.1438599199.git.vdavydov@parallels.com>
 <55C16842.9040505@jp.fujitsu.com>
 <20150806085911.GL11971@esperanza>
 <55C40C08.8010706@jp.fujitsu.com>
 <20150808130501.GA16760@esperanza>
 <55C75FC9.2060803@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <55C75FC9.2060803@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Aug 09, 2015 at 11:12:25PM +0900, Kamezawa Hiroyuki wrote:
> On 2015/08/08 22:05, Vladimir Davydov wrote:
> >On Fri, Aug 07, 2015 at 10:38:16AM +0900, Kamezawa Hiroyuki wrote:
...
> >>All ? hmm. It seems that mixture of record of global memory pressure and of local memory
> >>pressure is just wrong.
> >
> >What makes you think so? An example of misbehavior caused by this would
> >be nice to have.
> >
> 
> By design, memcg's LRU aging logic is independent from global memory allocation/pressure.
> 
> 
> Assume there are 4 containers(using much page-cache) with 1GB limit on 4GB server,
>   # contaienr A  workingset=600M   limit=1G (sleepy)
>   # contaienr B  workingset=300M   limit=1G (work often)
>   # container C  workingset=500M   limit=1G (work slowly)
>   # container D  workingset=1.2G   limit=1G (work hard)
> container D can drive the zone's distance counter because of local memory reclaim.
> If active/inactive = 1:1, container D page can be activated.
> At kswapd(global reclaim) runs, all container's LRU will rotate.
> 
> Possibility of refault in A, B, C is reduced by conainer D's counter updates.

This does not necessarily mean we have to use different inactive_age
counter for global and local memory pressure. In your example, having
inactive_age per lruvec and using it for evictions on both global and
local memory pressure would work just fine.

> 
> But yes, some _real_  test are required.
> 
> >>
> >>Now, the record is
> >>a??a??a??a??
> >>a??a??a??a??eviction | node | zone | 2bit.
> >>
> >>How about changing this as
> >>
> >>         0 |eviction | node | zone | 2bit
> >>         1 |eviction |  memcgid    | 2bit
> >>
> >>Assume each memcg has an eviction counter, which ignoring node/zone.
> >>i.e. memcg local reclaim happens against memcg not against zone.
> >>
> >>At page-in,
> >>         if (the 1st bit is 0)
> >>                 compare eviction counter with zone's counter and activate the page if needed.
> >>         else if (the 1st bit is 1)
> >>                 compare eviction counter with the memcg (if exists)
> >
> >Having a single counter per memcg won't scale with the number of NUMA
> >nodes.
> >
> It doesn't matter, we can use lazy counter like pcpu counter because it's not needed to be very accurate.

Fair enough.

> 
> 
> >>                 if (current memcg == recorded memcg && eviction distance is okay)
> >>                      activate page.
> >>                 else
> >>                      inactivate
> >>At page-out
> >>         if (global memory pressure)
> >>                 record eviction id with using zone's counter.
> >>         else if (memcg local memory pressure)
> >>                 record eviction id with memcg's counter.
> >>
> >
> >I don't understand how this is supposed to work when a memory cgroup
> >experiences both local and global pressure simultaneously.
> >
> 
> I think updating global distance counter by local reclaim may update counter too much.

But if the inactive_age counter was per lruvec, then we wouldn't need to
bother about it.

> Above is to avoid updating zone's counter and keep memcg's LRU active/inactive balanced.
> 
> >Also, what if a memory cgroup is protected by memory.low? Such a cgroup
> >may have all its pages in the active list, because it is never scanned.
> 
> If LRU never scanned, all file caches tend to be in INACTIVE...it never refaults.

This is not true - there still may be activations from
mark_page_accessed.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
