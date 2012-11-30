Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C4D3E6B0068
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 09:59:31 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so509591pbc.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 06:59:31 -0800 (PST)
Date: Fri, 30 Nov 2012 06:59:24 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
Message-ID: <20121130145924.GA3873@htj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <50B8263C.7060908@jp.fujitsu.com>
 <50B875B4.2020507@parallels.com>
 <20121130092435.GD29317@dhcp22.suse.cz>
 <50B87F84.7040206@parallels.com>
 <20121130094959.GE29317@dhcp22.suse.cz>
 <50B883B5.8020705@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50B883B5.8020705@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lizefan@huawei.com, paul@paulmenage.org, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, bsingharora@gmail.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Fri, Nov 30, 2012 at 02:00:21PM +0400, Glauber Costa wrote:
> Now, what I am actually seeing with cgroup creation, is that the
> children will copy a lot of the values from the parent, like swappiness,
> hierarchy, etc. Once the child copies it, we should no longer be able to
> change those values in the parent: otherwise we'll get funny things like
> parent.use_hierarchy = 1, child.use_hierarchy = 0.

So, the best way to do this is from ->css_online().  If memcg
synchronizes and inherits from ->css_online(), it can guarantee that
the new cgroup will be visible in any following iterations.  Just have
an online flag which is turned on and off from ->css_on/offline() and
ignore any cgroups w/o online set.

> One option is to take a global lock in memcg_alloc_css(), and keep it
> locked until we did all the cgroup bookkeeping, and then unlock it in
> css_online. But I am guessing Tejun won't like it very much.

No, please *NEVER* *EVER* do that.  You'll be creating a bunch of
locking dependencies as cgroup walks through different controllers.

memcg should be able to synchornize fully both css on/offlining and
task attachments in memcg proper.  Let's please be boring about
locking.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
