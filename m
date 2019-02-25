Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64687C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:16:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2177120842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:16:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="0Qvv+sPu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2177120842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72CD88E0012; Mon, 25 Feb 2019 15:16:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B4D08E000C; Mon, 25 Feb 2019 15:16:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 556AD8E0012; Mon, 25 Feb 2019 15:16:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 257488E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:16:52 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id h7so7064481ybq.18
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:16:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=xYRD3i2lO0S8FmpT0yhEIbRdeHMhHjlJuWkUHWcpJsw=;
        b=lymw7eEj/AyqBwmisuAgCFnsvJzAeFs5/0m3jIWXnPatiG5iKuUIuv+2NXEoyXOWn3
         zef63s3aGtm2TI1TcLQR4Fz8fcbKRlm0Vh+zY/CheLWkA7s17e5YlnInrXR9LnKZndDv
         mz03L3UkXzPejsswzWgylhbW67ljXJZkvsduiWgK+pXGFomz1sg1tr2lHPWr7R/bt7b/
         AeUF3dH1bCoCAX5W1c97rngoXDRKRhR0ATUjyW1JcgpzBFGMV3dxlKYhpD4D26Usfmtw
         2t1DKgN3YLP3W9MjwiM5zZnAsgT3NO/LYK2bJ4LDi2I6Iwe4mkGHpAcc6sSuMP0bjnnv
         oSFg==
X-Gm-Message-State: AHQUAuYZxfTO8q1l+bYAoUlCuk3GwusCA3Q3w5NynU8CNNlphtajyZY1
	TNn9MXTDLomlWP94CNiiV/6vVFXwGTIzDx3hMzYD+LsYt+4ad/HkwSByh44j3OSX1h9ZQFMTjg1
	QK+ACTgDGLUxreDFf5huQOVmPEutjyD4JMPWxHmpRqX/Ng1Mq78i+ydWsG44TKjMSPv3+ykhoLz
	IZxfNvnV7PZM9mBLKtagZt7YgVNgsapgDTUnPyjz9A21ddXHHIbdy8wG7ouykyF/ZSgZa9ghLfa
	ez75k5IN+EjvvyHSlpXZdWYA+Johy1cHMnEB4T3qAU5feBIjiBLOcMBgfs68WX05ckU+C3fhopZ
	FhpP02F/j6scAHtuhz3/qQ4PSVeBYZSu0bhSWNbzZHSmcEZ7M3NV8vOZygRcvOrgwsW4hLuM8W6
	V
X-Received: by 2002:a25:84cd:: with SMTP id x13mr2638130ybm.218.1551125811919;
        Mon, 25 Feb 2019 12:16:51 -0800 (PST)
X-Received: by 2002:a25:84cd:: with SMTP id x13mr2638079ybm.218.1551125811202;
        Mon, 25 Feb 2019 12:16:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551125811; cv=none;
        d=google.com; s=arc-20160816;
        b=YT4/7jRajvurcZa8Ce/bd5MC+9sIOZDEoVAjicXbBHlMIppiU5Vid565ePUMRiDUvh
         Qu7PkVveh3j1CbdbkTJxDzNVWopv5RKvd6OGs3eguxzyhYqBX115uQriuBVl5KSzJzUk
         xT+zaowHCUm71d4M4EeelWhW9joiKoKiADfTv4GH256bFv8ZtO5M7sO7fyVsp2u8dC0d
         uafHFxoHUsaH4051167/2lSSV2Ov3cocQnz2YL2omkwx2R+ovB2K97T6orFxnGSH4gL0
         ryWeR0i4V0P8L9yjTgHKSNW0TuvVqNPZPRZCRJO5NO4ktjTsSaQ18ygu7/QrHe7xE+TK
         gk+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=xYRD3i2lO0S8FmpT0yhEIbRdeHMhHjlJuWkUHWcpJsw=;
        b=lS1neI+rKeiLksF4l70M1LWq+R9m0Fz/CLlj0p2Gf0uDmj4w5ijLjviPbPx+F8Ayrj
         iTZSY7xmOYf55JKldH1/hPHB4n8llVKPMTVFu2u6MZEtc0kfT9jyqsJmHPLOjzLwAiQs
         Cevz0Q7Gdj276+cLUGDVJXvULLVW45up35Iit7y5IoT6OdWYkL2OU5LrlUGbQ+jiZobb
         7LEqsP+3nheGyTRcaeFBds9E8C8fpSvID8wgQ92e1KBsu8OLYSUeiny7QyeFZckRUN7p
         H3+O1Cm0WBrcykv8CVNUA0gheSr8SGGJbbEr5SoUG/VD2Q1XRjOSMcOUofh/WAB/VVmX
         D/hQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0Qvv+sPu;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u206sor5140355ybb.48.2019.02.25.12.16.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 12:16:50 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0Qvv+sPu;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=xYRD3i2lO0S8FmpT0yhEIbRdeHMhHjlJuWkUHWcpJsw=;
        b=0Qvv+sPuypt43ngbcniPJ2vvh40jSAQI87jwhwkzlPgrQhFS7RhXTd7OWCXq+iXvev
         Uo6PWeYSxzZJCCuxahigvKNfYRi6jmY04vSJYCHHMWjXSJLS/zZYU8zPAQbfn0vMjuLx
         lV/P55+xYtaFmT6/4rs/jvCN4waWoiZrFI9Lza8UBLmlRfZZXsPwR6uQ22uzDM6b3kQp
         DTJVZ69NfJhNXx+tj/PX3rft7V0BMtavC9Jfp4ePMr9fSYvZk1EwDeqdEu0xB7lYQFrV
         fnArNZfI47SsnWGh76pw/mfo+w6J+RIbhvH6AmvN62vtsUPKDj3DIvefac4ycQi3Bs6w
         zCFA==
X-Google-Smtp-Source: AHgI3IbPw29CG2NUoIo2FNnxPOMDd3lhUuauPMBmLEVmk36pSzm6+slOz2azGHhrwS1+ibAkUopPdw==
X-Received: by 2002:a25:35d5:: with SMTP id c204mr16173302yba.325.1551125810575;
        Mon, 25 Feb 2019 12:16:50 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::2:5fab])
        by smtp.gmail.com with ESMTPSA id 77sm3611855ywr.19.2019.02.25.12.16.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 12:16:49 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 5/6] mm: memcontrol: push down mem_cgroup_nr_lru_pages()
Date: Mon, 25 Feb 2019 15:16:34 -0500
Message-Id: <20190225201635.4648-6-hannes@cmpxchg.org>
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

