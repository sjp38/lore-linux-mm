Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 049E0C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 10:47:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B77F82080C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 10:47:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B77F82080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 320616B0003; Tue, 18 Jun 2019 06:47:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D2078E0002; Tue, 18 Jun 2019 06:47:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C08A8E0001; Tue, 18 Jun 2019 06:47:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6D7B6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 06:47:04 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u21so9017774pfn.15
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 03:47:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=BuoH6wYhxiZnTHbGkuTBAlzJgETRqINFhHA9RarPeF4=;
        b=CpNE0mKX9RE/03LemrKe8IyKABLGzaKt05mvl/Ia6E9p4g7AYM3s287e6qCSzdtCgq
         exiCApIOjsDQpi5rQmbTZAo0xx44iTI49EINXCPb9r/RszJsPNNk0w42vhjCuGV/EaO6
         I2u6giXDfddTXrLQ+dZNrNq2WCbI+7EhSf5NA00IK0mq7J+DibhDXWRnPuYz45A4J/C1
         nxSr7obpmcSuxRQBDkxXkoVYg1cKI44DHoTzwDKxs7qY6m5/qtLusg2X1k9/IlcoI68d
         ZdP+T3QO7+dKo7BCKLvBkytGF8venpuruZeU7esBkrbyof4qux3lFFFk62ZjIOvWw0o5
         7GLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAWk8OEV4Kw1d2toNPhpR0o23IDDS/OwJ/ZIL5h2QIWRPkOwK3Gw
	hrbgPIOf4RLVHQq37+ka2UjtczeqYXEe2rTQK9PSg9X9AiXj/Us1ThTVb4UN1FqWmrLdxJ6tA0P
	LoJUxSK6IElDvnPVr/jmgHMJEDvzsi+ZakNXUswBvHPOiX7FWBjSVvue4vUozD0cztA==
X-Received: by 2002:a17:902:8ec7:: with SMTP id x7mr36924072plo.224.1560854824489;
        Tue, 18 Jun 2019 03:47:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQmrCmghOL4GrLrnXJmi0V/LUU0iX9P+kAkoTFpzzk4H3iRm7WOa/vfJdfh853KWImiRAu
X-Received: by 2002:a17:902:8ec7:: with SMTP id x7mr36924011plo.224.1560854823223;
        Tue, 18 Jun 2019 03:47:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560854823; cv=none;
        d=google.com; s=arc-20160816;
        b=noQfH8h2P+r+hwZe3S2BnvhVKLwPqaXKDFX4JNOQ9L5ZFogjCQxraV/GywEmI3Loxf
         zKEzhL8iLxBYA5zLBlUrTzlorNIhiA4e1AQwhK+AjtMNTyosBdpAtpCRSP0gnCmaf7a2
         vErNPUMtgdEG/ze+JLiTgK8ziK2WCGZYOr99B6HCSb3byP/sA2ckWhjGsLJNeMKN1HoN
         deIoOlirOCBnpNYWSbxZxcdbm/n8lbwP6RTKbHRvWWgefHBAa+5C6iivWCST3CpI3OQC
         bgnivO39ur+x28agayTys5UXW6JZrlZaDF7ba2X4ELuBxWaptDb2KA3q0ECLrY0uLdcU
         00BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=BuoH6wYhxiZnTHbGkuTBAlzJgETRqINFhHA9RarPeF4=;
        b=tkDa4IN2Bj5JfxZYiiKgRfaZkCbf1dlC6fnVS7BfbSrE1abh3ulHKOLmzo/1I8RTHe
         NavqPafc+y9fPdSDRi7awz5ljBe2XmCPrGnyTSpHL/YAQicXJXiPZxmxpJjMqnDpJysq
         vW2cY44LAIZA8Tdv9zCiFC6bMAHmOrCaiLULuA2ra1QBCS8lnQgU1rk8SdQCwmSld9of
         QHnPTGXuXEtCtg/U1RsJNDx/Q4odFmcqTcaEhN/BoWFVSru5xdpZQCZuospGwBLGwxAx
         muh1Lmpwei1HOe9ky5Sq1JZGQsR84JxIGDvRvpmXmzuPbm0rhkSjOxOv85wK1gzUVhqY
         PKFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j18si12941008pfi.75.2019.06.18.03.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 03:47:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav405.sakura.ne.jp (fsav405.sakura.ne.jp [133.242.250.104])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5IA2p6P051089;
	Tue, 18 Jun 2019 19:02:51 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav405.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp);
 Tue, 18 Jun 2019 19:02:51 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5IA2l8w051047
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 18 Jun 2019 19:02:51 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        David Rientjes <rientjes@google.com>,
        Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm: memcontrol: Remove task_in_mem_cgroup().
Date: Tue, 18 Jun 2019 19:02:34 +0900
Message-Id: <1560852154-14218-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

oom_unkillable_task() no longer calls task_in_mem_cgroup().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: David Rientjes <rientjes@google.com>
---
 include/linux/memcontrol.h |  7 -------
 mm/memcontrol.c            | 26 --------------------------
 2 files changed, 33 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1dcb763..dcc5785 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -392,7 +392,6 @@ static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
 
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
 
-bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
 struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
 struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm);
@@ -870,12 +869,6 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 	return true;
 }
 
-static inline bool task_in_mem_cgroup(struct task_struct *task,
-				      const struct mem_cgroup *memcg)
-{
-	return true;
-}
-
 static inline struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	return NULL;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b09ff45..0b17c77 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1255,32 +1255,6 @@ void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 		*lru_size += nr_pages;
 }
 
-bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
-{
-	struct mem_cgroup *task_memcg;
-	struct task_struct *p;
-	bool ret;
-
-	p = find_lock_task_mm(task);
-	if (p) {
-		task_memcg = get_mem_cgroup_from_mm(p->mm);
-		task_unlock(p);
-	} else {
-		/*
-		 * All threads may have already detached their mm's, but the oom
-		 * killer still needs to detect if they have already been oom
-		 * killed to prevent needlessly killing additional tasks.
-		 */
-		rcu_read_lock();
-		task_memcg = mem_cgroup_from_task(task);
-		css_get(&task_memcg->css);
-		rcu_read_unlock();
-	}
-	ret = mem_cgroup_is_descendant(task_memcg, memcg);
-	css_put(&task_memcg->css);
-	return ret;
-}
-
 /**
  * mem_cgroup_margin - calculate chargeable space of a memory cgroup
  * @memcg: the memory cgroup
-- 
1.8.3.1

