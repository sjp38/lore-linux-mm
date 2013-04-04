Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 746AC6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 08:00:53 -0400 (EDT)
Date: Thu, 4 Apr 2013 14:00:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 0/7] memcg: make memcg's life cycle the same as
 cgroup
Message-ID: <20130404120049.GI29911@dhcp22.suse.cz>
References: <515BF233.6070308@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515BF233.6070308@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed 03-04-13 17:11:15, Li Zefan wrote:
> (I'll be off from my office soon, and I won't be responsive in the following
> 3 days.)
> 
> I'm working on converting memcg to use cgroup->id, and then we can kill css_id.
> 
> Now memcg has its own refcnt, so when a cgroup is destroyed, the memcg can
> still be alive. This patchset converts memcg to always use css_get/put, so
> memcg will have the same life cycle as its corresponding cgroup, and then
> it's always safe for memcg to use cgroup->id.
> 
> The historical reason that memcg didn't use css_get in some cases, is that
> cgroup couldn't be removed if there're still css refs. The situation has
> changed so that rmdir a cgroup will succeed regardless css refs, but won't
> be freed until css refs goes down to 0.
> 
> This is an early post, and it's NOT TESTED. I just want to see if the changes
> are fine in general.

yes, I like the approach and it looks correct as well (some minor things
mentioned in the patches). Thanks a lot Li! This will make our lifes much
easier. The separate ref counting was PITA especially after
introduction of kmem accounting which made its usage even more trickier.

> btw, after this patchset I think we don't need to free memcg via RCU, because
> cgroup is already freed in RCU callback.

But this depends on changes waiting in for-3.10 branch, right?
Anyway, I think we should be safe with the workqueue based releasing as
well once mem_cgroup_{get,put} are gone, right?

> Note this patchset is based on a few memcg fixes I sent (but hasn't been
> accepted)
> 
> --
>  kernel/cgroup.c |  10 ++++++++
>  mm/memcontrol.c | 129 ++++++++++++++++++++++++++++++++++++++-------------------------------------------------------
>  2 files changed, 62 insertions(+), 77 deletions(-)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
