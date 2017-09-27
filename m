Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60FCF6B0261
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 06:19:47 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q8so13885785qtb.2
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 03:19:47 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k51si5014514qtk.68.2017.09.27.03.19.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 03:19:46 -0700 (PDT)
Date: Wed, 27 Sep 2017 11:19:13 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170927101913.GB4159@castle>
References: <20170925170004.GA22704@cmpxchg.org>
 <20170925181533.GA15918@castle>
 <20170925202442.lmcmvqwy2jj2tr5h@dhcp22.suse.cz>
 <20170926105925.GA23139@castle.dhcp.TheFacebook.com>
 <20170926112134.r5eunanjy7ogjg5n@dhcp22.suse.cz>
 <20170926121300.GB23139@castle.dhcp.TheFacebook.com>
 <20170926133040.uupv3ibkt3jtbotf@dhcp22.suse.cz>
 <20170926172610.GA26694@cmpxchg.org>
 <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
 <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tim Hockin <thockin@hockin.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Sep 27, 2017 at 09:43:19AM +0200, Michal Hocko wrote:
> On Tue 26-09-17 20:37:37, Tim Hockin wrote:
> [...]
> > I feel like David has offered examples here, and many of us at Google
> > have offered examples as long ago as 2013 (if I recall) of cases where
> > the proposed heuristic is EXACTLY WRONG.
> 
> I do not think we have discussed anything resembling the current
> approach. And I would really appreciate some more examples where
> decisions based on leaf nodes would be EXACTLY WRONG.
>

I would agree here.

The discussing two-step approach (select biggest leaf or oom_group memcg,
then select largest process inside) does really look as a way to go.

It should work well in practice and it allows further development.
It will catch workloads which are leaking child processes by default,
which is an advantage in comparison to the existing algorithm.

Both strong hierarchical approach (as in v8) and pure flat (by Johannes)
are more limiting. In first case, deep hierarchies are affected (as Michal
mentioned) and we stick with tree traverse policy (Tejun's point).

In second case, the further development is under a question: any new idea
(say, oom_priorities, or, for example, if we will have a new useful memcg
metric) should be applied to processes and memcgs simultaneously.
Also, We drop any idea of memcg-level fairness and obtain some implementation
issues (which I mentioned earlier). The idea of mixing tasks and memcgs
leads to a much more hairy code, and the OOM code is already quite hairy.
The idea of comparing killable entities is a leaking abstraction,
as we can't predict how much memory killing a single process will release
(say, for example, the process is the init in a pid namespace).

> > We need OOM behavior to kill in a deterministic order configured by
> > policy.
> 
> And nobody is objecting to this usecase. I think we can build a priority
> policy on top of leaf-based decision as well. The main point we are
> trying to sort out here is a reasonable semantic that would work for
> most workloads. Sibling based selection will simply not work on those
> that have to use deeper hierarchies for organizational purposes. I
> haven't heard a counter argument for that example yet.

Yes, implementing oom_priorities is a ~15 lines patch on top of
the discussing approach. David can use this small off-stream patch
for now, in any case it's a step forward in comparison to the existing state.


Overall, do we have any open question left? Does anyone has any strong
arguments against the discussing design?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
