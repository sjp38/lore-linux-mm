Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7F1F6B0007
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:11:13 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id m6-v6so3380861pln.8
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:11:13 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v6si3704434pgq.146.2018.03.15.10.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 10:11:12 -0700 (PDT)
Date: Thu, 15 Mar 2018 17:10:41 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [patch -mm v3 1/3] mm, memcg: introduce per-memcg oom policy
 tunable
Message-ID: <20180315171039.GB1853@castle.DHCP.thefacebook.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1803121757080.192200@chino.kir.corp.google.com>
 <20180314123851.GB20850@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.20.1803141341180.163553@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803141341180.163553@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, David!

On Wed, Mar 14, 2018 at 01:58:59PM -0700, David Rientjes wrote:
> On Wed, 14 Mar 2018, Roman Gushchin wrote:
>  - Does not lock the entire system into a single methodology.  Users
>    working in a subtree can default to what they are used to: per-process
>    oom selection even though their subtree might be targeted by a system
>    policy level decision at the root.  This allow them flexibility to
>    organize their subtree intuitively for use with other controllers in a
>    single hierarchy.
> 
>    The real-world example is a user who currently organizes their subtree
>    for this purpose and has defined oom_score_adj appropriately and now
>    regresses if the admin mounts with the needless "groupoom" option.

I find this extremely confusing.

The problem is that OOM policy defines independently how the OOM
of the corresponding scope is handled, not like how it prefers
to handle OOMs from above.

As I've said, if you're inside a container, you can have OOMs
of different types, depending on settings, which you don't even know about.
Sometimes oom_score_adj works, sometimes not.
Sometimes all processes are killed, sometimes not.
IMO, this adds nothing but mess.

The mount option (which I'm not a big fan of too) was added only
to provide a 100% backward compatibility, what was forced by Michal.
But I doubt that mixing per-process and per-cgroup approach
makes any sense.

> 
>  - Allows changing the oom policy at runtime without remounting the entire
>    cgroup fs.  Depending on how cgroups are going to be used, per-process 
>    vs cgroup-aware may be mandated separately.  This is a trait only of
>    the mem cgroup controller, the root level oom policy is no different
>    from the subtree and depends directly on how the subtree is organized.
>    If other controllers are already being used, requiring a remount to
>    change the system-wide oom policy is an unnecessary burden.
> 
>    The real-world example is systems software that either supports user
>    subtrees or strictly subtrees that it maintains itself.  While other
>    controllers are used, the mem cgroup oom policy can be changed at
>    runtime rather than requiring a remount and reorganizing other
>    controllers exactly as before.

Btw, what the problem with remounting? You don't have to re-create cgroups,
or something like this; the operation is as trivial as adding a flag.

> 
>  - Can be extended to cgroup v1 if necessary.  There is no need for a
>    new cgroup v1 mount option and mem cgroup oom selection is not
>    dependant on any functionality provided by cgroup v2.  The policies
>    introduced here work exactly the same if used with cgroup v1.
> 
>    The real-world example is a cgroup configuration that hasn't had
>    the ability to move to cgroup v2 yet and still would like to use
>    cgroup-aware oom selection with a very trivial change to add the
>    memory.oom_policy file to the cgroup v1 filesystem.

I assume that v1 interface is frozen.

Thanks!
