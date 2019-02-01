Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6A98C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:18:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9437120870
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:18:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="b3f8X3vk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9437120870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B45D8E0002; Fri,  1 Feb 2019 00:18:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 262448E0001; Fri,  1 Feb 2019 00:18:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 153108E0002; Fri,  1 Feb 2019 00:18:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE4DE8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 00:18:13 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k90so6591473qte.0
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 21:18:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:in-reply-to:user-agent;
        bh=bVOuN27+dQpcYjyoBP7qcpwIAC0k6Nxrf6LI5xH+LA4=;
        b=Iv6QUIIbAzb/+0lv+3g5LPksaVUwC741eyy3kUawlqfWuJw4cjBtdvi8KadOZ+b+JZ
         VtPcTda3mhQxvFZi+ryMTjD9DDO6j7Z2jvwTrK+ldhgNsuBQvj7SWT3dbzlGhqGetSc8
         eYeOsYF1Vk5VIkguUrPMZaa53lvhTuqqEP7XhJpG90stB1w9iM0k8SBWz3Pm7e06J1Zh
         I17tVdMrHDEZyYtkbDYXdX9XBQMy/N0RnBgrGDnVpiZVbvaLI5s2mdPMQveMxy2eYnow
         v+JzP0EZMeKNQT9fUSY4Vdjh4UH+ZVKC/PtPPTv2wNhMcxvAnZ7DEH0ajjACrfw1EpjQ
         Y2DQ==
X-Gm-Message-State: AJcUukf0K+aezSRz2pUk6YzhMGILxurii+wrZUzZp/vAQxS5X3m4T51B
	O6hKEpPI3EQCcDC95DYU2Nr0zpvtjY3LHEeqWBO/8sAkXaGOFdUgiWe1DI2d3hJqKebd1z/qEhF
	7YSeuPPETHZnjEqmJV739yTaddo4kFsqPazdPcHztXZr3XumGH61pGRLMdY86Hhzn2VbA2NQOYN
	/fjN4qYoG1j0iXamV13MNSx5BzCHP5lL/d/P+1RWHOXkKPbS05pqK/XH7tztHp4TFOWocb7MHar
	VKID+NQaIUqA5UwZbKlv9NzIJLkt8i6XCpXfOQtYz814spKntZJOJ7F3D48ZgJU9pIthkiyubcW
	UMPdxZqMX7nAnwEM5kDsrRACyEaStSPyye4SEoh1I+mou0YWsK7MWtDdPG6tH8p7VEHveTGUB3J
	/
X-Received: by 2002:a37:ea0a:: with SMTP id t10mr33614726qkj.273.1548998293624;
        Thu, 31 Jan 2019 21:18:13 -0800 (PST)
X-Received: by 2002:a37:ea0a:: with SMTP id t10mr33614697qkj.273.1548998292914;
        Thu, 31 Jan 2019 21:18:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548998292; cv=none;
        d=google.com; s=arc-20160816;
        b=dvBh9b1HhNSSITvsf0/IY4/TUmzBDDRXZZ6NI3fHZXuvysAEskKj16i4brHWmGKS2h
         r+cMnDB5Py1p80w86fD9Fqbhgnvz636yXE6tE8ZSlrj8XnOqAAiHnQC1ElAqOnzrylrV
         dm/mu0fqkIYKyn9ESK+LaAL0zQhXtLuZ05LX9rGm79TR1Uwt3DvhLuwxdLHX5/P1tiHF
         zLcV71jCMzAN6iKSU0TgIFx0AchyW+DFDaDBcdg7Y1d6E47wcaHy3OKJ8Smx3rPyJpXi
         tU3mPz5QgFVcxiVYgJM47iLXYyLH1V7rRI/em2SBpSptXY+tnXHVmpn8wB/X0/7C9TB3
         CIJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=bVOuN27+dQpcYjyoBP7qcpwIAC0k6Nxrf6LI5xH+LA4=;
        b=Vjcn9nsR1yBLq0cE+QpP2okGP7o9/sd2D+yHjeaCOGq0u/b1PqZ1/QigDVNaxA0QTB
         15a7lvWSyyJzs52U6OL18VJTUJ/TlTm47NkUVzcqq7CN8+mNnjzMpsreOJqWPPGZtsQ/
         MYNrE2Aoge16sz3aL+Xh2XzykCs1iBeOdyjonz1NKvvdWNv/PQYh8RM+TQK2q+dhxpcf
         GCeRUNXnt1+5jLLoKYrXKlwdzP0YX5NcF+EZv1ohrMd9lbNZAQpFghvEWxqaHnAEPDe8
         JOWEee1HTx11Euw5zW5xFY2S1Roi85rCez6g9K30AwTcst+wZMea1q1GPQxduIdgnkWk
         6auA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=b3f8X3vk;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor8157742qtb.53.2019.01.31.21.18.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 21:18:12 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=b3f8X3vk;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bVOuN27+dQpcYjyoBP7qcpwIAC0k6Nxrf6LI5xH+LA4=;
        b=b3f8X3vkGREfwb8cgrZL68JTIwv9yiDjla7EXDA9MgwWVXeSsFHmJHsi3G7GDankY5
         T57lz9NGHBL4NeJ4dlqbpYJrsoEI7+Uvw2GlbxDI3rbmFQ64Yj2KIQZr7rEORjlCsHTj
         efE4MLs4dUIptQZ4a/SYpQh36Wod7GTl8OAbk=
X-Google-Smtp-Source: ALg8bN5ysSl/ioCr4AIRCKDjPjIJTkc87tOvKrQfy+6635gtKpl8vT/9tnbpYJcsNa/DPIYglsoRWg==
X-Received: by 2002:ac8:4a10:: with SMTP id x16mr38505487qtq.164.1548998292366;
        Thu, 31 Jan 2019 21:18:12 -0800 (PST)
Received: from localhost (rrcs-108-176-24-99.nyc.biz.rr.com. [108.176.24.99])
        by smtp.gmail.com with ESMTPSA id p8sm6253906qtk.70.2019.01.31.21.18.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 21:18:11 -0800 (PST)
Date: Fri, 1 Feb 2019 00:18:10 -0500
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>,
	Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: [PATCH v4] mm: Make memory.emin the baseline for utilisation
 determination
Message-ID: <20190201051810.GA18895@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129191525.GB10430@chrisdown.name>
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
 include/linux/memcontrol.h | 19 ++++++++-----
 mm/vmscan.c                | 55 +++++++++++++++++++++++---------------
 2 files changed, 46 insertions(+), 28 deletions(-)

Rebase on top of and apply the same idea as what was applied to handle 
cgroup_memory=disable properly for the original proportional patch 
(20190201045711.GA18302@chrisdown.name, "mm, memcg: Handle 
cgroup_disable=memory when getting memcg protection").

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 49742489aa56..0fcbea7ad0c8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -333,12 +333,17 @@ static inline bool mem_cgroup_disabled(void)
 	return !cgroup_subsys_enabled(memory_cgrp_subsys);
 }
 
-static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg)
+static inline void mem_cgroup_protection(struct mem_cgroup *memcg,
+					 unsigned long *min, unsigned long *low)
 {
-	if (mem_cgroup_disabled())
-		return 0;
+	if (mem_cgroup_disabled()) {
+		*min = 0;
+		*low = 0;
+		return;
+	}
 
-	return max(READ_ONCE(memcg->memory.emin), READ_ONCE(memcg->memory.elow));
+	*min = READ_ONCE(memcg->memory.emin);
+	*low = READ_ONCE(memcg->memory.elow);
 }
 
 enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
@@ -829,9 +834,11 @@ static inline void memcg_memory_event_mm(struct mm_struct *mm,
 {
 }
 
-static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg)
+static inline void mem_cgroup_protection(struct mem_cgroup *memcg,
+					 unsigned long *min, unsigned long *low)
 {
-	return 0;
+	*min = 0;
+	*low = 0;
 }
 
 static inline enum mem_cgroup_protection mem_cgroup_protected(
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

