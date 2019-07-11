Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09655C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 13:33:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B52B221537
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 13:33:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lxhnkEkD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B52B221537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CA868E00BA; Thu, 11 Jul 2019 09:33:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 479B18E0032; Thu, 11 Jul 2019 09:33:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3685E8E00BA; Thu, 11 Jul 2019 09:33:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 00B738E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 09:33:28 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id r7so3245683plo.6
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 06:33:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=M8lOXUHv+7p9u5NfLq/YM+deQQyR/m+/D5zv6uZZuVc=;
        b=GkL4u+iosixZSVA+XsCPqTEkGXrubxsXep2+EM8MkrATAMoPsbrHlWDsDbBawiZ5kV
         Bm/NvR+95oLpwsBJXU5zgwMCo8+0WKpHRO28kfagaH3MX/vl0qI+odBSiRv5s3Y3ycQP
         x8y2OCvjJRrabtOJy/xzq1YfkaPpBrwrJRgFdRS/pqHy+eGXceE4dQxmeq8wNZhIDcxy
         u6JVOXcjfwqcJKciG0r1tYvjYNTYpAZn6T65CP2w5E70LD5TY7AwFDez710twAB+4eun
         rwYyAEOmva2YT/CrNYcEFTxrlfPWa0vOECHKNnvxw6krypR7IACtH2KhfNcRcUYQqxIw
         FS8A==
X-Gm-Message-State: APjAAAXtnLjq4nOyuhkdEX6UPU8MRuc1N0edtJ3+7h9/LZ2yyT8i+pJW
	DDeybd/Ic+ztejRbKpkSH5ms0dZIDdSqMG+xcBpSi80blngzGrZ1xw81wRvBPeqx+yTTPFnk5ze
	d8Od4LlIIz3+6tfDoc/fqGhMWQJwCDQkQQAM0hXp1jzpTksPsEH29GGAYLS3YGBgHrQ==
X-Received: by 2002:a17:902:2a68:: with SMTP id i95mr4804034plb.167.1562852008507;
        Thu, 11 Jul 2019 06:33:28 -0700 (PDT)
X-Received: by 2002:a17:902:2a68:: with SMTP id i95mr4803908plb.167.1562852007189;
        Thu, 11 Jul 2019 06:33:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562852007; cv=none;
        d=google.com; s=arc-20160816;
        b=qGCtkTxcp8MV16aMHs/IjMIQWQfSxxRpjvdOHrgb/lklze6Bd/ZbhlnseldDLrBK6A
         jpSciDJvjW60XudkVQdNN76jg9I7t/twCP5dYbJ9gEIgsvO60Ek8TX6oYL7Y+1LPPWZY
         l96A7rFMCXGMnd7JCcvlYVRN0zJTOqtzmx1gsYmQZ4TY+VsVl8Zqcl2dB5uHV/MKhjoa
         IpJfc1PL1JpQQFeZLX+gy3vVcR908OMxLROt89vIn72X8iF++tP3YxQ+79GGZCCEiR1J
         RpDl8vX+ziqtBya13XaSvI/QfK2OvHMsOxUC+OfTxJzRaPLNuTIFoO3UPKaii2MxZccE
         kb7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=M8lOXUHv+7p9u5NfLq/YM+deQQyR/m+/D5zv6uZZuVc=;
        b=DyG3IwyfhQCI+erqp/182k2V68m2tjIdVA/v26vkOMyc4pXlSDkwWVNu8IGvlKI98r
         hX7hcfdoSRUSVJlWKvTesNEdwbJpNVqPRro4M6kXmtPmNV8cQrKLQvE9sLyDFw1orhLN
         RqRmZ2sQ6B8dGDS9xIDUSn4aC5K6MzqMRyQ6Bo4KJYAWmp8OmJUDmDauqpL+1xTUiaZS
         bqc+Hc83Tj//l0Q1bXYNG65X5rZniG2jyFFlsPPv0nUXV3qZPNfGMxSPOIgJvuM7m2gP
         1e+wLVdB+Z2gZpQdlQ8RINRRhLFN+nA91YERikcKeYWedzvQHsXN1cjhgzXHeefYy745
         Cdeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lxhnkEkD;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6sor2930825pgs.79.2019.07.11.06.33.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 06:33:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lxhnkEkD;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=M8lOXUHv+7p9u5NfLq/YM+deQQyR/m+/D5zv6uZZuVc=;
        b=lxhnkEkDHCBnUNsTquAJTvgr2ZgcT4RZBaj8b4v0lrMv7P7HY3rhkJbcDB5SzPSTdC
         NKWOzrIbHUE81wqTJ+cEBQKpqpqQboQoPaCg8xqYYtz3AUCxt4gGz791uj4jhzQzvhZz
         X43AipEs4mzniGhqxKrZOHK5+shiOWjFQUV8uIO7IO7tf2F9mqrsh+GVoIpEcDxhA0p/
         lXmv/CXSNgcg9d1U5TMeZVdMTfGSsCqL8raPJAsqCWqa6roEmmQEvqtrux6mQstqispy
         NT6pzMCrNti+mu2Db71AdxSgjdDTKskjj9qMLspvO3FknvyyE+I1YtcXRffdLHYBvybW
         tjAw==
X-Google-Smtp-Source: APXvYqybJb17rGV4A0VweI9ImUzg6XDsnt8Mzg559FQXqw3TOHc6Sbg18iUSC/VcrI4DOugqIV21sg==
X-Received: by 2002:a63:125c:: with SMTP id 28mr4470026pgs.255.1562852006829;
        Thu, 11 Jul 2019 06:33:26 -0700 (PDT)
Received: from bogon.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id i15sm5611805pfd.160.2019.07.11.06.33.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 06:33:25 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: [PATCH v2] mm/memcontrol: keep local VM counters in sync with the hierarchical ones
Date: Thu, 11 Jul 2019 09:32:59 -0400
Message-Id: <1562851979-10610-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
the local VM counters is not in sync with the hierarchical ones.

Bellow is one example in a leaf memcg on my server (with 8 CPUs),
	inactive_file 3567570944
	total_inactive_file 3568029696
We can find that the deviation is very great, that is because the 'val' in
__mod_memcg_state() is in pages while the effective value in
memcg_stat_show() is in bytes.
So the maximum of this deviation between local VM stats and total VM
stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
great value.

We should keep the local VM stats in sync with the total stats.
In order to keep this behavior the same across counters, this patch updates
__mod_lruvec_state() and __count_memcg_events() as well.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Yafang Shao <shaoyafang@didiglobal.com>
---
 mm/memcontrol.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba9138a..07b4ca5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -691,12 +691,15 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
 	if (mem_cgroup_disabled())
 		return;
 
-	__this_cpu_add(memcg->vmstats_local->stat[idx], val);
-
 	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
 	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup *mi;
 
+		/*
+		 * Batch local counters to keep them in sync with
+		 * the hierarchical ones.
+		 */
+		__this_cpu_add(memcg->vmstats_local->stat[idx], x);
 		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 			atomic_long_add(x, &mi->vmstats[idx]);
 		x = 0;
@@ -745,13 +748,15 @@ void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
 	/* Update memcg */
 	__mod_memcg_state(memcg, idx, val);
 
-	/* Update lruvec */
-	__this_cpu_add(pn->lruvec_stat_local->count[idx], val);
-
 	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
 	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup_per_node *pi;
 
+		/*
+		 * Batch local counters to keep them in sync with
+		 * the hierarchical ones.
+		 */
+		__this_cpu_add(pn->lruvec_stat_local->count[idx], x);
 		for (pi = pn; pi; pi = parent_nodeinfo(pi, pgdat->node_id))
 			atomic_long_add(x, &pi->lruvec_stat[idx]);
 		x = 0;
@@ -773,12 +778,15 @@ void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
 	if (mem_cgroup_disabled())
 		return;
 
-	__this_cpu_add(memcg->vmstats_local->events[idx], count);
-
 	x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
 	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
 		struct mem_cgroup *mi;
 
+		/*
+		 * Batch local counters to keep them in sync with
+		 * the hierarchical ones.
+		 */
+		__this_cpu_add(memcg->vmstats_local->events[idx], x);
 		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
 			atomic_long_add(x, &mi->vmevents[idx]);
 		x = 0;
-- 
1.8.3.1

