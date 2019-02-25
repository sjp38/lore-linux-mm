Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0231AC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:16:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4C4920842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:16:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="LSeURdiK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4C4920842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F19E8E000F; Mon, 25 Feb 2019 15:16:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 727C38E000C; Mon, 25 Feb 2019 15:16:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C8888E000F; Mon, 25 Feb 2019 15:16:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4D98E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:16:48 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 202so6976261ybe.2
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:16:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=q68vDKJoy4wkBVCCNbeXOOo5XkzY9NuLFWEJjvpu9MI=;
        b=eyKMTvSjiNYr/Y9RgZVMgh00eEED93Z9DYpvTUofDk6S+BEdU1xLYTE2lFgjRlk715
         04nuAvnyXHLDl9MYWj1DMYI7edpXeHppzGZfPWa5hqyop74XXxEaLlrntg06OND0i3z/
         ZFuHkLkejxqvj5fKSoKf3HtPHpanumTbGFn7aOrX+9JsCB63iXNp66wxgH9JNZ/8JqTt
         oqx3h1YXaHhRbY5KCQCHKP8/Ss4Je6GbSQ+GJYbPCiXAGcJi7S8TIh21Ar+94K2sLzqB
         KppinZ5TgdAyPdYxNADQJQTmMFtXwdf5gsvldy3/MMMXtxv3b0j3vB3YuRBqC1SKPDAa
         /ckA==
X-Gm-Message-State: AHQUAubNyIBopWlbMD43cP1nr4LmZaZreI7GEUPR3zshFk6A4ghkvCB+
	TxIrO5xWmMGyPo/2g8dTtls/EDZYKDlCd7NsxxUbMpIR8i5Ofk7dlIk7qDMgEra2zR+9lat+Lg7
	YrwtvRLtUysP67qNIb+jB2ECwzeRHjc4MDEszUC9bz+6ZUUGNRScyjCuEM+qL5BdIwRpmG+FMAy
	cnsez769yDKTF3Zr4sZuqJ5rdITRv8sp4Cj81YxlTC22NnxQtYjrWYZzpt1X0uVbWl/QAoEl50K
	E0JWtMrcQ39cZD4CiaEPtrVQjoHG45q9rxbu4+SsMjG+MBJt5qrwlj/mw4+CxAusDBSVwi6Z4dY
	3n6/gsomEriKSMQ/Gkm/yuXYZFYphb9k7hBvm1TCKWatltOFq1XtXcOYLHstaUkVpX3WPI0Z3JK
	f
X-Received: by 2002:a5b:2c6:: with SMTP id h6mr14290902ybp.476.1551125807958;
        Mon, 25 Feb 2019 12:16:47 -0800 (PST)
X-Received: by 2002:a5b:2c6:: with SMTP id h6mr14290856ybp.476.1551125807159;
        Mon, 25 Feb 2019 12:16:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551125807; cv=none;
        d=google.com; s=arc-20160816;
        b=LliVNrLHJn3xiYtWq0Mf9yyzrHRjtd4lRdl85mo7XoxFSeDiMFVIZHkJoBbHKgOriU
         xwE32NvU8BonCXxWIT7U1+LAb5///R7SbDy36a3uWuH5RXrcG/EABESzBYqkxeQHA0TB
         OoDKXkJLnZ50fQj9xq0o1Lv1bJb/wFeBUIxvc8x3sArW//7/gd6QOtv9sZmR3aav5MOA
         l59dVS2tH+SAPhDjPm19zMu2F87+NYbu8grM4qVRxQ4rsnKWmvlQAw4thE4BexqAqW5j
         qAgbkqPiNkAaNv86r845lmqf+oRRT0Iz3a2ORNI41HVyevARJW8jVnIGjrq1olfuva7Y
         8KZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=q68vDKJoy4wkBVCCNbeXOOo5XkzY9NuLFWEJjvpu9MI=;
        b=hv8pcwJDnzK3iwYqvuBOSEiwehMLppXd3DIJ5BisFQHMm05wL6HTlcRpcyb+HyzBEW
         6kdM9TksF6OcKrUGKWwRCOUi9HGImAi/UE8pAj5hlzIf8yGI4rAwA7/OcT5+7VHBTqVY
         gtTLnCo1biM3s86Y5La2vrneeNCmN4k2SHRvjmwTYqLJE5h1BrKtr/fL7H9RQBX8gPga
         c+BxppqjDruJ+Fv8NTP9cx4di5Dtbcrql/RQMf1ECs830iMB90H91t62Pce6qbdVHay8
         upbck0ckmW+w0YhWG78ioMBLPNBZK3xfXzlO4roCYCU3T2f5eakN5yE0/IhVVRIwS1+s
         ScFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=LSeURdiK;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o126sor1967803ywd.179.2019.02.25.12.16.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 12:16:47 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=LSeURdiK;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=q68vDKJoy4wkBVCCNbeXOOo5XkzY9NuLFWEJjvpu9MI=;
        b=LSeURdiK/5CWWWFp/3/7azLqMNHcbE40aqPO/fF3J/AxPZCZPbNPd2yNz9YNGW9LQp
         r1bEwX2620t8VCAssnDkeNu05CWPaLjAcMBjPuLvyZQa0Y+sCBhnDM7/d3er0j2fEB8G
         3lMSOzrBJjETnIypMBCQ1TmQIluv6lRa9LI74di9YTAdodY5kBsUJ9dT2nv7IRFTd5ql
         b86bP8deruwQcGDf/ijMpSBtp/C33ZNm4mx8/JjeZ14csnZ3nTpwneoOijefuSUYxoFP
         wA3gCdexiMvHdVGBLCC8gzYJqVNgluF9Rvx3aOfkfqRUJps5SWyeTFyHX6vHdaFFkXUZ
         gwSA==
X-Google-Smtp-Source: AHgI3Iao/Go5XjNUoA5s8pQCn5DH6YCa97MlrjNtbdAx0SrypGx8YzmFQ3F1KNP8GyTaOgDTdDSZ0w==
X-Received: by 2002:a0d:c6c6:: with SMTP id i189mr15451828ywd.12.1551125806966;
        Mon, 25 Feb 2019 12:16:46 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::2:5fab])
        by smtp.gmail.com with ESMTPSA id q185sm3524476ywb.15.2019.02.25.12.16.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 12:16:46 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 3/6] mm: memcontrol: replace node summing with memcg_page_state()
Date: Mon, 25 Feb 2019 15:16:32 -0500
Message-Id: <20190225201635.4648-4-hannes@cmpxchg.org>
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

Instead of adding up the node counters, use memcg_page_state() to get
the memcg state directly. This is a bit cheaper and more stream-lined.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d85a41cfee60..e702b67cde41 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -746,10 +746,13 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
 			unsigned int lru_mask)
 {
 	unsigned long nr = 0;
-	int nid;
+	enum lru_list lru;
 
-	for_each_node_state(nid, N_MEMORY)
-		nr += mem_cgroup_node_nr_lru_pages(memcg, nid, lru_mask);
+	for_each_lru(lru) {
+		if (!(BIT(lru) & lru_mask))
+			continue;
+		nr += memcg_page_state(memcg, NR_LRU_BASE + lru);
+	}
 	return nr;
 }
 
-- 
2.20.1

