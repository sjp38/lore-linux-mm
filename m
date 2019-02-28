Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 016B2C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:31:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A094220857
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:31:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="UszRHdt+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A094220857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56BFE8E0004; Thu, 28 Feb 2019 16:31:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51B578E0001; Thu, 28 Feb 2019 16:31:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 432168E0004; Thu, 28 Feb 2019 16:31:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDF488E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 16:30:59 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id j7so10329487wrs.20
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 13:30:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=M5qRV30ip8IGNC83XxPf/9k/uWZjwDt12qJmaexTUOA=;
        b=kmnc9iD4GcgLv5/ZnqeD6O8yqqpiJ/mhq9AQyEsC7wR/UGaPK2PML/Zn2qJtG7Var4
         ya2FQaMiQqs4HwTlyNdZBdRq1MBTNvg7BH3hXCO9nVxugD9G9XTGpn+lRgrKjMi5GPA2
         BiPhVxVFYbuwonZ1+sctvZVTyW40vDWP4XNT9FOgUj1O9BDdRL0xcBQPT+YofU3pHCld
         XdL7dCqf1iuEdPyeR7wN9MewKkGD8a5lHlqQETEmEWCEvZyjhIvQxoRNbcmsVUhGSB3f
         R56I3R7DzINr+GWh/fsyTnP/2jHplfP2WxCDUiWPtobrhxMztqTggb8B/lkf60e7lLlW
         4YdQ==
X-Gm-Message-State: AHQUAuZmuamSK3aPqxRJfb9sMPp3+Yg2f8kWw92luWZql88JfSU3+FaB
	j3U+gMJfoeiB+U2Iw1ew2ReiqAPOhfmOo4gU0bAa0dfR/jRpu8gdvhGZEMLO0Eg7F0tJszpzr6W
	37WFifKWCBBT6OprZlFXqrPVMx9P0sCeoVaLrubNwqD0gJhyJp0DAuvwP9SM3SBW0hzEgKk2d/0
	l3SnbLBXnv66SjbYgqNWyOvGHJxUtWpv+k1y4dy0jKsgjZKJCM6T6qnbamVvWUXgvc3RLW1q2JX
	USgBmoYHULZFk32Gp4UnejPEo7c3rY6mu/+3JrwtWpcwm2hROLcMQw70mLpJmSCrvmM/mSOTEqz
	Tu8xhrODzlur1zMNDfCDQehe84gyC9NSCci+8CGdLiD7oOv8yn6SeglhlSYH1ios2JwD40aNgJQ
	f
X-Received: by 2002:a1c:3b06:: with SMTP id i6mr1047058wma.55.1551389459368;
        Thu, 28 Feb 2019 13:30:59 -0800 (PST)
X-Received: by 2002:a1c:3b06:: with SMTP id i6mr1047006wma.55.1551389457285;
        Thu, 28 Feb 2019 13:30:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551389457; cv=none;
        d=google.com; s=arc-20160816;
        b=Y6coH+icfty7lWyGqBLokbwi7ccay95LZW11QNAdS/J+cFtBXKTgUlKbstS33c/F3G
         /PtNNIROVTzkQS5xCynNeCIPomydo07w1vMTqJsv/1dQdb8JKWqpYxE8gsiSVzzr4QTb
         uY7aVb1Z/orfWm9uvqHPXJDTZ1YnjDo8i+u0z+vDS7CJqrABjjV93cvPuUrN87eKdL+W
         p3/cYCr3H5rAY0FaVSLN5M/DT0FXTh7Jhn1UBcM1pk46Yd61mTMj0wG5OyAW2yTPnGVB
         kJM+z43cDuHd2hgg8fzFCDDYm5vYQ5wKOgN8rpxdk+xEAA8UKQTeLOiJGOlaWv+mYwN/
         5gcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=M5qRV30ip8IGNC83XxPf/9k/uWZjwDt12qJmaexTUOA=;
        b=O4Vbs8zsj9a6KSemQi1RBEWEZjbyysJEz48itIwbZip7RqtHu/SuC1Zm1rSCoYtX9W
         ju5JM/SPZpXAo5CEZXL6FNTk2ShMxmx0JDX/TpKE8hevFYu7U1LOt7sE1X382kbs4tz3
         w+pV/0XSarekftX7wp/4plpxJ1B2LzrWLkWEFD8cVin1M4M4nIhDnxw/KjK4av0O0cMP
         U8BDqjyKMJSpz9ZkYfWmj9f7BQu1UFQyjhQ1rZJdwRkHz3m5u8baQmiNz1qCYFUvhIQR
         ZqoC4R440PTId+RZ7AUhg44BLVXlKIK/CkHb7ZP0xvdpOqm5JYeJcS7Hy0YiEKrVpTUJ
         h9DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=UszRHdt+;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor4101246wmg.4.2019.02.28.13.30.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 13:30:57 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=UszRHdt+;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=M5qRV30ip8IGNC83XxPf/9k/uWZjwDt12qJmaexTUOA=;
        b=UszRHdt+ZAsX06/EHTKapRQhXB+mYA+Xg8GhwFOSw+o/Xz0f5Q7zbRQXuZW3X/IjSJ
         vEUydqWKMAzfaihII8BrnY/ZeGFVj6StP3MhUoaSrBzsfa4cz9NHfoclp+IWG9cEOWMP
         dHiBKeMkSk/kTr7GB9aS0VLKO1UDLJ7gecLo8=
X-Google-Smtp-Source: AHgI3IYa0u8pBtC+MPRef2jYaDEZmsw6+6IKLBdlfUXCIbRGsbNTvDAUXwcPX56YevYzCTadNMR+mg==
X-Received: by 2002:a1c:4844:: with SMTP id v65mr1175688wma.66.1551389456492;
        Thu, 28 Feb 2019 13:30:56 -0800 (PST)
Received: from localhost (host-92-23-123-154.as13285.net. [92.23.123.154])
        by smtp.gmail.com with ESMTPSA id x11sm39389596wrt.27.2019.02.28.13.30.53
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 28 Feb 2019 13:30:55 -0800 (PST)
Date: Thu, 28 Feb 2019 21:30:50 +0000
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>,
	Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: [PATCH] mm, memcg: Make scan aggression always exclude protection
Message-ID: <20190228213050.GA28211@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is an incremental improvement on the existing
memory.{low,min} relative reclaim work to base its scan pressure
calculations on how much protection is available compared to the current
usage, rather than how much the current usage is over some protection
threshold.

Previously the way that memory.low protection works is that if you are
50% over a certain baseline, you get 50% of your normal scan pressure.
This is certainly better than the previous cliff-edge behaviour, but it
can be improved even further by always considering memory under the
currently enforced protection threshold to be out of bounds. This means
that we can set relatively low memory.low thresholds for variable or
bursty workloads while still getting a reasonable level of protection,
whereas with the previous version we may still trivially hit the 100%
clamp. The previous 100% clamp is also somewhat arbitrary, whereas this
one is more concretely based on the currently enforced protection
threshold, which is likely easier to reason about.

There is also a subtle issue with the way that proportional reclaim
worked previously -- it promotes having no memory.low, since it makes
pressure higher during low reclaim. This happens because we base our
scan pressure modulation on how far memory.current is between memory.min
and memory.low, but if memory.low is unset, we only use the overage
method. In most cromulent configurations, this then means that we end up
with *more* pressure than with no memory.low at all when we're in low
reclaim, which is not really very usable or expected.

With this patch, memory.low and memory.min affect reclaim pressure in a
more understandable and composable way. For example, from a user
standpoint, "protected" memory now remains untouchable from a reclaim
aggression standpoint, and users can also have more confidence that
bursty workloads will still receive some amount of guaranteed
protection.

Signed-off-by: Chris Down <chris@chrisdown.name>
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
 include/linux/memcontrol.h | 25 ++++++++--------
 mm/vmscan.c                | 61 +++++++++++++-------------------------
 2 files changed, 32 insertions(+), 54 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 534267947664..2799008c1f88 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -333,17 +333,17 @@ static inline bool mem_cgroup_disabled(void)
 	return !cgroup_subsys_enabled(memory_cgrp_subsys);
 }
 
-static inline void mem_cgroup_protection(struct mem_cgroup *memcg,
-					 unsigned long *min, unsigned long *low)
+static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg,
+						  bool in_low_reclaim)
 {
-	if (mem_cgroup_disabled()) {
-		*min = 0;
-		*low = 0;
-		return;
-	}
+	if (mem_cgroup_disabled())
+		return 0;
+
+	if (in_low_reclaim)
+		return READ_ONCE(memcg->memory.emin);
 
-	*min = READ_ONCE(memcg->memory.emin);
-	*low = READ_ONCE(memcg->memory.elow);
+	return max(READ_ONCE(memcg->memory.emin),
+		   READ_ONCE(memcg->memory.elow));
 }
 
 enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
@@ -845,11 +845,10 @@ static inline void memcg_memory_event_mm(struct mm_struct *mm,
 {
 }
 
-static inline void mem_cgroup_protection(struct mem_cgroup *memcg,
-					 unsigned long *min, unsigned long *low)
+static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg,
+						  bool in_low_reclaim)
 {
-	*min = 0;
-	*low = 0;
+	return 0;
 }
 
 static inline enum mem_cgroup_protection mem_cgroup_protected(
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ac4806f0f332..920a9c3ee792 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2414,12 +2414,13 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		int file = is_file_lru(lru);
 		unsigned long lruvec_size;
 		unsigned long scan;
-		unsigned long min, low;
+		unsigned long protection;
 
 		lruvec_size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
-		mem_cgroup_protection(memcg, &min, &low);
+		protection = mem_cgroup_protection(memcg,
+						   sc->memcg_low_reclaim);
 
-		if (min || low) {
+		if (protection) {
 			/*
 			 * Scale a cgroup's reclaim pressure by proportioning
 			 * its current usage to its memory.low or memory.min
@@ -2432,13 +2433,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			 * setting extremely liberal protection thresholds. It
 			 * also means we simply get no protection at all if we
 			 * set it too low, which is not ideal.
-			 */
-			unsigned long cgroup_size = mem_cgroup_size(memcg);
-
-			/*
-			 * If there is any protection in place, we adjust scan
-			 * pressure in proportion to how much a group's current
-			 * usage exceeds that, in percent.
+			 *
+			 * If there is any protection in place, we reduce scan
+			 * pressure by how much of the total memory used is
+			 * within protection thresholds.
 			 *
 			 * There is one special case: in the first reclaim pass,
 			 * we skip over all groups that are within their low
@@ -2448,43 +2446,24 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			 * ideally want to honor how well-behaved groups are in
 			 * that case instead of simply punishing them all
 			 * equally. As such, we reclaim them based on how much
-			 * of their best-effort protection they are using. Usage
-			 * below memory.min is excluded from consideration when
-			 * calculating utilisation, as it isn't ever
-			 * reclaimable, so it might as well not exist for our
-			 * purposes.
+			 * memory they are using, reducing the scan pressure
+			 * again by how much of the total memory used is under
+			 * hard protection.
 			 */
-			if (sc->memcg_low_reclaim && low > min) {
-				/*
-				 * Reclaim according to utilisation between min
-				 * and low
-				 */
-				scan = lruvec_size * (cgroup_size - min) /
-					(low - min);
-			} else {
-				/* Reclaim according to protection overage */
-				scan = lruvec_size * cgroup_size /
-					max(min, low) - lruvec_size;
-			}
+			unsigned long cgroup_size = mem_cgroup_size(memcg);
+
+			/* Avoid TOCTOU with earlier protection check */
+			cgroup_size = max(cgroup_size, protection);
+
+			scan = lruvec_size - lruvec_size * protection /
+				cgroup_size;
 
 			/*
-			 * Don't allow the scan target to exceed the lruvec
-			 * size, which otherwise could happen if we have >200%
-			 * overage in the normal case, or >100% overage when
-			 * sc->memcg_low_reclaim is set.
-			 *
-			 * This is important because other cgroups without
-			 * memory.low have their scan target initially set to
-			 * their lruvec size, so allowing values >100% of the
-			 * lruvec size here could result in penalising cgroups
-			 * with memory.low set even *more* than their peers in
-			 * some cases in the case of large overages.
-			 *
-			 * Also, minimally target SWAP_CLUSTER_MAX pages to keep
+			 * Minimally target SWAP_CLUSTER_MAX pages to keep
 			 * reclaim moving forwards, avoiding decremeting
 			 * sc->priority further than desirable.
 			 */
-			scan = clamp(scan, SWAP_CLUSTER_MAX, lruvec_size);
+			scan = max(scan, SWAP_CLUSTER_MAX);
 		} else {
 			scan = lruvec_size;
 		}
-- 
2.21.0

