Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 7376B6B005D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 02:58:54 -0500 (EST)
Message-ID: <50BDAD38.6030200@parallels.com>
Date: Tue, 4 Dec 2012 11:58:48 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] memcg: replace cgroup_lock with memcg specific memcg_lock
References: <1354282286-32278-1-git-send-email-glommer@parallels.com> <1354282286-32278-5-git-send-email-glommer@parallels.com> <20121203171532.GG17093@dhcp22.suse.cz>
In-Reply-To: <20121203171532.GG17093@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On 12/03/2012 09:15 PM, Michal Hocko wrote:
> On Fri 30-11-12 17:31:26, Glauber Costa wrote:
> [...]
>> +/*
>> + * must be called with memcg_lock held, unless the cgroup is guaranteed to be
>> + * already dead (like in mem_cgroup_force_empty, for instance).
>> + */
>> +static inline bool memcg_has_children(struct mem_cgroup *memcg)
>> +{
>> +	return mem_cgroup_count_children(memcg) != 1;
>> +}
> 
> Why not just keep list_empty(&cgrp->children) which is much simpler much
> more effective and correct here as well because cgroup cannot vanish
> while we are at the call because all callers come from cgroup fs?
> 
Because it depends on cgroup's internal representation, which I think
we're better off not depending upon, even if this is not as serious a
case as the locking stuff. But also, technically, cgrp->children is
protected by the cgroup_lock(), while since we'll hold the memcg_lock
during creation and also around the iterators, we cover everything with
the same lock.

That said, of course we don't need to do the full iteration here, and
mem_cgroup_count_children is indeed overkill. We could just as easily
verify if any child exist - it is just an emptiness test after all. But
it is not living in any fast path, though, and I just assumed code reuse
to win over efficiency in this particular case -
mem_cgroup_count_children already existed...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
