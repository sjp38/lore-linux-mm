Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 2F29D6B0068
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 05:48:49 -0400 (EDT)
Date: Mon, 1 Oct 2012 11:48:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 06/13] memcg: kmem controller infrastructure
Message-ID: <20121001094846.GC8622@dhcp22.suse.cz>
References: <1347977050-29476-1-git-send-email-glommer@parallels.com>
 <1347977050-29476-7-git-send-email-glommer@parallels.com>
 <20120926155108.GE15801@dhcp22.suse.cz>
 <5064392D.5040707@parallels.com>
 <20120927134432.GE29104@dhcp22.suse.cz>
 <50658B3B.9020303@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50658B3B.9020303@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 28-09-12 15:34:19, Glauber Costa wrote:
> On 09/27/2012 05:44 PM, Michal Hocko wrote:
> >> > the reference count aquired by mem_cgroup_get will still prevent the
> >> > memcg from going away, no?
> > Yes but you are outside of the rcu now and we usually do css_get before
> > we rcu_unlock. mem_cgroup_get just makes sure the group doesn't get
> > deallocated but it could be gone before you call it. Or I am just
> > confused - these 2 levels of ref counting is really not nice.
> > 
> > Anyway, I have just noticed that __mem_cgroup_try_charge does
> > VM_BUG_ON(css_is_removed(&memcg->css)) on a given memcg so you should
> > keep css ref count up as well.
> > 
> 
> IIRC, css_get will prevent the cgroup directory from being removed.
> Because some allocations are expected to outlive the cgroup, we
> specifically don't want that.

Yes, but how do you guarantee that the above VM_BUG_ON doesn't trigger?
Task could have been moved to another group between mem_cgroup_from_task
and mem_cgroup_get, no?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
