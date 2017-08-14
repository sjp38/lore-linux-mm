Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5968E6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 14:32:53 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t80so149217946pgb.0
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 11:32:53 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f87si4496708pfe.137.2017.08.14.11.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 11:32:52 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v5 0/4] cgroup-aware OOM killer
Date: Mon, 14 Aug 2017 19:32:10 +0100
Message-ID: <20170814183213.12319-2-guro@fb.com>
In-Reply-To: <20170814183213.12319-1-guro@fb.com>
References: <20170814183213.12319-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

This patchset makes the OOM killer cgroup-aware.

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

Roman Gushchin (4):
  mm, oom: refactor the oom_kill_process() function
  mm, oom: cgroup-aware OOM killer
  mm, oom: introduce oom_priority for memory cgroups
  mm, oom, docs: describe the cgroup-aware OOM killer

 Documentation/cgroup-v2.txt |  62 +++++++++++
 include/linux/memcontrol.h  |  36 ++++++
 include/linux/oom.h         |   3 +
 mm/memcontrol.c             | 259 ++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill.c               | 181 +++++++++++++++++++++----------
 5 files changed, 484 insertions(+), 57 deletions(-)

-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
