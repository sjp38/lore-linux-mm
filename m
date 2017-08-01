Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1198F6B0569
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 13:03:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d24so3160256wmi.0
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 10:03:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k63si1556390wmf.26.2017.08.01.10.03.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 10:03:07 -0700 (PDT)
Date: Tue, 1 Aug 2017 19:03:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v4 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170801170302.GB15518@dhcp22.suse.cz>
References: <20170726132718.14806-1-guro@fb.com>
 <20170726132718.14806-3-guro@fb.com>
 <20170801145435.GN15774@dhcp22.suse.cz>
 <20170801152548.GA29502@castle.dhcp.TheFacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170801152548.GA29502@castle.dhcp.TheFacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 01-08-17 16:25:48, Roman Gushchin wrote:
> On Tue, Aug 01, 2017 at 04:54:35PM +0200, Michal Hocko wrote:
[...]
> > I would reap out the oom_kill_process into a separate patch.
> 
> It was a separate patch, I've merged it based on Vladimir's feedback.
> No problems, I can divide it back.

It would make the review slightly more easier
> 
> > > -static void oom_kill_process(struct oom_control *oc, const char *message)
> > > +static void __oom_kill_process(struct task_struct *victim)
> > 
> > To the rest of the patch. I have to say I do not quite like how it is
> > implemented. I was hoping for something much simpler which would hook
> > into oom_evaluate_task. If a task belongs to a memcg with kill-all flag
> > then we would update the cumulative memcg badness (more specifically the
> > badness of the topmost parent with kill-all flag). Memcg will then
> > compete with existing self contained tasks (oom_badness will have to
> > tell whether points belong to a task or a memcg to allow the caller to
> > deal with it). But it shouldn't be much more complex than that.
> 
> I'm not sure, it will be any simpler. Basically I'm doing the same:
> the difference is that you want to iterate over tasks and for each
> task traverse the memcg tree, update per-cgroup oom score and find
> the corresponding memcg(s) with the kill-all flag. I'm doing the opposite:
> traverse the cgroup tree, and for each leaf cgroup iterate over processes.

Yeah but this doesn't fit very well to the existing scheme so we would
need two different schemes which is not ideal from maint. point of view.
We also do not have to duplicate all the tricky checks we already do in
oom_evaluate_task. So I would prefer if we could try to hook there and
do the special handling there.

> Also, please note, that even without the kill-all flag the decision is made
> on per-cgroup level (except tasks in the root cgroup).

Yeah and I am not sure this is a reasonable behavior. Why should we
consider memcgs which are not kill-all as a single entity?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
