Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 4C8E36B0005
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 05:11:22 -0500 (EST)
From: Roman Gushchin <klamm@yandex-team.ru>
In-Reply-To: <xr93y5eacgmj.fsf@gthelen.mtv.corp.google.com>
References: <8121361952156@webcorp1g.yandex-team.ru> <xr93y5eacgmj.fsf@gthelen.mtv.corp.google.com>
Subject: Re: [PATCH] memcg: implement low limits
MIME-Version: 1.0
Message-Id: <16331361959879@webcorp2g.yandex-team.ru>
Date: Wed, 27 Feb 2013 14:11:19 +0400
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=koi8-r
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner-Arquette <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> So the new low limit is not a rigid limit. ?Global reclaim can reclaim
> from a cgroup when its usage is below low_limit_in_bytes although such
> reclaim is less aggressive than when usage is above low_limit_in_bytes.
> Correct?

That's true.
But such reclaim occurs only on very small reclaiming priorities, 
so it's not a common behavior. It's mostly a protection against 
a case when all cgroups are under low limit (a results of wrong cgroups configuration).

>
> Why doesn't memcg reclaim (i.e. !global_reclaim) also consider
> low_limit_in_bytes?

For some configurations (for instance, low_limit_in_bytes == limit_in_bytes) it will work ugly.
May be it's better to introduce some restrictions on setting memcg limits, but it will be
a much more significant change from a user's point of view.

>
> Do you have demonstration of how this improves system operation?

Assume, you have a machine with some production processes (db, web servers, etc) and a set 
of additional helper processes. You have to protect production processes from steeling theirs 
memory by other processes.
You have constant memory starvation, so kswapd works fast permanently. The production processes 
use, for instance, 80-90% of all physical memory.
Setting low limit for production cgroup to 80% of physical memory solves this problem easily and secure.

And I see no possibility to solve this task with current hard- and soft limits.
So, even if I set hard limit for all other processes to 20% of physical memory, it doesn't mean that 
production cgroup will not been scanned/reclaimed. Some magic with soft limits can help in some cases, 
but it's much more complex in configuration (see below).

> Why is soft_limit insufficient?


1) If I want to grant (and protect) some amount of memory to a cgroup, i have to set soft limits for 
all other cgroups. I must consider total amount of memory, number of cgroups, theirs soft and hard limits.
Low limits provide an easier interface.
2) It works only on DEF_PRIORITY priority.
3) Also, it can be so, that my preferable cgroup is higher above it's soft limit than 
other cgroups (and it's hard to control), so it will be reclaimed more intensively than necessary.

>> ?Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
>> ?---
>> ??include/linux/memcontrol.h ?| ???7 +++++
>> ??include/linux/res_counter.h | ??17 +++++++++++
>> ??kernel/res_counter.c ???????| ???2 ++
>> ??mm/memcontrol.c ????????????| ??67 +++++++++++++++++++++++++++++++++++++++++++
>> ??mm/vmscan.c ????????????????| ???5 ++++
>> ??5 files changed, 98 insertions(+)
>
> Need to update Documentation/cgroups/memory.txt explaining the external
> behavior of this new know and how it interacts with soft_limit_in_bytes.

Will do.

Thank you!

--
Regards,
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
