Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id BB0266B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 22:58:32 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id to18so31297256igc.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 19:58:32 -0800 (PST)
Received: from mgwkm02.jp.fujitsu.com (mgwkm02.jp.fujitsu.com. [202.219.69.169])
        by mx.google.com with ESMTPS id ka5si8274192igb.53.2015.12.15.19.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 19:58:32 -0800 (PST)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id E3054AC0081
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 12:58:25 +0900 (JST)
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz> <20151214194258.GH28521@esperanza>
 <20151215172127.GC27880@dhcp22.suse.cz>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <5670E147.8060203@jp.fujitsu.com>
Date: Wed, 16 Dec 2015 12:57:59 +0900
MIME-Version: 1.0
In-Reply-To: <20151215172127.GC27880@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/12/16 2:21, Michal Hocko wrote:
  
> I completely agree that malicious/untrusted users absolutely have to
> be capped by the hard limit. Then the separate swap limit would work
> for sure. But I am less convinced about usefulness of the rigid (to
> the global memory pressure) swap limit without the hard limit. All the
> memory that could have been swapped out will make a memory pressure to
> the rest of the system without being punished for it too much. Memcg
> is allowed to grow over the high limit (in the current implementation)
> without any way to shrink back in other words.
>
> My understanding was that the primary use case for the swap limit is to
> handle potential (not only malicious but also unexpectedly misbehaving
> application) anon memory consumption runaways more gracefully without
> the massive disruption on the global level. I simply didn't see swap
> space partitioning as important enough because an alternative to swap
> usage is to consume primary memory which is a more precious resource
> IMO. Swap storage is really cheap and runtime expandable resource which
> is not the case for the primary memory in general. Maybe there are other
> use cases I am not aware of, though. Do you want to guarantee the swap
> availability?
>

At the first implementation, NEC guy explained their use case in HPC area.
At that time, there was no swap support.

Considering 2 workloads partitioned into group A, B. total swap was 100GB.
   A: memory.limit = 40G
   B: memory.limit = 40G

Job scheduler runs applications in A and B in turn. Apps in A stops while Apps in B running.

If App-A requires 120GB of anonymous memory, it uses 80GB of swap. So, App-B can use only
20GB of swap. This can cause trouble if App-B needs 100GB of anonymous memory.
They need some knob to control amount of swap per cgroup.

The point is, at least for their customer, the swap is "resource", which should be under
control. With their use case, memory usage and swap usage has the same meaning. So,
mem+swap limit doesn't cause trouble.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
