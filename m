Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E854B6B000D
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:07:25 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r2-v6so2408647pgp.3
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:07:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3-v6sor6571245pgr.176.2018.07.13.16.07.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 16:07:24 -0700 (PDT)
Date: Fri, 13 Jul 2018 16:07:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v3 -mm 0/6] rewrite cgroup aware oom killer for general use
In-Reply-To: <alpine.DEB.2.20.1803221451370.17056@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.21.1807131604560.217600@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com> <alpine.DEB.2.20.1803151351140.55261@chino.kir.corp.google.com> <alpine.DEB.2.20.1803161405410.209509@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1803221451370.17056@chino.kir.corp.google.com>
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
v3:
 - Rebased to next-20180713

v2:
 - Rebased to next-20180322
 - Fixed get_nr_swap_pages() build bug found by kbuild test robot

 Documentation/admin-guide/cgroup-v2.rst | 100 ++++++-----
 include/linux/cgroup-defs.h             |   5 -
 include/linux/memcontrol.h              |  21 +++
 kernel/cgroup/cgroup.c                  |  13 +-
 mm/memcontrol.c                         | 221 ++++++++++++++----------
 5 files changed, 204 insertions(+), 156 deletions(-)
