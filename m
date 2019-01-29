Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7D7BC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:25:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C26021873
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:25:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="McgI8bfv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C26021873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40D448E0003; Tue, 29 Jan 2019 13:25:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BC318E0001; Tue, 29 Jan 2019 13:25:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 285238E0003; Tue, 29 Jan 2019 13:25:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB2BB8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:25:18 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id t205so11870678ywa.10
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:25:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=UEWYKVrLyoeo+EHNXuBgk1+ZBNjf1UAZ3jeHlECOcAQ=;
        b=SD5wz0evBqL5VWxE+kj4oneKsrXZlSUdKuCC3DLZl+Xyzj9rSduSDZ6KsUy1jaUc6w
         ujRfdBqHLUdMjHg/EqhdN1iETIK2v5G71QDsC8n8WU7t9uT8YlzxF8Jm6ROdrQBsUgke
         99luSINE906vjr8qXFrfHq/0uSx7ZpDtblS4eZBT/fjBNyBMUHgG7PGfVxoiPoY/wq5O
         H7jwMa3cMZuai/DkONnrVW/4rCJRIwZe1kMPuAiDoeIf6f9y15q0LUxWCdqUAwe/YxH2
         +SSOkpOVqwvJ2WnuJK0sPCJE1v6NZ6hgCXawU3pxSOZ7DGs7u/nu1VY5krH1Cd00jwml
         l1ig==
X-Gm-Message-State: AJcUukcZGfLG5xbbTCizQSkdKRedgq6Ce/jDBj9HnhE1TL/XSsKF/GSI
	EgNFhE5d3v8rCd+IF7aSjXMh8dG/T3LegL4yrNCgYnCb3d41h7izNSzKutr38OQNUhvfnDnt8+B
	OhpJm2vw/748nyePYsx7bDGx1vg33F+mT25XsAjCWTxe1G/1KZo5q4NXIFz6ogr/9z1gn5mG7As
	sdGKpoNnbFOJydpfCn8gomkMII+f+hsMhbIG1dWgqVdByySGVYbzLfKh7ts7kEZ8LFCHcCEB4V0
	JhEIxErdx4CDclVxWyCtCS6rhlTh0i/gPPNw+57bXWl2E+eT6BPRlt1FhloJJsTUtxoDrSU/9Jw
	VvzQv0kxF8z8ssyLiJ3qYFvrb3dBCzVSwuwR+3aZHixaLR2cfif/XVpeFOUr1rMzF1hzcmDgjwR
	J
X-Received: by 2002:a81:6c90:: with SMTP id h138mr25648693ywc.379.1548786318639;
        Tue, 29 Jan 2019 10:25:18 -0800 (PST)
X-Received: by 2002:a81:6c90:: with SMTP id h138mr25648655ywc.379.1548786317883;
        Tue, 29 Jan 2019 10:25:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548786317; cv=none;
        d=google.com; s=arc-20160816;
        b=hryAdX0zOP3np1sfKorOX7KJHHUzEHIbJTZyi7iXqDBj0lr/agUMBts20vB0Frx8s/
         dlvnpivxf/HYZqgV/7yM8k19+RWabiNm25RHYmZOBpJdQV4qpURNibOdVdkjFeCfqth6
         uEnAh0KOMhEkiOXo6dqevlO3q15uYsSGtsh2okTaTattttNTpTY/yqWYX68mlpA7KHRl
         k1oSIMnOXwMpmc9RA75xTlWMHgiuuY4K5Iv4Cjwel+PUmLDut7agfVw58qHIKhVUkT+u
         AiEoxnxeCRFfI77NYG3j5xM1N+w5MAFVJlsXtQhA2DwQUZedOdZf/YU1fyGDbLmRhEuI
         p+1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=UEWYKVrLyoeo+EHNXuBgk1+ZBNjf1UAZ3jeHlECOcAQ=;
        b=TTsISRHLq+kGGx6upVXtJt6QwoXDaOsxujB6xwT72B0j3FFL1I+7SSNb6YxJJ4gu+D
         jpCSRYU0vFZp/M3Ip2u9s042tGoMN3M8EVG6buMBhxB11wHLNe30TO5SzRmzaHWLSwYG
         FjgaEMpWkKOIzt9VGrXWOwp44TXMt/WJ4DwbQBT8+sAI7LwapyDW0HzEyDrt6dij1Bkg
         6ngfGODEuWgjFf4kGUOzFkmp4T2tDLZtwzmiYKAL2hY4OzPNQ1BP76Dg3ls4HAF0GXds
         VAxJR4DMPmRzz/nXsRqnCagVXwAZ8dZiZ06rIn90KQnqj+9JVztnge8qypTcj3w/y+i6
         +urw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=McgI8bfv;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t4sor6414274ywa.78.2019.01.29.10.25.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 10:25:17 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=McgI8bfv;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=UEWYKVrLyoeo+EHNXuBgk1+ZBNjf1UAZ3jeHlECOcAQ=;
        b=McgI8bfvdTRAl+2DLzBET3/Zjz/BtOczncjJHHBGvJ3GOUy9g7c49IqGOr3yNuniV0
         oqcOkePmToWyG86MaU9XxkXYumP42ZRTkHKM7Smar0unOFX53UAIgM7g+/0Poxdi7oI1
         PzErKCQtFsTmSap0QpdD/5nml7gMUDzxJk/Bs=
X-Google-Smtp-Source: ALg8bN577D3vsrWrco8DYQ5GHfXNdfHyNspCRtVPvoceQad/0oDbiZflNlI4aul0HsoG3q7bwTR0JA==
X-Received: by 2002:a81:6246:: with SMTP id w67mr26154697ywb.60.1548786317308;
        Tue, 29 Jan 2019 10:25:17 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::6:f1fc])
        by smtp.gmail.com with ESMTPSA id k62sm15883985ywk.84.2019.01.29.10.25.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 29 Jan 2019 10:25:16 -0800 (PST)
Date: Tue, 29 Jan 2019 13:25:16 -0500
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>,
	Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: [PATCH] mm: Make memory.emin the baseline for utilisation
 determination
Message-ID: <20190129182516.GA1834@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Roman points out that when when we do the low reclaim pass, we scale the
reclaim pressure relative to position between 0 and the maximum
protection threshold.

However, if the maximum protection is based on memory.elow, and
memory.emin is above zero, this means we still may get binary behaviour
on second-pass low reclaim. This is because we scale starting at 0, not
starting at memory.emin, and since we don't scan at all below emin, we
end up with cliff behaviour.

This should be a fairly uncommon case since usually we don't go into the
second pass, but it makes sense to scale our low reclaim pressure
starting at emin.

You can test this by catting two large sparse files, one in a cgroup
with emin set to some moderate size compared to physical RAM, and
another cgroup without any emin. In both cgroups, set an elow larger
than 50% of physical RAM. The one with emin will have less page
scanning, as reclaim pressure is lower.

Signed-off-by: Chris Down <chris@chrisdown.name>
Suggested-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>
Cc: Dennis Zhou <dennis@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 include/linux/memcontrol.h |  6 +++--
 mm/vmscan.c                | 55 +++++++++++++++++++++++---------------
 2 files changed, 37 insertions(+), 24 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 290cfbfd60cd..89e460f9612f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -333,9 +333,11 @@ static inline bool mem_cgroup_disabled(void)
 	return !cgroup_subsys_enabled(memory_cgrp_subsys);
 }
 
-static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg)
+static inline void mem_cgroup_protection(struct mem_cgroup *memcg,
+					 unsigned long *min, unsigned long *low)
 {
-	return max(READ_ONCE(memcg->memory.emin), READ_ONCE(memcg->memory.elow));
+	*min = READ_ONCE(memcg->memory.emin);
+	*low = READ_ONCE(memcg->memory.elow);
 }
 
 enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 549251818605..f7c4ab39d5d0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2447,12 +2447,12 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		int file = is_file_lru(lru);
 		unsigned long lruvec_size;
 		unsigned long scan;
-		unsigned long protection;
+		unsigned long min, low;
 
 		lruvec_size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
-		protection = mem_cgroup_protection(memcg);
+		mem_cgroup_protection(memcg, &min, &low);
 
-		if (protection > 0) {
+		if (min || low) {
 			/*
 			 * Scale a cgroup's reclaim pressure by proportioning
 			 * its current usage to its memory.low or memory.min
@@ -2467,28 +2467,38 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			 * set it too low, which is not ideal.
 			 */
 			unsigned long cgroup_size = mem_cgroup_size(memcg);
-			unsigned long baseline = 0;
 
 			/*
-			 * During the reclaim first pass, we only consider
-			 * cgroups in excess of their protection setting, but if
-			 * that doesn't produce free pages, we come back for a
-			 * second pass where we reclaim from all groups.
+			 * If there is any protection in place, we adjust scan
+			 * pressure in proportion to how much a group's current
+			 * usage exceeds that, in percent.
 			 *
-			 * To maintain fairness in both cases, the first pass
-			 * targets groups in proportion to their overage, and
-			 * the second pass targets groups in proportion to their
-			 * protection utilization.
-			 *
-			 * So on the first pass, a group whose size is 130% of
-			 * its protection will be targeted at 30% of its size.
-			 * On the second pass, a group whose size is at 40% of
-			 * its protection will be
-			 * targeted at 40% of its size.
+			 * There is one special case: in the first reclaim pass,
+			 * we skip over all groups that are within their low
+			 * protection. If that fails to reclaim enough pages to
+			 * satisfy the reclaim goal, we come back and override
+			 * the best-effort low protection. However, we still
+			 * ideally want to honor how well-behaved groups are in
+			 * that case instead of simply punishing them all
+			 * equally. As such, we reclaim them based on how much
+			 * of their best-effort protection they are using. Usage
+			 * below memory.min is excluded from consideration when
+			 * calculating utilisation, as it isn't ever
+			 * reclaimable, so it might as well not exist for our
+			 * purposes.
 			 */
-			if (!sc->memcg_low_reclaim)
-				baseline = lruvec_size;
-			scan = lruvec_size * cgroup_size / protection - baseline;
+			if (sc->memcg_low_reclaim && low > min) {
+				/*
+				 * Reclaim according to utilisation between min
+				 * and low
+				 */
+				scan = lruvec_size * (cgroup_size - min) /
+					(low - min);
+			} else {
+				/* Reclaim according to protection overage */
+				scan = lruvec_size * cgroup_size /
+					max(min, low) - lruvec_size;
+			}
 
 			/*
 			 * Don't allow the scan target to exceed the lruvec
@@ -2504,7 +2514,8 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			 * some cases in the case of large overages.
 			 *
 			 * Also, minimally target SWAP_CLUSTER_MAX pages to keep
-			 * reclaim moving forwards.
+			 * reclaim moving forwards, avoiding decremeting
+			 * sc->priority further than desirable.
 			 */
 			scan = clamp(scan, SWAP_CLUSTER_MAX, lruvec_size);
 		} else {
-- 
2.20.1

