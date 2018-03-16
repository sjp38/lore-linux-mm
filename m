Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E151E6B0027
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:08:48 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o61-v6so6170746pld.5
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:08:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o6-v6sor3221226pls.80.2018.03.16.14.08.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 14:08:47 -0700 (PDT)
Date: Fri, 16 Mar 2018 14:08:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 0/6] rewrite cgroup aware oom killer for general use
In-Reply-To: <alpine.DEB.2.20.1803151351140.55261@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.20.1803161405410.209509@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com> <alpine.DEB.2.20.1803151351140.55261@chino.kir.corp.google.com>
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

This patchset fixes (1) and (2) completely and, by doing so, introduces a
completely extensible user interface that can be expanded in the future.

Concern (3) could subsequently be addressed either before or after the
cgroup-aware oom killer feature is merged.

It preserves all functionality that currently exists in -mm and extends
it to be generally useful outside of very specialized usecases.

It eliminates the mount option for the cgroup aware oom killer entirely
since it is now enabled through the root mem cgroup's oom policy.
---
 - Rebased to next-20180305
 - Fixed issue where total_sock_pages was not being modified
 - Changed output of memory.oom_policy to show all available policies

 Documentation/cgroup-v2.txt | 100 ++++++++--------
 include/linux/cgroup-defs.h |   5 -
 include/linux/memcontrol.h  |  21 ++++
 kernel/cgroup/cgroup.c      |  13 +--
 mm/memcontrol.c             | 221 +++++++++++++++++++++---------------
 5 files changed, 204 insertions(+), 156 deletions(-)
