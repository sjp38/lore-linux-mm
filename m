Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 902FF6B0006
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 04:44:31 -0400 (EDT)
Message-ID: <516131D7.8030004@huawei.com>
Date: Sun, 7 Apr 2013 16:44:07 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/7] memcg: make memcg's life cycle the same as cgroup
References: <515BF233.6070308@huawei.com>
In-Reply-To: <515BF233.6070308@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi,

I'm rebasing this patchset against latest linux-next, and it conflicts with
"[PATCH v2] memcg: debugging facility to access dangling memcgs." slightly.

That is a debugging patch and will never be pushed into mainline, so should I
still base this patchset on that debugging patch?

Also that patch needs update (and can be simplified) after this patchset:
- move memcg_dangling_add() to mem_cgroup_css_offline()
- remove memcg->memcg_name, and use cgroup_path() in mem_cgroup_dangling_read()?

On 2013/4/3 17:11, Li Zefan wrote:
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
> 
> btw, after this patchset I think we don't need to free memcg via RCU, because
> cgroup is already freed in RCU callback.
> 
> Note this patchset is based on a few memcg fixes I sent (but hasn't been
> accepted)
> 
> --
>  kernel/cgroup.c |  10 ++++++++
>  mm/memcontrol.c | 129 ++++++++++++++++++++++++++++++++++++++-------------------------------------------------------
>  2 files changed, 62 insertions(+), 77 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
