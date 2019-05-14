Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E722C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:23:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E080520881
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:23:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KhlkHLib"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E080520881
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 728E36B0005; Tue, 14 May 2019 17:23:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7006D6B0006; Tue, 14 May 2019 17:23:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 618066B0007; Tue, 14 May 2019 17:23:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3598C6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:23:20 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id e3so191531otk.1
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:23:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=eeCk7+ZeaGS0zOYMgnht4wfwSEDnFnUqNORnM8SadLc=;
        b=fX/Tbl4UCwK3U1rAU/d4q0veJBz12Vg9ijFAp7axSGsmH4jsiUM+XZiWhTGYeo8MsK
         bNtzCj1SVAetATxt6dzC+xsB8h6VgE0gCgqN0Vuc2bKh4+XdXt5TwPbX+0AIHp2gGQX+
         TKd5ARbN8rmrFw1aq1OrIdQkyW7ZB3loOTbyAFoupAyigMC0FdT6sgp+Sv0cR4VOr4VO
         mRmYThcoHR/wRy3Y01AdnRamJAFwCHyVwPTBhS5qsD0+EJG2pz9tuxZWOZ004DDkR58r
         2fVOi63Qx304CGZqjjg81l+t0/9fzQE0s2ediurPSFuMgzhPJYeNqVGd9aKxLsgLE3ib
         zOGQ==
X-Gm-Message-State: APjAAAUShpPBeUajZQXWsqtU/kdAqxEQqj95RM5JW/pyCsnaJwLU7bw0
	WQaB6uQ/Hm8X33SQ7Nk3UXSNKF1cdJzrD8I7nduiKBv9hLEtdCN3BdvPQxHeWh2Z8tO7+ElHdwP
	yxUY//9cWnJ/7nliEp4te/s+tdlb7xniVWUeCyj4mpHboUBF3ql5Vz5CkhRS37ZnCWA==
X-Received: by 2002:aca:ab03:: with SMTP id u3mr4381181oie.112.1557868999777;
        Tue, 14 May 2019 14:23:19 -0700 (PDT)
X-Received: by 2002:aca:ab03:: with SMTP id u3mr4381132oie.112.1557868998813;
        Tue, 14 May 2019 14:23:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557868998; cv=none;
        d=google.com; s=arc-20160816;
        b=Vw5CEsPTx+7wxAEZQX+r7QlpffX73lK58uYARw3VgKlC5CLo+uMStw/Zko48lSXYln
         r46XUnSdQSQl/J2qFDrENhNYJf/wHfRYsclWrzcPNNgsUnSC4VFWfX4hLWLafqHCIERs
         wJOtg7gh9Gub1T8ri4+Tzad9TQ6m7B85tao5g6r+oJai3OoEFecostpDcf3PiORnIwy6
         BaXTH+S2KI0lSjDupgdsLyS1aRrOSLifSWK3IK4c+MLiKf063cshA8KkVk3dCdpE9jp2
         twv91B79Yvf7H8e25TgwuQvs1PbxDigxzG2frjNXd5G9gXpH+EGQDkvBHvG1mVrOUEmc
         UsjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=eeCk7+ZeaGS0zOYMgnht4wfwSEDnFnUqNORnM8SadLc=;
        b=xgqsMU+5nQ5IvxMZqodsaUL4v0bLfrb5bg5PhtgZ5IEY7Q83DqT92kgoYQUlC9iDkn
         xdbA8iefgLQ5qF4hjfNan7iwodpNHdhfUWYwKpAtvTOU0HWBoUFC7nDVq0hk4l2Bjl9R
         k5OyxvUc/I7KnPKqpEG5NpTFnJFfDrPRxsiDP8zAwuArwpUDPmaT+57rsLf9AGYIxQCm
         Z8XpgNuu5erEt0Lq8E+S02ryxXvNTpkQMwIlMhKQ383Jk6GT4iTdf8viPkwSXghM8M4f
         BQYui88hTbbxzxK5TqcYOUFeGvl/Zdk1XERPNkldqTclnQxCFvZBpzX0rrxqRi+J8333
         YYkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KhlkHLib;
       spf=pass (google.com: domain of 3xjhbxagkcimzohrllsinvvnsl.jvtspu14-ttr2hjr.vyn@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3xjHbXAgKCIMzohrllsinvvnsl.jvtspu14-ttr2hjr.vyn@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id p124sor22083oia.101.2019.05.14.14.23.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 14:23:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3xjhbxagkcimzohrllsinvvnsl.jvtspu14-ttr2hjr.vyn@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KhlkHLib;
       spf=pass (google.com: domain of 3xjhbxagkcimzohrllsinvvnsl.jvtspu14-ttr2hjr.vyn@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3xjHbXAgKCIMzohrllsinvvnsl.jvtspu14-ttr2hjr.vyn@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=eeCk7+ZeaGS0zOYMgnht4wfwSEDnFnUqNORnM8SadLc=;
        b=KhlkHLib2ZPt4MDKCmX3c5l6XUgu0JVLpDWiWLHfXrPp0hxxZkxpHxkH1XrFOsEM89
         FqNJrRBNOCGPmvxx/zTZh4CXK32vZVQOu449TEHyRwOl0xnrhtyLa5z/ZyuYbcd+jTg5
         egg2OAqF68EFnUsvjahoKCziQ6IvuYM8te2XZIJZniMKC6HLA9NMfvOtJb3qkeCrdMsa
         BjOXZkMLhKCypZnpp9MS2yg4/hlRIbuFNjmwh/1nqJE0iEB6bHqQk5Julg/FopkKbaTy
         0rtCntR1kgrRaYkAYomFcUibIOJGio6AG65oPwzdJZyLNYTDw6AjveM4efi10hjnRFHQ
         waoA==
X-Google-Smtp-Source: APXvYqyZAuGU/XaFCSkGl6IOZEqgfvmlg+RqkdHfDZ0i4BaPmxmcfnZJdw9EanHQZrulIbxHkwi9al4HwyjzeQ==
X-Received: by 2002:aca:ef8a:: with SMTP id n132mr4290624oih.98.1557868998432;
 Tue, 14 May 2019 14:23:18 -0700 (PDT)
Date: Tue, 14 May 2019 14:22:58 -0700
Message-Id: <20190514212259.156585-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v3 1/2] memcg, oom: no oom-kill for __GFP_RETRY_MAYFAIL
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
Changelog since v2:
- None

Changelog since v1:
- commit message updated

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

