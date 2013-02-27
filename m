Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id B49986B0005
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 03:20:38 -0500 (EST)
Received: by mail-ye0-f201.google.com with SMTP id m12so28075yen.4
        for <linux-mm@kvack.org>; Wed, 27 Feb 2013 00:20:37 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] memcg: implement low limits
References: <8121361952156@webcorp1g.yandex-team.ru>
Date: Wed, 27 Feb 2013 00:20:36 -0800
In-Reply-To: <8121361952156@webcorp1g.yandex-team.ru> (Roman Gushchin's
	message of "Wed, 27 Feb 2013 12:02:36 +0400")
Message-ID: <xr93y5eacgmj.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: Johannes Weiner-Arquette <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 27 2013, Roman Gushchin wrote:

> Hi, all!
>
> I've implemented low limits for memory cgroups. The primary goal was to add an ability 
> to protect some memory from reclaiming without using mlock(). A kind of "soft mlock()".
>
> I think this patch will be helpful when it's necessary to protect production processes from
> memory-wasting backup processes.
>
> --
>
> Low limits for memory cgroup can be used to limit memory pressure on it.
> If memory usage of a cgroup is under it's low limit, it will not be
> affected by global reclaim. If it reaches it's low limit from above,
> the reclaiming speed will be dropped exponentially.
>
> Low limits don't affect soft reclaim.
> Also, it's possible that a cgroup with memory usage under low limit
> will be reclaimed slowly on very low scanning priorities.

So the new low limit is not a rigid limit.  Global reclaim can reclaim
from a cgroup when its usage is below low_limit_in_bytes although such
reclaim is less aggressive than when usage is above low_limit_in_bytes.
Correct?

Why doesn't memcg reclaim (i.e. !global_reclaim) also consider
low_limit_in_bytes?

Do you have demonstration of how this improves system operation?

Why is soft_limit insufficient?

> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> ---
>  include/linux/memcontrol.h  |    7 +++++
>  include/linux/res_counter.h |   17 +++++++++++
>  kernel/res_counter.c        |    2 ++
>  mm/memcontrol.c             |   67 +++++++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                 |    5 ++++
>  5 files changed, 98 insertions(+)

Need to update Documentation/cgroups/memory.txt explaining the external
behavior of this new know and how it interacts with soft_limit_in_bytes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
