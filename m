Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A45C5280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:15:03 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id f67so5566418itf.2
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:15:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v191sor2143188ith.115.2018.01.16.18.15.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 18:15:02 -0800 (PST)
Date: Tue, 16 Jan 2018 18:14:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 0/4] mm, memcg: introduce oom policies
Message-ID: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There are three significant concerns about the cgroup aware oom killer as
it is implemented in -mm:

 (1) allows users to evade the oom killer by creating subcontainers or
     using other controllers since scoring is done per cgroup and not
     hierarchically,

 (2) does not allow the user to influence the decisionmaking, such that
     important subtrees cannot be preferred or biased, and

 (3) unfairly compares the root mem cgroup using completely different
     criteria than leaf mem cgroups and allows wildly inaccurate results
     if oom_score_adj is used.

This patchset aims to fix (1) completely and, by doing so, introduces a
completely extensible user interface that can be expanded in the future.

It eliminates the mount option for the cgroup aware oom killer entirely
since it is now enabled through the root mem cgroup's oom policy.

It eliminates a pointless tunable, memory.oom_group, that unnecessarily
pollutes the mem cgroup v2 filesystem and is invalid when cgroup v2 is
mounted with the "groupoom" option.
---
 Applied on top of -mm.

 Documentation/cgroup-v2.txt |  87 ++++++++++++++++-----------------
 include/linux/cgroup-defs.h |   5 --
 include/linux/memcontrol.h  |  37 ++++++++++----
 kernel/cgroup/cgroup.c      |  13 +----
 mm/memcontrol.c             | 116 +++++++++++++++++++++++++-------------------
 mm/oom_kill.c               |   4 +-
 6 files changed, 139 insertions(+), 123 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
