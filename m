Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E4B6C6B0035
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 21:23:54 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ey11so10483974pad.20
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 18:23:54 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id gh7si29732151pbd.204.2014.09.10.18.23.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 18:23:53 -0700 (PDT)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 964793EE0CD
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 10:23:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 94482AC0759
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 10:23:50 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3821F1DB803F
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 10:23:50 +0900 (JST)
Message-ID: <5410F96B.1020308@jp.fujitsu.com>
Date: Thu, 11 Sep 2014 10:22:51 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
References: <20140904143055.GA20099@esperanza> <5408E1CD.3090004@jp.fujitsu.com> <20140905082846.GA25641@esperanza> <5409C6BB.7060009@jp.fujitsu.com> <20140905160029.GF25641@esperanza> <540A4420.2030504@jp.fujitsu.com> <20140908110131.GA11812@esperanza> <540DB4EC.6060100@jp.fujitsu.com> <20140910120157.GA13796@esperanza>
In-Reply-To: <20140910120157.GA13796@esperanza>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

(2014/09/10 21:01), Vladimir Davydov wrote:
> On Mon, Sep 08, 2014 at 10:53:48PM +0900, Kamezawa Hiroyuki wrote:
>> (2014/09/08 20:01), Vladimir Davydov wrote:
>>> On Sat, Sep 06, 2014 at 08:15:44AM +0900, Kamezawa Hiroyuki wrote:
>>>> As you noticed, hitting anon+swap limit just means oom-kill.
>>>> My point is that using oom-killer for "server management" just seems crazy.
>>>>
>>>> Let my clarify things. your proposal was.
>>>>   1. soft-limit will be a main feature for server management.
>>>>   2. Because of soft-limit, global memory reclaim runs.
>>>>   3. Using swap at global memory reclaim can cause poor performance.
>>>>   4. So, making use of OOM-Killer for avoiding swap.
>>>>
>>>> I can't agree "4". I think
>>>>
>>>>   - don't configure swap.
>>>
>>> Suppose there are two containers, each having soft limit set to 50% of
>>> total system RAM. One of the containers eats 90% of the system RAM by
>>> allocating anonymous pages. Another starts using file caches and wants
>>> more than 10% of RAM to work w/o issuing disk reads. So what should we
>>> do then?
>>> We won't be able to shrink the first container to its soft
>>> limit, because there's no swap. Leaving it as is would be unfair from
>>> the second container's point of view. Kill it? But the whole system is
>>> going OK, because the working set of the second container is easily
>>> shrinkable. Besides there may be some progress in shrinking file caches
>> >from the first container.
>>>
>>>>   - use zram
>>>
>>> In fact this isn't different from the previous proposal (working w/o
>>> swap). ZRAM only compresses data while still storing them in RAM so we
>>> eventually may get into a situation where almost all RAM is full of
>>> compressed anon pages.
>>>
>>
>> In above 2 cases, "vmpressure" works fine.
>
> What if a container allocates memory so fast that the userspace thread
> handling its threshold notifications won't have time to react before it
> eats all memory?
>

Softlimit is for avoiding such unfair memory scheduling, isn't it ?

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
