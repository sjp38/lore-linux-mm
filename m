Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AA6FC282DE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:15:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30023218A3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:15:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="ILqDJJHk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30023218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8336E6B026B; Fri, 12 Apr 2019 11:15:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E7B26B026C; Fri, 12 Apr 2019 11:15:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63AB96B026D; Fri, 12 Apr 2019 11:15:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39E176B026B
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:15:25 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z24so8992295qto.7
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:15:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PRTUaF678C5HIzdBjBIPSEr+aHrXt+S0IRBXo9MeAws=;
        b=tH1VaIsWfd20kC4otvaAJRRqMPzp1KBuWC1BPL+0WAra/Bpm9q3iCPx3TJWuZQWAYP
         BvZG/2R8Pqm0owb4xGtPMO/3tW0YN7MROpX+6ahUdMWWrWcUvWQE9sH1CVrp1khLhWys
         ORNjTSRZbpq8ZC8Y5+YAdpQlg7gaC9OhLRbVAt3LCZkDHzneQFaqJnTibYJcXfmgyEqx
         GMjKALhHjct+SBW2f8EZS+zQEnwGRHYWXe6lZdm1xu0EoxfPVw8LjqVsSQIuvwkrlgJp
         Q313zenrwvRUqKU9f7n/vKJ6YgPaj/TQ4s0xH4MZomfXxIq2uXkKMLRVmpjBnBUuwxiM
         b7wg==
X-Gm-Message-State: APjAAAWPCPP8D0MfVWac5D5P58Kt6qMtqksLwEo2uDN/siXIKiCSCCMB
	t3PQD6a+pj2XX3LHdXLKnYEkcwMr75ajJJHlJuch9Wwtt93mczA1gOfBohaURDWLkk5FI4IZ0YL
	XfnsfaobvqBaRxYSf6qPFeSm/u1SPal/giGXZ9PajcYWY6PR0aAg9GNXxePXAKDRO2Q==
X-Received: by 2002:ac8:72c4:: with SMTP id o4mr47680823qtp.88.1555082124930;
        Fri, 12 Apr 2019 08:15:24 -0700 (PDT)
X-Received: by 2002:ac8:72c4:: with SMTP id o4mr47680708qtp.88.1555082123645;
        Fri, 12 Apr 2019 08:15:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555082123; cv=none;
        d=google.com; s=arc-20160816;
        b=gkT1D5dMqCZp/bSyL9kLGSsd/I35rTVbJud5Qy5zoAy4gOg+LRvPxsYamdou6Kje18
         yHEOkM3cIV9IuyyFJGiGHRd/vu0B87hdTK2Xkl+jdgslcGnq0w7kizWS5fUsQx/eGHnQ
         lX5c1bBGrLiaHRto0FMnS/nh9vq0xlWdbxc4+ab7qiBWoE4h6XkQGSTotcd0R/y+uv32
         ZNsWWtZOaiddRNnhUcXjuZk1aACKLXOMCI7RPQfZDCaTwOa0hDv6NQ/xzEuCwVqcP/FR
         L5+WqMAn2mOg6R164E4Lw0oCi69UXw8mrPpNZy9hkFDndFNyoOnEoPcRCJ+gIfRhjtjU
         ug9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=PRTUaF678C5HIzdBjBIPSEr+aHrXt+S0IRBXo9MeAws=;
        b=G0ND7KzKA8KxrCXpmqiE5+eB5+7oTY1MTjGSvBhamBiy3dX7tK2XqSGjh8uFmSsdfk
         BeUBiQ+xG2RemFnF/Eexk1MDKP2IxIBxAaAUrEcN1Gp6cscWSjtn9MktlHaTRsj8Su6I
         tMhjd9F4novqBAC+b5X+6ABr+PuI0YzkNw9wzZ5+YsgoLh6HMr3xjAc/hNo1u58FHfjB
         7NDAhhWPafzyMs1O0fnz90ms8aYmtH4ed/CEzdu610o0BtKdkvP5dHLY+rg6GAHtjpSV
         sVFDeVoTv9C55VH36EpoWjNZ1wbGhxO7xAMF+zfoCdpRnkdYqMGWx5nkH434p59moiw0
         5rvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ILqDJJHk;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d7sor25525040qki.7.2019.04.12.08.15.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 08:15:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ILqDJJHk;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=PRTUaF678C5HIzdBjBIPSEr+aHrXt+S0IRBXo9MeAws=;
        b=ILqDJJHkPZz+eoKOvEr4x0/kgN/IBd0kCMfXy7rPlSfiWsGSmDI6DjyrVYmzgB/KgJ
         o/a/0Y1afe7RfkMShz9vwu+3rR2TVnT91QuwBCSOdI5Q13s8C0dbu9xj3PjV4IRsSngj
         +xYSZhSKjRK1gaqwdDvmiaOzBR7OeV2vcxlhnLdTeOQSTfrRfivBEbyYNTxVKLSnp+CB
         zjIsSHe6XO4EZuIEVpRXex1t0Chpz6YqKKdL/mvxmkyCEQpYZDkvyznHQ6p01d47B6DJ
         dw6CszzzPqXfI2qk2mij7G5QVuKJIXQGJm+0/35AP73eRIX1DEbeAooXRbZCZUFLrkSP
         7iKg==
X-Google-Smtp-Source: APXvYqysIlg0nPC2TAIyhyZGpUry9fm9BHzZ/cusQuSfW34/ihXJ8nq+qmczg5uW0MTGOcK5jfgKsQ==
X-Received: by 2002:a37:4f95:: with SMTP id d143mr45617065qkb.253.1555082119044;
        Fri, 12 Apr 2019 08:15:19 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id x24sm13094296qtm.65.2019.04.12.08.15.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 08:15:18 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 2/4] mm: memcontrol: move stat/event counting functions out-of-line
Date: Fri, 12 Apr 2019 11:15:05 -0400
Message-Id: <20190412151507.2769-3-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190412151507.2769-1-hannes@cmpxchg.org>
References: <20190412151507.2769-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These are getting too big to be inlined in every callsite. They were
stolen from vmstat.c, which already out-of-lines them, and they have
only been growing since. The callsites aren't that hot, either.

Move __mod_memcg_state()
     __mod_lruvec_state() and
     __count_memcg_events() out of line and add kerneldoc comments.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 62 +++---------------------------
 mm/memcontrol.c            | 79 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 84 insertions(+), 57 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 139be7d44c29..cae7d1b11eea 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -580,22 +580,7 @@ static inline unsigned long memcg_page_state_local(struct mem_cgroup *memcg,
 	return x;
 }
 
-/* idx can be of type enum memcg_stat_item or node_stat_item */
-static inline void __mod_memcg_state(struct mem_cgroup *memcg,
-				     int idx, int val)
-{
-	long x;
-
-	if (mem_cgroup_disabled())
-		return;
-
-	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
-	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &memcg->vmstats[idx]);
-		x = 0;
-	}
-	__this_cpu_write(memcg->vmstats_percpu->stat[idx], x);
-}
+void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val);
 
 /* idx can be of type enum memcg_stat_item or node_stat_item */
 static inline void mod_memcg_state(struct mem_cgroup *memcg,
@@ -657,31 +642,8 @@ static inline unsigned long lruvec_page_state_local(struct lruvec *lruvec,
 	return x;
 }
 
-static inline void __mod_lruvec_state(struct lruvec *lruvec,
-				      enum node_stat_item idx, int val)
-{
-	struct mem_cgroup_per_node *pn;
-	long x;
-
-	/* Update node */
-	__mod_node_page_state(lruvec_pgdat(lruvec), idx, val);
-
-	if (mem_cgroup_disabled())
-		return;
-
-	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
-
-	/* Update memcg */
-	__mod_memcg_state(pn->memcg, idx, val);
-
-	/* Update lruvec */
-	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
-	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &pn->lruvec_stat[idx]);
-		x = 0;
-	}
-	__this_cpu_write(pn->lruvec_stat_cpu->count[idx], x);
-}
+void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
+			int val);
 
 static inline void mod_lruvec_state(struct lruvec *lruvec,
 				    enum node_stat_item idx, int val)
@@ -723,22 +685,8 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
 
-static inline void __count_memcg_events(struct mem_cgroup *memcg,
-					enum vm_event_item idx,
-					unsigned long count)
-{
-	unsigned long x;
-
-	if (mem_cgroup_disabled())
-		return;
-
-	x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
-	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &memcg->vmevents[idx]);
-		x = 0;
-	}
-	__this_cpu_write(memcg->vmstats_percpu->events[idx], x);
-}
+void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
+			  unsigned long count);
 
 static inline void count_memcg_events(struct mem_cgroup *memcg,
 				      enum vm_event_item idx,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 109608b8091f..3535270ebeec 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -687,6 +687,85 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_node *mctz)
 	return mz;
 }
 
+/**
+ * __mod_memcg_state - update cgroup memory statistics
+ * @memcg: the memory cgroup
+ * @idx: the stat item - can be enum memcg_stat_item or enum node_stat_item
+ * @val: delta to add to the counter, can be negative
+ */
+void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
+{
+	long x;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
+	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
+		atomic_long_add(x, &memcg->vmstats[idx]);
+		x = 0;
+	}
+	__this_cpu_write(memcg->vmstats_percpu->stat[idx], x);
+}
+
+/**
+ * __mod_lruvec_state - update lruvec memory statistics
+ * @lruvec: the lruvec
+ * @idx: the stat item
+ * @val: delta to add to the counter, can be negative
+ *
+ * The lruvec is the intersection of the NUMA node and a cgroup. This
+ * function updates the all three counters that are affected by a
+ * change of state at this level: per-node, per-cgroup, per-lruvec.
+ */
+void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
+			int val)
+{
+	struct mem_cgroup_per_node *pn;
+	long x;
+
+	/* Update node */
+	__mod_node_page_state(lruvec_pgdat(lruvec), idx, val);
+
+	if (mem_cgroup_disabled())
+		return;
+
+	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
+
+	/* Update memcg */
+	__mod_memcg_state(pn->memcg, idx, val);
+
+	/* Update lruvec */
+	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
+	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
+		atomic_long_add(x, &pn->lruvec_stat[idx]);
+		x = 0;
+	}
+	__this_cpu_write(pn->lruvec_stat_cpu->count[idx], x);
+}
+
+/**
+ * __count_memcg_events - account VM events in a cgroup
+ * @memcg: the memory cgroup
+ * @idx: the event item
+ * @count: the number of events that occured
+ */
+void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
+			  unsigned long count)
+{
+	unsigned long x;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
+	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
+		atomic_long_add(x, &memcg->vmevents[idx]);
+		x = 0;
+	}
+	__this_cpu_write(memcg->vmstats_percpu->events[idx], x);
+}
+
 static unsigned long memcg_events_local(struct mem_cgroup *memcg,
 					int event)
 {
-- 
2.21.0

