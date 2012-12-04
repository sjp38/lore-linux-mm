Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 071486B007D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 09:52:26 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so2909292pad.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2012 06:52:26 -0800 (PST)
Date: Tue, 4 Dec 2012 06:52:21 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] memcg: replace cgroup_lock with memcg specific
 memcg_lock
Message-ID: <20121204145221.GA3885@mtj.dyndns.org>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
 <1354282286-32278-5-git-send-email-glommer@parallels.com>
 <20121203171532.GG17093@dhcp22.suse.cz>
 <50BDAD38.6030200@parallels.com>
 <20121204082316.GB31319@dhcp22.suse.cz>
 <50BDB4E3.4040107@parallels.com>
 <20121204084544.GC31319@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121204084544.GC31319@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

Hello, Michal, Glauber.

On Tue, Dec 04, 2012 at 09:45:44AM +0100, Michal Hocko wrote:
> Because such a helper might be useful in general? I didn't check if
> somebody does the same test elsewhere though.

The problem is that whether a cgroup has a child or not may differ
depending on the specific controller.  You can't tell whether
something exists or not at a given time without synchronization and
synchronization is per-controller.  IOW, if a controller cares about
when a cgroup comes online and goes offline, it should synchronize
those events in ->css_on/offline() and only consider cgroups marked
online as online.

> > If you really dislike doing a children count (I don't like as well, I
> > just don't dislike), maybe we can do something like:
> > 
> > i = 0;
> > for_each_mem_cgroup_tree(iter, memcg) {
> > 	if (i++ == 1)
> > 		return false;
> > }
> > return true;
> 
> I guess you meant:
> i = 0;
> for_each_mem_cgroup_tree(iter, memcg) {
> 	if (i++ == 1) {
> 		mem_cgroup_iter_break(iter);
> 		break;
> 	}
> }
> return i > 1;

Or sth like the following?

bool memcg_has_children(cgrp)
{
	lockdep_assert_held(memcg_lock);

	rcu_read_lock();
	cgroup_for_each_children(pos, cgrp) {
		if (memcg_is_online(pos)) {
			rcu_read_unlock();
			return true;
		}
	}
	rcu_read_unlock();
	return ret;
}

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
