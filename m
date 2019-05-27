Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B0E3C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 17:47:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12754208C3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 17:47:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JwAG/FOC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12754208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E5476B0283; Mon, 27 May 2019 13:47:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56DE36B0285; Mon, 27 May 2019 13:47:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E6F56B0286; Mon, 27 May 2019 13:47:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 116326B0283
	for <linux-mm@kvack.org>; Mon, 27 May 2019 13:47:12 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id o3so7424253vke.6
        for <linux-mm@kvack.org>; Mon, 27 May 2019 10:47:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=WabwXVWKHDF9Gj73vwc0I/pwrF46pP20FoOfyIilig8=;
        b=TYo99Nf6AGXXiwXbarDY+pjL0WSDg5ziex9a6i2HzySlGvgl2rbT4jJTGoh47t2Zdo
         N5l+uR0sxLw9b/QLGNeBehYNvSLHd3ZmprpLSokbDEwDDRnBP6rv1bS0kp7JVmsWNwMb
         YdWltykckUcUlm+4Rz0l4gBheaytNi3TB+rcyv5XxHmQHoCVg/bhEYzjVKVKbjWmxQw5
         W0eqJxktC/QSg3py3cepiee9UvCevFPyMEuvrhg3hPxIUUuXkQEUCaWCFlmD//kSnQ41
         TT5FyE7MiNKYm9Z+1ob79QYcJA8uSZCjls2+V/8HyG40iVnXqTDtaLmgxFLlw0GIAl0o
         4XBg==
X-Gm-Message-State: APjAAAV5YSlrHVkAKArszpWAbuGa9B3PR3eUyZjN17FsgfCY2lXv4SVQ
	Ze4OF+k9CTO+MrIhCF2Pi/BiBG6hweX9i5GjBMxIyBU8Nh6/kSGmYu3aNozUVKfI0+KHXuv3tyM
	rCgeaLtR3Wf7nh2BVHUVmGZDjBLwvh1o2DetMCvHndYYFh6/SBhZL5hQE0NAfnCL+GQ==
X-Received: by 2002:a1f:fe81:: with SMTP id l123mr20813841vki.51.1558979231705;
        Mon, 27 May 2019 10:47:11 -0700 (PDT)
X-Received: by 2002:a1f:fe81:: with SMTP id l123mr20813729vki.51.1558979230500;
        Mon, 27 May 2019 10:47:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558979230; cv=none;
        d=google.com; s=arc-20160816;
        b=Q6KVQkr66CWKU829k8pINQdiiEd3rUxLhOPQH0G9SeNOVoKBzOplwAKR6m8o4u+R0i
         CQIiVx5CB3oPCHIJfN7Tyh36DSVAx1qTAOXg267n+9CKzdIeA0gLPcRuvgdJFFtYleBn
         JMmRGLAanwVa4s95WWgzeyPV6IrmxC6TH5iyhIEAV5QpgT48GOIS8Ut9fz0f6L4Lx6sO
         DyLHX1lHkBKdEAXK2JbPpbb2DihLbbZKV6vregi0clNTlj5z/mNBgeeT1xRMQ8hVtOvs
         hklX994RnYOk3M6MZ/QCIAf5EpCgqKWPAcoAGp+jmf8feV7pplC5AacK7IhW657fvIPp
         TyYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=WabwXVWKHDF9Gj73vwc0I/pwrF46pP20FoOfyIilig8=;
        b=CiBeJMr8WsPgvtA2tK0rMvI1pinTx43MEjA21W7CH6v1vs1tngoQmY7P1pt9121KE9
         CWnEeiOKluH4Si42eSdyIn7ndIQP3kJLURV6OBZXskOiuGJ0xFdxbobmKt8WLlUXYp7y
         qIJ9AtIg0pWKKN7kEO03pt8wjB+oKplqE8k7FtJqovugUpTU6qj678hy19d5CmfoxPIf
         QrvNZwPqTdJiILBR6yP+mkMcQqWbCQh3IaHSv8VpaWZ6eZ5rBgFzOd+EAx6DxGLfTBlD
         lC5NEOlWFYUcDdSbWCsBHbdzxA5YPwIEu5+UTdRLPQ+rZMpT1s6ybtNhH6U5LWvTofBD
         7f3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="JwAG/FOC";
       spf=pass (google.com: domain of 3nslsxagkciawleoiipfksskpi.gsqpmry1-qqozego.svk@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3nSLsXAgKCIAwleoiipfksskpi.gsqpmry1-qqozego.svk@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id u50sor4578971uau.37.2019.05.27.10.47.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 10:47:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3nslsxagkciawleoiipfksskpi.gsqpmry1-qqozego.svk@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="JwAG/FOC";
       spf=pass (google.com: domain of 3nslsxagkciawleoiipfksskpi.gsqpmry1-qqozego.svk@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3nSLsXAgKCIAwleoiipfksskpi.gsqpmry1-qqozego.svk@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=WabwXVWKHDF9Gj73vwc0I/pwrF46pP20FoOfyIilig8=;
        b=JwAG/FOCufiHwOPhwR/U8FpRywH60cnD+4+jDfx6S4A///ABXalQdR96p/DGNSiINt
         taQAVzi4ZWYDlppGDunCnKCNi5U8BJB8Ytw4L2DJRBZO1g1Re6PWcNpn6UDYZSUkQWkB
         IepdDzZx5Kgi7HIlAX8OeDAag68w+Znn93OZRx0meQF2zD2u7gKnDQxpsQZT9fK2gIWa
         mIY6D3mPHsyHG7SVQhl75Ss/FIBUzprB9kA/K4Wr7eWTYv+q+JrprJphWF2gcAp5fyg+
         mE+PUeHZzG74iVppBlJ7SW1XU4rhwK1VvZYszfeEqkhWJwngLRqmQhx8OrIDksadQBnd
         aZRg==
X-Google-Smtp-Source: APXvYqxRk9l2Xm/VuGGKrKk6z1pZngrkZJw9tB+kHYOSMI90hyZqW/59RtYGljuqxAiUAnNldNNH4TeiKvMH4g==
X-Received: by 2002:ab0:28c9:: with SMTP id g9mr46031261uaq.73.1558979229956;
 Mon, 27 May 2019 10:47:09 -0700 (PDT)
Date: Mon, 27 May 2019 10:46:43 -0700
Message-Id: <20190527174643.209172-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.rc1.257.g3120a18244-goog
Subject: [PATCH v3] mm, memcg: introduce memory.events.local
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Chris Down <chris@chrisdown.name>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The memory controller in cgroup v2 exposes memory.events file for each
memcg which shows the number of times events like low, high, max, oom
and oom_kill have happened for the whole tree rooted at that memcg.
Users can also poll or register notification to monitor the changes in
that file. Any event at any level of the tree rooted at memcg will
notify all the listeners along the path till root_mem_cgroup. There are
existing users which depend on this behavior.

However there are users which are only interested in the events
happening at a specific level of the memcg tree and not in the events in
the underlying tree rooted at that memcg. One such use-case is a
centralized resource monitor which can dynamically adjust the limits of
the jobs running on a system. The jobs can create their sub-hierarchy
for their own sub-tasks. The centralized monitor is only interested in
the events at the top level memcgs of the jobs as it can then act and
adjust the limits of the jobs. Using the current memory.events for such
centralized monitor is very inconvenient. The monitor will keep
receiving events which it is not interested and to find if the received
event is interesting, it has to read memory.event files of the next
level and compare it with the top level one. So, let's introduce
memory.events.local to the memcg which shows and notify for the events
at the memcg level.

Now, does memory.stat and memory.pressure need their local versions.
IMHO no due to the no internal process contraint of the cgroup v2. The
memory.stat file of the top level memcg of a job shows the stats and
vmevents of the whole tree. The local stats or vmevents of the top level
memcg will only change if there is a process running in that memcg but
v2 does not allow that. Similarly for memory.pressure there will not be
any process in the internal nodes and thus no chance of local pressure.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Reviewed-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
Changelog since v2:
- Added documentation.

Changelog since v1:
- refactor memory_events_show to share between events and events.local

 Documentation/admin-guide/cgroup-v2.rst | 10 ++++++++
 include/linux/memcontrol.h              |  7 ++++-
 mm/memcontrol.c                         | 34 +++++++++++++++++--------
 3 files changed, 40 insertions(+), 11 deletions(-)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 19c4e78666ff..0e961fc90cd9 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1119,6 +1119,11 @@ PAGE_SIZE multiple when read back.
 	otherwise, a value change in this file generates a file
 	modified event.
 
+	Note that all fields in this file are hierarchical and the
+	file modified event can be generated due to an event down the
+	hierarchy. For for the local events at the cgroup level see
+	memory.events.local.
+
 	  low
 		The number of times the cgroup is reclaimed due to
 		high memory pressure even though its usage is under
@@ -1158,6 +1163,11 @@ PAGE_SIZE multiple when read back.
 		The number of processes belonging to this cgroup
 		killed by any kind of OOM killer.
 
+  memory.events.local
+	Similar to memory.events but the fields in the file are local
+	to the cgroup i.e. not hierarchical. The file modified event
+	generated on this file reflects only the local events.
+
   memory.stat
 	A read-only flat-keyed file which exists on non-root cgroups.
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 36bdfe8e5965..de77405eec46 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -239,8 +239,9 @@ struct mem_cgroup {
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
-	/* memory.events */
+	/* memory.events and memory.events.local */
 	struct cgroup_file events_file;
+	struct cgroup_file events_local_file;
 
 	/* handle for "memory.swap.events" */
 	struct cgroup_file swap_events_file;
@@ -286,6 +287,7 @@ struct mem_cgroup {
 	atomic_long_t		vmevents_local[NR_VM_EVENT_ITEMS];
 
 	atomic_long_t		memory_events[MEMCG_NR_MEMORY_EVENTS];
+	atomic_long_t		memory_events_local[MEMCG_NR_MEMORY_EVENTS];
 
 	unsigned long		socket_pressure;
 
@@ -761,6 +763,9 @@ static inline void count_memcg_event_mm(struct mm_struct *mm,
 static inline void memcg_memory_event(struct mem_cgroup *memcg,
 				      enum memcg_memory_event event)
 {
+	atomic_long_inc(&memcg->memory_events_local[event]);
+	cgroup_file_notify(&memcg->events_local_file);
+
 	do {
 		atomic_long_inc(&memcg->memory_events[event]);
 		cgroup_file_notify(&memcg->events_file);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2713b45ec3f0..a57dfcc4c4a4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5630,21 +5630,29 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
+static void __memory_events_show(struct seq_file *m, atomic_long_t *events)
+{
+	seq_printf(m, "low %lu\n", atomic_long_read(&events[MEMCG_LOW]));
+	seq_printf(m, "high %lu\n", atomic_long_read(&events[MEMCG_HIGH]));
+	seq_printf(m, "max %lu\n", atomic_long_read(&events[MEMCG_MAX]));
+	seq_printf(m, "oom %lu\n", atomic_long_read(&events[MEMCG_OOM]));
+	seq_printf(m, "oom_kill %lu\n",
+		   atomic_long_read(&events[MEMCG_OOM_KILL]));
+}
+
 static int memory_events_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 
-	seq_printf(m, "low %lu\n",
-		   atomic_long_read(&memcg->memory_events[MEMCG_LOW]));
-	seq_printf(m, "high %lu\n",
-		   atomic_long_read(&memcg->memory_events[MEMCG_HIGH]));
-	seq_printf(m, "max %lu\n",
-		   atomic_long_read(&memcg->memory_events[MEMCG_MAX]));
-	seq_printf(m, "oom %lu\n",
-		   atomic_long_read(&memcg->memory_events[MEMCG_OOM]));
-	seq_printf(m, "oom_kill %lu\n",
-		   atomic_long_read(&memcg->memory_events[MEMCG_OOM_KILL]));
+	__memory_events_show(m, memcg->memory_events);
+	return 0;
+}
+
+static int memory_events_local_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
 
+	__memory_events_show(m, memcg->memory_events_local);
 	return 0;
 }
 
@@ -5806,6 +5814,12 @@ static struct cftype memory_files[] = {
 		.file_offset = offsetof(struct mem_cgroup, events_file),
 		.seq_show = memory_events_show,
 	},
+	{
+		.name = "events.local",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.file_offset = offsetof(struct mem_cgroup, events_local_file),
+		.seq_show = memory_events_local_show,
+	},
 	{
 		.name = "stat",
 		.flags = CFTYPE_NOT_ON_ROOT,
-- 
2.22.0.rc1.257.g3120a18244-goog

