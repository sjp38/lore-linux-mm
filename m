Return-Path: <SRS0=dvGr=TS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EF7DC04AB4
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 00:18:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC63A218B0
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 00:18:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QI3CMrbU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC63A218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56E766B0003; Fri, 17 May 2019 20:18:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 521146B0005; Fri, 17 May 2019 20:18:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E7E26B0006; Fri, 17 May 2019 20:18:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1EEFD6B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 20:18:26 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n126so7186044qkc.18
        for <linux-mm@kvack.org>; Fri, 17 May 2019 17:18:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=qkDr2UAFkscvX8ezXGKmGGmc+dl6f/FAMKwyKcz0Ozc=;
        b=IuB2NfZGmK7hvZ0JZY+BH5edwZLmExz8IS8Gl5eCoaxx6nKsEYudVNRcCiRid+9moY
         g18doHR+nLS6uwxdOa5kd8DibTjaJatPnQ+mrOj878HPZzmGGGrA2m4T9DhcHE0h2Vjo
         vVg3FpgvllPybDu38P3vl5xdbN8eQEkRAYjMfQOzzGRtHdJ4Qlnmskh/l0fhuz3wKB9B
         re7P9Mi8SXVZDWapTPktOx74FUi/7Sps+DUYI3XTPhiO0Nv5BfMDn5TtHykGaFLhyQNu
         ag6msQmnFLhtw5xEgRy1Ltp9eMG8CJO3l41+u8ZRLVM7mZg0u9jkf66THgaesUXAiQC1
         kt2A==
X-Gm-Message-State: APjAAAVjMT2MoZiZCw7QGZ1clGwGMEjGEwmyNrRvY6slTAsUgZfrX4xU
	ISgK3RiZBdkjrc+z8D62U+C8WwchK5w8VMH0Nlr0DBO9GokZVyWk+iVRtGM9rN0sm+AUwsZN8JY
	ztnW32LA1R7I43RZ3ZsB9OgzLTxTwNEZYwMgMSkzWEZV+dyiwVJJtBS2cmh+8QGLc8A==
X-Received: by 2002:a37:691:: with SMTP id 139mr41262896qkg.5.1558138705702;
        Fri, 17 May 2019 17:18:25 -0700 (PDT)
X-Received: by 2002:a37:691:: with SMTP id 139mr41262861qkg.5.1558138704938;
        Fri, 17 May 2019 17:18:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558138704; cv=none;
        d=google.com; s=arc-20160816;
        b=MzN2Zb/JdUlubbCHVJhv08irQa44frINAsd3HrdWF7ri0lvr1qiaKxDNbD6C6A722G
         ohO1MFm0DMJWE5JW1szmxL+JdSfU7jCC9LBqlbMrzoFxuWj/Yr/QzDJmqjDP1tNUrFyi
         /fH6fLWx+W4O/2fzuTyVUeUzz2p/I+GIIHzLo7qzaEwKCZhskxALLZtycGXuGxJc77nR
         Bs7/tAZF8WDdjhSp/TQ4/WcyCRYwQ53NMSt5RSKNDuW+Mia5p6/8iQ1SJLf+TCHu8elG
         kz6bgj0A4C59/yQmZcpQ2KIH2ZpTPK62aUSq3tSRTyQoL31BDZuRM5ofZ4nWBiekN7bv
         0OVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=qkDr2UAFkscvX8ezXGKmGGmc+dl6f/FAMKwyKcz0Ozc=;
        b=RGWQxAXuCacTm7G3nMun8Qj8qp6BFEGmM/yNdxaULoDuZMfgC3FvpnhfS2/0C+ZgVl
         zgWQJQV1ERvUnCdQDggDRLmJVkZUhGi87p4bhEyGZ+ff8Y84dcwVUscyKxiIfvKkwaC/
         axkrk2lWAnNlDRT58zxn5SUE10kBvGUDVqW5rEc2GwHa2IsR08Jxz8F419G9W8Dbjyzh
         7sdXDjeh+WNZF94yOeE2agPKewkhfShGtMKH1gTtp/sW8MB107HvtCbNPf6ubSQm5CIx
         MH8gw69XgNsxZGfqel1hNmtUGiSaBqM5P3+GoTzSUQjO1UcEdxLnaFma6dNxkCHlyYl/
         GSsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QI3CMrbU;
       spf=pass (google.com: domain of 3ue_fxagkcfkj81b55c27ff7c5.3fdc9elo-ddbm13b.fi7@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3UE_fXAgKCFkJ81B55C27FF7C5.3FDC9ELO-DDBM13B.FI7@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id z25sor13877341qtb.38.2019.05.17.17.18.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 17:18:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ue_fxagkcfkj81b55c27ff7c5.3fdc9elo-ddbm13b.fi7@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QI3CMrbU;
       spf=pass (google.com: domain of 3ue_fxagkcfkj81b55c27ff7c5.3fdc9elo-ddbm13b.fi7@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3UE_fXAgKCFkJ81B55C27FF7C5.3FDC9ELO-DDBM13B.FI7@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=qkDr2UAFkscvX8ezXGKmGGmc+dl6f/FAMKwyKcz0Ozc=;
        b=QI3CMrbUSisbO3F4zPF1hI/gUiK8dDCRjfX1TsAw9fftIwjnK8TdYw9nsLJY+RumM7
         Shb9J86yo+n5aXxg08eiEqZj+2z9qtyWZZf7Tpv3HzS5PRcNpiIGroILaSRAMUzE9Dzh
         kVb8DvXdY9osu7DCtFy07wfSZzUCDwO0B7L2gRNjrgKvc+pUzdBc9TTYDb3H+uw5c31O
         4WDfAt3UWxQtKDB3C5AoRY4WnPyNHBQgtUUhRMKQdjs8CEz6bIrXQF+O0EBBG6tjURat
         PomO6vvTPD6Sch2zcwASVvtsnQ3dhWAfNTYq9HRAlrpqLUGzo0UNA6yQgo8+kwneUm74
         fPMA==
X-Google-Smtp-Source: APXvYqzjvHIrSFCW8O8i+BzHoGWkysNM/KdQQ3zDtRn0LUwcgEMg0FCe79ufJdlJrN78yJCcMfe/ggmKl62N5A==
X-Received: by 2002:ac8:2817:: with SMTP id 23mr16045714qtq.174.1558138704651;
 Fri, 17 May 2019 17:18:24 -0700 (PDT)
Date: Fri, 17 May 2019 17:18:18 -0700
Message-Id: <20190518001818.193336-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v2] mm, memcg: introduce memory.events.local
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
Changelog since v1:
- refactor memory_events_show to share between events and events.local

 include/linux/memcontrol.h |  7 ++++++-
 mm/memcontrol.c            | 34 ++++++++++++++++++++++++----------
 2 files changed, 30 insertions(+), 11 deletions(-)

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
2.21.0.1020.gf2820cf01a-goog

