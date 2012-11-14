Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 6211B6B0072
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:33:48 -0500 (EST)
Date: Wed, 14 Nov 2012 13:33:30 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 3/6] memcg: Simplify mem_cgroup_force_empty_list error
 handling
Message-ID: <20121114183330.GA32421@cmpxchg.org>
References: <1351251453-6140-1-git-send-email-mhocko@suse.cz>
 <1351251453-6140-4-git-send-email-mhocko@suse.cz>
 <508E8B95.406@parallels.com>
 <20121029150022.a595b866.akpm@linux-foundation.org>
 <20121030103559.GA7394@dhcp22.suse.cz>
 <20121113211041.GB1543@cmpxchg.org>
 <20121114135930.GE4929@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121114135930.GE4929@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Wed, Nov 14, 2012 at 02:59:30PM +0100, Michal Hocko wrote:
> On Tue 13-11-12 16:10:41, Johannes Weiner wrote:
> > Would it make sense to stick a wait_on_page_locked() in there just so
> > that we don't busy spin on a page under migration/reclaim?
> 
> Hmm, this would also mean that get_page_unless_zero would fail as well
> and so we would schedule in mem_cgroup_force_empty_list. It is true that
> there might be no other runnable task so we can busy loop so yes this
> would help. Care to cook the patch?

Eventually get_page_unless_zero() would fail but we could still spin
on a page while it's off the LRU and migration performs writeback on
it e.g.  cond_resched() does not necessarily schedule just because
there is another runnable task, I think, it's voluntary preemption
when the task needs rescheduling anyway, not yield.

Maybe not worth bothering...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
