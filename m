Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EB62C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:30:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A224218CD
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:30:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="ZAGBYz8G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A224218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 452BC8E0005; Thu, 28 Feb 2019 11:30:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 404678E0001; Thu, 28 Feb 2019 11:30:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A9228E0005; Thu, 28 Feb 2019 11:30:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id E51848E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:30:44 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id j64so17725167ywg.22
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:30:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NxReYuZN9DV/fcdnYYWinsazWkVL2jKBNqgEJlRIVkI=;
        b=CgqokhozVEYYvN6ueegUBVUp29pkahAiGCcM2/wYoZRY/VgeaiQHM+68dAXQA/OqQO
         Qtr+dnifPVXDBVJn79Uq/cBlRkaCVdqJe4fcSRE6EqxGCOTwpf7GQgwdLcsHbw/uMexP
         xDItZ0sgO4INbUcRRo3qM8y0CH3hyz1Co14zUSlvaOsUAo2v+rtJ8kUAh94fYEkBmzBJ
         wbwa+Nr5U1R+i7chvYGGiH/ANHTcikPFoh+SMRlzk4aiDp2BlC3UwgqZVS+HrKYhVEXA
         FjxoJj1i3TZrUWUbD1KL9oIzVt8xrGa6/3E3cTlDCO9KElK3ZltWifE+1yz6NlyS9VH2
         WhvA==
X-Gm-Message-State: AHQUAuYR7le4z2LHip2TDXZcUXPvlNz5ASiCy/NAZFXWGskIB0XbeCnN
	IJlIJXgV/wvFuB3melXJZi6f92vANfJm74jRIUjfXizneO5QI8x+r4iPlPI7qvms16DyXw5QjGe
	SPZxKRnU+WO5d6s/R/rDWbdDT4Zs1KeiXsamRvMFbJ967oLTlT0F3BDINzajFi/XWt8Mv+e9HNr
	sJXMm5n9witpgbMIa4MwDHw60AwUfGsvi8oxNzbnujH+WL7uGb58eRMCRzFFzj/szkKw21qae26
	Atzj9NUou8xRdzm10SJ0wC9lVuRUpngdR5KIfXN/NGj0NHYu2f+36i8GxingDOIsfQYHmRdaDyk
	aILqHcbvOCP0+O42NtFv9Ew/2sgKrY8ddHVya8EV7QW8qMfxA3VNFApp+lJDLFJkzux5uGNlCK4
	W
X-Received: by 2002:a81:1d58:: with SMTP id d85mr6330736ywd.286.1551371444671;
        Thu, 28 Feb 2019 08:30:44 -0800 (PST)
X-Received: by 2002:a81:1d58:: with SMTP id d85mr6330673ywd.286.1551371443810;
        Thu, 28 Feb 2019 08:30:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551371443; cv=none;
        d=google.com; s=arc-20160816;
        b=lq48wcynB0VYnwsJD9Uyv0Rgz5F7kyo3byom+x6QRCSg8hE+GxKp1ezIB/pbuYs+lT
         cp4AZhKkY/WQCdY6X5eEUsKhw51giXxZMB6tAXSn6gtz9uOmi9rosxkgALnrDafIb2kw
         +frRdUiwnlhO9ubax76cqvkDzJOf8BywZ5yBJeodkAuXYu8hHYf49U8R238LxmuNqoQL
         V6wb0SYHEEay4Bep5lW9sSOdpcbW4HzAKpQndBh4K6Y2l+8fVvOBQaYp6/jkkl6TorDx
         Z9apQgUjlhsGMJiKXHWEGHxt4w55bKr6KFEDVK3LTwhiEqcUy0fRWWpHZyEzpWskRI8n
         iy3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NxReYuZN9DV/fcdnYYWinsazWkVL2jKBNqgEJlRIVkI=;
        b=nT+54mw6GUkeu5vLuPJPu7mqK959lkxwBpLaePZ4Fh9cDmDft9aK+gb2YMtUCGTcBo
         ONWTPGY0CfQvIMmB2WRscd+Y1ecyZRDOd8bb/i37Vktg3QwRGHRs35T93r7Z/7lOSrqQ
         oPQ3ANHTd24CHSpSHH01h+YPEh/7MdYRrrovi9byob6aJ9lO/rI832zPAWcchcyCodSO
         /pTsqBPnTPB6IXy+2VgLa1YcO9lD4qrbhs2LCVvYtfr3XatC67VQHNbAoVkKfxGIzmRA
         xE3Mo/7VCyBbOEXmEtXWAT7K9C+REEIYGPlJCP6Gi/5zlNefKN/tCQQkZLNi7Z92Cyif
         eiAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ZAGBYz8G;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i17sor2259343ybg.193.2019.02.28.08.30.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 08:30:43 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ZAGBYz8G;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=NxReYuZN9DV/fcdnYYWinsazWkVL2jKBNqgEJlRIVkI=;
        b=ZAGBYz8GP7xIIzJFVPTadJPGGMIowtbAf7+EPG3yvgRIeRyXKmFnQnaswl/xN6iA1h
         Stype2OdeKY7ecFjCOIUKdyiqmYipTgueLOOP9OfEcLkTklZQs71jTxnDHOs/Afca+Ff
         dh99RRH2hehKyyfIpmHBwk1bsz20KaPjXYYkmNhguy18yadeh7dnamP67D/VmkLw2nUb
         ktqdqI4pYdDPvQjETyKp9zSCQqE+VSyjVVX6OecZlKOlxHzVlzveix/BhPrzCNSZJyS+
         CdTvtK4NOJvO4/kPQ5/PxHPZu0t7yQiJLF5gQi2Q3xs2G+vSxFcKWfWRHeCrCn8bRNfR
         8bZA==
X-Google-Smtp-Source: APXvYqyeHHEs3NCGgQH9pHOJZbtgFB/JeWqSzcj6DKjRixvKM6LESsPz5wgeJvfex5scPRevDjuqDg==
X-Received: by 2002:a5b:348:: with SMTP id q8mr166652ybp.479.1551371443602;
        Thu, 28 Feb 2019 08:30:43 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::3:da64])
        by smtp.gmail.com with ESMTPSA id r77sm6517577ywg.10.2019.02.28.08.30.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Feb 2019 08:30:42 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 2/6] mm: memcontrol: replace zone summing with lruvec_page_state()
Date: Thu, 28 Feb 2019 11:30:16 -0500
Message-Id: <20190228163020.24100-3-hannes@cmpxchg.org>
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

Instead of adding up the zone counters, use lruvec_page_state() to get
the node state directly. This is a bit cheaper and more stream-lined.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 18 ------------------
 mm/memcontrol.c            |  2 +-
 mm/vmscan.c                |  2 +-
 3 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 534267947664..5050d281f67d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -517,19 +517,6 @@ void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 					   int nid, unsigned int lru_mask);
 
-static inline
-unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
-{
-	struct mem_cgroup_per_node *mz;
-	unsigned long nr_pages = 0;
-	int zid;
-
-	mz = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
-	for (zid = 0; zid < MAX_NR_ZONES; zid++)
-		nr_pages += mz->lru_zone_size[zid][lru];
-	return nr_pages;
-}
-
 static inline
 unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 		enum lru_list lru, int zone_idx)
@@ -985,11 +972,6 @@ static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
 	return true;
 }
 
-static inline unsigned long
-mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
-{
-	return 0;
-}
 static inline
 unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 		enum lru_list lru, int zone_idx)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5fc2e1a7d4d2..d85a41cfee60 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -737,7 +737,7 @@ unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 	for_each_lru(lru) {
 		if (!(BIT(lru) & lru_mask))
 			continue;
-		nr += mem_cgroup_get_lru_size(lruvec, lru);
+		nr += lruvec_page_state(lruvec, NR_LRU_BASE + lru);
 	}
 	return nr;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ac4806f0f332..cdf8d92e6b89 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -346,7 +346,7 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone
 	int zid;
 
 	if (!mem_cgroup_disabled())
-		lru_size = mem_cgroup_get_lru_size(lruvec, lru);
+		lru_size = lruvec_page_state(lruvec, NR_LRU_BASE + lru);
 	else
 		lru_size = node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
 
-- 
2.20.1

