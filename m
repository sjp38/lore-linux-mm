Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2274E8E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 19:19:47 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id bj3so28026111plb.17
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 16:19:47 -0800 (PST)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id c17si54144404pfb.81.2019.01.04.16.19.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 16:19:45 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v2 PATCH 0/5] mm: memcontrol: do memory reclaim when offlining
Date: Sat,  5 Jan 2019 08:19:15 +0800
Message-Id: <1546647560-40026-1-git-send-email-yang.shi@linux.alibaba.com>
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

v1 -> v2:
* Introduced wipe_on_offline interface suggested by Michal
* Bring force_empty into default hierarchy

Patch #1: Fix some obsolete information about force_empty in the document
Patch #2: A minor improvement to skip swap for force_empty
Patch #3: Introduces wipe_on_offline interface
Patch #4: Being force_empty into default hierarchy
Patch #5: Document update

Yang Shi (5):
      doc: memcontrol: fix the obsolete content about force empty
      mm: memcontrol: do not try to do swap when force empty
      mm: memcontrol: introduce wipe_on_offline interface
      mm: memcontrol: bring force_empty into default hierarchy
      doc: memcontrol: add description for wipe_on_offline

 Documentation/admin-guide/cgroup-v2.rst | 23 +++++++++++++++++++++++
 Documentation/cgroup-v1/memory.txt      | 17 ++++++++++++++---
 include/linux/memcontrol.h              |  3 +++
 mm/memcontrol.c                         | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 94 insertions(+), 4 deletions(-)
