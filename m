Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1736B0279
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 17:19:42 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f49so19455153wrf.5
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:19:42 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 2si3692673wri.139.2017.06.21.14.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 14:19:40 -0700 (PDT)
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5LLH2IB007077
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:19:39 -0700
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2b7xavrg4t-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:19:39 -0700
From: Roman Gushchin <guro@fb.com>
Subject: [v3 0/6] cgroup-aware OOM killer
Date: Wed, 21 Jun 2017 22:19:10 +0100
Message-ID: <1498079956-24467-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>

This patchset makes the OOM killer cgroup-aware.

Patch 1 causes out_of_memory() look at the oom_victim counter
      	to decide if a new victim is required.

Patch 2 is main patch which implements cgroup-aware OOM killer.

Patch 3 adds some debug output, which can be refined later.

Patch 4 introduces per-cgroup oom_score_adj knob.

Patch 5 fixes a problem with too many processes receiving an
      	access to the memory reserves.

Patch 6 is docs update.

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

v3:
  - Fixed swap accounting
  - Switched to use oom_victims counter to prevent unnecessary kills
  - TIF_MEMDIE is set only when necessary
  - Moved all oom victim killing code into oom_kill.c
  - Merged commits 1-4 into 6
  - Separated oom_score_adj logic into a separate commit 4
  - Separated debug output into a separate commit 3

Roman Gushchin (6):
  mm, oom: use oom_victims counter to synchronize oom victim selection
  mm, oom: cgroup-aware OOM killer
  mm, oom: cgroup-aware OOM killer debug info
  mm, oom: introduce oom_score_adj for memory cgroups
  mm, oom: don't mark all oom victims tasks with TIF_MEMDIE
  mm,oom,docs: describe the cgroup-aware OOM killer

 Documentation/cgroup-v2.txt |  44 ++++++++++
 include/linux/memcontrol.h  |  23 +++++
 include/linux/oom.h         |   3 +
 kernel/exit.c               |   2 +-
 mm/memcontrol.c             | 209 ++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill.c               | 202 ++++++++++++++++++++++++++++--------------
 6 files changed, 416 insertions(+), 67 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
