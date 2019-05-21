Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8862BC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:16:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19A182173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:16:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="CXGnUo0N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19A182173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89B376B0007; Tue, 21 May 2019 11:16:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84C4F6B0008; Tue, 21 May 2019 11:16:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7139F6B000A; Tue, 21 May 2019 11:16:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37E6B6B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:16:52 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b69so11580336plb.9
        for <linux-mm@kvack.org>; Tue, 21 May 2019 08:16:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Vrg5abMyMrA/Oyy7NYVIaBdRIazxG5RLmR80PbEB3d4=;
        b=XVPzM00Qv+OKy+3nVmWRWzWy8uiJ+E57bLNwVtEQbIw7l0iQ88TEUz9RRO9NAeAHSF
         VnvW5u2WvxcPUVDFyMCgqjr4B45J3ZE3YxGUHXX5FwGoziypFwIlXRsmvBiGjYF4nlp3
         C8cfWk/6DU6IU/BLAUOX7hk7SkoRskSy9qICr+fLtrWXOwzL9BrI/D+QqLSMGou6eF6a
         Uv3OS0r5XZ1vHv07F6aNYz008opnO4/GELVo9TGCIYHaFvTwOXWwXXdmPr32quq54s6Q
         jR2O6C2vFHrWenDQCOQyENcOvbVywmilI8IzGGTpeujK24MVNRnWhOWYU63lZjf9jGvb
         Nu7A==
X-Gm-Message-State: APjAAAVJ/jH9pD7XNW7BRwrVkvDGA8pjkIeNYQ61TDNguW+kDfBdBFfS
	NPDK8G1E6BRGUvYeLAnocAb10NT2CFkLlkGyKCA/I8vAV5nIwg5o4K4DYSha5gSILGSfuNj0IAr
	ATVFuBrdaoPHa5LrOZdzdRFt8SFp1WvgKo0nadlgIZFNP7Rzum1dJVIzYqzZNdZpWUQ==
X-Received: by 2002:a17:902:4e:: with SMTP id 72mr30972995pla.80.1558451811714;
        Tue, 21 May 2019 08:16:51 -0700 (PDT)
X-Received: by 2002:a17:902:4e:: with SMTP id 72mr30972852pla.80.1558451810594;
        Tue, 21 May 2019 08:16:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558451810; cv=none;
        d=google.com; s=arc-20160816;
        b=k/gsoLRO5o4WKJAVQoiH9gPybQk576+Zjd5nubMDSUT57+rA+M0BSDjHISTJt/7f5f
         5lg32ZgvCHB3S1R65ksHjlHSrngQPkEEd2JSfG3n5PbtdSs8agsxPq7jsavm8YGH/OhE
         EewCRk2axkdCXfGOKq0+7e/GB0ZwtVK7r5Fh7hIyyZFH2TTiOzDh8sHU053+L4G9HAvi
         LOofH8uiF6UP8lwfvIMsuqoPO/I19wa7nql8BR3lOFVJ3K4kCDGRoHc22U5Ip3IsNyD9
         Dz7Q4svEOLr6CZP9bqwQWaSnHsPhOUeoxbBQ3vb4bS4jKsHMueKZHmOtkR1HdLgKSPlc
         cyaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Vrg5abMyMrA/Oyy7NYVIaBdRIazxG5RLmR80PbEB3d4=;
        b=HcfStfNzDN99NGd/W6UCCnmZYvILG1yi50EKeJrfDo+ZCmPYjDmPu9YKYHZMKp112E
         PtickxgGvKU7R1PKPU/AztbVZsNZhxUKX3+0P+cwsZajnNZYIl3jjLYWtGB2+a3HeCLt
         8bD8k4LQ8YqGHSv7cgpF2i2k4mhES1+VpxSWYraxtcXgDfRJwhUaIqBKfiRdijDqzkDO
         hrPD7UJS69GUWLcYG39zxwxBs97XVOY+AwKDhl1gnHsvBaMlrrBD/DXcqGhRckBbIH7y
         yHlUQysMcfdf0kRNBt8G7QBXhNBChWWj+QFt94Rxqc9H1nL20DYNcxaTQamBHUpNsOO2
         W1bw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=CXGnUo0N;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t24sor5082932plo.58.2019.05.21.08.16.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 08:16:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=CXGnUo0N;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Vrg5abMyMrA/Oyy7NYVIaBdRIazxG5RLmR80PbEB3d4=;
        b=CXGnUo0NOi4At02ITCCmdyHJ0AwOqIlU0nQykBnSRQSU+lhNfqbW2hqm+PBjYDrNgH
         lhaKBx8BCeTXCIi2XympJ0T1+J+/hCxdfmPujbrmmgZI8FasBx++X988gr0VU8W6+u6a
         T5nReELXdCpJqbrco5rCliUK508JgLBGELt4od7nGkimwgDXuxeo70gH0ibDkHCD0x1Y
         30Ynm4iYfj8JY3KISIHJUd/1hyesf4eBRhb49P+37XwsIths3GottOjy3eiKnE7v8Rgt
         Y3/XVZfFmyE+4Vc5oQFKP+n7Hi0ubyjBv5Bf5jZoLZgXHXpSSIred2rXbzJv1aeuSW4x
         z3nw==
X-Google-Smtp-Source: APXvYqzbATTqdyKAC0CB4fuXle7r+DgZw4voGOd0swqaxdX3fNcD3yEd+FSrsFjoN+9qNUPodak3wQ==
X-Received: by 2002:a17:902:a70f:: with SMTP id w15mr13184209plq.222.1558451810064;
        Tue, 21 May 2019 08:16:50 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5a76])
        by smtp.gmail.com with ESMTPSA id m6sm31800996pgr.18.2019.05.21.08.16.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 May 2019 08:16:49 -0700 (PDT)
Date: Tue, 21 May 2019 11:16:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Cc: kernel test robot <rong.a.chen@intel.com>, lkp@01.org,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@kernel.org>,
	Shakeel Butt <shakeelb@google.com>, Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org, cgroups@vger.kernel.org
Subject: [PATCH] mm: memcontrol: don't batch updates of local VM stats and
 events
Message-ID: <20190521151647.GB2870@cmpxchg.org>
References: <20190520063534.GB19312@shao2-debian>
 <20190520215328.GA1186@cmpxchg.org>
 <20190521134646.GE19312@shao2-debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521134646.GE19312@shao2-debian>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The kernel test robot noticed a 26% will-it-scale pagefault regression
from commit 42a300353577 ("mm: memcontrol: fix recursive statistics
correctness & scalabilty"). This appears to be caused by bouncing the
additional cachelines from the new hierarchical statistics counters.

We can fix this by getting rid of the batched local counters instead.

Originally, there were *only* group-local counters, and they were
fully maintained per cpu. A reader of a stats file high up in the
cgroup tree would have to walk the entire subtree and collect each
level's per-cpu counters to get the recursive view. This was
prohibitively expensive, and so we switched to per-cpu batched updates
of the local counters during a983b5ebee57 ("mm: memcontrol: fix
excessive complexity in memory.stat reporting"), reducing the
complexity from nr_subgroups * nr_cpus to nr_subgroups.

With growing machines and cgroup trees, the tree walk itself became
too expensive for monitoring top-level groups, and this is when the
culprit patch added hierarchy counters on each cgroup level. When the
per-cpu batch size would be reached, both the local and the hierarchy
counters would get batch-updated from the per-cpu delta simultaneously.

This makes local and hierarchical counter reads blazingly fast, but it
unfortunately makes the write-side too cache line intense.

Since local counter reads were never a problem - we only centralized
them to accelerate the hierarchy walk - and use of the local counters
are becoming rarer due to replacement with hierarchical views (ongoing
rework in the page reclaim and workingset code), we can make those
local counters unbatched per-cpu counters again.

The scheme will then be as such:

   when a memcg statistic changes, the writer will:
   - update the local counter (per-cpu)
   - update the batch counter (per-cpu). If the batch is full:
   - spill the batch into the group's atomic_t
   - spill the batch into all ancestors' atomic_ts
   - empty out the batch counter (per-cpu)

   when a local memcg counter is read, the reader will:
   - collect the local counter from all cpus

   when a hiearchy memcg counter is read, the reader will:
   - read the atomic_t

We might be able to simplify this further and make the recursive
counters unbatched per-cpu counters as well (batch upward propagation,
but leave per-cpu collection to the readers), but that will require a
more in-depth analysis and testing of all the callsites. Deal with the
immediate regression for now.

Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")
Reported-by: kernel test robot <rong.a.chen@intel.com>
Tested-by: kernel test robot <rong.a.chen@intel.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 26 ++++++++++++++++--------
 mm/memcontrol.c            | 41 ++++++++++++++++++++++++++------------
 2 files changed, 46 insertions(+), 21 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index bc74d6a4407c..2d23ae7bd36d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -126,9 +126,12 @@ struct memcg_shrinker_map {
 struct mem_cgroup_per_node {
 	struct lruvec		lruvec;
 
+	/* Legacy local VM stats */
+	struct lruvec_stat __percpu *lruvec_stat_local;
+
+	/* Subtree VM stats (batched updates) */
 	struct lruvec_stat __percpu *lruvec_stat_cpu;
 	atomic_long_t		lruvec_stat[NR_VM_NODE_STAT_ITEMS];
-	atomic_long_t		lruvec_stat_local[NR_VM_NODE_STAT_ITEMS];
 
 	unsigned long		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
 
@@ -274,17 +277,18 @@ struct mem_cgroup {
 	atomic_t		moving_account;
 	struct task_struct	*move_lock_task;
 
-	/* memory.stat */
+	/* Legacy local VM stats and events */
+	struct memcg_vmstats_percpu __percpu *vmstats_local;
+
+	/* Subtree VM stats and events (batched updates) */
 	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
 
 	MEMCG_PADDING(_pad2_);
 
 	atomic_long_t		vmstats[MEMCG_NR_STAT];
-	atomic_long_t		vmstats_local[MEMCG_NR_STAT];
-
 	atomic_long_t		vmevents[NR_VM_EVENT_ITEMS];
-	atomic_long_t		vmevents_local[NR_VM_EVENT_ITEMS];
 
+	/* memory.events */
 	atomic_long_t		memory_events[MEMCG_NR_MEMORY_EVENTS];
 
 	unsigned long		socket_pressure;
@@ -576,7 +580,11 @@ static inline unsigned long memcg_page_state(struct mem_cgroup *memcg, int idx)
 static inline unsigned long memcg_page_state_local(struct mem_cgroup *memcg,
 						   int idx)
 {
-	long x = atomic_long_read(&memcg->vmstats_local[idx]);
+	long x = 0;
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		x += per_cpu(memcg->vmstats_local->stat[idx], cpu);
 #ifdef CONFIG_SMP
 	if (x < 0)
 		x = 0;
@@ -650,13 +658,15 @@ static inline unsigned long lruvec_page_state_local(struct lruvec *lruvec,
 						    enum node_stat_item idx)
 {
 	struct mem_cgroup_per_node *pn;
-	long x;
+	long x = 0;
+	int cpu;
 
 	if (mem_cgroup_disabled())
 		return node_page_state(lruvec_pgdat(lruvec), idx);
 
 	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
-	x = atomic_long_read(&pn->lruvec_stat_local[idx]);
+	for_each_possible_cpu(cpu)
+		x += per_cpu(pn->lruvec_stat_local->count[idx], cpu);
 #ifdef CONFIG_SMP
 	if (x < 0)
 		x = 0;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e50a2db5b4ff..8d42e5c7bf37 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -700,11 +700,12 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
 	if (mem_cgroup_disabled())
 		return;
 
+	__this_cpu_add(memcg->vmstats_local->stat[idx], val);
+
 	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
 	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup *mi;
 
-		atomic_long_add(x, &memcg->vmstats_local[idx]);
 		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 			atomic_long_add(x, &mi->vmstats[idx]);
 		x = 0;
@@ -754,11 +755,12 @@ void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
 	__mod_memcg_state(memcg, idx, val);
 
 	/* Update lruvec */
+	__this_cpu_add(pn->lruvec_stat_local->count[idx], val);
+
 	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
 	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup_per_node *pi;
 
-		atomic_long_add(x, &pn->lruvec_stat_local[idx]);
 		for (pi = pn; pi; pi = parent_nodeinfo(pi, pgdat->node_id))
 			atomic_long_add(x, &pi->lruvec_stat[idx]);
 		x = 0;
@@ -780,11 +782,12 @@ void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
 	if (mem_cgroup_disabled())
 		return;
 
+	__this_cpu_add(memcg->vmstats_local->events[idx], count);
+
 	x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
 	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup *mi;
 
-		atomic_long_add(x, &memcg->vmevents_local[idx]);
 		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 			atomic_long_add(x, &mi->vmevents[idx]);
 		x = 0;
@@ -799,7 +802,12 @@ static unsigned long memcg_events(struct mem_cgroup *memcg, int event)
 
 static unsigned long memcg_events_local(struct mem_cgroup *memcg, int event)
 {
-	return atomic_long_read(&memcg->vmevents_local[event]);
+	long x = 0;
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		x += per_cpu(memcg->vmstats_local->events[event], cpu);
+	return x;
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
@@ -2200,11 +2208,9 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 			long x;
 
 			x = this_cpu_xchg(memcg->vmstats_percpu->stat[i], 0);
-			if (x) {
-				atomic_long_add(x, &memcg->vmstats_local[i]);
+			if (x)
 				for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 					atomic_long_add(x, &memcg->vmstats[i]);
-			}
 
 			if (i >= NR_VM_NODE_STAT_ITEMS)
 				continue;
@@ -2214,12 +2220,10 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 
 				pn = mem_cgroup_nodeinfo(memcg, nid);
 				x = this_cpu_xchg(pn->lruvec_stat_cpu->count[i], 0);
-				if (x) {
-					atomic_long_add(x, &pn->lruvec_stat_local[i]);
+				if (x)
 					do {
 						atomic_long_add(x, &pn->lruvec_stat[i]);
 					} while ((pn = parent_nodeinfo(pn, nid)));
-				}
 			}
 		}
 
@@ -2227,11 +2231,9 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 			long x;
 
 			x = this_cpu_xchg(memcg->vmstats_percpu->events[i], 0);
-			if (x) {
-				atomic_long_add(x, &memcg->vmevents_local[i]);
+			if (x)
 				for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 					atomic_long_add(x, &memcg->vmevents[i]);
-			}
 		}
 	}
 
@@ -4492,8 +4494,15 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	if (!pn)
 		return 1;
 
+	pn->lruvec_stat_local = alloc_percpu(struct lruvec_stat);
+	if (!pn->lruvec_stat_local) {
+		kfree(pn);
+		return 1;
+	}
+
 	pn->lruvec_stat_cpu = alloc_percpu(struct lruvec_stat);
 	if (!pn->lruvec_stat_cpu) {
+		free_percpu(pn->lruvec_stat_local);
 		kfree(pn);
 		return 1;
 	}
@@ -4515,6 +4524,7 @@ static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 		return;
 
 	free_percpu(pn->lruvec_stat_cpu);
+	free_percpu(pn->lruvec_stat_local);
 	kfree(pn);
 }
 
@@ -4525,6 +4535,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->vmstats_percpu);
+	free_percpu(memcg->vmstats_local);
 	kfree(memcg);
 }
 
@@ -4553,6 +4564,10 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (memcg->id.id < 0)
 		goto fail;
 
+	memcg->vmstats_local = alloc_percpu(struct memcg_vmstats_percpu);
+	if (!memcg->vmstats_local)
+		goto fail;
+
 	memcg->vmstats_percpu = alloc_percpu(struct memcg_vmstats_percpu);
 	if (!memcg->vmstats_percpu)
 		goto fail;
-- 
2.21.0

