Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B774C6B0033
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:10:29 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id q8so14304045qtb.2
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 06:10:29 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q63si1504222qkf.15.2017.09.27.06.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 06:10:27 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v9 0/5] cgroup-aware OOM killer
Date: Wed, 27 Sep 2017 14:09:31 +0100
Message-ID: <20170927130936.8601-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

This patchset makes the OOM killer cgroup-aware.

v9:
  - Change siblings-to-siblings comparison to the tree-wide search,
    make related refactorings
  - Make oom_group implicitly propagated down by the tree
  - Fix an issue with task selection in root cgroup

v8:
  - Do not kill tasks with OOM_SCORE_ADJ -1000
  - Make the whole thing opt-in with cgroup mount option control
  - Drop oom_priority for further discussions
  - Kill the whole cgroup if oom_group is set and it's
    memory.max is reached
  - Update docs and commit messages

v7:
  - __oom_kill_process() drops reference to the victim task
  - oom_score_adj -1000 is always respected
  - Renamed oom_kill_all to oom_group
  - Dropped oom_prio range, converted from short to int
  - Added a cgroup v2 mount option to disable cgroup-aware OOM killer
  - Docs updated
  - Rebased on top of mmotm

v6:
  - Renamed oom_control.chosen to oom_control.chosen_task
  - Renamed oom_kill_all_tasks to oom_kill_all
  - Per-node NR_SLAB_UNRECLAIMABLE accounting
  - Several minor fixes and cleanups
  - Docs updated

v5:
  - Rebased on top of Michal Hocko's patches, which have changed the
    way how OOM victims becoming an access to the memory
    reserves. Dropped corresponding part of this patchset
  - Separated the oom_kill_process() splitting into a standalone commit
  - Added debug output (suggested by David Rientjes)
  - Some minor fixes

v4:
  - Reworked per-cgroup oom_score_adj into oom_priority
    (based on ideas by David Rientjes)
  - Tasks with oom_score_adj -1000 are never selected if
    oom_kill_all_tasks is not set
  - Memcg victim selection code is reworked, and
    synchronization is based on finding tasks with OOM victim marker,
    rather then on global counter
  - Debug output is dropped
  - Refactored TIF_MEMDIE usage

v3:
  - Merged commits 1-4 into 6
  - Separated oom_score_adj logic and debug output into separate commits
  - Fixed swap accounting

v2:
  - Reworked victim selection based on feedback
    from Michal Hocko, Vladimir Davydov and Johannes Weiner
  - "Kill all tasks" is now an opt-in option, by default
    only one process will be killed
  - Added per-cgroup oom_score_adj
  - Refined oom score calculations, suggested by Vladimir Davydov
  - Converted to a patchset

v1:
  https://lkml.org/lkml/2017/5/18/969


Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Roman Gushchin (5):
  mm, oom: refactor the oom_kill_process() function
  mm: implement mem_cgroup_scan_tasks() for the root memory cgroup
  mm, oom: cgroup-aware OOM killer
  mm, oom: add cgroup v2 mount option for cgroup-aware OOM killer
  mm, oom, docs: describe the cgroup-aware OOM killer

 Documentation/cgroup-v2.txt |  44 +++++++++
 include/linux/cgroup-defs.h |   5 +
 include/linux/memcontrol.h  |  38 +++++++
 include/linux/oom.h         |  12 ++-
 kernel/cgroup/cgroup.c      |  10 ++
 mm/memcontrol.c             | 235 +++++++++++++++++++++++++++++++++++++++++++-
 mm/oom_kill.c               | 194 +++++++++++++++++++++++-------------
 7 files changed, 465 insertions(+), 73 deletions(-)

-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
