Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F01B6B025E
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 18:21:06 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m30so18341272pgn.2
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 15:21:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o88sor3457425pfj.79.2017.09.25.15.21.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 15:21:05 -0700 (PDT)
Date: Mon, 25 Sep 2017 15:21:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
In-Reply-To: <20170925170004.GA22704@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1709251510430.15961@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com> <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz> <20170913215607.GA19259@castle> <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz> <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz> <20170915152301.GA29379@castle> <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz> <20170920215341.GA5382@castle> <20170925122400.4e7jh5zmuzvbggpe@dhcp22.suse.cz> <20170925170004.GA22704@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 25 Sep 2017, Johannes Weiner wrote:

> > True but we want to have the semantic reasonably understandable. And it
> > is quite hard to explain that the oom killer hasn't selected the largest
> > memcg just because it happened to be in a deeper hierarchy which has
> > been configured to cover a different resource.
> 
> Going back to Michal's example, say the user configured the following:
> 
>        root
>       /    \
>      A      D
>     / \
>    B   C
> 
> A global OOM event happens and we find this:
> - A > D
> - B, C, D are oomgroups
> 
> What the user is telling us is that B, C, and D are compound memory
> consumers. They cannot be divided into their task parts from a memory
> point of view.
> 
> However, the user doesn't say the same for A: the A subtree summarizes
> and controls aggregate consumption of B and C, but without groupoom
> set on A, the user says that A is in fact divisible into independent
> memory consumers B and C.
> 
> If we don't have to kill all of A, but we'd have to kill all of D,
> does it make sense to compare the two?
> 

No, I agree that we shouldn't compare sibling memory cgroups based on 
different criteria depending on whether group_oom is set or not.

I think it would be better to compare siblings based on the same criteria 
independent of group_oom if the user has mounted the hierarchy with the 
new mode (I think we all agree that the mount option is needed).  It's 
very easy to describe to the user and the selection is simple to 
understand.  Then, once a cgroup has been chosen as the victim cgroup, 
kill the process with the highest badness, allowing the user to influence 
that with /proc/pid/oom_score_adj just as today, if group_oom is disabled; 
otherwise, kill all eligible processes if enabled.

That, to me, is a very clear semantic and I believe it addresses Roman's 
usecase.  My desire to have oom priorities amongst siblings is so that 
userspace can influence which cgroup is chosen, just as it can influence 
which process is chosen.

I see group_oom as a mechanism to be used when victim selection has 
already been done instead of something that should be considered in the 
policy of victim selection.

> Let's consider an extreme case of this conundrum:
> 
> 	root
>       /     \
>      A       B
>     /|\      |
>  A1-A1000    B1
> 
> Again we find:
> - A > B
> - A1 to A1000 and B1 are oomgroups
> But:
> - A1 to A1000 individually are tiny, B1 is huge
> 
> Going level by level, we'd pick A as the bigger hierarchy in the
> system, and then kill off one of the tiny groups A1 to A1000.
> 
> Conversely, going for biggest consumer regardless of hierarchy, we'd
> compare A1 to A1000 and B1, then pick B1 as the biggest single atomic
> memory consumer in the system and kill all its tasks.
> 

If we compare sibling memcgs independent of group_oom, we don't 
necessarily pick A unless it really is larger than B.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
