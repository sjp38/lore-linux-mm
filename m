Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1422628029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 06:46:37 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id z37so14613935qtz.16
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 03:46:37 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p6si5059850qtp.126.2018.01.17.03.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 03:46:36 -0800 (PST)
Date: Wed, 17 Jan 2018 11:46:03 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [patch -mm 0/4] mm, memcg: introduce oom policies
Message-ID: <20180117114554.GA10523@castle.DHCP.thefacebook.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 16, 2018 at 06:14:58PM -0800, David Rientjes wrote:
> There are three significant concerns about the cgroup aware oom killer as
> it is implemented in -mm:
> 
>  (1) allows users to evade the oom killer by creating subcontainers or
>      using other controllers since scoring is done per cgroup and not
>      hierarchically,
> 
>  (2) does not allow the user to influence the decisionmaking, such that
>      important subtrees cannot be preferred or biased, and
> 
>  (3) unfairly compares the root mem cgroup using completely different
>      criteria than leaf mem cgroups and allows wildly inaccurate results
>      if oom_score_adj is used.
> 
> This patchset aims to fix (1) completely and, by doing so, introduces a
> completely extensible user interface that can be expanded in the future.
> 
> It eliminates the mount option for the cgroup aware oom killer entirely
> since it is now enabled through the root mem cgroup's oom policy.
> 
> It eliminates a pointless tunable, memory.oom_group, that unnecessarily
> pollutes the mem cgroup v2 filesystem and is invalid when cgroup v2 is
> mounted with the "groupoom" option.

You're introducing a new oom_policy knob, which has two separate sets
of possible values for the root and non-root cgroups. I don't think
it aligns with the existing cgroup v2 design.

For the root cgroup it works exactly as mount option, and both "none"
and "cgroup" values have no meaning outside of the root cgroup. We can
discuss if a knob on root cgroup is better than a mount option, or not
(I don't think so), but it has nothing to do with oom policy as you
define it for non-root cgroups.

For non-root cgroups you're introducing "all" and "tree", and the _only_
difference is that in the "all" mode all processes will be killed, rather
than the biggest in the "tree". I find these names confusing, in reality
it's more "evaluate together and kill all" and "evaluate together and
kill one".

So, it's not really the fully hierarchical approach, which I thought,
you were arguing for. You can easily do the same with adding the third
value to the memory.groupoom knob, as I've suggested earlier (say, "disable,
"kill" and "evaluate"), and will be much less confusing.

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
