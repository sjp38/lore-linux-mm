Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id BF3AD6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 22:32:20 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l126so2867241wml.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 19:32:20 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w124si585541wmd.90.2015.12.16.19.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 19:32:19 -0800 (PST)
Date: Wed, 16 Dec 2015 22:32:04 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151217033204.GA29735@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz>
 <20151214194258.GH28521@esperanza>
 <566F8781.80108@jp.fujitsu.com>
 <20151215145011.GA20355@cmpxchg.org>
 <5670D806.60408@jp.fujitsu.com>
 <20151216110912.GA29816@cmpxchg.org>
 <56722203.5030604@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56722203.5030604@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 17, 2015 at 11:46:27AM +0900, Kamezawa Hiroyuki wrote:
> On 2015/12/16 20:09, Johannes Weiner wrote:
> >On Wed, Dec 16, 2015 at 12:18:30PM +0900, Kamezawa Hiroyuki wrote:
> >>  - swap-full notification via vmpressure or something mechanism.
> >
> >Why?
> >
> 
> I think it's a sign of unhealthy condition, starting file cache drop rate to rise.
> But I forgot that there are resource threshold notifier already. Does the notifier work
> for swap.usage ?

That will be reflected in vmpressure or other distress mechanisms. I'm
not convinced "ran out of swap space" needs special casing in any way.

> >>  - force swap-in at reducing swap.limit
> >
> >Why?
> >
> If full, swap.limit cannot be reduced even if there are available memory in a cgroup.
> Another cgroup cannot make use of the swap resource while it's occupied by other cgroup.
> The job scheduler should have a chance to fix the situation.

I don't see why swap space allowance would need to be as dynamically
adjustable as the memory allowance. There is usually no need to be as
tight with swap space as with memory, and the performance penalty of
swapping, even with flash drives, is high enough that swap space acts
as an overflow vessel rather than be part of the regularly backing of
the anonymous/shmem working set. It really is NOT obvious that swap
space would need to be adjusted on the fly, and that it's important
that reducing the limit will be reflected in consumption right away.

We shouldn't be adding hundreds of lines of likely terrible heuristics
code* on speculation that somebody MIGHT find this useful in real life.
We should wait until we are presented with a real usecase that applies
to a whole class of users, and then see what the true requirements are.

* If a group has 200M swapped out and the swap limit is reduced by 10M
below the current consumption, which pages would you swap in? There is
no LRU list for swap space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
