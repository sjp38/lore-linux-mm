Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F2CE96B055C
	for <linux-mm@kvack.org>; Thu, 17 May 2018 23:07:38 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e18-v6so2366870pgt.3
        for <linux-mm@kvack.org>; Thu, 17 May 2018 20:07:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f34-v6sor3719507ple.122.2018.05.17.20.07.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 May 2018 20:07:37 -0700 (PDT)
From: ufo19890607 <ufo19890607@gmail.com>
Subject: [PATCH v2] Print the memcg's name when system-wide OOM happened
Date: Fri, 18 May 2018 04:07:14 +0100
Message-Id: <1526612834-8898-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian <yuzhoujian@didichuxing.com>

From: yuzhoujian <yuzhoujian@didichuxing.com>

The dump_header does not print the memcg's name when the system
oom happened. So users cannot locate the certain container which
contains the task that has been killed by the oom killer. System
oom report will contain the memcg's name after this patch.

Changes since v1:
- replace adding mem_cgroup_print_oom_info with printing the memcg's
  name only.

Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
---
 mm/oom_kill.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8ba6cb88cf58..b0abb5930232 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -433,6 +433,9 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	if (is_memcg_oom(oc))
 		mem_cgroup_print_oom_info(oc->memcg, p);
 	else {
+		pr_info("Task in ");
+		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
+		pr_cont(" killed as a result of limit of ");
 		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
 		if (is_dump_unreclaim_slabs())
 			dump_unreclaimable_slab();
-- 
2.14.1
