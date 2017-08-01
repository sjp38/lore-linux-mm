Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E74C6B056D
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 14:14:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l3so3206638wrc.12
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 11:14:25 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id a23si1693966wme.75.2017.08.01.11.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 11:14:23 -0700 (PDT)
Date: Tue, 1 Aug 2017 19:13:52 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v4 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170801181352.GA26074@castle.DHCP.thefacebook.com>
References: <20170726132718.14806-1-guro@fb.com>
 <20170726132718.14806-3-guro@fb.com>
 <20170801145435.GN15774@dhcp22.suse.cz>
 <20170801152548.GA29502@castle.dhcp.TheFacebook.com>
 <20170801170302.GB15518@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170801170302.GB15518@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 01, 2017 at 07:03:03PM +0200, Michal Hocko wrote:
> On Tue 01-08-17 16:25:48, Roman Gushchin wrote:
> > On Tue, Aug 01, 2017 at 04:54:35PM +0200, Michal Hocko wrote:
> [...]
> > > I would reap out the oom_kill_process into a separate patch.
> > 
> > It was a separate patch, I've merged it based on Vladimir's feedback.
> > No problems, I can divide it back.
> 
> It would make the review slightly more easier
> > 
> > > > -static void oom_kill_process(struct oom_control *oc, const char *message)
> > > > +static void __oom_kill_process(struct task_struct *victim)
> > > 
> > > To the rest of the patch. I have to say I do not quite like how it is
> > > implemented. I was hoping for something much simpler which would hook
> > > into oom_evaluate_task. If a task belongs to a memcg with kill-all flag
> > > then we would update the cumulative memcg badness (more specifically the
> > > badness of the topmost parent with kill-all flag). Memcg will then
> > > compete with existing self contained tasks (oom_badness will have to
> > > tell whether points belong to a task or a memcg to allow the caller to
> > > deal with it). But it shouldn't be much more complex than that.
> > 
> > I'm not sure, it will be any simpler. Basically I'm doing the same:
> > the difference is that you want to iterate over tasks and for each
> > task traverse the memcg tree, update per-cgroup oom score and find
> > the corresponding memcg(s) with the kill-all flag. I'm doing the opposite:
> > traverse the cgroup tree, and for each leaf cgroup iterate over processes.
> 
> Yeah but this doesn't fit very well to the existing scheme so we would
> need two different schemes which is not ideal from maint. point of view.
> We also do not have to duplicate all the tricky checks we already do in
> oom_evaluate_task. So I would prefer if we could try to hook there and
> do the special handling there.

I hope, that iterating over all tasks just to check if there are
in-flight OOM victims might be optimized at some point.
That means, we would be able to choose a victim much cheaper.
It's not easy, but it feels as a right direction to go.

Also, adding new tricks to the oom_evaluate_task() will make the code
even more hairy. Some of the existing tricks are useless for memcg selection.

> 
> > Also, please note, that even without the kill-all flag the decision is made
> > on per-cgroup level (except tasks in the root cgroup).
> 
> Yeah and I am not sure this is a reasonable behavior. Why should we
> consider memcgs which are not kill-all as a single entity?

I think, it's reasonable to choose a cgroup/container to blow off based on
the cgroup oom_priority/size (including hierarchical settings), and then
kill one biggest or all tasks depending on cgroup settings.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
