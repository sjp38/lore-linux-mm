Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 640E46B0292
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:35:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b84so12045435wmh.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:35:48 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t6si19888993edd.254.2017.06.01.11.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 11:35:47 -0700 (PDT)
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v51IWJhB006891
	for <linux-mm@kvack.org>; Thu, 1 Jun 2017 11:35:45 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2at6exau2j-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:35:45 -0700
From: Roman Gushchin <guro@fb.com>
Subject: [RFC PATCH v2 0/7] cgroup-aware OOM killer
Date: Thu, 1 Jun 2017 19:35:08 +0100
Message-ID: <1496342115-3974-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>

This patchset makes the OOM killer cgroup-aware.

Patches 1-3 are simple refactorings of the OOM killer code,
required to reuse the code in the memory controller.
Patches 4 & 5 are introducing new memcg settings:
oom_kill_all_tasks and oom_score_adj.
Patch 6 introduces the cgroup-aware OOM killer.
Patch 7 is docs update.

v1:
  https://lkml.org/lkml/2017/5/18/969

v2:
  - Reworked victim selection based on feedback
    from Michal Hocko, Vladimir Davydov and Johannes Weiner
  - "Kill all tasks" is now an opt-in option, by default
    only one process will be killed
  - Added per-cgroup oom_score_adj
  - Refined oom score calculations, suggested by Vladimir Davydov
  - Converted to a patchset


Roman Gushchin (7):
  mm, oom: refactor select_bad_process() to take memcg as an argument
  mm, oom: split oom_kill_process() and export __oom_kill_process()
  mm, oom: export oom_evaluate_task() and select_bad_process()
  mm, oom: introduce oom_kill_all_tasks option for memory cgroups
  mm, oom: introduce oom_score_adj for memory cgroups
  mm, oom: cgroup-aware OOM killer
  mm,oom,docs: describe the cgroup-aware OOM killer

 Documentation/cgroup-v2.txt |  47 ++++++++-
 include/linux/memcontrol.h  |  19 ++++
 include/linux/oom.h         |   6 ++
 mm/memcontrol.c             | 247 ++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill.c               | 137 +++++++++++++-----------
 5 files changed, 392 insertions(+), 64 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
