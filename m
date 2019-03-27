Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2EA2C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5875521738
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="SA2lh+AA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5875521738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 921B46B0278; Wed, 27 Mar 2019 14:11:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D2A56B027A; Wed, 27 Mar 2019 14:11:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7765C6B027B; Wed, 27 Mar 2019 14:11:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 396DB6B0278
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:11:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f67so14659973pfh.9
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:11:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Nj53lnk4fc3MbaatlwwJKcXw/y0hzD8iRlSlneQIqK8=;
        b=WjaXGBJqd+kxtjCesGbUcokY2HPe5k7ZtpbBNlh7tWFxf+jZBUx/g+lLqzlboYIFyI
         gaFjPtt7IDJndgzdOr5TPTCog6OFKx/M5ro1NnwMqm5+AlFV0vl6v0JxH5oDDMr5Or9w
         9mbqX7Vaf12g0h7/YZcVOC/nwXjRmxwdRNl/bJIqTUrlK4iDvLizdbqlQ2hDHlySMRFP
         IntIG+dI8eLcGxBz9k8ynfPiHAsWRk/7ms4sPsBbtPxmmD3YaIw/VT0HD9tliymkWUyJ
         VICizUyIbya+DGVXpv82v8GVykkTFctE5uNCApfAeINEZt0R09WqNKCQr/NM+xEbRnLq
         0Oug==
X-Gm-Message-State: APjAAAVMMKuRAezlbnH5Bv7BlymWi6IjrHOhRVvmv3xomji59couaqkH
	7dn/enpncMgDn0xCeZwNnyBP/DhEqBTwCMJyX2sAiWDN+k5aEI2dI+dciNrhSXoTZXjqB1UgWQG
	iI9e7iyK3CcZuHdxMNVhqHf3qelH1+d/fsCBrnQdVRsyH5cjEnPYf3j3LEdGI5c78Bw==
X-Received: by 2002:a17:902:8d97:: with SMTP id v23mr30582942plo.298.1553710271878;
        Wed, 27 Mar 2019 11:11:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVSOyLPHWJE6oET4weWYpvC1umaQpp3huILPMxqTZOtI3XJMjq2rgOvraRnkxCnGUf8b9k
X-Received: by 2002:a17:902:8d97:: with SMTP id v23mr30582861plo.298.1553710271044;
        Wed, 27 Mar 2019 11:11:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710271; cv=none;
        d=google.com; s=arc-20160816;
        b=r5n7O80c4u8iIKctG3JeoXUpJsdWs8MRldlXRUL+gxWKJd8RMAi5lCZIZrogrVFviC
         2AU0cVferfK9eMaKRSVNAtsEkDemYbwbrXdDJ7JOmlMl/LkraDOUvu3Hzm7OrJOksNEn
         FS0GZD2QVG7P+UMTQBXcMmKO9T2NIF0ZhWnM2WNJuLllfS8ykr2cdIHr92tgoTY+whyk
         GGUeqkfx83RWzENhyqKmWKYjKCTJlpvw9VrTlRltzw9In4mRB3tqA55PtFUqYQi0CwP7
         KvH/+qcQlyK6PP0KjVQf4rkmRyFOntZqtgXVfUvSb0IwH7VC1jUB3XRlHFI4k44ZeC4x
         jkxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Nj53lnk4fc3MbaatlwwJKcXw/y0hzD8iRlSlneQIqK8=;
        b=zUaT1vL3FdHeT5roMux6RTyG/2GjLHm5Lj0xaLW9oiJn2e7Lk2tSbP2qEr6n0iQ6gX
         EjV7egJAOb8OkQ+EP0KyT6LJ15DvfwtcizbT5/se+axNobel7KUaxlMTqD/NYw3XNX1R
         D8/2qY9F+TOqLmvfQ7mdb8+DFE/ygGF0SAFs1w2lJgj95qLT5j2jWv8kAqctydHN7Pwr
         P7BzdLJG5dYNfT/QmVuSvy9Ar1W7aDLdYARrdJkUfUdYe4rJs0GAG5jU5Mosv0G4m1ml
         qeWSFNqvMlbSW3straAkd3k+f9ea+TgKD4rjIWWLGAnbdW7JHalvIO+pJpE/q0S6ARMn
         aZzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=SA2lh+AA;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q13si13149860pff.3.2019.03.27.11.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:11:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=SA2lh+AA;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9DFA7217F5;
	Wed, 27 Mar 2019 18:11:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710270;
	bh=Mh/4AwY9a0OWVofv47T5bGj6Q2yFFjAdYT4sKx0s80w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=SA2lh+AAUVQkL1+HzlZZifq6G7DmYcdtg3FFhWcZXK2VIzXdmEe3DWEWNinc+94Mv
	 oOgcj4eZrKdGUMEyDe5V/BKJ8NS9seMg8WgJh7rBuBC7F3+eT7Fv6J3iKThsmkzYCg
	 ma206JbQDKh6bI4vQ5eg1ORJpFo7Lv+a4+D1UOfg=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	David Rientjes <rientjes@google.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	cgroups@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 026/192] memcg: killed threads should not invoke memcg OOM killer
Date: Wed, 27 Mar 2019 14:07:38 -0400
Message-Id: <20190327181025.13507-26-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181025.13507-1-sashal@kernel.org>
References: <20190327181025.13507-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

[ Upstream commit 7775face207922ea62a4e96b9cd45abfdc7b9840 ]

If a memory cgroup contains a single process with many threads
(including different process group sharing the mm) then it is possible
to trigger a race when the oom killer complains that there are no oom
elible tasks and complain into the log which is both annoying and
confusing because there is no actual problem.  The race looks as
follows:

P1				oom_reaper		P2
try_charge						try_charge
  mem_cgroup_out_of_memory
    mutex_lock(oom_lock)
      out_of_memory
        oom_kill_process(P1,P2)
         wake_oom_reaper
    mutex_unlock(oom_lock)
    				oom_reap_task
							  mutex_lock(oom_lock)
							    select_bad_process # no victim

The problem is more visible with many threads.

Fix this by checking for fatal_signal_pending from
mem_cgroup_out_of_memory when the oom_lock is already held.

The oom bypass is safe because we do the same early in the try_charge
path already.  The situation migh have changed in the mean time.  It
should be safe to check for fatal_signal_pending and tsk_is_oom_victim
but for a better code readability abstract the current charge bypass
condition into should_force_charge and reuse it from that path.  "

Link: http://lkml.kernel.org/r/01370f70-e1f6-ebe4-b95e-0df21a0bc15e@i-love.sakura.ne.jp
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memcontrol.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9518aefd8cbb..7c712c4565e6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -248,6 +248,12 @@ enum res_type {
 	     iter != NULL;				\
 	     iter = mem_cgroup_iter(NULL, iter, NULL))
 
+static inline bool should_force_charge(void)
+{
+	return tsk_is_oom_victim(current) || fatal_signal_pending(current) ||
+		(current->flags & PF_EXITING);
+}
+
 /* Some nice accessors for the vmpressure. */
 struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg)
 {
@@ -1382,8 +1388,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	};
 	bool ret;
 
-	mutex_lock(&oom_lock);
-	ret = out_of_memory(&oc);
+	if (mutex_lock_killable(&oom_lock))
+		return true;
+	/*
+	 * A few threads which were not waiting at mutex_lock_killable() can
+	 * fail to bail out. Therefore, check again after holding oom_lock.
+	 */
+	ret = should_force_charge() || out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 	return ret;
 }
@@ -2200,9 +2211,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * bypass the last charges so that they can exit quickly and
 	 * free their memory.
 	 */
-	if (unlikely(tsk_is_oom_victim(current) ||
-		     fatal_signal_pending(current) ||
-		     current->flags & PF_EXITING))
+	if (unlikely(should_force_charge()))
 		goto force;
 
 	/*
-- 
2.19.1

