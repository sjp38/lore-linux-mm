Return-Path: <SRS0=ZOUz=TM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EA8EC04AB4
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 16:09:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6FFF2173E
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 16:09:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rT6GYZe9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6FFF2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 476636B0006; Sun, 12 May 2019 12:09:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4272A6B0007; Sun, 12 May 2019 12:09:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3153D6B0008; Sun, 12 May 2019 12:09:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1036D6B0006
	for <linux-mm@kvack.org>; Sun, 12 May 2019 12:09:43 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id q7so1432780vsp.13
        for <linux-mm@kvack.org>; Sun, 12 May 2019 09:09:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=ZQi/sjipIMJL03RXDXGUBdRsbi1X2/+nI6E1TTfR44o=;
        b=Xqpvdz/v/LVTOzGHRYAkMMJx0G0CV87qgAWqXINjKuI5rUjSMe6XCBZvRbITuqTj4z
         P44L539Ef4sCdaYNeTR0g32WlwfjdVYy+ISfGEMKlBZcauzHvOAoiLmX+Zzd82TSoORJ
         UhEa/QDc2lfwqN5oTlYN6r7f/9iUPbKu6OgbH12ug3hhtw7w02IwyKIhr2urZaCJlUmX
         D6iqBpDGTRPdHq/X26gnffFeCxF1nA3MQGjzFUKWA+54YWIIDNyLJSFwcZoRTbCrxDV8
         piSvYK5A9TzE2C6PkiwKSdjN2yRx2v3Ctz/LfTJkt4IPe7460pkVZMqIZBW42ivG2dsZ
         pVJg==
X-Gm-Message-State: APjAAAX/XVa68hLaZxqXXZJh/UJZj6NVc4cDePe9H4xV7OzZKe5iCwic
	/iztnZMTIfWRrwfjIVJNhg6wEerqoQXgBnyQ4pAvUoDEuXpb4010FEC/3Jd4TdRh5hRmU3XPkor
	azNa0ajPKD02Yi+p3ppcnBuSlMzN1PXSc5jS6aP71UF25vNRBf7nqOG2dVi8AI1rhJA==
X-Received: by 2002:a9f:3381:: with SMTP id p1mr3224684uab.40.1557677382667;
        Sun, 12 May 2019 09:09:42 -0700 (PDT)
X-Received: by 2002:a9f:3381:: with SMTP id p1mr3224648uab.40.1557677381879;
        Sun, 12 May 2019 09:09:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557677381; cv=none;
        d=google.com; s=arc-20160816;
        b=z/P7aYBb46THCv6/HhKxqCBfiKRZlFM2Jn36JbZNXV82rAX9JlYV5OYvRv6n1uZnJB
         rJZ55s8bllmJ0pp+pcegK+EW9AkWsb8O/cv/gUjyT7ytqU8F5jLPUIQqr/HuuKnQWpN+
         7lVAm+R6FiHn6sXXuOrl6xWnMa6OMrpvXMcHz46sXf+srQiDEkbp+BV53jL1nElqjpSC
         8R4j0yJjnT+G1lhHMNMX4kuhJMNjZecbAH7nZYcO2miJwV14HuN6Tohg0ABudsmTGFtx
         uFyuAUgQyx4OJ9weiZzmJl/7/Z7KcQanG6WVbEoM8ldJrkzaI3nsDWU33gB7Eatfic2p
         CFlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=ZQi/sjipIMJL03RXDXGUBdRsbi1X2/+nI6E1TTfR44o=;
        b=Ut9+ZBwJYvPxQbGewXKKXhNpVClvrM/YQNf84XO+0ACgIc6kn5FgUxUwAuG3XlLbIT
         FG2ZU02okR2Zwo/ll7NJ2ZNKEYL/4HEj/VyggLPZsV3lpZe2x7YTdUDOKG8rDKxpFNWo
         15o4UcPMrC21zcui/Np63CW7mHIRfrKzX9KXxnJ2z7hFJxvumWBJDCyY9bovNV7R5RVw
         gjLf4KdipZVgzdPY8vcrEkydqmBL+4iHDh4VWTBnFJTZAiQWv/rnE+j1fhh4nicjRIKV
         dpHWrSwEaf6yuBaFTqjt3hQHzvHFf/wjfA1l7Pabgt0yr/JPwAzkHodQGKSvyjtfe/WR
         R29g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rT6GYZe9;
       spf=pass (google.com: domain of 3ruxyxagkcb4mb4e88f5aiiaf8.6igfchor-ggep46e.ila@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3RUXYXAgKCB4MB4E88F5AIIAF8.6IGFCHOR-GGEP46E.ILA@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id x186sor1663762vsc.24.2019.05.12.09.09.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 12 May 2019 09:09:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ruxyxagkcb4mb4e88f5aiiaf8.6igfchor-ggep46e.ila@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rT6GYZe9;
       spf=pass (google.com: domain of 3ruxyxagkcb4mb4e88f5aiiaf8.6igfchor-ggep46e.ila@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3RUXYXAgKCB4MB4E88F5AIIAF8.6IGFCHOR-GGEP46E.ILA@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=ZQi/sjipIMJL03RXDXGUBdRsbi1X2/+nI6E1TTfR44o=;
        b=rT6GYZe9JljSs+O2RaDoCdYaRjz42r+UWesVjP61KLuG6brTai+B8I0s6wONcIdeUT
         ZgBS6h91WxDWjJLdDl7mdy4nSk0wB5tEBBSyUohFeLAeQOweZF4nSJgoeSX+Z5lOzW7w
         w1Kh4U5cruF03Fr6NcBIc2mu420URojoYNetRwXEgPNIIXNvzdCfMX4cuXwBaod2hE8y
         AcVWU+jdpmBSZ75RVzArG/oirAEeyO6gh8KNjZ7rVUrwOjObNx6lGpqFGYsn7BWv0Bz4
         yPD+2/26OCSf5xX0lvA/2dklhzgpKqeKHWI2sajCsyjGu0mYRjb04/FHoNtrsslXB/MH
         Fe+A==
X-Google-Smtp-Source: APXvYqzwH4rxmIbxD+iMOiqD9UQKKFw9tWXDR5aDKuxRx6lP62JMAnkQ546tt3tD+hmPNt6X3Uoy8PlTi8nDoA==
X-Received: by 2002:a67:dd0c:: with SMTP id y12mr1988351vsj.119.1557677381452;
 Sun, 12 May 2019 09:09:41 -0700 (PDT)
Date: Sun, 12 May 2019 09:09:26 -0700
Message-Id: <20190512160927.80042-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [RESEND PATCH v2 1/2] memcg, oom: no oom-kill for __GFP_RETRY_MAYFAIL
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The documentation of __GFP_RETRY_MAYFAIL clearly mentioned that the
OOM killer will not be triggered and indeed the page alloc does not
invoke OOM killer for such allocations. However we do trigger memcg
OOM killer for __GFP_RETRY_MAYFAIL. Fix that. This flag will used later
to not trigger oom-killer in the charging path for fanotify and inotify
event allocations.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
Changelog since v1:
- commit message updated.

 mm/memcontrol.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2535e54e7989..9548dfcae432 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2294,7 +2294,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned long nr_reclaimed;
 	bool may_swap = true;
 	bool drained = false;
-	bool oomed = false;
 	enum oom_status oom_status;
 
 	if (mem_cgroup_is_root(memcg))
@@ -2381,7 +2380,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (nr_retries--)
 		goto retry;
 
-	if (gfp_mask & __GFP_RETRY_MAYFAIL && oomed)
+	if (gfp_mask & __GFP_RETRY_MAYFAIL)
 		goto nomem;
 
 	if (gfp_mask & __GFP_NOFAIL)
@@ -2400,7 +2399,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	switch (oom_status) {
 	case OOM_SUCCESS:
 		nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-		oomed = true;
 		goto retry;
 	case OOM_FAILED:
 		goto force;
-- 
2.21.0.1020.gf2820cf01a-goog

