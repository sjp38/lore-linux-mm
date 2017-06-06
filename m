Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E73906B02F4
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 12:20:57 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k30so15667651wrc.9
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 09:20:57 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 7si16818228wrs.220.2017.06.06.09.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 09:20:56 -0700 (PDT)
Date: Tue, 6 Jun 2017 17:20:07 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH v2 1/7] mm, oom: refactor select_bad_process() to
 take memcg as an argument
Message-ID: <20170606162007.GB752@castle>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
 <1496342115-3974-2-git-send-email-guro@fb.com>
 <alpine.DEB.2.10.1706041550290.24226@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1706041550290.24226@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Jun 04, 2017 at 03:50:37PM -0700, David Rientjes wrote:
> We use a heavily modified system and memcg oom killer and I'm wondering
> if there is some opportunity for collaboration because we may have some
> shared goals.
> 
> I can summarize how we currently use the oom killer at a high level so
> that it is not overwhelming with implementation details and give some
> rationale for why we have converged onto this strategy over the period of
> a few years.
> 
> For victim selection, we have strict priority based oom killing both at
> the memcg level and the process level.
> 
> Each process has its own "badness" value that is independent of
> oom_score_adj, although some conversion is done if a third-party thread
> chooses to disable itself from oom killing for backwards compatibility.
> Lower values are more preferable victims, but that detail should not
> matter significantly.  If two processes share the same badness value,
> tiebreaks are done by selecting the largest rss.
> 
> Each memcg in a hierarchy also has its own badness value which
> semantically means the same as the per-process value, although it
> considers the entire memcg as a unit, similar to your approach, when
> iterating the hierarchy to choose a process.  The benefit of the
> per-memcg and per-process approach is that you can kill the lowest
> priority process from the lowest priority memcg.
> 
> The above scoring is enabled with a VM sysctl for the system and is used
> for both system (global) and memcg oom kills.  For system overcommit,
> this means we can kill the lowest priority job on the system; for memcg,
> we can allow users to define their oom kill priorities at each level of
> their own hierarchy.
> 
> When the system or root of an oom memcg hierarchy encounters its limit,
> we iterate each level of the memcg hierarchy to find the lowest priority
> job.  This is done by comparing the badness of the sibling memcgs at
> each level, finding the lowest, and iterating that subtree.  If there are
> lower priority processes per the per-process badness value compared to
> all sibling memcgs, that process is killed.
> 
> We also have complete userspace oom handling support.  This complements
> the existing memory.oom_control notification when a memcg is oom with a
> separate notifier that notifies when the kernel has oom killed a process.
> It is possible to delay the oom killer from killing a process for memcg
> oom kills with a configurable, per-memcg, oom delay.  If set, the kernel
> will wait for userspace to respond to its oom notification and effect its
> own policy decisions until memory is uncharged to that memcg hierarchy,
> or the oom delay expires.  If the oom delay expires, the kernel oom
> killer kills a process based on badness.
> 
> Our oom kill notification file used to get an fd to register with
> cgroup.event_control also provides oom kill statistics based on system,
> memcg, local, hierarchical, and user-induced oom kills when read().
> 
> We also have a convenient "kill all" knob that userspace can write when
> handling oom conditions to iterate all threads attached to a particular
> memcg and kill them.  This is merely to prevent races where userspace
> does the oom killing itself, which is not problematic in itself, but
> additional tasks continue to be attached to an oom memcg.
> 
> A caveat here is that we also support fully inclusive kmem accounting to
> memcg hierarchies, so we call the oom killer as part of the memcg charge
> path rather than only upon returning from fault with VM_FAULT_OOM.  We
> have our own oom killer livelock detection that isn't necessarily
> important in this thread, but we haven't encountered a situation where we
> livelock by calling the oom killer during charge, and this is a
> requirement for memcg charging as part of slab allocation.
> 
> I could post many patches to implement all of this functionality that we
> have used for a few years, but I first wanted to send this email to see
> if there is any common ground or to better understand your methodology
> for using the kernel oom killer for both system and memcg oom kills.
> 
> Otherwise, very interesting stuff!

Hi David!

Thank you for sharing this!

It's very interesting, and it looks like,
it's not that far from what I've suggested.

So we definitily need to come up with some common solution.

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
