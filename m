Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4EBCC282CB
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 22:43:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40F5321908
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 22:43:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="EsAfVVn2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40F5321908
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D70388E00A5; Fri,  8 Feb 2019 17:43:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D21028E00A1; Fri,  8 Feb 2019 17:43:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE8208E00A5; Fri,  8 Feb 2019 17:43:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 530F68E00A1
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 17:43:24 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id u74so1897236wmf.0
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 14:43:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:in-reply-to:user-agent;
        bh=qEhiWB+rK/9iHqqYezdOKf30G2VGfrb5M4E9rdjBBZo=;
        b=B12RWYxIRj4eOxVdOAae1+E5RhZvXsjSE8fxSD0wrxkFxOC/X1c9dVmUkRGi1+kjPW
         /yiIN8gOtOgFwRqAV2Knx6+a8Ft0Clje/4CqoTZIWFyKtYjGKNWoDFPcZEJ/n/6qJwr+
         O+Ws+qD0OQHPw+14XGiKeOaEFCsJtjEcI6lzEQ89RnFHTGuj11ctPekP/CLKtC4OEIBs
         dVt+f4MCafI1gs5YDYehBGwG0UvENm0KQC7S/nmIXbW9gTmMd3Zcds6NsBQm3mEX59IE
         +o9VdooIj19CLgm1AccL+71BNFYKumN9buuUR5ng51BJVoRgqIxhcExRGjSmMxBp3c8U
         fOOQ==
X-Gm-Message-State: AHQUAuawwPAKMsBAK3gHBRbtqtXzwaGr7oqp7F4Sc4V9QpZP4Xt3059Q
	pZZA2Pq4Fc4kP3NHcO9g2DGD4n65Sm2M8m9RdUprnavlyNlQAntsXVHKQXe4isoeJo2walmbeX5
	ae1oYL6+WiTrAnet2eIT1RyLUwhVWKQoDXUrpMtkCp7drOvO6UjO1pB86KQbe7vFyQ7nMF9zNuZ
	0l4Tq//Vj2sKEorgP/bz/da84QzM5aHtzAMtVA2l29jeSPIodiNvaBofo1/Et9LnYz8rocktegw
	2JYhdbc9xojg/0U37Zk5QE2VLR5XU4V3GSmFieGrZUJ3DNkvCvhYOi54LRlQ9gJYOgH0jyiXTr7
	AL371EI0r9pca5tisKA8VYdR1eZach5Wc2H/ejGgYyN2EKFCoYtKBH4B896xskGO1ZStq/RYo67
	5
X-Received: by 2002:a1c:c441:: with SMTP id u62mr622909wmf.69.1549665803791;
        Fri, 08 Feb 2019 14:43:23 -0800 (PST)
X-Received: by 2002:a1c:c441:: with SMTP id u62mr622831wmf.69.1549665802419;
        Fri, 08 Feb 2019 14:43:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549665802; cv=none;
        d=google.com; s=arc-20160816;
        b=mm+GmUCO1VYPn8paOrFUJ35s6QwGhGEur5ofrmAiA/diUvQTYABkkgYVoQaHqRlJ6J
         059Xk780iyqMxW7Bhx8zjQshei2+qhsTiXbUfgSJfg+1whsshrITss9Lw8wMZWE32TGM
         Y45+R+gW4eJuv01ZwCXQqQpTz/7GC5J4EMTexp1chYl9ThJ8GjmV8hMhrpIU44mtFeqZ
         y0sHl3nHLQRKFrrom1iU5LYyB23bTdy56YbXzk+tN/qVotCyQZOpI70lygSBfBY0Ui+O
         c1RhxcpqYCI6IxHLfDa5whMsy014/wANL3Kn+5apgj13xNRRCzetAsyOSi+TtFKJlKO1
         nxdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=qEhiWB+rK/9iHqqYezdOKf30G2VGfrb5M4E9rdjBBZo=;
        b=aTHyhQZk4yE/6tuT9DWq6aUPwRRwYyyfhwQ7HhvOghJMkQV3Z5+TJVO+r/Ajeu+gN5
         IXJGzh05c9Wh0mt2nnuaCwLzfgqfJZ6WDHp07U/6k7wLsFB81Gu4HdomkCwsi7d3YUZL
         +ubBvR27IU5ZAhCPR1gQW+E3nIRrBFbzHSs63hXlL3FmxubMTyb+nk6gyJm8TXi3CrBC
         OZvigZaGoGzy6Nl5mTvp+s4/Psl1LmbUnWdm3+yD/QOuASsniY/lmn+pFqMZ2eb65NcA
         jNhH6Ugowe1EKeARtLbo6Wx7E9tYz3BP/U+sTcGrOSp+66OW0k/oXDHcdEp0e1rD81QK
         1FCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=EsAfVVn2;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i4sor2267736wrx.38.2019.02.08.14.43.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Feb 2019 14:43:22 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=EsAfVVn2;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qEhiWB+rK/9iHqqYezdOKf30G2VGfrb5M4E9rdjBBZo=;
        b=EsAfVVn21c36p+RKUj/nyiAKhHhCN1k7pZTYmI1j5aAHwgtIqxXdQ44fVRJX1+mFpU
         dP7gDZ2he3FOkRudxQAfs7LVhUt7jfnl1nhR/wqBpXL20K0b1EKk2dfjHN9JBbIb3jQV
         m+Wd+UdyFAU28CYgkUAbOapi44LwwLSXl7vt8=
X-Google-Smtp-Source: AHgI3IZH6VXqexMg1Yt/MEKI14E+gGyxqswsvrRt2XsWRGPaDd5u8pesJOHUIkdzhLk0vdkjnUB6ig==
X-Received: by 2002:a5d:558a:: with SMTP id i10mr17639019wrv.287.1549665801695;
        Fri, 08 Feb 2019 14:43:21 -0800 (PST)
Received: from localhost (host-92-23-118-117.as13285.net. [92.23.118.117])
        by smtp.gmail.com with ESMTPSA id t4sm4743971wrb.64.2019.02.08.14.43.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 08 Feb 2019 14:43:20 -0800 (PST)
Date: Fri, 8 Feb 2019 22:43:19 +0000
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>,
	Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: [PATCH v2 1/2] mm: Rename ambiguously named memory.stat counters and
 functions
Message-ID: <20190208224319.GA23801@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190123223144.GA10798@chrisdown.name>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I spent literally an hour trying to work out why an earlier version of
my memory.events aggregation code doesn't work properly, only to find
out I was calling memcg->events instead of memcg->memory_events, which
is fairly confusing.

This naming seems in need of reworking, so make it harder to do the
wrong thing by using vmevents instead of events, which makes it more
clear that these are vm counters rather than memcg-specific counters.

There are also a few other inconsistent names in both the percpu and
aggregated structs, so these are all cleaned up to be more coherent and
easy to understand.

This commit contains code cleanup only: there are no logic changes.

Signed-off-by: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>
Cc: Dennis Zhou <dennis@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 include/linux/memcontrol.h |  24 +++----
 mm/memcontrol.c            | 144 +++++++++++++++++++------------------
 2 files changed, 86 insertions(+), 82 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1803abfd7c00..94f9c5bc26ff 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -94,8 +94,8 @@ enum mem_cgroup_events_target {
 	MEM_CGROUP_NTARGETS,
 };
 
-struct mem_cgroup_stat_cpu {
-	long count[MEMCG_NR_STAT];
+struct memcg_vmstats_percpu {
+	long stat[MEMCG_NR_STAT];
 	unsigned long events[NR_VM_EVENT_ITEMS];
 	unsigned long nr_page_events;
 	unsigned long targets[MEM_CGROUP_NTARGETS];
@@ -274,12 +274,12 @@ struct mem_cgroup {
 	struct task_struct	*move_lock_task;
 
 	/* memory.stat */
-	struct mem_cgroup_stat_cpu __percpu *stat_cpu;
+	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
 
 	MEMCG_PADDING(_pad2_);
 
-	atomic_long_t		stat[MEMCG_NR_STAT];
-	atomic_long_t		events[NR_VM_EVENT_ITEMS];
+	atomic_long_t		vmstats[MEMCG_NR_STAT];
+	atomic_long_t		vmevents[NR_VM_EVENT_ITEMS];
 	atomic_long_t memory_events[MEMCG_NR_MEMORY_EVENTS];
 
 	unsigned long		socket_pressure;
@@ -585,7 +585,7 @@ void unlock_page_memcg(struct page *page);
 static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
 					     int idx)
 {
-	long x = atomic_long_read(&memcg->stat[idx]);
+	long x = atomic_long_read(&memcg->vmstats[idx]);
 #ifdef CONFIG_SMP
 	if (x < 0)
 		x = 0;
@@ -602,12 +602,12 @@ static inline void __mod_memcg_state(struct mem_cgroup *memcg,
 	if (mem_cgroup_disabled())
 		return;
 
-	x = val + __this_cpu_read(memcg->stat_cpu->count[idx]);
+	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
 	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &memcg->stat[idx]);
+		atomic_long_add(x, &memcg->vmstats[idx]);
 		x = 0;
 	}
-	__this_cpu_write(memcg->stat_cpu->count[idx], x);
+	__this_cpu_write(memcg->vmstats_percpu->stat[idx], x);
 }
 
 /* idx can be of type enum memcg_stat_item or node_stat_item */
@@ -745,12 +745,12 @@ static inline void __count_memcg_events(struct mem_cgroup *memcg,
 	if (mem_cgroup_disabled())
 		return;
 
-	x = count + __this_cpu_read(memcg->stat_cpu->events[idx]);
+	x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
 	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &memcg->events[idx]);
+		atomic_long_add(x, &memcg->vmevents[idx]);
 		x = 0;
 	}
-	__this_cpu_write(memcg->stat_cpu->events[idx], x);
+	__this_cpu_write(memcg->vmstats_percpu->events[idx], x);
 }
 
 static inline void count_memcg_events(struct mem_cgroup *memcg,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6464de2648b2..5fc2e1a7d4d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -690,7 +690,7 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_node *mctz)
 static unsigned long memcg_sum_events(struct mem_cgroup *memcg,
 				      int event)
 {
-	return atomic_long_read(&memcg->events[event]);
+	return atomic_long_read(&memcg->vmevents[event]);
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
@@ -722,7 +722,7 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 		nr_pages = -nr_pages; /* for event */
 	}
 
-	__this_cpu_add(memcg->stat_cpu->nr_page_events, nr_pages);
+	__this_cpu_add(memcg->vmstats_percpu->nr_page_events, nr_pages);
 }
 
 unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
@@ -758,8 +758,8 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 {
 	unsigned long val, next;
 
-	val = __this_cpu_read(memcg->stat_cpu->nr_page_events);
-	next = __this_cpu_read(memcg->stat_cpu->targets[target]);
+	val = __this_cpu_read(memcg->vmstats_percpu->nr_page_events);
+	next = __this_cpu_read(memcg->vmstats_percpu->targets[target]);
 	/* from time_after() in jiffies.h */
 	if ((long)(next - val) < 0) {
 		switch (target) {
@@ -775,7 +775,7 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 		default:
 			break;
 		}
-		__this_cpu_write(memcg->stat_cpu->targets[target], next);
+		__this_cpu_write(memcg->vmstats_percpu->targets[target], next);
 		return true;
 	}
 	return false;
@@ -2117,9 +2117,9 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 			int nid;
 			long x;
 
-			x = this_cpu_xchg(memcg->stat_cpu->count[i], 0);
+			x = this_cpu_xchg(memcg->vmstats_percpu->stat[i], 0);
 			if (x)
-				atomic_long_add(x, &memcg->stat[i]);
+				atomic_long_add(x, &memcg->vmstats[i]);
 
 			if (i >= NR_VM_NODE_STAT_ITEMS)
 				continue;
@@ -2137,9 +2137,9 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 		for (i = 0; i < NR_VM_EVENT_ITEMS; i++) {
 			long x;
 
-			x = this_cpu_xchg(memcg->stat_cpu->events[i], 0);
+			x = this_cpu_xchg(memcg->vmstats_percpu->events[i], 0);
 			if (x)
-				atomic_long_add(x, &memcg->events[i]);
+				atomic_long_add(x, &memcg->vmevents[i]);
 		}
 	}
 
@@ -2979,30 +2979,34 @@ static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
 	return retval;
 }
 
-struct accumulated_stats {
-	unsigned long stat[MEMCG_NR_STAT];
-	unsigned long events[NR_VM_EVENT_ITEMS];
+struct accumulated_vmstats {
+	unsigned long vmstats[MEMCG_NR_STAT];
+	unsigned long vmevents[NR_VM_EVENT_ITEMS];
 	unsigned long lru_pages[NR_LRU_LISTS];
-	const unsigned int *stats_array;
-	const unsigned int *events_array;
-	int stats_size;
-	int events_size;
+
+	/* overrides for v1 */
+	const unsigned int *vmstats_array;
+	const unsigned int *vmevents_array;
+
+	int vmstats_size;
+	int vmevents_size;
 };
 
-static void accumulate_memcg_tree(struct mem_cgroup *memcg,
-				  struct accumulated_stats *acc)
+static void accumulate_vmstats(struct mem_cgroup *memcg,
+			       struct accumulated_vmstats *acc)
 {
 	struct mem_cgroup *mi;
 	int i;
 
 	for_each_mem_cgroup_tree(mi, memcg) {
-		for (i = 0; i < acc->stats_size; i++)
-			acc->stat[i] += memcg_page_state(mi,
-				acc->stats_array ? acc->stats_array[i] : i);
+		for (i = 0; i < acc->vmstats_size; i++)
+			acc->vmstats[i] += memcg_page_state(mi,
+				acc->vmstats_array ? acc->vmstats_array[i] : i);
 
-		for (i = 0; i < acc->events_size; i++)
-			acc->events[i] += memcg_sum_events(mi,
-				acc->events_array ? acc->events_array[i] : i);
+		for (i = 0; i < acc->vmevents_size; i++)
+			acc->vmevents[i] += memcg_sum_events(mi,
+				acc->vmevents_array
+				? acc->vmevents_array[i] : i);
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
 			acc->lru_pages[i] +=
@@ -3417,7 +3421,7 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 	unsigned long memory, memsw;
 	struct mem_cgroup *mi;
 	unsigned int i;
-	struct accumulated_stats acc;
+	struct accumulated_vmstats acc;
 
 	BUILD_BUG_ON(ARRAY_SIZE(memcg1_stat_names) != ARRAY_SIZE(memcg1_stats));
 	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
@@ -3451,22 +3455,22 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 			   (u64)memsw * PAGE_SIZE);
 
 	memset(&acc, 0, sizeof(acc));
-	acc.stats_size = ARRAY_SIZE(memcg1_stats);
-	acc.stats_array = memcg1_stats;
-	acc.events_size = ARRAY_SIZE(memcg1_events);
-	acc.events_array = memcg1_events;
-	accumulate_memcg_tree(memcg, &acc);
+	acc.vmstats_size = ARRAY_SIZE(memcg1_stats);
+	acc.vmstats_array = memcg1_stats;
+	acc.vmevents_size = ARRAY_SIZE(memcg1_events);
+	acc.vmevents_array = memcg1_events;
+	accumulate_vmstats(memcg, &acc);
 
 	for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
 		if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
 			continue;
 		seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
-			   (u64)acc.stat[i] * PAGE_SIZE);
+			   (u64)acc.vmstats[i] * PAGE_SIZE);
 	}
 
 	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
 		seq_printf(m, "total_%s %llu\n", memcg1_event_names[i],
-			   (u64)acc.events[i]);
+			   (u64)acc.vmevents[i]);
 
 	for (i = 0; i < NR_LRU_LISTS; i++)
 		seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i],
@@ -4431,7 +4435,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
-	free_percpu(memcg->stat_cpu);
+	free_percpu(memcg->vmstats_percpu);
 	kfree(memcg);
 }
 
@@ -4460,8 +4464,8 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (memcg->id.id < 0)
 		goto fail;
 
-	memcg->stat_cpu = alloc_percpu(struct mem_cgroup_stat_cpu);
-	if (!memcg->stat_cpu)
+	memcg->vmstats_percpu = alloc_percpu(struct memcg_vmstats_percpu);
+	if (!memcg->vmstats_percpu)
 		goto fail;
 
 	for_each_node(node)
@@ -5547,7 +5551,7 @@ static int memory_events_show(struct seq_file *m, void *v)
 static int memory_stat_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
-	struct accumulated_stats acc;
+	struct accumulated_vmstats acc;
 	int i;
 
 	/*
@@ -5562,30 +5566,30 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	 */
 
 	memset(&acc, 0, sizeof(acc));
-	acc.stats_size = MEMCG_NR_STAT;
-	acc.events_size = NR_VM_EVENT_ITEMS;
-	accumulate_memcg_tree(memcg, &acc);
+	acc.vmstats_size = MEMCG_NR_STAT;
+	acc.vmevents_size = NR_VM_EVENT_ITEMS;
+	accumulate_vmstats(memcg, &acc);
 
 	seq_printf(m, "anon %llu\n",
-		   (u64)acc.stat[MEMCG_RSS] * PAGE_SIZE);
+		   (u64)acc.vmstats[MEMCG_RSS] * PAGE_SIZE);
 	seq_printf(m, "file %llu\n",
-		   (u64)acc.stat[MEMCG_CACHE] * PAGE_SIZE);
+		   (u64)acc.vmstats[MEMCG_CACHE] * PAGE_SIZE);
 	seq_printf(m, "kernel_stack %llu\n",
-		   (u64)acc.stat[MEMCG_KERNEL_STACK_KB] * 1024);
+		   (u64)acc.vmstats[MEMCG_KERNEL_STACK_KB] * 1024);
 	seq_printf(m, "slab %llu\n",
-		   (u64)(acc.stat[NR_SLAB_RECLAIMABLE] +
-			 acc.stat[NR_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
+		   (u64)(acc.vmstats[NR_SLAB_RECLAIMABLE] +
+			 acc.vmstats[NR_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
 	seq_printf(m, "sock %llu\n",
-		   (u64)acc.stat[MEMCG_SOCK] * PAGE_SIZE);
+		   (u64)acc.vmstats[MEMCG_SOCK] * PAGE_SIZE);
 
 	seq_printf(m, "shmem %llu\n",
-		   (u64)acc.stat[NR_SHMEM] * PAGE_SIZE);
+		   (u64)acc.vmstats[NR_SHMEM] * PAGE_SIZE);
 	seq_printf(m, "file_mapped %llu\n",
-		   (u64)acc.stat[NR_FILE_MAPPED] * PAGE_SIZE);
+		   (u64)acc.vmstats[NR_FILE_MAPPED] * PAGE_SIZE);
 	seq_printf(m, "file_dirty %llu\n",
-		   (u64)acc.stat[NR_FILE_DIRTY] * PAGE_SIZE);
+		   (u64)acc.vmstats[NR_FILE_DIRTY] * PAGE_SIZE);
 	seq_printf(m, "file_writeback %llu\n",
-		   (u64)acc.stat[NR_WRITEBACK] * PAGE_SIZE);
+		   (u64)acc.vmstats[NR_WRITEBACK] * PAGE_SIZE);
 
 	/*
 	 * TODO: We should eventually replace our own MEMCG_RSS_HUGE counter
@@ -5594,43 +5598,43 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	 * where the page->mem_cgroup is set up and stable.
 	 */
 	seq_printf(m, "anon_thp %llu\n",
-		   (u64)acc.stat[MEMCG_RSS_HUGE] * PAGE_SIZE);
+		   (u64)acc.vmstats[MEMCG_RSS_HUGE] * PAGE_SIZE);
 
 	for (i = 0; i < NR_LRU_LISTS; i++)
 		seq_printf(m, "%s %llu\n", mem_cgroup_lru_names[i],
 			   (u64)acc.lru_pages[i] * PAGE_SIZE);
 
 	seq_printf(m, "slab_reclaimable %llu\n",
-		   (u64)acc.stat[NR_SLAB_RECLAIMABLE] * PAGE_SIZE);
+		   (u64)acc.vmstats[NR_SLAB_RECLAIMABLE] * PAGE_SIZE);
 	seq_printf(m, "slab_unreclaimable %llu\n",
-		   (u64)acc.stat[NR_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
+		   (u64)acc.vmstats[NR_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
 
 	/* Accumulated memory events */
 
-	seq_printf(m, "pgfault %lu\n", acc.events[PGFAULT]);
-	seq_printf(m, "pgmajfault %lu\n", acc.events[PGMAJFAULT]);
+	seq_printf(m, "pgfault %lu\n", acc.vmevents[PGFAULT]);
+	seq_printf(m, "pgmajfault %lu\n", acc.vmevents[PGMAJFAULT]);
 
 	seq_printf(m, "workingset_refault %lu\n",
-		   acc.stat[WORKINGSET_REFAULT]);
+		   acc.vmstats[WORKINGSET_REFAULT]);
 	seq_printf(m, "workingset_activate %lu\n",
-		   acc.stat[WORKINGSET_ACTIVATE]);
+		   acc.vmstats[WORKINGSET_ACTIVATE]);
 	seq_printf(m, "workingset_nodereclaim %lu\n",
-		   acc.stat[WORKINGSET_NODERECLAIM]);
-
-	seq_printf(m, "pgrefill %lu\n", acc.events[PGREFILL]);
-	seq_printf(m, "pgscan %lu\n", acc.events[PGSCAN_KSWAPD] +
-		   acc.events[PGSCAN_DIRECT]);
-	seq_printf(m, "pgsteal %lu\n", acc.events[PGSTEAL_KSWAPD] +
-		   acc.events[PGSTEAL_DIRECT]);
-	seq_printf(m, "pgactivate %lu\n", acc.events[PGACTIVATE]);
-	seq_printf(m, "pgdeactivate %lu\n", acc.events[PGDEACTIVATE]);
-	seq_printf(m, "pglazyfree %lu\n", acc.events[PGLAZYFREE]);
-	seq_printf(m, "pglazyfreed %lu\n", acc.events[PGLAZYFREED]);
+		   acc.vmstats[WORKINGSET_NODERECLAIM]);
+
+	seq_printf(m, "pgrefill %lu\n", acc.vmevents[PGREFILL]);
+	seq_printf(m, "pgscan %lu\n", acc.vmevents[PGSCAN_KSWAPD] +
+		   acc.vmevents[PGSCAN_DIRECT]);
+	seq_printf(m, "pgsteal %lu\n", acc.vmevents[PGSTEAL_KSWAPD] +
+		   acc.vmevents[PGSTEAL_DIRECT]);
+	seq_printf(m, "pgactivate %lu\n", acc.vmevents[PGACTIVATE]);
+	seq_printf(m, "pgdeactivate %lu\n", acc.vmevents[PGDEACTIVATE]);
+	seq_printf(m, "pglazyfree %lu\n", acc.vmevents[PGLAZYFREE]);
+	seq_printf(m, "pglazyfreed %lu\n", acc.vmevents[PGLAZYFREED]);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	seq_printf(m, "thp_fault_alloc %lu\n", acc.events[THP_FAULT_ALLOC]);
+	seq_printf(m, "thp_fault_alloc %lu\n", acc.vmevents[THP_FAULT_ALLOC]);
 	seq_printf(m, "thp_collapse_alloc %lu\n",
-		   acc.events[THP_COLLAPSE_ALLOC]);
+		   acc.vmevents[THP_COLLAPSE_ALLOC]);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 	return 0;
@@ -6066,7 +6070,7 @@ static void uncharge_batch(const struct uncharge_gather *ug)
 	__mod_memcg_state(ug->memcg, MEMCG_RSS_HUGE, -ug->nr_huge);
 	__mod_memcg_state(ug->memcg, NR_SHMEM, -ug->nr_shmem);
 	__count_memcg_events(ug->memcg, PGPGOUT, ug->pgpgout);
-	__this_cpu_add(ug->memcg->stat_cpu->nr_page_events, nr_pages);
+	__this_cpu_add(ug->memcg->vmstats_percpu->nr_page_events, nr_pages);
 	memcg_check_events(ug->memcg, ug->dummy_page);
 	local_irq_restore(flags);
 
-- 
2.20.1

