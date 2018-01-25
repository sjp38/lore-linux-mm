Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4940A6B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 18:27:33 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id d62so8258616iof.8
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 15:27:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g79sor1383404itb.57.2018.01.25.15.27.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jan 2018 15:27:32 -0800 (PST)
Date: Thu, 25 Jan 2018 15:27:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
In-Reply-To: <20180125080542.GK28465@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1801251517460.152440@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com> <20180117154155.GU3460072@devbig577.frc2.facebook.com> <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com> <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com>
 <20180120123251.GB1096857@devbig577.frc2.facebook.com> <alpine.DEB.2.10.1801221420120.16871@chino.kir.corp.google.com> <20180123155301.GS1526@dhcp22.suse.cz> <alpine.DEB.2.10.1801231416330.254281@chino.kir.corp.google.com> <20180124082041.GD1526@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801241340310.24330@chino.kir.corp.google.com> <20180125080542.GK28465@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 25 Jan 2018, Michal Hocko wrote:

> > As a result, this would remove patch 3/4 from the series.  Do you have any 
> > other feedback regarding the remainder of this patch series before I 
> > rebase it?
> 
> Yes, and I have provided it already. What you are proposing is
> incomplete at best and needs much better consideration and much more
> time to settle.
> 

Could you elaborate on why specifying the oom policy for the entire 
hierarchy as part of the root mem cgroup and also for individual subtrees 
is incomplete?  It allows admins to specify and delegate policy decisions 
to subtrees owners as appropriate.  It addresses your concern in the 
/admins and /students example.  It addresses my concern about evading the 
selection criteria simply by creating child cgroups.  It appears to be a 
win-win.  What is incomplete or are you concerned about?

> > I will address the unfair root mem cgroup vs leaf mem cgroup comparison in 
> > a separate patchset to fix an issue where any user of oom_score_adj on a 
> > system that is not fully containerized gets very unusual, unexpected, and 
> > undocumented results.
> 
> I will not oppose but as it has been mentioned several times, this is by
> no means a blocker issue. It can be added on top.
> 

The current implementation is only useful for fully containerized systems 
where no processes are attached to the root mem cgroup.  Anything in the 
root mem cgroup is judged by different criteria and if they use 
/proc/pid/oom_score_adj the entire heuristic breaks down.  That's because 
per-process usage and oom_score_adj are only relevant for the root mem 
cgroup and irrelevant when attached to a leaf.  Because of that, users are 
affected by the design decision and will organize their hierarchies as 
approrpiate to avoid it.  Users who only want to use cgroups for a subset 
of processes but still treat those processes as indivisible logical units 
when attached to cgroups find that it is simply not possible.

I'm focused solely on fixing the three main issues that this 
implementation causes.  One of them, userspace influence to protect 
important cgroups, can be added on top.  The other two, evading the 
selection criteria and unfair comparison of root vs leaf, are shortcomings 
in the design that I believe should be addressed before it's merged to 
avoid changing the API later.  I'm in no rush to ask for the cgroup aware 
oom killer to be merged if it's incomplete and must be changed for 
usecases that are not highly specialized (fully containerized and no use 
of oom_score_adj for any process).  I am actively engaged in fixing it, 
however, so that it becomes a candidate for merge.  Your feedback is 
useful with regard to those fixes, but daily emails on how we must merge 
the current implementation now are not providing value, at least to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
