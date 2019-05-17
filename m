Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C272C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 23:49:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF5D02166E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 23:49:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Bvr6EX1B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF5D02166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F0646B0003; Fri, 17 May 2019 19:49:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A1F46B0005; Fri, 17 May 2019 19:49:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED1376B0006; Fri, 17 May 2019 19:49:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7C706B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 19:49:20 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id k134so7812694ywe.7
        for <linux-mm@kvack.org>; Fri, 17 May 2019 16:49:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=A7gs1+mF+FP/rGmpwnYONHmDSeyLtKWRbITND9nfmUM=;
        b=ABeq1S2pRlgki7TcCXmpNwAOTRTd60WkCd899ICBivP21nuTMpT8GKa4CucAbaTkQ5
         c80nGuZmvlSz3XqiQEMGAck9+aLls2KQnFddq2TdfDQSphi2n/umMBWswRJRa9k25Vv/
         ovsZ10r+Pp4rn1ANjsVQd5nJvNbK1dGQdA1+HmnFG2typ0bPj9ob1hx1Obr+Pso8pUVB
         3T32ECCfmeptx0PIS661jEIQc5vVCTSpgUhQwoN0QNYhyaZ1vJKg2zewdZJbQuwBrKab
         mYqB57H6gtSj0AxmN/tZlqouzDqnWYrM7PmreBFBUNWMxCNBYxQRxjtDRtdcqxUdT9/J
         FuKA==
X-Gm-Message-State: APjAAAW4SFrrxFI0QhrooCUXJ92VXR9Rd+MS7hmVoRSCetmzO8D7DQao
	bBeAm6uuAyRXxynho+fHF1N9sCr2FQ+ZfMhCDnfk8789ZyIlPG3iX7+YwAGuw+cyMfkloIG9q3t
	rCvyW+CT8LkmDnRcbl9D2c1IG7XEmfDDXXwWtwjFmK2sC1F22MZ9lQu5iIb6ia5/Qaw==
X-Received: by 2002:a25:74d0:: with SMTP id p199mr26676014ybc.492.1558136960446;
        Fri, 17 May 2019 16:49:20 -0700 (PDT)
X-Received: by 2002:a25:74d0:: with SMTP id p199mr26676002ybc.492.1558136959662;
        Fri, 17 May 2019 16:49:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558136959; cv=none;
        d=google.com; s=arc-20160816;
        b=oJ7OGi4sdWeClMWlNKZeSbIEP5B6IBaRlULqApGG/NBSUuy+qjcD68KoNcvJnE108p
         xAmPsbGg/CbabrbDrjef4ku4oQow9KMWwnFLzSa9Yq7caVmP6FTi5HZiz/9gih9b3Y/b
         8YnswutnPl6PjK4SJLV7QcSS+Ss4OVGilqhIW0Unq3PYyctVHvCVoZz+d76nZ3DqF7p4
         zG5Uo2vL6xOg1y9mVkoEHTyo86t+NbWdf+i8YzCvg3lipqWkm4TyJReaWHx2QLAfy3TZ
         yL3IEnuH22R4JjBrtYYJG70LHEroceBVsTtzaXD8gAck2HBb7fSZxmjvf5pQd1+wZR6V
         Gm8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=A7gs1+mF+FP/rGmpwnYONHmDSeyLtKWRbITND9nfmUM=;
        b=w8OZmGXsM/P/oAq5bJlHDjq+q3ImcHQZrVFNYI70WKzNMr61pvk8NvmatKR0HTyBeJ
         2KLtwMaWIr+1+kGZZWLqu1IfWX1BMwHEs8r5YLjOYFCkC9iZGRQW/Xc27UqM2Sy9egAE
         4NumhMyn6H4OXpfjwTCFefoOUYdm2FHeR7rU+aIlnGxUs2yKuCDAum932o+jFx/LfVQQ
         vHI48YHzmNcGaFN5UQWnznssx5lO5/72uM7bxMaj3o1RZD3uujnHsgjjSb0EaYXvx5FK
         JFoJXqkGYgiQwkfUd/hHa5W2DtHjDmh7VP13fOnY8IqVjCbQY171kzYoXATZ7eLX6iZg
         M96A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Bvr6EX1B;
       spf=pass (google.com: domain of 3f0jfxagkchoqfyiccjzemmejc.amkjglsv-kkityai.mpe@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3f0jfXAgKCHoqfYiccjZemmejc.amkjglsv-kkitYai.mpe@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 10sor3111146ywv.175.2019.05.17.16.49.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 16:49:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3f0jfxagkchoqfyiccjzemmejc.amkjglsv-kkityai.mpe@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Bvr6EX1B;
       spf=pass (google.com: domain of 3f0jfxagkchoqfyiccjzemmejc.amkjglsv-kkityai.mpe@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3f0jfXAgKCHoqfYiccjZemmejc.amkjglsv-kkitYai.mpe@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=A7gs1+mF+FP/rGmpwnYONHmDSeyLtKWRbITND9nfmUM=;
        b=Bvr6EX1BZXsucquzdYD7Uqmbj6wwCOxg3rcQn60MXW4DU7nJ6/r0BcLbdwz5tSoo77
         t8gK6+Z8fzNWaCdetWoEM7f+2o8RnbLx8CS1YTx0OWWOXgHf9GbSSna8rk7ZkJtW9366
         qbOsVKy8h934mTsg17ZQzmg23y3wZf6pC6xq1BVMNnUuFeutN/8AR5EEbmK2sMuprJRg
         a6emrfrio99QVrVPAotorRVenxbKFArMXtlR5cm7+deloUaXTiqoqlTSpS4oeX0kgREi
         0grH9KoxLi4uE2v2hT9u5ceJ8cARpo0zsvhoqwkeDP3WrpIcGPvl6wRM7wSZypUbnFbe
         t2WA==
X-Google-Smtp-Source: APXvYqwKEww9mPrrXsrI0/TpLKrEc7pSe78bah2w5Z+0kdvcu66zLeplA2OTybD6hUGaqQkHasrvoaOkRdan0w==
X-Received: by 2002:a81:3589:: with SMTP id c131mr28332892ywa.456.1558136959229;
 Fri, 17 May 2019 16:49:19 -0700 (PDT)
Date: Fri, 17 May 2019 16:49:09 -0700
Message-Id: <20190517234909.175734-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH] mm, memcg: introduce memory.events.local
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
---
 include/linux/memcontrol.h |  7 ++++++-
 mm/memcontrol.c            | 25 +++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 1 deletion(-)

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
index 2713b45ec3f0..a746127012fa 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5648,6 +5648,25 @@ static int memory_events_show(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int memory_events_local_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
+
+	seq_printf(m, "low %lu\n",
+		   atomic_long_read(&memcg->memory_events_local[MEMCG_LOW]));
+	seq_printf(m, "high %lu\n",
+		   atomic_long_read(&memcg->memory_events_local[MEMCG_HIGH]));
+	seq_printf(m, "max %lu\n",
+		   atomic_long_read(&memcg->memory_events_local[MEMCG_MAX]));
+	seq_printf(m, "oom %lu\n",
+		   atomic_long_read(&memcg->memory_events_local[MEMCG_OOM]));
+	seq_printf(m, "oom_kill %lu\n",
+		   atomic_long_read(&memcg->memory_events_local[MEMCG_OOM_KILL])
+		   );
+
+	return 0;
+}
+
 static int memory_stat_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
@@ -5806,6 +5825,12 @@ static struct cftype memory_files[] = {
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
2.21.0.1020.gf2820cf01a-goog

