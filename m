Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01CDEC76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 12:29:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A245C20880
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 12:29:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="nq8XUGG5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A245C20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF3946B0008; Wed, 17 Jul 2019 08:29:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7AF16B000A; Wed, 17 Jul 2019 08:29:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 942CD8E0001; Wed, 17 Jul 2019 08:29:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE966B0008
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 08:29:23 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id g13so1393409lfb.2
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 05:29:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=aMpv7Xct1a+OGXg8ADZUVXKf/2FGP5PbSlVY1U6Mlv0=;
        b=JsabH8SlUU9Uv1cC4Rup1gyjzXe5QCAy91WQHinKkqAyd8iXzOD1THfzugjLj4x2g2
         lpmYiHHOLXUqfEGm9nTc2ABbSddYWibquB914AAiCsfJYufYTWKY3jLqR3n8GgIP2of4
         h1dpJCDcWA1a5QzVfnWIivcaW4wk0hw4jIvDhPdgd3ROoxduLbKyZwJgpZsh4hQ59Myh
         8wo74cO78JjqT36Zc5Rc6REyu3CaZ2NjSnAqlAq55wy6t4Ds3CWSFPqbytsJ6KMGVjEk
         dZe7bCb/V/FIn97iY9ivYxc20n2tn2tOyvRNCigQ7sVIISkfHc4DWLmIrfcyw9OBGbqf
         GNhQ==
X-Gm-Message-State: APjAAAVQ79qhjjCj4aA+au208sK6BiQnhtRnOl8R4ID25pMwQwhXDY8O
	1N2cM+vMiAbcQfZb6eQgAN2aw465EodBgPoPlhoMHiHgUG3jeABSvosdkyIU2FRNiMrMFF7b2SO
	tJ1yX9fmppWqxW7EFZim7+OtfArdsxE34UAvyUSoRiJmyHXF83bR/p1TxQDeXP/X0fw==
X-Received: by 2002:a19:6904:: with SMTP id e4mr18099671lfc.156.1563366562440;
        Wed, 17 Jul 2019 05:29:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZS4ZfKhKqP0TwQCx+zy4Jl38fUeXb2+eUITIr8tJMlk8uasU80fl9U0wybRVuQ/S7N23S
X-Received: by 2002:a19:6904:: with SMTP id e4mr18099609lfc.156.1563366561071;
        Wed, 17 Jul 2019 05:29:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563366561; cv=none;
        d=google.com; s=arc-20160816;
        b=GFZ1MglDs4xtYtKbm2lASfvlTFzRFzN6gA4J9HrHZWza4jxIIYLgu1UUfCLlYh7eRx
         gfuFwW7Ge8vCVaLaefZmMz9Lbe54VCb0UD5DBnhGbfc7P0x0/V3ob2GSEygQd8dj6JgY
         Qlt3JmD64lKK3ZVFQkJjpLfPzwwpNy4MCeloteU+GA2NR8RCRWzHcjCLG57//QV0UYaz
         tkNPINEbITvfDPNVR2MKx3RwNe3sPTrky6ew7hPnpx019tZZhrscSrfpKvdpYSOOz9/N
         okHy6Bj2cJ7I5f3ch8DU9MJR4jKGP8hRiz/V+1gDBbLieL76KoxlKVG2g8HBaT4vpBua
         oV5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=aMpv7Xct1a+OGXg8ADZUVXKf/2FGP5PbSlVY1U6Mlv0=;
        b=JiOhpT3nPnmQaqCwJ1hhp1prGkmAbeA8K/jkhtkmQ3bcGgiCPurK4d1JmrIuEEqSl4
         pqS2oNoX+ogGdpwFunJN8F4UVAjdpvQTqPb93IdDeaJAfW096O5GThrjqkr+ek5d+o4P
         234F6UAbH5zVzFG4mOfTPgwqxkFQiuGM+bx9lgyq35CWglcuY/vpPwZhZ5blx8pJL+cX
         S8BAB8eGartKq1vSQNLbEseHwrA2AzvqVi887Ac8ppOhcNMjFWTv2tR0MEz2fnhC/zpK
         crxL6er1JocGGbaz3nD2Vto4cO85l+CsRZJedGjJVQzdNzck9NQdbAwdrC+4LmOKyK2G
         C30Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=nq8XUGG5;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [2a02:6b8:0:1472:2741:0:8b6:217])
        by mx.google.com with ESMTPS id t26si21804718ljc.124.2019.07.17.05.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 05:29:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) client-ip=2a02:6b8:0:1472:2741:0:8b6:217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=nq8XUGG5;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 6DEBB2E14BD;
	Wed, 17 Jul 2019 15:29:20 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id zAEKNlfcnL-TKt4QiXA;
	Wed, 17 Jul 2019 15:29:20 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1563366560; bh=aMpv7Xct1a+OGXg8ADZUVXKf/2FGP5PbSlVY1U6Mlv0=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=nq8XUGG5Mgz9Txk1sHrC9JAhqHwzZBZiWqPSAVh4DZFsIM3GQogd0iO9GHwLL1QQi
	 Q+o47kVvkdIbKdckX1i/F8IPbcT9SnAkEeVFD4Nil4hDg59DziL1LK/eTKk8BYp978
	 zobtuPhWhYFl58Tbs0ccVmOopzum0l2zDBo44etE=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38d2:81d0:9f31:221f])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id YSbPaaLWJy-TK9CVQFZ;
	Wed, 17 Jul 2019 15:29:20 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH 2/2] mm/memcontrol: split local and nested atomic
 vmstats/vmevents counters
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Date: Wed, 17 Jul 2019 15:29:19 +0300
Message-ID: <156336655979.2828.15196553724473875230.stgit@buzz>
In-Reply-To: <156336655741.2828.4721531901883313745.stgit@buzz>
References: <156336655741.2828.4721531901883313745.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is alternative solution for problem addressed in commit 815744d75152
("mm: memcontrol: don't batch updates of local VM stats and events").

Instead of adding second set of percpu counters which wastes memory and
slows down showing statistics in cgroup-v1 this patch use two arrays of
atomic counters: local and nested statistics.

Then update has the same amount of atomic operations: local update and
one nested for each parent cgroup. Readers of hierarchical statistics
have to sum two atomics which isn't a big deal.

All updates are still batched using one set of percpu counters.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/memcontrol.h |   19 +++++++----------
 mm/memcontrol.c            |   48 +++++++++++++++++++-------------------------
 2 files changed, 29 insertions(+), 38 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 44c41462be33..4dd75d50c200 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -269,16 +269,16 @@ struct mem_cgroup {
 	atomic_t		moving_account;
 	struct task_struct	*move_lock_task;
 
-	/* Legacy local VM stats and events */
-	struct memcg_vmstats_percpu __percpu *vmstats_local;
-
 	/* Subtree VM stats and events (batched updates) */
 	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
 
 	MEMCG_PADDING(_pad2_);
 
-	atomic_long_t		vmstats[MEMCG_NR_STAT];
-	atomic_long_t		vmevents[NR_VM_EVENT_ITEMS];
+	atomic_long_t		vmstats_local[MEMCG_NR_STAT];
+	atomic_long_t		vmstats_nested[MEMCG_NR_STAT];
+
+	atomic_long_t		vmevents_local[NR_VM_EVENT_ITEMS];
+	atomic_long_t		vmevents_nested[NR_VM_EVENT_ITEMS];
 
 	/* memory.events */
 	atomic_long_t		memory_events[MEMCG_NR_MEMORY_EVENTS];
@@ -557,7 +557,8 @@ void unlock_page_memcg(struct page *page);
  */
 static inline unsigned long memcg_page_state(struct mem_cgroup *memcg, int idx)
 {
-	long x = atomic_long_read(&memcg->vmstats[idx]);
+	long x = atomic_long_read(&memcg->vmstats_local[idx]) +
+		 atomic_long_read(&memcg->vmstats_nested[idx]);
 #ifdef CONFIG_SMP
 	if (x < 0)
 		x = 0;
@@ -572,11 +573,7 @@ static inline unsigned long memcg_page_state(struct mem_cgroup *memcg, int idx)
 static inline unsigned long memcg_page_state_local(struct mem_cgroup *memcg,
 						   int idx)
 {
-	long x = 0;
-	int cpu;
-
-	for_each_possible_cpu(cpu)
-		x += per_cpu(memcg->vmstats_local->stat[idx], cpu);
+	long x = atomic_long_read(&memcg->vmstats_local[idx]);
 #ifdef CONFIG_SMP
 	if (x < 0)
 		x = 0;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 06d33dfc4ec4..97debc8e4120 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -695,14 +695,13 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
 	if (mem_cgroup_disabled())
 		return;
 
-	__this_cpu_add(memcg->vmstats_local->stat[idx], val);
-
 	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
 	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup *mi;
 
-		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
-			atomic_long_add(x, &mi->vmstats[idx]);
+		atomic_long_add(x, &memcg->vmstats_local[idx]);
+		for (mi = memcg; (mi = parent_mem_cgroup(mi)); )
+			atomic_long_add(x, &mi->vmstats_nested[idx]);
 		x = 0;
 	}
 	__this_cpu_write(memcg->vmstats_percpu->stat[idx], x);
@@ -777,14 +776,13 @@ void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
 	if (mem_cgroup_disabled())
 		return;
 
-	__this_cpu_add(memcg->vmstats_local->events[idx], count);
-
 	x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
 	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup *mi;
 
-		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
-			atomic_long_add(x, &mi->vmevents[idx]);
+		atomic_long_add(x, &memcg->vmevents_local[idx]);
+		for (mi = memcg; (mi = parent_mem_cgroup(mi)); )
+			atomic_long_add(x, &mi->vmevents_nested[idx]);
 		x = 0;
 	}
 	__this_cpu_write(memcg->vmstats_percpu->events[idx], x);
@@ -792,17 +790,13 @@ void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
 
 static unsigned long memcg_events(struct mem_cgroup *memcg, int event)
 {
-	return atomic_long_read(&memcg->vmevents[event]);
+	return atomic_long_read(&memcg->vmevents_local[event]) +
+	       atomic_long_read(&memcg->vmevents_nested[event]);
 }
 
 static unsigned long memcg_events_local(struct mem_cgroup *memcg, int event)
 {
-	long x = 0;
-	int cpu;
-
-	for_each_possible_cpu(cpu)
-		x += per_cpu(memcg->vmstats_local->events[event], cpu);
-	return x;
+	return atomic_long_read(&memcg->vmevents_local[event]);
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
@@ -2257,9 +2251,11 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 			long x;
 
 			x = this_cpu_xchg(memcg->vmstats_percpu->stat[i], 0);
-			if (x)
-				for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
-					atomic_long_add(x, &mi->vmstats[i]);
+			if (x) {
+				atomic_long_add(x, &memcg->vmstats_local[i]);
+				for (mi = memcg; (mi = parent_mem_cgroup(mi)); )
+					atomic_long_add(x, &mi->vmstats_nested[i]);
+			}
 
 			if (i >= NR_VM_NODE_STAT_ITEMS)
 				continue;
@@ -2280,9 +2276,11 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 			long x;
 
 			x = this_cpu_xchg(memcg->vmstats_percpu->events[i], 0);
-			if (x)
-				for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
-					atomic_long_add(x, &mi->vmevents[i]);
+			if (x) {
+				atomic_long_add(x, &memcg->vmevents_local[i]);
+				for (mi = memcg; (mi = parent_mem_cgroup(mi)); )
+					atomic_long_add(x, &mi->vmevents_nested[i]);
+			}
 		}
 	}
 
@@ -4085,7 +4083,8 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
  */
 static unsigned long memcg_exact_page_state(struct mem_cgroup *memcg, int idx)
 {
-	long x = atomic_long_read(&memcg->vmstats[idx]);
+	long x = atomic_long_read(&memcg->vmstats_local[idx]) +
+		 atomic_long_read(&memcg->vmstats_nested[idx]);
 	int cpu;
 
 	for_each_online_cpu(cpu)
@@ -4638,7 +4637,6 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
 	free_percpu(memcg->vmstats_percpu);
-	free_percpu(memcg->vmstats_local);
 	kfree(memcg);
 }
 
@@ -4667,10 +4665,6 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (memcg->id.id < 0)
 		goto fail;
 
-	memcg->vmstats_local = alloc_percpu(struct memcg_vmstats_percpu);
-	if (!memcg->vmstats_local)
-		goto fail;
-
 	memcg->vmstats_percpu = alloc_percpu(struct memcg_vmstats_percpu);
 	if (!memcg->vmstats_percpu)
 		goto fail;

