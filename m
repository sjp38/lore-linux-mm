Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 385006B0027
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 16:21:37 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id k19so2229425qcs.41
        for <linux-mm@kvack.org>; Sun, 07 Apr 2013 13:21:36 -0700 (PDT)
Date: Sun, 7 Apr 2013 22:21:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 0/7] memcg: make memcg's life cycle the same as
 cgroup
Message-ID: <20130407202130.GB12678@dhcp22.suse.cz>
References: <515BF233.6070308@huawei.com>
 <20130404120049.GI29911@dhcp22.suse.cz>
 <51610B78.7080001@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51610B78.7080001@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Sun 07-04-13 14:00:24, Li Zefan wrote:
> On 2013/4/4 20:00, Michal Hocko wrote:
> > On Wed 03-04-13 17:11:15, Li Zefan wrote:
> >> (I'll be off from my office soon, and I won't be responsive in the following
> >> 3 days.)
> >>
> >> I'm working on converting memcg to use cgroup->id, and then we can kill css_id.
> >>
> >> Now memcg has its own refcnt, so when a cgroup is destroyed, the memcg can
> >> still be alive. This patchset converts memcg to always use css_get/put, so
> >> memcg will have the same life cycle as its corresponding cgroup, and then
> >> it's always safe for memcg to use cgroup->id.
> >>
> >> The historical reason that memcg didn't use css_get in some cases, is that
> >> cgroup couldn't be removed if there're still css refs. The situation has
> >> changed so that rmdir a cgroup will succeed regardless css refs, but won't
> >> be freed until css refs goes down to 0.
> >>
> >> This is an early post, and it's NOT TESTED. I just want to see if the changes
> >> are fine in general.
> > 
> > yes, I like the approach and it looks correct as well (some minor things
> > mentioned in the patches). Thanks a lot Li! This will make our lifes much
> > easier. The separate ref counting was PITA especially after
> > introduction of kmem accounting which made its usage even more trickier.
> > 
> >> btw, after this patchset I think we don't need to free memcg via RCU, because
> >> cgroup is already freed in RCU callback.
> > 
> > But this depends on changes waiting in for-3.10 branch, right?
> 
> What changes? memcg changes or cgroup core changes? I don't think this depends
> on anything in cgroup 3.10 branch.

cgroup (be445626 e.g.) but now I've noticed that those are already
merged in Linus tree.

FYI: I've cherry-picked themo my -mm git tree.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
