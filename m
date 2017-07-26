Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C87716B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:27:55 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b8so76030730pgn.10
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:27:55 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id z187si1199274pgb.817.2017.07.26.06.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 06:27:54 -0700 (PDT)
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6QDO6Bx008374
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:27:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2bxqwygrbb-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:27:53 -0700
From: Roman Gushchin <guro@fb.com>
Subject: [v4 0/4] cgroup-aware OOM killer
Date: Wed, 26 Jul 2017 14:27:14 +0100
Message-ID: <20170726132718.14806-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>

This patchset makes the OOM killer cgroup-aware.

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
  mm, oom: refactor the TIF_MEMDIE usage
  mm, oom: cgroup-aware OOM killer
  mm, oom: introduce oom_priority for memory cgroups
  mm, oom, docs: describe the cgroup-aware OOM killer

 Documentation/cgroup-v2.txt |  62 +++++++++++
 include/linux/memcontrol.h  |  26 +++++
 include/linux/oom.h         |   3 +
 kernel/exit.c               |   2 +-
 mm/memcontrol.c             | 261 +++++++++++++++++++++++++++++++++++++++++++-
 mm/oom_kill.c               | 202 +++++++++++++++++++++++-----------
 6 files changed, 492 insertions(+), 64 deletions(-)

-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
