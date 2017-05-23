Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1942C6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 03:07:51 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b28so14716170wrb.2
        for <linux-mm@kvack.org>; Tue, 23 May 2017 00:07:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i24si12672130wrc.170.2017.05.23.00.07.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 May 2017 00:07:49 -0700 (PDT)
Date: Tue, 23 May 2017 09:07:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170523070747.GF12813@dhcp22.suse.cz>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
 <20170520183729.GA3195@esperanza>
 <20170522170116.GB22625@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170522170116.GB22625@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Vladimir Davydov <vdavydov@tarantool.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 22-05-17 18:01:16, Roman Gushchin wrote:
> On Sat, May 20, 2017 at 09:37:29PM +0300, Vladimir Davydov wrote:
> > Hello Roman,
> 
> Hi Vladimir!
> 
> > 
> > On Thu, May 18, 2017 at 05:28:04PM +0100, Roman Gushchin wrote:
> > ...
> > > +5-2-4. Cgroup-aware OOM Killer
> > > +
> > > +Cgroup v2 memory controller implements a cgroup-aware OOM killer.
> > > +It means that it treats memory cgroups as memory consumers
> > > +rather then individual processes. Under the OOM conditions it tries
> > > +to find an elegible leaf memory cgroup, and kill all processes
> > > +in this cgroup. If it's not possible (e.g. all processes belong
> > > +to the root cgroup), it falls back to the traditional per-process
> > > +behaviour.
> > 
> > I agree that the current OOM victim selection algorithm is totally
> > unfair in a system using containers and it has been crying for rework
> > for the last few years now, so it's great to see this finally coming.
> > 
> > However, I don't reckon that killing a whole leaf cgroup is always the
> > best practice. It does make sense when cgroups are used for
> > containerizing services or applications, because a service is unlikely
> > to remain operational after one of its processes is gone, but one can
> > also use cgroups to containerize processes started by a user. Kicking a
> > user out for one of her process has gone mad doesn't sound right to me.
> 
> I agree, that it's not always a best practise, if you're not allowed
> to change the cgroup configuration (e.g. create new cgroups).
> IMHO, this case is mostly covered by using the v1 cgroup interface,
> which remains unchanged.

But there are features which are v2 only and users might really want to
use it. So I really do not buy this v2-only argument.

> If you do have control over cgroups, you can put processes into
> separate cgroups, and obtain control over OOM victim selection and killing.

Usually you do not have that control because there is a global daemon
doing the placement for you.

> > Another example when the policy you're suggesting fails in my opinion is
> > in case a service (cgroup) consists of sub-services (sub-cgroups) that
> > run processes. The main service may stop working normally if one of its
> > sub-services is killed. So it might make sense to kill not just an
> > individual process or a leaf cgroup, but the whole main service with all
> > its sub-services.
> 
> I agree, although I do not pretend for solving all possible
> userspace problems caused by an OOM.
> 
> How to react on an OOM - is definitely a policy, which depends
> on the workload. Nothing is changing here from how it's working now,
> except now kernel will choose a victim cgroup, and kill the victim cgroup
> rather than a process.

There is a _big_ difference. The current implementation just tries
to recover from the OOM situation without carying much about the
consequences on the workload. This is the last resort and a services for
the _system_ to get back to sane state. You are trying to make it more
clever and workload aware and that is inevitable going to depend on the
specific workload. I really do think we cannot simply hardcode any
policy into the kernel for this purpose and that is why I would like to
see a discussion about how to do that in a more extensible way. This
might be harder to implement now but it I believe it will turn out
better longerm.

> > And both kinds of workloads (services/applications and individual
> > processes run by users) can co-exist on the same host - consider the
> > default systemd setup, for instance.
> > 
> > IMHO it would be better to give users a choice regarding what they
> > really want for a particular cgroup in case of OOM - killing the whole
> > cgroup or one of its descendants. For example, we could introduce a
> > per-cgroup flag that would tell the kernel whether the cgroup can
> > tolerate killing a descendant or not. If it can, the kernel will pick
> > the fattest sub-cgroup or process and check it. If it cannot, it will
> > kill the whole cgroup and all its processes and sub-cgroups.
> 
> The last thing we want to do, is to compare processes with cgroups.
> I agree, that we can have some option to disable the cgroup-aware OOM at all,
> mostly for backward-compatibility. But I don't think it should be a
> per-cgroup configuration option, which we will support forever.

I can clearly see a demand for "this is definitely more important
container than others so do not kill" usecases. I can also see demand
for "do not kill this container running for X days". And more are likely
to pop out.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
