Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CEC8B6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:46:07 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f51so1687767wrf.10
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 01:46:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c37si6726685wrg.214.2017.09.26.01.46.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 01:46:06 -0700 (PDT)
Date: Tue, 26 Sep 2017 10:46:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170926084602.sloinq7gdoyxo23y@dhcp22.suse.cz>
References: <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
 <20170915152301.GA29379@castle>
 <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz>
 <20170920215341.GA5382@castle>
 <20170925122400.4e7jh5zmuzvbggpe@dhcp22.suse.cz>
 <20170925170004.GA22704@cmpxchg.org>
 <alpine.DEB.2.10.1709251510430.15961@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1709251510430.15961@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 25-09-17 15:21:03, David Rientjes wrote:
> On Mon, 25 Sep 2017, Johannes Weiner wrote:
> 
> > > True but we want to have the semantic reasonably understandable. And it
> > > is quite hard to explain that the oom killer hasn't selected the largest
> > > memcg just because it happened to be in a deeper hierarchy which has
> > > been configured to cover a different resource.
> > 
> > Going back to Michal's example, say the user configured the following:
> > 
> >        root
> >       /    \
> >      A      D
> >     / \
> >    B   C
> > 
> > A global OOM event happens and we find this:
> > - A > D
> > - B, C, D are oomgroups
> > 
> > What the user is telling us is that B, C, and D are compound memory
> > consumers. They cannot be divided into their task parts from a memory
> > point of view.
> > 
> > However, the user doesn't say the same for A: the A subtree summarizes
> > and controls aggregate consumption of B and C, but without groupoom
> > set on A, the user says that A is in fact divisible into independent
> > memory consumers B and C.
> > 
> > If we don't have to kill all of A, but we'd have to kill all of D,
> > does it make sense to compare the two?
> > 
> 
> No, I agree that we shouldn't compare sibling memory cgroups based on 
> different criteria depending on whether group_oom is set or not.
> 
> I think it would be better to compare siblings based on the same criteria 
> independent of group_oom if the user has mounted the hierarchy with the 
> new mode (I think we all agree that the mount option is needed).  It's 
> very easy to describe to the user and the selection is simple to 
> understand. 

I disagree. Just take the most simplistic example when cgroups reflect
some other higher level organization - e.g. school with teachers,
students and admins as the top level cgroups to control the proper cpu
share load. Now you want to have a fair OOM selection between different
entities. Do you consider selecting students all the time as an expected
behavior just because their are the largest group? This just doesn't
make any sense to me.

> Then, once a cgroup has been chosen as the victim cgroup, 
> kill the process with the highest badness, allowing the user to influence 
> that with /proc/pid/oom_score_adj just as today, if group_oom is disabled; 
> otherwise, kill all eligible processes if enabled.

And now, what should be the semantic of group_oom on an intermediate
(non-leaf) memcg? Why should we compare it to other killable entities?
Roman was mentioning a setup where a _single_ workload consists of a
deeper hierarchy which has to be shut down at once. It absolutely makes
sense to consider the cumulative memory of that hierarchy when we are
going to kill it all.

> That, to me, is a very clear semantic and I believe it addresses Roman's 
> usecase.  My desire to have oom priorities amongst siblings is so that 
> userspace can influence which cgroup is chosen, just as it can influence 
> which process is chosen.

But what you are proposing is something different from oom_score_adj.
That only sets bias to the killable entities while priorities on
intermediate non-killable memcgs controls how the whole oom hierarchy
is traversed. So a non-killable intermediate memcg can hugely influence
what gets killed in the end. This is IMHO a tricky and I would even dare
to claim a wrong semantic. I can see priorities being very useful on
killable entities for sure. I am not entirely sure what would be the
best approach yet and that is why I've suggested that to postpone to
after we settle with a simple approach first. Bringing priorities back
to the discussion again will not help to move that forward I am afraid.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
