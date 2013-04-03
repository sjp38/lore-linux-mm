Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 248EF6B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 17:43:41 -0400 (EDT)
Received: by mail-da0-f46.google.com with SMTP id y19so838394dan.33
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 14:43:40 -0700 (PDT)
Date: Wed, 3 Apr 2013 14:43:36 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH 0/7] memcg: make memcg's life cycle the same as
 cgroup
Message-ID: <20130403214336.GF3411@htj.dyndns.org>
References: <515BF233.6070308@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515BF233.6070308@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Apr 03, 2013 at 05:11:15PM +0800, Li Zefan wrote:
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

Hallelujah.  This one is egregious if you take a step back and what
happened as a whole.  cgroup core had this weird object life-time
management rule where it forces draining of all css refs on cgroup
destruction, which is very unusual and puts unnecessary restrictions
on css object usages in controllers.

As the restriction wasn't too nice, memcg goes ahead and creates its
own object which basically is the same as css but has a different
life-time rule and does refcnting for both objects.  Bah....

So, yeah, let's please get rid of this abomination.  It shouldn't have
existed from the beginning.

Thanks a lot for doing this!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
