Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEBF56B0007
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 11:55:25 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i10-v6so30476149qtp.13
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 08:55:25 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x33-v6si3153076qtd.174.2018.07.12.08.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 08:55:20 -0700 (PDT)
Date: Thu, 12 Jul 2018 08:55:00 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180712155456.GA28187@castle.DHCP.thefacebook.com>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
 <20180712120703.GJ32648@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180712120703.GJ32648@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Thu, Jul 12, 2018 at 02:07:03PM +0200, Michal Hocko wrote:
> On Wed 11-07-18 15:40:03, Roman Gushchin wrote:
> > Hello!
> > 
> > I was thinking on how to move forward with the cgroup-aware OOM killer.
> > It looks to me, that we all agree on the "cleanup" part of the patchset:
> > it's a nice feature to be able to kill all tasks in the cgroup
> > to guarantee the consistent state of the workload.
> > All our disagreements are related to the victim selection algorithm.
> > 
> > So, I wonder, if the right thing to do is to split the problem.
> > We can agree on the "cleanup" part, which is useful by itself,
> > merge it upstream, and then return to the victim selection
> > algorithm.
> 
> Could you be more specific which patches are those please?

It's not quite a part of existing patchset. But I had such version
during my work on the current patchset, and it was really small and cute.
I need some time to restore/rebase it.

> 
> > So, here is my proposal:
> > let's introduce the memory.group_oom knob with the following semantics:
> > if the knob is set, the OOM killer can kill either none, either all
> > tasks in the cgroup*.
> > It can perfectly work with the current OOM killer (as a "cleanup" option),
> > and allows _any_ further approach on the OOM victim selection.
> > It also doesn't require any mount/boot/tree-wide options.
> > 
> > How does it sound?
> 
> Well, I guess we have already discussed that. One problem I can see with
> that approach is that there is a disconnection between what is the oom
> killable entity and oom candidate entity. This will matter when we start
> seeing reports that a wrong container has been torn down because there
> were larger ones running. All that just because the latter ones consists
> of smaller tasks.
> 
> Is this a fundamental roadblock? I am not sure but I would tend to say
> _no_ because the oom victim selection has always been an implementation
> detail. We just need to kill _somebody_ to release _some_ memory. Kill
> the whole workload is a sensible thing to do.

Yes. We also use Johaness's memory pressure metrics for making OOM
decisions internally, which is working nice. In this case the in-kernel
OOM decision logic serves more as a backup solution, and consistency
is the only thing which does really matter.

> 
> So I would be ok with that even though I am still not sure why we should
> start with something half done when your original implementation was
> much more consistent. Sure there is some disagreement but I suspect
> that we will get stuck with an intermediate solution later on again for
> very same reasons. I have summarized [1] current contention points and
> I would really appreciate if somebody who wasn't really involved in the
> previous discussions could just join there and weight arguments. OOM
> selection policy is just a heuristic with some potential drawbacks and
> somebody might object and block otherwise useful features for others for
> ever.  So we should really find some consensus on what is reasonable and
> what is just over the line.

I would definitely prefer just to land the existing version, and I prefer
it over this proposal. But it doesn't seem to be going forward well...

Maybe making the described step first might help.

Thanks,
Roman
