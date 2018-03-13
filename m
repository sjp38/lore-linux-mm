Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC8496B0007
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 20:57:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t6so4295823pgt.11
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 17:57:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7-v6sor2740515pls.108.2018.03.12.17.57.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Mar 2018 17:57:53 -0700 (PDT)
Date: Mon, 12 Mar 2018 17:57:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm v3 0/3] mm, memcg: introduce oom policies
Message-ID: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There are three significant concerns about the cgroup aware oom killer as
it is implemented in -mm:

 (1) allows users to evade the oom killer by creating subcontainers or
     using other controllers since scoring is done per cgroup and not
     hierarchically,

 (2) unfairly compares the root mem cgroup using completely different
     criteria than leaf mem cgroups and allows wildly inaccurate results
     if oom_score_adj is used, and

 (3) does not allow the user to influence the decisionmaking, such that
     important subtrees cannot be preferred or biased.

This patchset aims to fix (1) completely and, by doing so, introduces a
completely extensible user interface that can be expanded in the future.

It preserves all functionality that currently exists in -mm and extends
it to be generally useful outside of very specialized usecases.

It eliminates the mount option for the cgroup aware oom killer entirely
since it is now enabled through the root mem cgroup's oom policy.
---
 v3:
  - updated documentation
  - rebased to next-20180309

 Documentation/cgroup-v2.txt | 90 ++++++++++++++++++++++++-------------
 include/linux/cgroup-defs.h |  5 ---
 include/linux/memcontrol.h  | 21 +++++++++
 kernel/cgroup/cgroup.c      | 13 +-----
 mm/memcontrol.c             | 64 +++++++++++++++++++++-----
 5 files changed, 132 insertions(+), 61 deletions(-)
