Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52C416B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 11:23:31 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b1so2965995qtc.4
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 08:23:31 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x139si1130698qkb.68.2017.09.15.08.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 08:23:30 -0700 (PDT)
Date: Fri, 15 Sep 2017 08:23:01 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170915152301.GA29379@castle>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
 <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Sep 15, 2017 at 12:58:26PM +0200, Michal Hocko wrote:
> On Thu 14-09-17 09:05:48, Roman Gushchin wrote:
> > On Thu, Sep 14, 2017 at 03:40:14PM +0200, Michal Hocko wrote:
> > > On Wed 13-09-17 14:56:07, Roman Gushchin wrote:
> > > > On Wed, Sep 13, 2017 at 02:29:14PM +0200, Michal Hocko wrote:
> > > [...]
> > > > > I strongly believe that comparing only leaf memcgs
> > > > > is more straightforward and it doesn't lead to unexpected results as
> > > > > mentioned before (kill a small memcg which is a part of the larger
> > > > > sub-hierarchy).
> > > > 
> > > > One of two main goals of this patchset is to introduce cgroup-level
> > > > fairness: bigger cgroups should be affected more than smaller,
> > > > despite the size of tasks inside. I believe the same principle
> > > > should be used for cgroups.
> > > 
> > > Yes bigger cgroups should be preferred but I fail to see why bigger
> > > hierarchies should be considered as well if they are not kill-all. And
> > > whether non-leaf memcgs should allow kill-all is not entirely clear to
> > > me. What would be the usecase?
> > 
> > We definitely want to support kill-all for non-leaf cgroups.
> > A workload can consist of several cgroups and we want to clean up
> > the whole thing on OOM.
> 
> Could you be more specific about such a workload? E.g. how can be such a
> hierarchy handled consistently when its sub-tree gets killed due to
> internal memory pressure?

Or just system-wide OOM.

> Or do you expect that none of the subtree will
> have hard limit configured?

And this can also be a case: the whole workload may have hard limit
configured, while internal memcgs have only memory.low set for "soft"
prioritization.

> 
> But then you just enforce a structural restriction on your configuration
> because
> 	root
>         /  \
>        A    D
>       /\   
>      B  C
> 
> is a different thing than
> 	root
>         / | \
>        B  C  D
>

I actually don't have a strong argument against an approach to select
largest leaf or kill-all-set memcg. I think, in practice there will be
no much difference.

The only real concern I have is that then we have to do the same with
oom_priorities (select largest priority tree-wide), and this will limit
an ability to enforce the priority by parent cgroup.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
