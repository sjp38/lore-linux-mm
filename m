Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id A5BFC6B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 11:33:53 -0500 (EST)
Date: Mon, 21 Jan 2013 17:33:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 4/6] memcg: replace cgroup_lock with memcg specific
 memcg_lock
Message-ID: <20130121163349.GR7798@dhcp22.suse.cz>
References: <1358766813-15095-1-git-send-email-glommer@parallels.com>
 <1358766813-15095-5-git-send-email-glommer@parallels.com>
 <20130121144919.GO7798@dhcp22.suse.cz>
 <50FD5AC0.9020406@parallels.com>
 <20130121152032.GP7798@dhcp22.suse.cz>
 <50FD6003.8060703@parallels.com>
 <20130121160731.GQ7798@dhcp22.suse.cz>
 <50FD68E1.2070303@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FD68E1.2070303@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Mon 21-01-13 20:12:17, Glauber Costa wrote:
> On 01/21/2013 08:07 PM, Michal Hocko wrote:
> >> > And the reason why kmemcg holds the set_limit mutex
> >> > is just to protect from itself, then there is no *need* to hold any
> >> > extra lock (and we'll never be able to stop holding the creation lock,
> >> > whatever it is). So my main point here is not memcg_mutex vs
> >> > set_limit_mutex, but rather, memcg_mutex is needed anyway, and once it
> >> > is taken, the set_limit_mutex *can* be held, but doesn't need to.
> > So you can update kmem specific usage of set_limit_mutex.
> Meaning ?

I thought you've said it is not needed and the code says that:
- memcg_propagate_kmem is called with memcg_mutex held in css_alloc
- memcg_update_kmem_limit takes both of them
- kmem_cache_destroy_memcg_children _doesn't_ take both

So one obvious way to go would be changing
kmem_cache_destroy_memcg_children to memcg_mutex and removing
set_limit_mutex from other two paths.

This would leave set_limit_mutex lock for its original intention.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
