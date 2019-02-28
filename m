Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA9B5C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:31:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AF58218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:31:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="DEAtdOPW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AF58218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D29D8E0009; Thu, 28 Feb 2019 11:30:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 981EC8E0001; Thu, 28 Feb 2019 11:30:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 851428E0009; Thu, 28 Feb 2019 11:30:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4019D8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:30:52 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id c8so18015965ywa.0
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:30:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z2sRN7pljcgc3IEs1HOIZy7cq4U6Vg2axPUdXHMU2lE=;
        b=J0zkuu6O2y/gZT7A4CO4cGPf3khMyl6n1thtVWvc4RJF9dQ89eNzKbJZQuNKGymA70
         7YY5Dv23/LO72ejQjuVhnkFKkY/Be+Dz2Lq5RMQnudeChshC794YsX9hXnKON4M/PHM9
         AYAhrlUm7A62y91vKgKIPHMLM+9yHGCaw2HVH5vQiPLEQAZIZKZFhgRh6DU0m0uJD0cA
         fI2kR1KCkfo4e63paJW7C/RLY5RKvj39OmPcrMCYt+RELk2CnAsv8zr4bSDO4cZ8nNyC
         YpO7rV8JEaD3uKfv3pyqtC4OtcLr82X+ppICgSh70g2Hfmbo1N1mKfXDSO62AV8t2yCT
         5L+Q==
X-Gm-Message-State: APjAAAUaLcNgbpIShkaI/jsAC/ImR2fgsUrJ0RTbHVFTGDOrMm1WYbcd
	49mYc2Ub/hg42dP+JuKK+wYtx8v0kcKiAitVmgFxh01kQ2d7GRbo/4QDmv1Gv9oXsoNhBweZqEh
	MyWwl3lPl9FAHNvYuBy/gKBD7tr/0GzUswYnjN65hBG9JRhpslmFZ9XAjlqaFp/4H+8wxgpOnTC
	KYHgNBvdO5e5VxZHSvJG/2BXVUh0C4+MHsOLi/dFCePXHvFvnMtUBfJ0jAZ6B5ghP/smZNNC6hp
	uqpRG+zqJjX4RNv/RQ1yPqLqB2WtdakjUwSpHCxXpg48oDz5yFLxkxCUYe2zmcfWNFEMZf4qEio
	0D7VEbpYO1yaKSc2cdf+Ef8/yJ2HywD0kcy9WQRO2GYUJc/qd0tAQUXFsJCTOMqarHjOZei7U+V
	3
X-Received: by 2002:a25:4ec5:: with SMTP id c188mr189079ybb.167.1551371451969;
        Thu, 28 Feb 2019 08:30:51 -0800 (PST)
X-Received: by 2002:a25:4ec5:: with SMTP id c188mr188995ybb.167.1551371450935;
        Thu, 28 Feb 2019 08:30:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551371450; cv=none;
        d=google.com; s=arc-20160816;
        b=RfT2lPEsgHLxXQBedqsGoavHDh0vGKGEO2Pj5Ikp/s8FhaYxKqbWqBABGrfnZh9vMj
         flOK2rNvn8vssxrgsCbSRffgOr/ixg2AMPX0PVLZvsX6DTRdiWYXSdXOzwpXqTEbJa9Y
         hf3nMo2yp/aH77yp6E6QQesNtPpSZzHog0LMf+Z3363kPPygR6RKB1Z4MDr9bvIP9bA9
         egn++3Ecq2NCqKMKoy6kD+Xq6P1ybUvQjxLBgrZMZqgH9CeFpZRUpASqP3NnoeBL+GjP
         fgt6fEm28NgIPZ1/Gh0YDEj4ZPXq8upj6gSWiz1YYSoj9sU0mScvGtQnAQNeEakn7lTQ
         Pjag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Z2sRN7pljcgc3IEs1HOIZy7cq4U6Vg2axPUdXHMU2lE=;
        b=Jks2r1dVcBinrTjCSYFDayEup2AqRbYARJoz5effBWWLEoiEfK9Kp7Fsv1Q9CEKTaM
         jeNEF0xwyUi/dOO50mCyJ6JeliSfCJOuz5yGXeTNRoMTqFnRge7MAOakOw5rsgaA2YQ8
         4YRyOvTsTaGUG87ETdnkeI8G20pLmoLkE3tGCt3f9o/dC+pCUt5eviwU3bnTRZzgT/8v
         Uw6OQSnUuv+qBT5aXX7IA9TIyB94sd4BcIom+M6pZ9/fqVBws1SfzhPQve6ZtGB712Mf
         mIpwfDqhENyIOWloIFUU+OJ8xWgdFJxCBlbGP3t90QIhjkcUa7JAM/tr0AKijaa20YAh
         DvdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=DEAtdOPW;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e64sor7709929ybb.116.2019.02.28.08.30.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 08:30:50 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=DEAtdOPW;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Z2sRN7pljcgc3IEs1HOIZy7cq4U6Vg2axPUdXHMU2lE=;
        b=DEAtdOPWiEo0uOoF/kNQdPF0USk1MRsY3/VKt8/mJQFicjBli6ttNVH8RkvHkOg7wY
         ByBYfX+mPzOz9P8Dn43tEMTeRXyvR12moI751Uv096CLMEY6EjSZA+WEDf1fNGD8fukR
         hI3+VbOhIJVPNA3hgzNYNYZIqwq8/bYnBQQFyYaygDjHRN0w9ne2jfjL/rrEuW2UgLZx
         ePVPYNWL+E839Gw74yrULf1nuqJO6jmJUWceXhvNVkSQYCxL+N+qwhDGHo4wc3vE1NnZ
         uvoFdHHWn7bP1Lkywedfry5vLXo9gAO6JiqCgHzo8jp3u2/gXV2IhksYFvEo+pcToDvJ
         XK6g==
X-Google-Smtp-Source: APXvYqyNcyZYPdtjY9m+2V16Yk0I+x1bw52PllT0bSsmtOHA4mF7H5azCPmD+vCWxBwj1x3AcONkCQ==
X-Received: by 2002:a25:804a:: with SMTP id a10mr234343ybn.150.1551371450712;
        Thu, 28 Feb 2019 08:30:50 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::3:da64])
        by smtp.gmail.com with ESMTPSA id l202sm4189232ywb.72.2019.02.28.08.30.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Feb 2019 08:30:50 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 6/6] mm: memcontrol: quarantine the mem_cgroup_[node_]nr_lru_pages() API
Date: Thu, 28 Feb 2019 11:30:20 -0500
Message-Id: <20190228163020.24100-7-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190228163020.24100-1-hannes@cmpxchg.org>
References: <20190228163020.24100-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Only memcg_numa_stat_show() uses those wrappers and the lru bitmasks,
group them together.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |  5 ----
 mm/memcontrol.c        | 67 +++++++++++++++++++++++-------------------
 2 files changed, 36 insertions(+), 36 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2fd4247262e9..4f92d32c26a7 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -305,11 +305,6 @@ struct lruvec {
 #endif
 };
 
-/* Mask used at gathering information at once (see memcontrol.c) */
-#define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
-#define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
-#define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
-
 /* Isolate unmapped file */
 #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x2)
 /* Isolate for asynchronous migration */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 76f599fbbbe8..84243831b738 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -725,37 +725,6 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 	__this_cpu_add(memcg->vmstats_percpu->nr_page_events, nr_pages);
 }
 
-static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
-					   int nid, unsigned int lru_mask)
-{
-	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
-	unsigned long nr = 0;
-	enum lru_list lru;
-
-	VM_BUG_ON((unsigned)nid >= nr_node_ids);
-
-	for_each_lru(lru) {
-		if (!(BIT(lru) & lru_mask))
-			continue;
-		nr += lruvec_page_state(lruvec, NR_LRU_BASE + lru);
-	}
-	return nr;
-}
-
-static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
-			unsigned int lru_mask)
-{
-	unsigned long nr = 0;
-	enum lru_list lru;
-
-	for_each_lru(lru) {
-		if (!(BIT(lru) & lru_mask))
-			continue;
-		nr += memcg_page_state(memcg, NR_LRU_BASE + lru);
-	}
-	return nr;
-}
-
 static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 				       enum mem_cgroup_events_target target)
 {
@@ -3357,6 +3326,42 @@ static int mem_cgroup_move_charge_write(struct cgroup_subsys_state *css,
 #endif
 
 #ifdef CONFIG_NUMA
+
+#define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
+#define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
+#define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
+
+static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
+					   int nid, unsigned int lru_mask)
+{
+	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
+	unsigned long nr = 0;
+	enum lru_list lru;
+
+	VM_BUG_ON((unsigned)nid >= nr_node_ids);
+
+	for_each_lru(lru) {
+		if (!(BIT(lru) & lru_mask))
+			continue;
+		nr += lruvec_page_state(lruvec, NR_LRU_BASE + lru);
+	}
+	return nr;
+}
+
+static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
+					     unsigned int lru_mask)
+{
+	unsigned long nr = 0;
+	enum lru_list lru;
+
+	for_each_lru(lru) {
+		if (!(BIT(lru) & lru_mask))
+			continue;
+		nr += memcg_page_state(memcg, NR_LRU_BASE + lru);
+	}
+	return nr;
+}
+
 static int memcg_numa_stat_show(struct seq_file *m, void *v)
 {
 	struct numa_stat {
-- 
2.20.1

