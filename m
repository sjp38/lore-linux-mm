Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30B0F6B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 16:07:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q76so560695pfq.5
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 13:07:36 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r90sor7294828pfg.111.2017.09.14.13.07.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Sep 2017 13:07:34 -0700 (PDT)
Date: Thu, 14 Sep 2017 13:07:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
In-Reply-To: <20170914133407.e7gstxssq6j5lo25@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1709141257400.91150@chino.kir.corp.google.com>
References: <20170911131742.16482-1-guro@fb.com> <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com> <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz> <alpine.DEB.2.10.1709131340020.146292@chino.kir.corp.google.com>
 <20170914133407.e7gstxssq6j5lo25@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 14 Sep 2017, Michal Hocko wrote:

> > It is certainly possible to add oom priorities on top before it is merged, 
> > but I don't see why it isn't part of the patchset.
> 
> Because the semantic of the priority for non-leaf memcgs is not fully
> clear and I would rather have the core of the functionality merged
> before this is sorted out.
> 

We can't merge the core of the feature before this is sorted out because 
then users start to depend on behavior and we must be backwards 
compatible.  We need a full patchset that introduces the new selection 
heuristic and a way for userspace to control it to either bias or prefer 
one cgroup over another.  The kill-all mechanism is a more orthogonal 
feature for the cgroup-aware oom killer than oom priorities.

I have a usecase for both the cgroup-aware oom killer and its oom 
priorities from previous versions of this patchset, I assume that Roman 
does as well, and would like to see it merged bacause there are real-world 
usecases for it rather than hypothetical usecases that would want to do 
something different.

> > We need it before its 
> > merged to avoid users playing with /proc/pid/oom_score_adj to prevent any 
> > killing in the most preferable memcg when they could have simply changed 
> > the oom priority.
> 
> I am sorry but I do not really understand your concern. Are you
> suggesting that users would start oom disable all tasks in a memcg to
> give it a higher priority? Even if that was the case why should such an
> abuse be a blocker for generic memcg aware oom killer being merged?

If users do not have any way to control victim selection because of a 
shortcoming in the kernel implementation, they will be required to oom 
disable processes and let that be inherited by children they fork in the 
memcg hierarchy to protect cgroups that they do not want to be oom killed, 
regardless of their size.  They simply are left with no other alternative 
if they want to use the cgroup-aware oom killer and/or the kill-all 
mechanism.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
