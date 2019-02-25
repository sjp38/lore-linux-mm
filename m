Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FE3EC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:17:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D752420842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:17:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="1+FrSkex"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D752420842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD5428E0013; Mon, 25 Feb 2019 15:16:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A101B8E000C; Mon, 25 Feb 2019 15:16:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88B1F8E0013; Mon, 25 Feb 2019 15:16:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5750F8E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:16:54 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 67so7492682ybm.23
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:16:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=Z2sRN7pljcgc3IEs1HOIZy7cq4U6Vg2axPUdXHMU2lE=;
        b=m0DBBg9pbuTH4rwOi25ZOe+NZekIIqAQt/ZOxiLfotc4gjlKv9FNQtN13m5SzbuqXH
         KgCBRhrE7M+xSh2FFm6SC5SPRsXy+tbGT52W2irmJ/U4zLEY71i/6Cbdj2TaTc4DcGae
         ikPd7Vmc+Gl+QipVMle92M5kK73kBEfv8l6hq7hxDwxbhwp+TNZm7lkqemFSXFEwETem
         zNPYmWsapwe4fqh7ScUFfKvqEzqIAZm31pC41zd0SN6MgFRwY/XcY+FSo2MYhWpGfI+4
         L0stcgN7gkh+NPsOA5EIr3/NpFNlDA0y6v9tbHGl5Cs0POqR/Db6U6R3DiTse1f7OKYV
         z3vg==
X-Gm-Message-State: AHQUAuZ74cyzi5606ulIlIVP69y9e53rjpY4nSWCtSAQ0nLk72htYuMz
	cGz647wt/4CdTIhlYhsKEFaEi/c1c8rvj3Q3+HoYUcNnHdWaFjU0YpyJhlbyIXQtiMd6CUMchlS
	+o5MrCBozA8SfkP8WiMiym71vGYFYZfrdwJHhvsL7HQE8clFTDZ24INDErTZYz5SOhCvUaTPmJe
	uyLcPQJdv7+Ahhln0kCkGVsTAKGO8cO5TubBtFh1DtdbRhp6S6SQasWYSddGI1U0lRP78Ts/i0S
	PN5pZ5hQvSPDTzDj9TCpA22ZGeX+v7WqAz1VLQrEZt73oDEopAteTn5naGWBmX+N7G04V/3rsOB
	jf6BHyzF9oI5HE/ZnCsb4NS1Rmhnnp+5m27adk41khyoBx4fWQg2zRraI4KVrRb8OVC4KB+lTUD
	0
X-Received: by 2002:a25:2455:: with SMTP id k82mr13815816ybk.268.1551125813565;
        Mon, 25 Feb 2019 12:16:53 -0800 (PST)
X-Received: by 2002:a25:2455:: with SMTP id k82mr13815756ybk.268.1551125812697;
        Mon, 25 Feb 2019 12:16:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551125812; cv=none;
        d=google.com; s=arc-20160816;
        b=XwKYlQQqP1yxpofdq4uIUmvgvnBm/ai5xXRjGB/RQEK2uf02ZBILz6sDPYqS77clZM
         VBOsoY+OkPNcdmr0GktmdXG4aD8U738EP9YI9AJEkgi5B2ilIZSLB6b28AUzQIIEShbQ
         UCmEDwYpV6gZUJLINycXoPesXVyTeowRqpLQp39Lm1rsf7kPL4MPnosE2T2GEB/+rv6p
         RNIAv7qo3BSzPUzZ9Tt7nPvkrGlLFrjVmX0f+KA6OYIoy7tX1MEx+CaqjDQGv+ASBePI
         D5+7DzpaXRCxEeb7LlJaKGv6sgMbmnzMv5ISLMOVN25w3BD2CwBkq4hs/vBV1A55aGlt
         /ZLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=Z2sRN7pljcgc3IEs1HOIZy7cq4U6Vg2axPUdXHMU2lE=;
        b=tuskSmGjG290f01v3aKnZQnRSdaHBZ1C7a8h5qiPJ1U9q6YkwdPF+WubZgDAmywNyd
         jhjGUJ4NwwQe2NTUZ9QjAMl9tCoylx8i8eahA+elJLfATueateVCcKXbsEaHqRv5N7XZ
         UdxEdXgRaopHy4RMgGfW/J2gZKuOK0NbBz3qjAg/umF8Fbl8og67lSlRc7F1btrb8kyF
         MR9C0w0SRdqPH8ZX3afLqgg+LUI5d+PyirY3OQWFf8JHOxSpwx/z6DCSO4b6O2sw5oba
         zd67fl9xaBdMnsrC0xu8FflnkiH9gCwTqdVwdniafeGujD34Albs5d7wi3m0RB0w01kL
         9A+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=1+FrSkex;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 62sor2289184ybf.91.2019.02.25.12.16.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 12:16:52 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=1+FrSkex;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=Z2sRN7pljcgc3IEs1HOIZy7cq4U6Vg2axPUdXHMU2lE=;
        b=1+FrSkexTFwKLt3ILN53KvvzB87QgBFIYMGtbBrfjQ/ipShMywFpPzWjN9kgHla69K
         s+Xaxg36MRA0UddoCVd0M7VsdkWbkeY64kdAyWFAoRn+VbhG3UgwV//T/RYHyiPvodDd
         QI+hSHfWdEeR9iMTEbMPTzGT7PBdYRhFiuy1hWKWEoscR3EVsMO4Xe65dTWVJMRC9XDh
         42OP6nF7O5K04TOClaqE/ZBq0QaulYAQ6YYIXQf/FJ6biVib8KYdBW+SEXI4uUW4iUS0
         gVvCAwC3Iv5jvs60VbFBJm5NY3Kd+mm2wh45UAhsyS1weGKcYGgsltyNo27vdHSNUS4T
         brbA==
X-Google-Smtp-Source: AHgI3IbV+Q6pr1OqJoRoDUVdDxORC2SryT/jNlKyj0mobroXn+6xFo8QtZnW4OtS933Nd0SoJfsj0Q==
X-Received: by 2002:a25:cb54:: with SMTP id b81mr15489528ybg.520.1551125812493;
        Mon, 25 Feb 2019 12:16:52 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::2:5fab])
        by smtp.gmail.com with ESMTPSA id k184sm1010344ywa.85.2019.02.25.12.16.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 12:16:51 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 6/6] mm: memcontrol: quarantine the mem_cgroup_[node_]nr_lru_pages() API
Date: Mon, 25 Feb 2019 15:16:35 -0500
Message-Id: <20190225201635.4648-7-hannes@cmpxchg.org>
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

