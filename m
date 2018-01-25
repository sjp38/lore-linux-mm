Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 717B66B0008
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 18:53:45 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id q18so8468280ioh.4
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 15:53:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w37sor2207076ioe.207.2018.01.25.15.53.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jan 2018 15:53:44 -0800 (PST)
Date: Thu, 25 Jan 2018 15:53:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm v2 0/3] mm, memcg: introduce oom policies
In-Reply-To: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
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

It preserves memory.oom_group behavior.
---
 Applied on top of -mm.

 Documentation/cgroup-v2.txt | 64 ++++++++++++++++++++++++++++-----------------
 include/linux/cgroup-defs.h |  5 ----
 include/linux/memcontrol.h  | 21 +++++++++++++++
 kernel/cgroup/cgroup.c      | 13 +--------
 mm/memcontrol.c             | 64 ++++++++++++++++++++++++++++++++++++---------
 5 files changed, 114 insertions(+), 53 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
