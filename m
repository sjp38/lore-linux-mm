Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED896B0292
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 18:50:40 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o8so58897320pgq.8
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 15:50:40 -0700 (PDT)
Received: from mail-pg0-x22e.google.com (mail-pg0-x22e.google.com. [2607:f8b0:400e:c05::22e])
        by mx.google.com with ESMTPS id a8si5813347ple.184.2017.06.04.15.50.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 15:50:39 -0700 (PDT)
Received: by mail-pg0-x22e.google.com with SMTP id 8so26643605pgc.2
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 15:50:39 -0700 (PDT)
Date: Sun, 4 Jun 2017 15:50:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH v2 1/7] mm, oom: refactor select_bad_process() to
 take memcg as an argument
In-Reply-To: <1496342115-3974-2-git-send-email-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1706041550290.24226@chino.kir.corp.google.com>
References: <1496342115-3974-1-git-send-email-guro@fb.com> <1496342115-3974-2-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

We use a heavily modified system and memcg oom killer and I'm wondering
if there is some opportunity for collaboration because we may have some
shared goals.

I can summarize how we currently use the oom killer at a high level so
that it is not overwhelming with implementation details and give some
rationale for why we have converged onto this strategy over the period of
a few years.

For victim selection, we have strict priority based oom killing both at
the memcg level and the process level.

Each process has its own "badness" value that is independent of
oom_score_adj, although some conversion is done if a third-party thread
chooses to disable itself from oom killing for backwards compatibility.
Lower values are more preferable victims, but that detail should not
matter significantly.  If two processes share the same badness value,
tiebreaks are done by selecting the largest rss.

Each memcg in a hierarchy also has its own badness value which
semantically means the same as the per-process value, although it
considers the entire memcg as a unit, similar to your approach, when
iterating the hierarchy to choose a process.  The benefit of the
per-memcg and per-process approach is that you can kill the lowest
priority process from the lowest priority memcg.

The above scoring is enabled with a VM sysctl for the system and is used
for both system (global) and memcg oom kills.  For system overcommit,
this means we can kill the lowest priority job on the system; for memcg,
we can allow users to define their oom kill priorities at each level of
their own hierarchy.

When the system or root of an oom memcg hierarchy encounters its limit,
we iterate each level of the memcg hierarchy to find the lowest priority
job.  This is done by comparing the badness of the sibling memcgs at
each level, finding the lowest, and iterating that subtree.  If there are
lower priority processes per the per-process badness value compared to
all sibling memcgs, that process is killed.

We also have complete userspace oom handling support.  This complements
the existing memory.oom_control notification when a memcg is oom with a
separate notifier that notifies when the kernel has oom killed a process.
It is possible to delay the oom killer from killing a process for memcg
oom kills with a configurable, per-memcg, oom delay.  If set, the kernel
will wait for userspace to respond to its oom notification and effect its
own policy decisions until memory is uncharged to that memcg hierarchy,
or the oom delay expires.  If the oom delay expires, the kernel oom
killer kills a process based on badness.

Our oom kill notification file used to get an fd to register with
cgroup.event_control also provides oom kill statistics based on system,
memcg, local, hierarchical, and user-induced oom kills when read().

We also have a convenient "kill all" knob that userspace can write when
handling oom conditions to iterate all threads attached to a particular
memcg and kill them.  This is merely to prevent races where userspace
does the oom killing itself, which is not problematic in itself, but
additional tasks continue to be attached to an oom memcg.

A caveat here is that we also support fully inclusive kmem accounting to
memcg hierarchies, so we call the oom killer as part of the memcg charge
path rather than only upon returning from fault with VM_FAULT_OOM.  We
have our own oom killer livelock detection that isn't necessarily
important in this thread, but we haven't encountered a situation where we
livelock by calling the oom killer during charge, and this is a
requirement for memcg charging as part of slab allocation.

I could post many patches to implement all of this functionality that we
have used for a few years, but I first wanted to send this email to see
if there is any common ground or to better understand your methodology
for using the kernel oom killer for both system and memcg oom kills.

Otherwise, very interesting stuff!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
