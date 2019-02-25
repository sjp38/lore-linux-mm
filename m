Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 044AFC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:16:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B66B320C01
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:16:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="luzQQLfA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B66B320C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 127C58E000D; Mon, 25 Feb 2019 15:16:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E79528E000E; Mon, 25 Feb 2019 15:16:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC8EB8E000D; Mon, 25 Feb 2019 15:16:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE9A8E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:16:46 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id g123so7035824ywb.20
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:16:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=NxReYuZN9DV/fcdnYYWinsazWkVL2jKBNqgEJlRIVkI=;
        b=Pb5tltlfePEXFfuxTx4kYqitmBto4aV0+OYBXTphaTnsyXU8ASd2yr8Nbtige58CxM
         aBRSG4B0sZXMugs4mhJTD9bwjpvkI9AF2zmh5vbrHr4dG3cl8PwPDoitDcuJExqUPlyk
         jIDDDL0BRhbOnTUTYceK/y4yXZFPUWNeHlTZfagUzkvr5TWj42nKSLltf7OqPfXCALxE
         DHjjb73SzPfpgBh5gfT7UpJxSc4JSWtEPQQ48dltqcKVJ07w9AZXnkQyl0Bn25uUummF
         mnbk0ty7D6ZFAoYbacpSVnkSJf8ADoaf1GgM39AUjh4w/ONEsRus4+DrIcmedXcLcx4u
         2yng==
X-Gm-Message-State: AHQUAuY/KQ9gSnS4DcIwcYaGOo1PQFZ3HAiWDoAtAdfJfO7wLoLh/Xdp
	xUGaQks3p3ymctwW7mVVRfyVRsCk7KHziNuUgXc7IcqjGrZm78mYt0fF6Is0dgMgPwCBzAFcYD5
	csLqGngCll8VrKaZTqs0iH7IOX7xBO49fZkuTiLEEv09f0YdtjiaC4FxuBaVP8VORyjdiafp/4N
	NDXThHaJOEOW4QPTFwICsAnOiXSoVaU3KcCHE8leFxTbqVsQBe01KZdltDqDJH02Wp30q+oPFCk
	9aqU0KkmerQHp+c22+HdCrRdpBaKpc0BhJg3TuJjdW31A/1tm4rw9RDXdd2mq+UX2i3mUyhgcU7
	/EjwUdVOWKjuaY0vFFsUbIrmWvQnTgG4udYrjJLiagVeBQIo7tlIUUsKyrQH6r9UcT5FdbOxwTG
	z
X-Received: by 2002:a81:a090:: with SMTP id x138mr15621481ywg.239.1551125806329;
        Mon, 25 Feb 2019 12:16:46 -0800 (PST)
X-Received: by 2002:a81:a090:: with SMTP id x138mr15621433ywg.239.1551125805568;
        Mon, 25 Feb 2019 12:16:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551125805; cv=none;
        d=google.com; s=arc-20160816;
        b=DxI4Fu2cNB7YrlNnXXGeLSkVb9ukuMuEl2z7Zs5vA5vx5KyU5xzclmMnCjzXrAI007
         1vtKhWd74CT+ZXc3spqgw99c8hlKtEtqh3KMGh7WtqQ1s0/NFU5nUWpWYvlt6i/X+tU0
         QvB7jZCzOZ3DoxMRE7pM5RGKEaLR2PDZWir0PaB/vHzE9G3SIuZN/vuvH0ssUbU2JpPP
         MSluPyodDNJir2vlln+wP769+AY/CVsRJssav3zE10Hsy23c525PggZI3TYQ8DCh7yst
         PujXxoOssuwQ3cbhmxIcrIbkO2wf60QPnfzAlveMeTOHV2GQZl5IgYupSR7OqxxlNrGo
         CQ0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=NxReYuZN9DV/fcdnYYWinsazWkVL2jKBNqgEJlRIVkI=;
        b=rwmhdTff1I+jtLSbJ6DISP2S6c4qNokQDj7ZPeLFjoUgdbSJfy/51Ki/n2CTKf4wfc
         EFkhNJWr07VpzX4z4x3NZuqASvsg5mt5XlvKadLFv6QsDMS2rx/QWjIdhfjCk9WhCyfL
         tLVBdWSQOC5PodeEh44YoiFNOv0Et1naexmANeJLbysJdOGd9mQqQIurG86yX0cu8OlL
         uLoqnZe7hVICSOXYeu36zYttrYgDcL3piqa/caVRvSBoWlPW2QlE9Hvrw9b6cz6JwbG6
         NdtvMPTyGqf/bXazoKvUPLlhcToORczb0sZfIVdiDg5FRAw2XUeXRcdDdWGDzSRZ0Nne
         bqww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=luzQQLfA;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e140sor348331ywe.83.2019.02.25.12.16.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 12:16:45 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=luzQQLfA;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=NxReYuZN9DV/fcdnYYWinsazWkVL2jKBNqgEJlRIVkI=;
        b=luzQQLfAlhkMiqxgs7iQVY191jzHqiLCl52U+WHYvTimOvbB2V7MACuC+gbDW528lU
         DKbiIKcrQtSNptJ9coYPFlIEFS+ssnPkar3GIPNUrQqZCcwC+Ag5WppsLRa96c7oXEhR
         thV9JSwWuUKRvsRXqKYpLBf5z87mDODHrbJG3/gbDB/4cZpk75LM8wLSYeC74xCHfEV9
         c27LRac51nakBosUq8aLjsnRE76h7Zd0qHnOgG5wn1IqKUq/vUs1x7gZ91P1BMzfgQui
         WVKsGjyCh5wpVn4EAD9dl0k4J5tz77Yr9sNCy2BP2OoRLMKizQ9I6+KdKREyX6ZboJRf
         fOlQ==
X-Google-Smtp-Source: AHgI3Ia4FrSj8aeVvg0ZcVodOSd2IjW8ZYgwMknfHnB4yrtpDrMEUX8nnSPTFdvLVZvj/z2LBP9NpA==
X-Received: by 2002:a81:480d:: with SMTP id v13mr15514287ywa.240.1551125805337;
        Mon, 25 Feb 2019 12:16:45 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::2:5fab])
        by smtp.gmail.com with ESMTPSA id h131sm3799113ywa.81.2019.02.25.12.16.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 12:16:44 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 2/6] mm: memcontrol: replace zone summing with lruvec_page_state()
Date: Mon, 25 Feb 2019 15:16:31 -0500
Message-Id: <20190225201635.4648-3-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190225201635.4648-1-hannes@cmpxchg.org>
References: <20190225201635.4648-1-hannes@cmpxchg.org>
Reply-To: "[PATCH 0/6]"@kvack.org, "mm:memcontrol:clean"@kvack.org,
	up@kvack.org, the@kvack.org, LRU@kvack.org, counts@kvack.org,
	tracking@kvack.org
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

