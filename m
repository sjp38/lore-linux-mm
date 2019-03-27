Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CFE6C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40D142082F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="CaENcYPG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40D142082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A626F6B000E; Wed, 27 Mar 2019 14:03:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A12636B0010; Wed, 27 Mar 2019 14:03:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88D646B0266; Wed, 27 Mar 2019 14:03:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42DC36B000E
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:03:05 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e5so4795796plb.9
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:03:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qGRaJYdU0RPlNYy/n/qyDjRuBW/Cix7lpsYJgd4zT0Q=;
        b=Z4FNsDsr9F1SaghqrZz2tdbDEg/bMu/1/5HHc8C29r5f92c+aWg0nic4cCc+0qibOT
         Fxy5Y4G/fzKpADEcADJ8UOsaqnwUMhlRBtDeM6cufuFM93xkdTbqJawjqLv6zojgflpy
         oxZp1hrKhHCjOcahAmieKTRJMuq79VPR3M6W+OiFwy/ttuDxQ2DNHbYbs6WaS5wJ/FGW
         zMJ5Me5rr4KYLrq1Z6scESR2T1YNQD0TplzYolFofvAdX3hT2FoPtdiB2unEM1ryPb5F
         6pUkRiD3CS4qNjMYjW6YdKodhReH05xvt5Sy2Um+Df63TicXyE+jvreA8amFf+L0EgBu
         1GJQ==
X-Gm-Message-State: APjAAAXLSna+IU0kQwxkR/p5ydgWFtYF2QbNprQcKalFDvxuOy4zAMHJ
	hY5sRq+JXWRmpqJZUZBv1m/BEp+0Is3Py2rqj/OhlV4EJAIRxYocjOc7L3WgEgMCPXGZ2871Q85
	tj3k9mjiDyeA+6lo6LlneY2R2UKBDZ+RbaOV9RkGOssxeAhT6oCBeo043ON0X54Grog==
X-Received: by 2002:a65:5ac3:: with SMTP id d3mr12551567pgt.168.1553709784920;
        Wed, 27 Mar 2019 11:03:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtYs2u9b5AeA1RlqAf5RVSYarcwCC4FfCXEgwiXv0o/l3dQnXRw4CbmnBfD0usNjBQuktt
X-Received: by 2002:a65:5ac3:: with SMTP id d3mr12551479pgt.168.1553709784052;
        Wed, 27 Mar 2019 11:03:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709784; cv=none;
        d=google.com; s=arc-20160816;
        b=GJaHoBrG0YPKPgy9a9LBxLRTSxwJKikCZSnJFCpbsYweXhdJ8WSpG6o1h37sOyL1P1
         ni27BODr48U7xtMEvoVgbuLD4eCyyMWHzS8yKmuf3D7tFZWU4+V4UrA8OKsVxblyWxhp
         p5OXSSDvdLJ+bANlKfpqDzp6dSBHUdWIJ77m7J+ioEDxghtTYsvt+91Rp1IIzHbfizRy
         DjCq/JOe/Ffe+km+NIfm2N5pByvh8Bick+6dSVc3Qns3jzuMxqxW1IVZPjGIsEfX+cUY
         Keabt8GwCaVyKyUNa7QYWQm0VaHvWbxkU/+7l00S8PwXANr+pNk/1uQpMXUrZLAZe4cE
         2jNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qGRaJYdU0RPlNYy/n/qyDjRuBW/Cix7lpsYJgd4zT0Q=;
        b=TnD6qnDOdmKUzRw7E8jpplWB2fC/2FjjCpEp2qCzHeonpQsIO8o5A/5eS54j7K1cYl
         I0eFkejWe2OTINh9g1c5Ab0nJ8Wym6E9S4toMCC4QucqXB41wyEzOJxMUBpe/HdG1ubn
         IRmiuMzK00dbeBVactO03OBBnZ1JOY5rvZb80tjOVw4FqpUHO2PBilT+XTmx+xgrXLzw
         JhTXs4gvMGl4Q2pDK9+UYZJQUCD3+6roBtQlinC0sax7jYfYSBILzWVIE99gluRoXAEP
         KDLxE7kzUd1Is77Xh/sGoLtw7eWz5bu6sBTYipBDXDU8HzCp5y1Ofo9pJZPOtW3lsmuG
         ss6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=CaENcYPG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f19si18649548pgj.563.2019.03.27.11.03.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:03:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=CaENcYPG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9D64121738;
	Wed, 27 Mar 2019 18:03:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553709783;
	bh=pPf0xG7tuJ/KeSsZbMSwoj8AVi5Un66nVo/A/1eQSFM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=CaENcYPGYio1KqBnWQi9APPoYaZrdGohufPuawQZc6bmaKTC+HEtPqHFEQfeb6r89
	 I88mB8kxI+OtVjI4yYiXc2533KwBuE+4qxIVzV9fwR0/I6x6XWKoHF2JNNgSYxV6nc
	 QTMDL77c0VJaKPZprfS3hg6l7PPmpxyDUaGu3ku0=
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
Subject: [PATCH AUTOSEL 5.0 036/262] memcg: killed threads should not invoke memcg OOM killer
Date: Wed, 27 Mar 2019 13:58:11 -0400
Message-Id: <20190327180158.10245-36-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327180158.10245-1-sashal@kernel.org>
References: <20190327180158.10245-1-sashal@kernel.org>
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
index af7f18b32389..79a7d2a06bba 100644
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
@@ -1389,8 +1395,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
@@ -2209,9 +2220,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
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

