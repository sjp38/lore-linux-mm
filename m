Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D012C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 10:21:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B65772085A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 10:21:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B65772085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52E986B0003; Tue, 18 Jun 2019 06:21:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DF228E0002; Tue, 18 Jun 2019 06:21:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A7C88E0001; Tue, 18 Jun 2019 06:21:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1B86B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 06:21:47 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id y5so15615618ioj.10
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 03:21:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=0zuk9ap3kdii5bGymjz3VhOYqS2Fp0WNvD9SwPrFQ54=;
        b=rmr4qhHBETeKAl133JEG9Gy6aWZESVg4d10r6mv8nwQWbAj5bMCGq9JlElrUjXaut1
         nRTm3GXPQCNsvOt2y+kuE5A7x6T6irOSDlh9LT0L8tMs2/dIXD5gNQOq7ZFvkxucbH4N
         ajlvec6f5H3qlUE/n8/Gp2iH6MJXNJjh/6Gkf1bIbXwTnFlT35IcvSN+9ejWTGbRTyGq
         4IXrTlf/yvm/ZCzW1ijsFbeE4IxN/MQ9pPZUX9HeBJgRfB9ZLHauqBoggFAhwrCpU+e/
         yxY+629n1CYhMei9wYA0d8K6JRKJWwmIRRYFqqfciAbwBglNVS/slCBdKsoyzDIQFL1w
         GKsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAVO3Fb3OnabO6wgUQubpq6qgsw2cyfRsflBAbwIhiwpU8JSxqR7
	+FlCRG27Iv+X8iAC0YR6uFYMIupyuiDBTqQY0AFYJZbnvNLOVl7yy8X3Qk+mg7D2fp1LJAhvfUo
	p8YNchtr2ojq4dUr74vcjjta0W7A68+4gLka/JXCx2mYNaRC4LXzyH6YrBg1lPtRBCA==
X-Received: by 2002:a5d:9047:: with SMTP id v7mr60892404ioq.18.1560853306878;
        Tue, 18 Jun 2019 03:21:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1ozq2rr1R2QTsE0S0KHX0UZzr/VCosEKAQFDUG+va/2/UquFgTeCAMyMl+C6cknQF7adw
X-Received: by 2002:a5d:9047:: with SMTP id v7mr60892253ioq.18.1560853304532;
        Tue, 18 Jun 2019 03:21:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560853304; cv=none;
        d=google.com; s=arc-20160816;
        b=fkkzLfA68tsYjFMCv4mt/+z9JV9yBGBwIBRlXw1lXiQoYz/4FI96Id0C/neSbE0cUw
         0lqhHkpFzFt0uRF0phbFkU8AbcxRFJmXecVohJofH07I9G/WXfmhecqch4QsfGhrlnf7
         sO5AAv4+UESdTtDHajdL6gu/jp4O89hK1om+oesFbEjKsHW0vTqhYXEb2vBRfpvrdvfX
         n6nIPuvmMaxEQ56Ta49biaGVK+MlrfmAUxQu504CdJIo7l4gSle/m6BveUUwd7cRwOB9
         MTveXS/XyMqm2XIoshq10bN7dQc7dnBiCB46Ew3I+lTUdsfSbblSHY2m/54dC4pt4WsU
         r2aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=0zuk9ap3kdii5bGymjz3VhOYqS2Fp0WNvD9SwPrFQ54=;
        b=KOkMjhJkH0baA/P/VZRPf/cmNDpk6WqHLrrHBszMNpGbGG17MI5vEmICUyfjQZ766P
         sBxPZmPLqUkZGd2tUgygQFVLVKa82PqRoEHM+xnHoJArX3sPqxEi2viWYdtBLPbXc/RG
         OVZTNGctF04yL+9uGRgQ6DgUc52Gg7br5kFc97r1ADzINMibAkSKjYI3R1/n204Tx4Yh
         Mrf55lx8aU3Dphetpd9Q5QNQcS9H5NkXlQAZLuKoETG9mYe3P1ZQohY6MwZMtSGCDwlQ
         a70pmDoV9yx7QfzqTLUWc1HjsfB5fs/roYYmO1Z9ToGE59TefQIjZB7dJsmztpJiJMtt
         gU1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m18si11065510jaa.95.2019.06.18.03.21.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 03:21:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav101.sakura.ne.jp (fsav101.sakura.ne.jp [27.133.134.228])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5IALFcr066488;
	Tue, 18 Jun 2019 19:21:15 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav101.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav101.sakura.ne.jp);
 Tue, 18 Jun 2019 19:21:15 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav101.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5IALA0K066330
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 18 Jun 2019 19:21:15 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
        Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mm: oom: Remove thread group leader check in oom_evaluate_task().
Date: Tue, 18 Jun 2019 19:20:57 +0900
Message-Id: <1560853257-14934-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since mem_cgroup_scan_tasks() uses CSS_TASK_ITER_PROCS, only thread group
leaders will be scanned (unless dying leaders with live threads). Thus,
commit d49ad9355420c743 ("mm, oom: prefer thread group leaders for display
purposes") makes little sense.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/oom_kill.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 32abc7a..09a5116 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -348,9 +348,6 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	if (!points || points < oc->chosen_points)
 		goto next;
 
-	/* Prefer thread group leaders for display purposes */
-	if (points == oc->chosen_points && thread_group_leader(oc->chosen))
-		goto next;
 select:
 	if (oc->chosen)
 		put_task_struct(oc->chosen);
-- 
1.8.3.1

