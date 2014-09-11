Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E6A2C6B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 03:04:11 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so10671303pdb.11
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 00:04:11 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id j7si177704pdp.1.2014.09.11.00.04.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 00:04:10 -0700 (PDT)
Date: Thu, 11 Sep 2014 11:03:53 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
Message-ID: <20140911070353.GA4151@esperanza>
References: <20140904143055.GA20099@esperanza>
 <5408E1CD.3090004@jp.fujitsu.com>
 <20140905082846.GA25641@esperanza>
 <5409C6BB.7060009@jp.fujitsu.com>
 <20140905160029.GF25641@esperanza>
 <540A4420.2030504@jp.fujitsu.com>
 <20140908110131.GA11812@esperanza>
 <540DB4EC.6060100@jp.fujitsu.com>
 <20140910120157.GA13796@esperanza>
 <5410F96B.1020308@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <5410F96B.1020308@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Sep 11, 2014 at 10:22:51AM +0900, Kamezawa Hiroyuki wrote:
> (2014/09/10 21:01), Vladimir Davydov wrote:
> >On Mon, Sep 08, 2014 at 10:53:48PM +0900, Kamezawa Hiroyuki wrote:
> >>(2014/09/08 20:01), Vladimir Davydov wrote:
> >>>On Sat, Sep 06, 2014 at 08:15:44AM +0900, Kamezawa Hiroyuki wrote:
> >>>>As you noticed, hitting anon+swap limit just means oom-kill.
> >>>>My point is that using oom-killer for "server management" just seems crazy.
> >>>>
> >>>>Let my clarify things. your proposal was.
> >>>>  1. soft-limit will be a main feature for server management.
> >>>>  2. Because of soft-limit, global memory reclaim runs.
> >>>>  3. Using swap at global memory reclaim can cause poor performance.
> >>>>  4. So, making use of OOM-Killer for avoiding swap.
> >>>>
> >>>>I can't agree "4". I think
> >>>>
> >>>>  - don't configure swap.
> >>>
> >>>Suppose there are two containers, each having soft limit set to 50% of
> >>>total system RAM. One of the containers eats 90% of the system RAM by
> >>>allocating anonymous pages. Another starts using file caches and wants
> >>>more than 10% of RAM to work w/o issuing disk reads. So what should we
> >>>do then?
> >>>We won't be able to shrink the first container to its soft
> >>>limit, because there's no swap. Leaving it as is would be unfair from
> >>>the second container's point of view. Kill it? But the whole system is
> >>>going OK, because the working set of the second container is easily
> >>>shrinkable. Besides there may be some progress in shrinking file caches
> >>>from the first container.
> >>>
> >>>>  - use zram
> >>>
> >>>In fact this isn't different from the previous proposal (working w/o
> >>>swap). ZRAM only compresses data while still storing them in RAM so we
> >>>eventually may get into a situation where almost all RAM is full of
> >>>compressed anon pages.
> >>>
> >>
> >>In above 2 cases, "vmpressure" works fine.
> >
> >What if a container allocates memory so fast that the userspace thread
> >handling its threshold notifications won't have time to react before it
> >eats all memory?
> >
> 
> Softlimit is for avoiding such unfair memory scheduling, isn't it ?

Yeah, and we're returning back to the very beginning. Anonymous memory
reclaim triggered by soft limit may be impossible due to lack of swap
space or really sluggish. The whole system will be dragging its feet
until it finally realizes the container must be killed. It's a kind of
DOS attack...

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
