Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AFC6C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:31:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05EEB218D3
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:31:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="qZBcQtun"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05EEB218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 983338E0008; Thu, 28 Feb 2019 11:30:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 934138E0001; Thu, 28 Feb 2019 11:30:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 801F48E0008; Thu, 28 Feb 2019 11:30:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4145D8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:30:50 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id v85so1569341ywc.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:30:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xYRD3i2lO0S8FmpT0yhEIbRdeHMhHjlJuWkUHWcpJsw=;
        b=qhAbA99nmZGXOssL8iAgfph5bkmCGEIafUUxa67lwJA6aBlP+5uJvgncJgOhkZMPQo
         KvaJdBhD9sLarG2xuYutxtfp2R1fHYTfoXafGL9y8CFMVGcnNtpBNi83K63c39MvY5TT
         qrgVTFvFU8IvjYhM9PvenkqH3dMogQqHxz2lg6qGnKWSQyAsaAU7nZtVoy5qna3NSYLK
         4Y9eYLBkC26PQ97DvKPB/o0CuVBuPPGFzCqrUgYk4NHl5WE2X3IlcRtHD0r47NgeL5yC
         TaAY+LuxE+0B9RdteYhXn5O8nGKGd8ZcCBg1Ib9FHRDmeXFxrHdTM+zOBVAjbe5UBjF5
         cTFw==
X-Gm-Message-State: AHQUAuYVB6Ziug87c7Fdt2FkrF4ODcBuN/fILnB07sHdVnDd2pOLpVyi
	QEtiCD8JfSuBeDSUHu4dR/MVWDeAmYsgAc7WlD2qbaeQDjtXQOJTnf9lsLfLidwDqJXjfSIJotU
	LdhqnNDW5U3uHcNlebRkeAzTRXQAhgPAn7DGPnrQYGTo9t8uHwjrWu8MtS8lz/yzudrQHTiWHmx
	nDeoHmIGH851Bf2EidohHSnyGE4ZBL+lh06PCdSKeHS/G182x9XW3Ru7j2oR6fv2y1AS2gAxO+W
	87TLr14jXxGzMGdwRtYVADfdlUpG4FN1cruHUpc9NgEts+qzn+43Ik4CW+YcMTjde4fAE2akJXF
	VhcvxNe3m45+eKb5wm685aHCZfSQC4VNyr2QdpeiorfRTtlsyKDi+4ChQmFafaJrM+D0zMjmWVG
	A
X-Received: by 2002:a81:6604:: with SMTP id a4mr6420526ywc.510.1551371449978;
        Thu, 28 Feb 2019 08:30:49 -0800 (PST)
X-Received: by 2002:a81:6604:: with SMTP id a4mr6420453ywc.510.1551371449098;
        Thu, 28 Feb 2019 08:30:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551371449; cv=none;
        d=google.com; s=arc-20160816;
        b=vrSvg0aT2sWwpVuanCxvtst8v+vqYgeDxiZ7JfT1XPkRdB5DnDKm9JIS6D5VhupTK8
         CXgD+MQJRTmuiMXS/XEwQ4lJiN6Acl3zjBPWjEbq3g7mGFXVaN7DrMxprTC0wu83fpBX
         n7wV2SZA+1z2ST/eoDSFIjOXpmZ4UC8Ru3enFKY3hKTMA32peCH7iqE8HGPeTNm6v3SS
         czJi4IBeIIk7WPK0hY0gM8dA1WzVOmGTudbha+zr/2bySzXum0zNnQpi9WJ4mAp5mIiT
         nZqRpyAX4QuwmGt8V3vLOtOPLpnPIny3cMX38yB084P5QTEfwT8RLwuvt04juTXUjtdX
         pcwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xYRD3i2lO0S8FmpT0yhEIbRdeHMhHjlJuWkUHWcpJsw=;
        b=QqqG/U9t5902Cnxp8gjd2uJ6hsE0RVkqOxyE8lYpw8stzP3ubaxmMnqSI9PwxVkI3g
         Tu0ixKSOEwVBMblR5gy6S/TFEiu7/PR4LTYIyBVW+m8dJb2CKAzAsmlCrmI45UZ6BADe
         vnyQZvbVWVtw9XkS5dYHt7RkJfjX9GZLF9vKmT8+SQxLSFpLomCOqFqhhP7XCV4s7nas
         rPTHQAo+6a+qHqVsn1xravnES7V3vCRJD0NnslrkgTOdFLhgc6jgijWHF9KNN2NN678Y
         RzTWu9iInehIBI+83x1N3r27iFusyZcH7/0xArukOUHQIILia2bghZAIQHxUZsOoSC7i
         G3Ow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=qZBcQtun;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x63sor2710945ywf.0.2019.02.28.08.30.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 08:30:49 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=qZBcQtun;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xYRD3i2lO0S8FmpT0yhEIbRdeHMhHjlJuWkUHWcpJsw=;
        b=qZBcQtunj0HpdKLEyd50kzMF5u4hwQOvpkuAEd9NtT3C1jIdB7SHj5Wu9SVJiJwk3c
         efLEI5hR9LP5jqeXRHv91q1Cfi7QKY7YBX/nYdAjWaCkhg0/6IEOPiQBjKAq0bfilI3N
         6+YUWT4QM7QuO2aTXzGCOAO03Gu8MEqoAFGi1AsO2Gy+6MSFPDuRjpmStKdiUf3gl9WQ
         rYJWUi4TxMM1rVZuaDh8gqG2aQjHBJ/peVLRMFwX1ONsJbyvqNoiueg8XQ0q6ZlZTrDO
         AmmgTrAeqcwX3nf/JCr/thMhQEdk6+oBM8aZcyfJ5f8xItULOYhkQICIPL/RS7FEkfXS
         5ByA==
X-Google-Smtp-Source: AHgI3IZPWS72vZA70SN28U7DTHABb87bYm9NNCIuTp6WKnKk1uOxy49S6BuAC7Fr2XXiYD0cttc+bQ==
X-Received: by 2002:a81:3083:: with SMTP id w125mr6232560yww.170.1551371448843;
        Thu, 28 Feb 2019 08:30:48 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::3:da64])
        by smtp.gmail.com with ESMTPSA id e3sm6679734ywe.33.2019.02.28.08.30.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Feb 2019 08:30:48 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 5/6] mm: memcontrol: push down mem_cgroup_nr_lru_pages()
Date: Thu, 28 Feb 2019 11:30:19 -0500
Message-Id: <20190228163020.24100-6-hannes@cmpxchg.org>
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

mem_cgroup_nr_lru_pages() is just a convenience wrapper around
memcg_page_state() that takes bitmasks of lru indexes and aggregates
the counts for those.

Replace callsites where the bitmask is simple enough with direct
memcg_page_state() call(s).

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ad6214b3d20b..76f599fbbbe8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1361,7 +1361,7 @@ void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
 			pr_cont(" %s:%luKB", mem_cgroup_lru_names[i],
-				K(mem_cgroup_nr_lru_pages(iter, BIT(i))));
+				K(memcg_page_state(iter, NR_LRU_BASE + i)));
 
 		pr_cont("\n");
 	}
@@ -3016,8 +3016,8 @@ static void accumulate_vmstats(struct mem_cgroup *memcg,
 				? acc->vmevents_array[i] : i);
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
-			acc->lru_pages[i] +=
-				mem_cgroup_nr_lru_pages(mi, BIT(i));
+			acc->lru_pages[i] += memcg_page_state(mi,
+							      NR_LRU_BASE + i);
 	}
 }
 
@@ -3447,7 +3447,8 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 
 	for (i = 0; i < NR_LRU_LISTS; i++)
 		seq_printf(m, "%s %lu\n", mem_cgroup_lru_names[i],
-			   mem_cgroup_nr_lru_pages(memcg, BIT(i)) * PAGE_SIZE);
+			   memcg_page_state(memcg, NR_LRU_BASE + i) *
+			   PAGE_SIZE);
 
 	/* Hierarchical information */
 	memory = memsw = PAGE_COUNTER_MAX;
@@ -3937,8 +3938,8 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 
 	/* this should eventually include NR_UNSTABLE_NFS */
 	*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
-	*pfilepages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
-						     (1 << LRU_ACTIVE_FILE));
+	*pfilepages = memcg_page_state(memcg, NR_INACTIVE_FILE) +
+		memcg_page_state(memcg, NR_ACTIVE_FILE);
 	*pheadroom = PAGE_COUNTER_MAX;
 
 	while ((parent = parent_mem_cgroup(memcg))) {
-- 
2.20.1

