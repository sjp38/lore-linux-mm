Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A91256B0007
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 08:07:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t11-v6so11261791edq.1
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 05:07:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z14-v6si391330edd.127.2018.07.12.05.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 05:07:05 -0700 (PDT)
Date: Thu, 12 Jul 2018 14:07:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180712120703.GJ32648@dhcp22.suse.cz>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Wed 11-07-18 15:40:03, Roman Gushchin wrote:
> Hello!
> 
> I was thinking on how to move forward with the cgroup-aware OOM killer.
> It looks to me, that we all agree on the "cleanup" part of the patchset:
> it's a nice feature to be able to kill all tasks in the cgroup
> to guarantee the consistent state of the workload.
> All our disagreements are related to the victim selection algorithm.
> 
> So, I wonder, if the right thing to do is to split the problem.
> We can agree on the "cleanup" part, which is useful by itself,
> merge it upstream, and then return to the victim selection
> algorithm.

Could you be more specific which patches are those please?

> So, here is my proposal:
> let's introduce the memory.group_oom knob with the following semantics:
> if the knob is set, the OOM killer can kill either none, either all
> tasks in the cgroup*.
> It can perfectly work with the current OOM killer (as a "cleanup" option),
> and allows _any_ further approach on the OOM victim selection.
> It also doesn't require any mount/boot/tree-wide options.
> 
> How does it sound?

Well, I guess we have already discussed that. One problem I can see with
that approach is that there is a disconnection between what is the oom
killable entity and oom candidate entity. This will matter when we start
seeing reports that a wrong container has been torn down because there
were larger ones running. All that just because the latter ones consists
of smaller tasks.

Is this a fundamental roadblock? I am not sure but I would tend to say
_no_ because the oom victim selection has always been an implementation
detail. We just need to kill _somebody_ to release _some_ memory. Kill
the whole workload is a sensible thing to do.

So I would be ok with that even though I am still not sure why we should
start with something half done when your original implementation was
much more consistent. Sure there is some disagreement but I suspect
that we will get stuck with an intermediate solution later on again for
very same reasons. I have summarized [1] current contention points and
I would really appreciate if somebody who wasn't really involved in the
previous discussions could just join there and weight arguments. OOM
selection policy is just a heuristic with some potential drawbacks and
somebody might object and block otherwise useful features for others for
ever.  So we should really find some consensus on what is reasonable and
what is just over the line.

[1] http://lkml.kernel.org/r/20180605114729.GB19202@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs
