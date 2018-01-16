Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAAD528024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:21:54 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id d17so15834844ioc.23
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:21:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z131sor1844159itb.40.2018.01.16.13.21.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 13:21:53 -0800 (PST)
Date: Tue, 16 Jan 2018 13:21:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
In-Reply-To: <20180115162500.GA26120@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1801161306250.242486@chino.kir.corp.google.com>
References: <20171130152824.1591-1-guro@fb.com> <20171130123930.cf3217c816fd270fa35a40cb@linux-foundation.org> <alpine.DEB.2.10.1801091556490.173445@chino.kir.corp.google.com> <20180110131143.GB26913@castle.DHCP.thefacebook.com>
 <20180110113345.54dd571967fd6e70bfba68c3@linux-foundation.org> <20180113171432.GA23484@cmpxchg.org> <alpine.DEB.2.10.1801141536380.131380@chino.kir.corp.google.com> <20180115162500.GA26120@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, linux-mm@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 15 Jan 2018, Johannes Weiner wrote:

> > It's quite trivial to allow the root mem cgroup to be compared exactly the 
> > same as another cgroup.  Please see 
> > https://marc.info/?l=linux-kernel&m=151579459920305.
> 
> This only says "that will be fixed" and doesn't address why I care.
> 

Because the design of the cgroup aware oom killer requires the entire 
system to be fully containerized to be useful and select the 
correct/anticipated victim.  If anything is left behind in the root mem 
cgroup, or on systems that use mem cgroups in ways that you do not, it 
returns wildly unpredictable and downright wrong results; it factors 
oom_score_adj into the selection criteria only for processes attached to 
the root mem cgroup and ignores it otherwise.  If we treated root and leaf 
cgroups as comparable, this problem wouldn't arise.

> > > This assumes you even need one. Right now, the OOM killer picks the
> > > biggest MM, so you can evade selection by forking your MM. This patch
> > > allows picking the biggest cgroup, so you can evade by forking groups.
> > 
> > It's quite trivial to prevent any cgroup from evading the oom killer by 
> > either forking their mm or attaching all their processes to subcontainers.  
> > Please see https://marc.info/?l=linux-kernel&m=151579459920305.
> 
> This doesn't address anything I wrote.
> 

It prevents both problems if you are attached to a mem cgroup subtree.  
You can't fork the mm and you can't fork groups to evade the selection 
logic.  If the root mem cgroup and leaf cgroups were truly comparable, it 
also prevents both problems regardless of which cgroup the processes 
attached to.

> > > It's not a new vector, and clearly nobody cares. This has never been
> > > brought up against the current design that I know of.
> > 
> > As cgroup v2 becomes more popular, people will organize their cgroup 
> > hierarchies for all controllers they need to use.  We do this today, for 
> > example, by attaching some individual consumers to child mem cgroups 
> > purely for the rich statistics and vmscan stats that mem cgroup provides 
> > without any limitation on those cgroups.
> 
> There is no connecting tissue between what I wrote and what you wrote.
> 

You're completely ignoring other usecases other than your own highly 
specialized usecase.  You may attach every user process on the system to 
leaf cgroups and you may not have any users who have control over a 
subtree.  Other people do.  And this patchset, as implemented, returns 
very inaccurate results or allows users to intentionally or 
unintentionally evade the oom killer just because they want to use 
subcontainers.

Creating and attaching a subset of processes to either top-level 
containers or subcontainers for either limitation by mem cgroup or for 
statistics is a valid usecase, and one that is used in practice.  Your 
suggestion of avoiding that problem to work around the shortcomings of 
this patchset by limiting how many subcontainers can be created by the 
user is utterly ridiculous.

> We have a patch set that was developed, iterated and improved over 10+
> revisions, based on evaluating and weighing trade-offs. It's reached a
> state where the memcg maintainers are happy with it and don't have any
> concern about future extendabilty to cover more specialized setups.
> 

It's also obviously untested in those 10+ revisions since it uses 
oom_badness() for the root mem cgroup and not leaf mem cgroups which is 
why it breaks any system where user processes are attached to the root mem 
cgroup.  See my example where a 1GB worker attached to the root mem cgroup 
is preferred over a cgroup with 6GB workers.  It may have been tested with 
your own highly specialized usecase, but not with anything else, and the 
author obviously admits its shortcomings.

> You've had nine months to contribute and shape this patch series
> productively, and instead resorted to a cavalcade of polemics,
> evasion, and repetition of truisms and refuted points. A ten paragraph
> proposal of vague ideas at this point is simply not a valid argument.
> 

The patch series has gone through massive changes over the past nine 
months and I've brought up three very specific concerns with its current 
form that makes it non-extensible.  I know the patchset has very 
significant changes or rewrites in its history, but I'm only concerned 
with its present form because it's not something that can easily be 
extended later.  We don't need useless files polutting the cgroup v2 
filesystem for things that don't matter with other oom policies and we 
don't need the mount option, actually.

> You can send patches to replace or improve on Roman's code and make
> the case for them.
> 

I volunteered in the email thread where I proposed an alternative to 
replace it, I'm actively seeking any feedback on that proposal to address 
anybody else's concerns early on.  Your participation in that would be 
very useful.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
