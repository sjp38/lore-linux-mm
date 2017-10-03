Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39D7A6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 10:22:51 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e26so6451248pfd.4
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 07:22:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q68si4073083pfb.223.2017.10.03.07.22.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 07:22:50 -0700 (PDT)
Date: Tue, 3 Oct 2017 16:22:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v9 3/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20171003142246.xactdt7xddqdhvtu@dhcp22.suse.cz>
References: <20170927130936.8601-1-guro@fb.com>
 <20170927130936.8601-4-guro@fb.com>
 <20171003114848.gstdawonla2gmfio@dhcp22.suse.cz>
 <20171003123721.GA27919@castle.dhcp.TheFacebook.com>
 <20171003133623.hoskmd3fsh4t2phf@dhcp22.suse.cz>
 <20171003140841.GA29624@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003140841.GA29624@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 03-10-17 15:08:41, Roman Gushchin wrote:
> On Tue, Oct 03, 2017 at 03:36:23PM +0200, Michal Hocko wrote:
[...]
> > I guess we want to inherit the value on the memcg creation but I agree
> > that enforcing parent setting is weird. I will think about it some more
> > but I agree that it is saner to only enforce per memcg value.
> 
> I'm not against, but we should come up with a good explanation, why we're
> inheriting it; or not inherit.

Inheriting sounds like a less surprising behavior. Once you opt in for
oom_group you can expect that descendants are going to assume the same
unless they explicitly state otherwise.

[...]
> > > > > @@ -962,6 +968,48 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> > > > >  	__oom_kill_process(victim);
> > > > >  }
> > > > >  
> > > > > +static int oom_kill_memcg_member(struct task_struct *task, void *unused)
> > > > > +{
> > > > > +	if (!tsk_is_oom_victim(task)) {
> > > > 
> > > > How can this happen?
> > > 
> > > We do start with killing the largest process, and then iterate over all tasks
> > > in the cgroup. So, this check is required to avoid killing tasks which are
> > > already in the termination process.
> > 
> > Do you mean we have tsk_is_oom_victim && MMF_OOM_SKIP == T?
> 
> No, just tsk_is_oom_victim. We're are killing the biggest task, and then _all_
> tasks. This is a way to skip the biggest task, and do not kill it again.

OK, I have missed that part. Why are we doing that actually? Why don't
we simply do 
	/* If oom_group flag is set, kill all belonging tasks */
	if (mem_cgroup_oom_group(oc->chosen_memcg))
		mem_cgroup_scan_tasks(oc->chosen_memcg, oom_kill_memcg_member,
				      NULL);

we are going to kill all the tasks anyway.

[...]
> > > > Hmm, does the full dump_header really apply for the new heuristic? E.g.
> > > > does it make sense to dump_tasks()? Would it make sense to print stats
> > > > of all eligible memcgs instead?
> > > 
> > > Hm, this is a tricky part: the dmesg output is at some point a part of ABI,
> > 
> > People are parsing oom reports but I disagree this is an ABI of any
> > sort. The report is closely tight to the particular implementation and
> > as such it has changed several times over the time.
> > 
> > > but is also closely connected with the implementation. So I would suggest
> > > to postpone this until we'll get more usage examples and will better
> > > understand what information we need.
> > 
> > I would drop tasks list at least because that is clearly misleading in
> > this context because we are not selecting from all tasks. We are
> > selecting between memcgs. The memcg information can be added in a
> > separate patch of course.
> 
> Let's postpone it until we'll land the rest of the patchset.

This is certainly not a show stopper but I would like to resolve it
sooner rather than later.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
