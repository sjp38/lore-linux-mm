Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 92B388E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 14:21:38 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id t10so4709754plo.13
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 11:21:38 -0800 (PST)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id p5si66295pls.338.2019.01.09.11.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 11:21:37 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v3 PATCH 0/5] mm: memcontrol: do memory reclaim when offlining
Date: Thu, 10 Jan 2019 03:14:40 +0800
Message-Id: <1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, hannes@cmpxchg.org, shakeelb@google.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


We have some usecases which create and remove memcgs very frequently,
and the tasks in the memcg may just access the files which are unlikely
accessed by anyone else.  So, we prefer force_empty the memcg before
rmdir'ing it to reclaim the page cache so that they don't get
accumulated to incur unnecessary memory pressure.  Since the memory
pressure may incur direct reclaim to harm some latency sensitive
applications.

Force empty would help out such usecase, however force empty reclaims
memory synchronously when writing to memory.force_empty.  It may take
some time to return and the afterwards operations are blocked by it.
Although this can be done in background, some usecases may need create
new memcg with the same name right after the old one is deleted.  So,
the creation might get blocked by the before reclaim/remove operation.

Delaying memory reclaim in cgroup offline for such usecase sounds
reasonable.  Introduced a new interface, called wipe_on_offline for both
default and legacy hierarchy, which does memory reclaim in css offline
kworker.

v2 -> v3:
* Introduced may_swap parameter to mem_cgroup_force_empty() to keep force_empty behavior per   Shakeel
* Fixed some comments from Shakeel
 
v1 -> v2:
* Introduced wipe_on_offline interface suggested by Michal
* Bring force_empty into default hierarchy

Patch #1: Fix some obsolete information about force_empty in the document
Patch #2: Introduce may_swap parameter to mem_cgroup_force_empty()
Patch #3: Introduces wipe_on_offline interface
Patch #4: Being force_empty into default hierarchy
Patch #5: Document update

Yang Shi (5):
      doc: memcontrol: fix the obsolete content about force empty
      mm: memcontrol: add may_swap parameter to mem_cgroup_force_empty()
      mm: memcontrol: introduce wipe_on_offline interface
      mm: memcontrol: bring force_empty into default hierarchy
      doc: memcontrol: add description for wipe_on_offline

 Documentation/admin-guide/cgroup-v2.rst | 23 ++++++++++++++++++++
 Documentation/cgroup-v1/memory.txt      | 17 ++++++++++++---
 include/linux/memcontrol.h              |  3 +++
 mm/memcontrol.c                         | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 98 insertions(+), 8 deletions(-)
