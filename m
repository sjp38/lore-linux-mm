Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 029BC6B0006
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 20:32:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c2-v6so227202edi.20
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 17:32:38 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d8-v6si763302edb.244.2018.08.01.17.32.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 17:32:37 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v2 0/3] introduce memory.oom.group
Date: Wed, 1 Aug 2018 17:31:58 -0700
Message-ID: <20180802003201.817-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

This is a tiny implementation of cgroup-aware OOM killer,
which adds an ability to kill a cgroup as a single unit
and so guarantee the integrity of the workload.

Although it has only a limited functionality in comparison
to what now resides in the mm tree (it doesn't change
the victim task selection algorithm, doesn't look
at memory stas on cgroup level, etc), it's also much
simpler and more straightforward. So, hopefully, we can
avoid having long debates here, as we had with the full
implementation.

As it doesn't prevent any futher development,
and implements an useful and complete feature,
it looks as a sane way forward.

v2->v1:
  - added dmesg message about killing all tasks in cgroup
  - removed an unnecessary check for memcg being NULL pointer
  - adjusted docs and commit message
  - rebased to linus/master

--

This patchset is against Linus's tree to avoid conflicts
with the cgroup-aware OOM killer patchset in the mm tree.
It's intended to replace it.

Two first patches are already in the mm tree.
The first one ("mm: introduce mem_cgroup_put() helper")
is totally fine.
Commit message of the second one has to be changed to reflect
that it's not a part of the old patchset anymore.

Roman Gushchin (3):
  mm: introduce mem_cgroup_put() helper
  mm, oom: refactor oom_kill_process()
  mm, oom: introduce memory.oom.group

 Documentation/admin-guide/cgroup-v2.rst |  18 ++++
 include/linux/memcontrol.h              |  27 ++++++
 mm/memcontrol.c                         |  93 +++++++++++++++++++
 mm/oom_kill.c                           | 153 ++++++++++++++++++++------------
 4 files changed, 233 insertions(+), 58 deletions(-)

-- 
2.14.4
