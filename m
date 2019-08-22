Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35BD8C3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 08:56:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4EE12173E
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 08:56:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lQyjSqxa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4EE12173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CA5B6B02E7; Thu, 22 Aug 2019 04:56:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 653566B02E8; Thu, 22 Aug 2019 04:56:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 519956B02E9; Thu, 22 Aug 2019 04:56:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0042.hostedemail.com [216.40.44.42])
	by kanga.kvack.org (Postfix) with ESMTP id 29C0C6B02E7
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 04:56:52 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B0246181AC9B6
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:56:51 +0000 (UTC)
X-FDA: 75849458622.12.balls02_1eb89bff4341f
X-HE-Tag: balls02_1eb89bff4341f
X-Filterd-Recvd-Size: 9325
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:56:50 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id go14so3070261plb.0
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 01:56:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=6IBOEBvaSKrYv/FX9CyvdAC9vCM9UIq+SSSdalZ2X+0=;
        b=lQyjSqxaAHigCD+Y7l2F0YTXOeJE9Dgg04wS4LSC1S6grmdb3M8MyK2IcaG05zgMO+
         HFs6orZM58cJA5nIn4uqR92nsV2Vg3HGfHkaPB2CrvKtHGWqQukhfNmhKBW0Cy6R81Uv
         sFSGXot8/j/O0D1VYKd9cymx9wbCchS2d3KrDjZEr1EYUHlMHdOvuYfWd18w5pZwxGpz
         QJe04/TyWC3zm3q8X0x8oBUIM0zPEBx+mKGArbmly5uDcPxuvV86cUHXBLbP6PNrgnGg
         O5cw35oscc1b7Xa6tOOPRKHCwJjQkV4Diw69QQBTxeci3c9XVCCJMEB8hF+uuZcu2AZS
         08MQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=6IBOEBvaSKrYv/FX9CyvdAC9vCM9UIq+SSSdalZ2X+0=;
        b=m61w/49P937TAq7frOan9ANzlXYdQspW6AtepkJ59BR4fWHDjttDapZBq/Oe0NKkhm
         mmp30vkEmK1U7mEpB8XEOMpGmH2WQmkASne1vg6zWbLVYBD4O5ZS50uK8GwP6HLqEV/l
         LCjEABcY9U4SMR9EieCa6GGWtp2Gpuu0+smt3K/gP6G0ujlqu9kWSx1ip1phvW48a+JA
         hxVTQLfzuq1PoOtCk5H7dYDobvZBMcLPcP6sKAGP9nDoknKQ3Eyb30vLkLFpNEwY72jB
         cjed4hLXhpEg5zb2fkV5qhSUkPEMWQ9kCuRt8MKhomllGtHwhtJ0W3bEJEiEENJP8NYf
         3/Rw==
X-Gm-Message-State: APjAAAWOjTP3L72ehGt8NFYkkJGTLZpSnhSO+wfpFWG1rtcwh2L+gtoT
	fSA1If4+Eb79MT5/Lcc08+I=
X-Google-Smtp-Source: APXvYqzxi5BB0Stwtxk8ZSbXbu7+VRPuv7gT2sQBtgBWhjShLlUsuVA+YLTgdTarmOGvzMt8oCDgNA==
X-Received: by 2002:a17:902:1027:: with SMTP id b36mr37025559pla.203.1566464209816;
        Thu, 22 Aug 2019 01:56:49 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id l31sm26620642pgm.63.2019.08.22.01.56.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Aug 2019 01:56:49 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm, memcg: introduce per memcg oom_score_adj
Date: Thu, 22 Aug 2019 04:56:29 -0400
Message-Id: <1566464189-1631-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

- Why we need a per memcg oom_score_adj setting ?
This is easy to deploy and very convenient for container.
When we use container, we always treat memcg as a whole, if we have a per
memcg oom_score_adj setting we don't need to set it process by process.
It will make the user exhausted to set it to all processes in a memcg.

In this patch, a file named memory.oom.score_adj is introduced.
The valid value of it is from -1000 to +1000, which is same with
process-level oom_score_adj.
When OOM is invoked, the effective oom_score_adj is as bellow,
    effective oom_score_adj = original oom_score_adj + memory.oom.score_adj
The valid effective value is also from -1000 to +1000.
This is something like a hook to re-calculate the oom_score_adj.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h | 24 ++++++++++++++++++++++++
 mm/memcontrol.c            | 38 ++++++++++++++++++++++++++++++++++++++
 mm/oom_kill.c              | 20 ++++++++------------
 3 files changed, 70 insertions(+), 12 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 2cd4359..d2dbde5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -21,6 +21,7 @@
 #include <linux/vmstat.h>
 #include <linux/writeback.h>
 #include <linux/page-flags.h>
+#include <linux/oom.h>
 
 struct mem_cgroup;
 struct page;
@@ -224,6 +225,7 @@ struct mem_cgroup {
 	 * Should the OOM killer kill all belonging tasks, had it kill one?
 	 */
 	bool oom_group;
+	short oom_score_adj;
 
 	/* protected by memcg_oom_lock */
 	bool		oom_lock;
@@ -538,6 +540,23 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
 	return p->memcg_in_oom;
 }
 
+static inline int mem_cgroup_score_adj(struct task_struct *p, int task_adj)
+{
+	struct mem_cgroup *memcg;
+	int adj = task_adj;
+
+	memcg = mem_cgroup_from_task(p);
+	if (memcg != root_mem_cgroup) {
+		adj += memcg->oom_score_adj;
+		if (adj < OOM_SCORE_ADJ_MIN)
+			adj = OOM_SCORE_ADJ_MIN;
+		else if (adj > OOM_SCORE_ADJ_MAX)
+			adj = OOM_SCORE_ADJ_MAX;
+	}
+
+	return adj;
+}
+
 bool mem_cgroup_oom_synchronize(bool wait);
 struct mem_cgroup *mem_cgroup_get_oom_group(struct task_struct *victim,
 					    struct mem_cgroup *oom_domain);
@@ -987,6 +1006,11 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
 	return false;
 }
 
+static inline int mem_cgroup_score_adj(struct task_struct *p, int task_adj)
+{
+	return task_adj;
+}
+
 static inline bool mem_cgroup_oom_synchronize(bool wait)
 {
 	return false;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6f5c0c5..065285c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5856,6 +5856,38 @@ static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
+static int memory_oom_score_adj_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
+
+	seq_printf(m, "%d\n", memcg->oom_score_adj);
+
+	return 0;
+}
+
+static ssize_t memory_oom_score_adj_write(struct kernfs_open_file *of,
+					  char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	int oom_score_adj;
+	int ret;
+
+	buf = strstrip(buf);
+	if (!buf)
+		return -EINVAL;
+
+	ret = kstrtoint(buf, 0, &oom_score_adj);
+	if (ret)
+		return ret;
+
+	if (oom_score_adj > 1000 || oom_score_adj < -1000)
+		return -EINVAL;
+
+	memcg->oom_score_adj = oom_score_adj;
+
+	return nbytes;
+}
+
 static struct cftype memory_files[] = {
 	{
 		.name = "current",
@@ -5909,6 +5941,12 @@ static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
 		.seq_show = memory_oom_group_show,
 		.write = memory_oom_group_write,
 	},
+	{
+		.name = "oom.score_adj",
+		.flags = CFTYPE_NOT_ON_ROOT | CFTYPE_NS_DELEGATABLE,
+		.seq_show = memory_oom_score_adj_show,
+		.write = memory_oom_score_adj_write,
+	},
 	{ }	/* terminate */
 };
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eda2e2a..f3b0276 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -212,13 +212,7 @@ unsigned long oom_badness(struct task_struct *p, unsigned long totalpages)
 	 * unkillable or have been already oom reaped or the are in
 	 * the middle of vfork
 	 */
-	adj = (long)p->signal->oom_score_adj;
-	if (adj == OOM_SCORE_ADJ_MIN ||
-			test_bit(MMF_OOM_SKIP, &p->mm->flags) ||
-			in_vfork(p)) {
-		task_unlock(p);
-		return 0;
-	}
+	adj = mem_cgroup_score_adj(p, p->signal->oom_score_adj);
 
 	/*
 	 * The baseline for the badness score is the proportion of RAM that each
@@ -404,7 +398,8 @@ static int dump_task(struct task_struct *p, void *arg)
 		task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
 		mm_pgtables_bytes(task->mm),
 		get_mm_counter(task->mm, MM_SWAPENTS),
-		task->signal->oom_score_adj, task->comm);
+		mem_cgroup_score_adj(task, task->signal->oom_score_adj),
+		task->comm);
 	task_unlock(task);
 
 	return 0;
@@ -453,7 +448,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 {
 	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d, oom_score_adj=%hd\n",
 		current->comm, oc->gfp_mask, &oc->gfp_mask, oc->order,
-			current->signal->oom_score_adj);
+		mem_cgroup_score_adj(current, current->signal->oom_score_adj));
 	if (!IS_ENABLED(CONFIG_COMPACTION) && oc->order)
 		pr_warn("COMPACTION is disabled!!!\n");
 
@@ -939,8 +934,8 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
  */
 static int oom_kill_memcg_member(struct task_struct *task, void *message)
 {
-	if (task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN &&
-	    !is_global_init(task)) {
+	if (mem_cgroup_score_adj(task, task->signal->oom_score_adj) !=
+	    OOM_SCORE_ADJ_MIN && !is_global_init(task)) {
 		get_task_struct(task);
 		__oom_kill_process(task, message);
 	}
@@ -1085,7 +1080,8 @@ bool out_of_memory(struct oom_control *oc)
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
 	    current->mm && !oom_unkillable_task(current) &&
 	    oom_cpuset_eligible(current, oc) &&
-	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
+	    mem_cgroup_score_adj(current, current->signal->oom_score_adj) !=
+	    OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
 		oc->chosen = current;
 		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
-- 
1.8.3.1


